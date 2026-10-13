{ ... }:

{
  homebrew = {
    enable = true;

    onActivation.cleanup = "zap";

    casks = [
      "ungoogled-chromium"
      "chatgpt"
      "gimp"
    ];
  };
}
