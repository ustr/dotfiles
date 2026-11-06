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
in
{
  home.packages = [ mlxWhisper ];
}
