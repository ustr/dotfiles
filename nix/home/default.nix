{ ... }:

{
  imports = [
    ./pi.nix
    ./zsh.nix
  ];

  programs.starship.enable = true;

  home.sessionPath = [
    "$HOME/.pi/agent/bin"
  ];

  home.stateVersion = "26.05";
}
