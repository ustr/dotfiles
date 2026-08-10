{ ... }:

{
  homebrew = {
    enable = true;

    brews = [
      "pi-coding-agent"
    ];

    casks = [
      "ungoogled-chromium"
      "chatgpt"
    ];

    onActivation.cleanup = "zap";
  };
}
