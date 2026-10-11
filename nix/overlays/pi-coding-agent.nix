final: prev:
let
  piSrc = prev.fetchFromGitHub {
    owner = "earendil-works";
    repo = "pi";
    tag = "v1.1.0";
    hash = "sha256-lwjspkMGrW+8Fl/yBEDEFsHZJA57OKOhmVQmi6zfej4=";
  };
in
{
  pi-coding-agent = prev.callPackage "${piSrc}/nix/package.nix" {
    source = piSrc;
  };
}
