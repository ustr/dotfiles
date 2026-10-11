{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = false;

    shellAliases = {
      vim = "nvim";
      rb = "sudo darwin-rebuild switch --flake ~/.config/nix#macos";
      dev = "tmux new-session -d -s dev -n pi pi \\; new-window -t dev -n nvim nvim \\; attach-session -t dev";
      gc = ''(set -o pipefail; git rev-parse --verify HEAD >/dev/null 2>&1 && git diff --no-ext-diff --no-textconv HEAD -- | nvim -n -R --cmd 'set nomodeline' -c 'setlocal filetype=diff nomodifiable' -c 'autocmd VimLeavePre * if confirm("Commit and push?", "&Approve\n&Cancel", 2) != 1 | cquit | endif' - && git commit -a --allow-empty-message -m "" && git push)'';
      pif = ''pi --fork "$HOME/.pi/agent/sessions/--''${''${PWD#/}//\//-}--"/*.jsonl(.om[1])'';
    };

  };
}
