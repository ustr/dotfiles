{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      vim = "nvim";
      gc = "git commit --allow-empty-message -m ''";
    };

    initContent = ''
      # Fork the most recently modified Pi session for this directory.
      pif() {
        local safe_path="''${PWD#/}"
        safe_path="''${safe_path//\//-}"
        safe_path="''${safe_path//:/-}"
        safe_path="''${safe_path//\\/-}"
        local agent_dir="''${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
        local session_dir="''${PI_CODING_AGENT_SESSION_DIR:-$agent_dir/sessions/--$safe_path--}"
        local -a sessions
        sessions=("$session_dir"/*.jsonl(N.om[1]))
        if (( ''${#sessions} == 0 )); then
          print -u2 -- "No Pi session found for $PWD"
          return 1
        fi
        pi --fork "$sessions[1]" "$@"
      }
    '';
  };
}
