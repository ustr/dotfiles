{ ... }:

{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    greedyCasks = true;

    casks = [
      "ungoogled-chromium"
      "gimp"
      "obs"
      "kitlangton-hex"
    ];
  };
}
