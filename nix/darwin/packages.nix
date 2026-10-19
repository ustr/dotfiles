{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gh
    git
    tmux

    ghostty-bin
    keepassxc
    signal-desktop
    ollama
    mpv

    uv
    pi-coding-agent
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
