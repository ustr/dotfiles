{ ... }:

{
  imports = [
    ./starship.nix
    ./zsh.nix
  ];

  home.sessionPath = [
    "$HOME/.pi/agent/bin"
  ];

  home.stateVersion = "26.05";
}
