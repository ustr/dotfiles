{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.gh
    pkgs.git
    pkgs.ghostty-bin
    pkgs.keepassxc
    pkgs.neovim
    pkgs.vesktop
    pkgs.uv
    pkgs.pi-coding-agent
    pkgs.ffmpeg
    pkgs.yt-dlp
    pkgs.scrcpy
    pkgs.android-tools
    pkgs.nixpkgs-fmt
    pkgs.shfmt
    pkgs.tex-fmt

    (pkgs.texliveBasic.withPackages (ps: with ps; [
      enumitem
      hyperref
      preprint
      titlesec
    ]))
  ];
}
