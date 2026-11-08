{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = false;

    initContent = ''
      qr() {
        local url
        if (( $# > 1 )); then
          print -u2 'Usage: qr [URL]'
          return 1
        fi
        if (( $# == 1 )); then
          url="$1"
        else
          read -r 'url?URL: ' || return
        fi
        [[ -n "$url" ]] || return 1
        ${pkgs.qrencode}/bin/qrencode -t ANSIUTF8 -- "$url"
      }

      qrdecode() {
        local image
        if (( $# > 1 )); then
          print -u2 'Usage: qrdecode [IMAGE]'
          return 1
        fi
        if (( $# == 1 )); then
          image="$1"
        else
          image=$(mktemp -t qrdecode).png
          /usr/sbin/screencapture -i "$image" || return 1
        fi
        ${pkgs.zbar}/bin/zbarimg --quiet --raw "$image"
      }
    '';

    shellAliases = {
      vim = "nvim";
      rb = ''bash "$HOME/.config/nix/rebuild.sh"'';
      dev = "tmux new-session -d -s dev -n pi pi \\; new-window -t dev -n nvim nvim \\; attach-session -t dev";
      gc = ''(set -o pipefail; git rev-parse --verify HEAD >/dev/null 2>&1 && git diff --no-ext-diff --no-textconv HEAD -- | nvim -n -R --cmd 'set nomodeline' -c 'setlocal filetype=diff nomodifiable' -c 'autocmd VimLeavePre * if confirm("Commit and push?", "&Approve\n&Cancel", 2) != 1 | cquit | endif' - && git commit -a --allow-empty-message -m "" && git push)'';
      pif = ''pi --fork "$HOME/.pi/agent/sessions/--''${''${PWD#/}//\//-}--"/*.jsonl(.om[1])'';
    };

  };
}
