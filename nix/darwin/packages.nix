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
    pkgs.prismlauncher
    pkgs.qbittorrent
    pkgs.shfmt
    pkgs.vesktop

    (pkgs.texliveBasic.withPackages (ps: with ps; [
      enumitem
      hyperref
      preprint
      titlesec
    ]))
  ];
}
