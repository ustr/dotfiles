final: prev:
let
  piSrc = prev.fetchFromGitHub {
    owner = "earendil-works";
    repo = "pi";
    tag = "v1.2.0";
    hash = "sha256-IjNJvVxjzRur2foQDWPA5iM9sa3ThBoZU1/LT5pU6jc=";
  };
in
{
  pi-coding-agent = (prev.callPackage "${piSrc}/nix/package.nix" {
    source = piSrc;
  }).overrideAttrs (_: {
    # v1.2.0's installCheck requires esbuild, but the runtime install-lock no
    # longer includes it. The CLI itself is still checked by normal use.
    doInstallCheck = false;
  });
}
