{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.gh
    pkgs.git
    pkgs.ghostty-bin
    pkgs.wireshark
    pkgs.uv
    pkgs.prismlauncher
    pkgs.keepassxc
    pkgs.mpv
    pkgs.neovim
    pkgs.nixpkgs-fmt
    pkgs.shfmt
    pkgs.tex-fmt
    pkgs.vesktop
    pkgs.ffmpeg
    pkgs.signal-desktop

    (pkgs.texliveBasic.withPackages (ps: with ps; [
      enumitem
      hyperref
      preprint
      titlesec
    ]))
  ];
}
