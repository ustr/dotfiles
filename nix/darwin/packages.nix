{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.gh
    pkgs.git
    pkgs.ghostty-bin
    pkgs.keepassxc
    pkgs.mpv
    pkgs.neovim
    pkgs.nixpkgs-fmt
    pkgs.qbittorrent
    pkgs.shfmt
    pkgs.tex-fmt
    pkgs.vesktop
    pkgs.ffmpeg
    pkgs.signal-desktop
    pkgs.openai-whisper

    (pkgs.texliveBasic.withPackages (ps: with ps; [
      enumitem
      hyperref
      preprint
      titlesec
    ]))
  ];
}
