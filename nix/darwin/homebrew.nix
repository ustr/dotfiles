{ ... }:

{
  homebrew = {
    enable = true;

    brews = [
      "pi-coding-agent"
    ];

    casks = [
      "ungoogled-chromium"
    ];

    onActivation.cleanup = "zap";
  };
}
