{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    tmux

    ghostty-bin
    chromium-cdp
    keepassxc
    signal-desktop
    ollama
    mpv

    uv
    pi-coding-agent
    estelle
    neovim
    ffmpeg
    yt-dlp

    scrcpy
    android-tools

    nixpkgs-fmt
    shfmt
    tex-fmt

    (texliveBasic.withPackages (ps: with ps; [
      enumitem
      hyperref
      preprint
      titlesec
    ]))
  ];
}
