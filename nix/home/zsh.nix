{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    defaultKeymap = "emacs";
    autosuggestion.enable = true;

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

      gc() {
        (
          set -o pipefail
          git rev-parse --verify HEAD >/dev/null 2>&1 &&
            git diff --no-ext-diff --no-textconv HEAD -- |
            nvim -n -R --cmd 'set nomodeline' -c 'setlocal filetype=diff nomodifiable' -c 'autocmd VimLeavePre * if confirm("Commit and push?", "&Approve\n&Cancel", 2) != 1 | cquit | endif' - ||
            exit
          if [[ "$(git rev-parse --show-toplevel)" == "$HOME/.config" ]]; then
            git reset --soft "$(git rev-list --max-parents=0 HEAD | tail -n 1)" &&
              GIT_AUTHOR_DATE='@0 +0000' GIT_COMMITTER_DATE='@0 +0000' \
              git commit -a --amend --reset-author --allow-empty-message -m "" &&
              git push --force-with-lease
          else
            git commit -a --allow-empty-message -m "" && git push
          fi
        )
      }

      rdp() {
        local mode=connect host user="" service log
        local prefs=local.freerdp-wrapper
        local -a client
        case "''${1-}" in
          --save|--detach) mode="$1"; shift ;;
        esac
        if (( $# < 1 )) || [[ -z "$1" || "$1" == -* ]]; then
          print -u2 'Usage: rdp HOST [USER] [FREERDP-ARGS...] | rdp {--save|--detach} HOST [USER]'
          return 1
        fi
        host="$1"; shift
        service="rdp:$host"
        if (( $# > 0 )) && [[ "$1" != [/+-]* ]]; then
          user="$1"; shift
        fi
        if [[ "$mode" != connect ]] && (( $# > 0 )); then
          print -u2 'Pass FreeRDP options only when connecting without --save or --detach.'
          return 1
        fi
        if [[ -z "$user" ]]; then
          if [[ "$mode" == --detach ]]; then
            user=$(/usr/bin/defaults read "$prefs" "$service" 2>/dev/null) || {
              print -u2 "No saved login for $host. Run: rdp --save $host"
              return 1
            }
          else
            read -r 'user?Username: ' || return 1
          fi
        fi
        if [[ -z "$user" ]]; then
          print -u2 'A Windows username is required.'
          return 1
        fi
        if [[ "$mode" == --save ]]; then
          /usr/bin/security add-generic-password -U -s "$service" -a "$user" -w &&
            /usr/bin/defaults write "$prefs" "$service" -string "$user"
          return $?
        fi
        client=( ${pkgs.freerdp}/bin/sdl-freerdp "/v:$host" "/u:$user"
          /from-stdin:force /dynamic-resolution +clipboard /cert:tofu "$@" )
        if [[ "$mode" == --detach ]]; then
          if ! /usr/bin/security find-generic-password -s "$service" -a "$user" >/dev/null 2>&1; then
            print -u2 "No Keychain password for $user at $host. Run: rdp --save $host"
            return 1
          fi
          log="$HOME/Library/Logs/rdp.log"
          mkdir -p "$HOME/Library/Logs" && : >> "$log" || return 1
          /usr/bin/security find-generic-password -s "$service" -a "$user" -w </dev/null 2>>"$log" |
            /usr/bin/nohup "''${client[@]}" >> "$log" 2>&1 &!
          print -r -- "Starting FreeRDP in the background. Log: $log"
        else
          "''${client[@]}"
        fi
      }
    '';

    shellAliases = {
      vim = "nvim";
      rb = ''bash "$HOME/.config/nix/rebuild.sh"'';
      dev = "tmux new-session -d -s dev -n pi pi \\; new-window -t dev -n nvim nvim \\; attach-session -t dev";
      pif = ''pi --fork "$HOME/.pi/agent/sessions/--''${''${PWD#/}//\//-}--"/*.jsonl(.om[1])'';
    };

  };
}
