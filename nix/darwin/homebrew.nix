{ ... }:

{
  homebrew = {
    enable = true;

    brews = [
    ];

    casks = [
      "ungoogled-chromium"
      "chatgpt"
      "gimp"
    ];

    onActivation.cleanup = "zap";
  };
}
