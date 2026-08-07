{ ... }:

{
  imports = [
    ./git.nix
    ./starship.nix
    ./zsh.nix
  ];

  home.stateVersion = "26.05";
}
