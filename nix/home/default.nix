{ lib, pkgs, ... }:

{
  imports = [
    ./zsh.nix
    ./git.nix
    ./gh.nix
  ];

  home.file.".pi/agent/models.json" = {
    force = true;
    text = builtins.toJSON {
      providers.ollama = {
        baseUrl = "http://localhost:11434/v1";
        api = "openai-completions";
        apiKey = "ollama";
        models = [{ id = "qwen3.5:9b"; }];
      };
    };
  };

  # Keep pi-subagents' `subagent` tool active from the first request instead of
  # gating it behind `subagents_enable`. Documented equivalent of launching with
  # `--exclude-tools subagents_enable` (pi-subagents docs/configuration.md).
  # pi-subagents reads this at session start from <agent-dir>/extensions/subagent.
  home.file.".pi/agent/extensions/subagent/config.json" = {
    force = true;
    text = builtins.toJSON {
      toolActivation = "eager";
    };
  };

  home.activation.pullOllamaModels = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.writeShellScript "pull-ollama-models" ''
      set -euo pipefail
      export OLLAMA_HOST="127.0.0.1:11434"
      ollama=${lib.getExe pkgs.ollama}
      server_pid=""
      cleanup() {
        if [[ -n "$server_pid" ]]; then
          kill "$server_pid" 2>/dev/null || true
          wait "$server_pid" 2>/dev/null || true
        fi
      }
      trap cleanup EXIT

      if ! "$ollama" list >/dev/null 2>&1; then
        "$ollama" serve &
        server_pid=$!
        for ((attempt = 0; attempt < 30; attempt++)); do
          if "$ollama" list >/dev/null 2>&1; then
            break
          fi
          ${pkgs.coreutils}/bin/sleep 1
        done
        "$ollama" list >/dev/null
      fi

      if ! "$ollama" show qwen3.5:9b >/dev/null 2>&1; then
        "$ollama" pull qwen3.5:9b
      fi
    ''}
  '';

  # Remove the stray ~/.gitconfig so it can't override the home-manager-managed
  # XDG config (~/.config/git/config). Git reads ~/.gitconfig last, so a leftover
  # file there would otherwise win.
  home.activation.removeStrayGitConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run rm -f "$HOME/.gitconfig"
  '';

  home.stateVersion = "26.05";
}
