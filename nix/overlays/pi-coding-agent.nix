final: prev:
let
  piSrc = prev.fetchFromGitHub {
    owner = "earendil-works";
    repo = "pi";
    tag = "v1.4.0";
    hash = "sha256-N9NOpiiZTbOMDMV+CxvJAgtLjJJ1/8NJBGS0cFHkhsc=";
  };
in
{
  pi-coding-agent = prev.callPackage "${piSrc}/nix/package.nix" {
    source = piSrc;
  };
}
