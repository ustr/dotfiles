{ ... }:

{
  homebrew = {
    enable = true;

    brews = [
      "pi-coding-agent"
      "llama.cpp"
    ];

    casks = [
      "ungoogled-chromium"
      "chatgpt"
    ];

    onActivation.cleanup = "zap";
  };
}
