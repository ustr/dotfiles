{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = false;

    shellAliases = {
      vim = "nvim";
      rb = "sudo darwin-rebuild switch --flake ~/.config/nix#macos";
      gc = "git commit -a --allow-empty-message -m '' && git push";
      pif = ''pi --fork "$HOME/.pi/agent/sessions/--''${''${PWD#/}//\//-}--"/*.jsonl(.om[1])'';
    };
  };
}
