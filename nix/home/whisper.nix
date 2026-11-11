{ lib, pkgs, pkgs-unstable, ... }:

let
  modelBase = "https://huggingface.co/mlx-community/whisper-base-mlx/resolve/1e3e249fb8d01c655324bd6841b1deadffd6d04c";
  model = pkgs.linkFarm "whisper-base-mlx" [
    {
      name = "config.json";
      path = pkgs.fetchurl {
        url = "${modelBase}/config.json";
        sha256 = "0bsc5v38jcs11sj2rsl47jc6cqjmj6lhz14gwx4avcsqv6k20wkk";
      };
    }
    {
      name = "weights.npz";
      path = pkgs.fetchurl {
        url = "${modelBase}/weights.npz";
        sha256 = "02zz5vb5yb6bxh9i7s4d23l1br2fdxqr07wn73358c27xzrxamrg";
      };
    }
  ];
  pythonPackages = pkgs-unstable.python3Packages;
  mlxWhisper = pythonPackages.buildPythonApplication {
    pname = "mlx-whisper";
    version = "0.4.3";
    format = "wheel";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/22/b7/a35232812a2ccfffcb7614ba96a91338551a660a0e9815cee668bf5743f0/mlx_whisper-0.4.3-py3-none-any.whl";
      sha256 = "6b82b6597a994643a3e5496c7bc229a672e5ca308458455bfe276e76ae024489";
    };
    dependencies = with pythonPackages; [
      mlx-bin
      numba
      numpy
      torch
      tqdm
      more-itertools
      tiktoken
      huggingface-hub
      scipy
    ];
    makeWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      (lib.makeBinPath [ pkgs.ffmpeg ])
      "--add-flags"
      "--model ${model}"
    ];
    meta.mainProgram = "mlx_whisper";
  };
  turboBase = "https://huggingface.co/mlx-community/whisper-large-v3-turbo/resolve/a4aaeec0636e6fef84abdcbe3544cb2bf7e9f6fb";
  turboModel = pkgs.linkFarm "whisper-large-v3-turbo-mlx" [
    {
      name = "config.json";
      path = pkgs.fetchurl {
        url = "${turboBase}/config.json";
        hash = "sha256-s0/Cnk4R4KJegSd13Wf03Rb8LI60PSiuJf99Zg7LY3k=";
      };
    }
    {
      name = "weights.safetensors";
      path = pkgs.fetchurl {
        url = "${turboBase}/weights.safetensors";
        hash = "sha256-lR7T/BID5qYkZ6uyFEqWzn6vyo+nfjcE/bhjX/Pn+KY=";
      };
    }
  ];

  # Speaker diarization models (no Hugging Face token needed).
  segmentationModel = pkgs.fetchzip {
    url = "https://github.com/k2-fsa/sherpa-onnx/releases/download/speaker-segmentation-models/sherpa-onnx-pyannote-segmentation-3-0.tar.bz2";
    hash = "sha256-hqaCTZJKZp6IHxYzgVBd9Bss6wC1qg+edB/v10BT1tA=";
  };
  embeddingModel = pkgs.fetchurl {
    url = "https://github.com/k2-fsa/sherpa-onnx/releases/download/speaker-recongition-models/nemo_en_titanet_small.onnx";
    hash = "sha256-rUoYAkhdizTHItKp0EJJZi8uzl0op6A5BjyiL1FaeJ4=";
  };
  diarizePython = pythonPackages.python.withPackages (ps: [
    ps.sherpa-onnx
    ps.soundfile
    ps.numpy
  ]);

  transcribe = pkgs.writeShellApplication {
    name = "transcribe";
    runtimeInputs = [
      mlxWhisper
      pkgs.ffmpeg
      pkgs.coreutils
    ];
    text = ''
      usage() {
        cat <<'EOF'
      Usage: transcribe [options] FILE...

      Writes FILE.txt next to each input, with timestamps and speaker labels.

        -n, --no-speakers     skip speaker detection
        -s, --speakers N      number of speakers, if known (more accurate)
        -l, --language LANG   language code, e.g. en (default: auto-detect)
        -h, --help            show this help
      EOF
      }

      speakers=-1
      diarize=true
      lang=()
      files=()
      while (( $# )); do
        case $1 in
          -n|--no-speakers) diarize=false ;;
          -s|--speakers) speakers=$2; shift ;;
          -l|--language) lang=(--language "$2"); shift ;;
          -h|--help) usage; exit 0 ;;
          -*) echo "transcribe: unknown option $1" >&2; usage >&2; exit 1 ;;
          *) files+=("$1") ;;
        esac
        shift
      done
      (( ''${#files[@]} )) || { usage >&2; exit 1; }

      tmp=$(mktemp -d)
      trap 'rm -rf "$tmp"' EXIT

      for f in "''${files[@]}"; do
        [[ -f $f ]] || { echo "transcribe: no such file: $f" >&2; exit 1; }
        out="''${f%.*}.txt"
        echo "==> $f" >&2

        mlx_whisper "$f" --model ${turboModel} --word-timestamps True --condition-on-previous-text False \
          --output-format json --output-dir "$tmp" --output-name whisper \
          --verbose False "''${lang[@]}"

        wav=()
        if [[ $diarize == true ]]; then
          ffmpeg -v error -y -i "$f" -ac 1 -ar 16000 "$tmp/audio.wav"
          wav=(--wav "$tmp/audio.wav")
        fi

        ${diarizePython}/bin/python -I ${./transcribe.py} \
          --whisper-json "$tmp/whisper.json" "''${wav[@]}" \
          --segmentation ${segmentationModel}/model.onnx \
          --embedding ${embeddingModel} \
          --speakers "$speakers" --out "$out"
        echo "==> $out" >&2
      done
    '';
  };
in
{
  home.packages = [
    mlxWhisper
    transcribe
  ];
}
