final: prev:
let
  piSrc = prev.fetchFromGitHub {
    owner = "earendil-works";
    repo = "pi";
    tag = "v1.5.2";
    hash = "sha256-0dKtABQqfvCLF0WOydu5rpycMqC+N8Pc9Ex4BWKElyw=";
  };
in
{
  pi-coding-agent = prev.callPackage "${piSrc}/nix/package.nix" {
    source = piSrc;
  };
}
