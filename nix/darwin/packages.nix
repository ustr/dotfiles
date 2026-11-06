{ lib, pkgs, pkgs-unstable, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg: lib.getName pkg == "claude-code";

  environment.systemPackages = with pkgs; [
    tmux

    ghostty-bin
    chromium-cdp
    signal-desktop
    ollama
    mpv

    uv
    pi-coding-agent
    pkgs-unstable.claude-code
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
