{ ... }:

let
  brewEnv = {
    HOMEBREW_NO_ANALYTICS = "1";
    HOMEBREW_NO_ENV_HINTS = "1";
  };
in
{
  environment.variables = brewEnv;

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
      extraEnv = brewEnv;
    };
    greedyCasks = true;

    casks = [
      "keepassxc"
      "ungoogled-chromium"
      "gimp"
      "obs"
      "kitlangton-hex"
    ];
  };
}
