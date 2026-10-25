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
      "kitlangton-hex"  # open-source local Whisper push-to-talk dictation
    ];
  };
}
