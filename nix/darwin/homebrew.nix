{ ... }:

{
  homebrew = {
    enable = true;

    onActivation.cleanup = "zap";

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
