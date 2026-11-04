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
      "chatgpt"
      "gimp"
      "docker-desktop"
      "obs"
      "kitlangton-hex"
    ];
  };
}
