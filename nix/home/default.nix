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

  home.file.".pi/agent/mcp.json" = {
    force = true;
    text = builtins.toJSON {
      mcpServers.playwright = {
        command = "${pkgs.playwright-mcp}/bin/playwright-mcp";
        args = [
          "--cdp-endpoint"
          "http://127.0.0.1:${toString pkgs.chromium-cdp.port}"
        ];
        exposure = "direct";
        description = "Drive the user's running ungoogled-chromium (launched via 'Chromium CDP'): tabs, navigation, clicks, forms, screenshots";
      };
    };
  };

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

  home.activation.removeStrayGitConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run rm -f "$HOME/.gitconfig"
  '';

  home.activation.configureClaudeCode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.writeShellScript "configure-claude-code" ''
      set -euo pipefail
      jq=${lib.getExe pkgs.jq}
      merge() {
        local file="$1" filter="$2"
        mkdir -p "$(dirname "$file")"
        [[ -f "$file" ]] || echo '{}' > "$file"
        tmp=$(mktemp)
        "$jq" "$filter" "$file" > "$tmp"
        mv "$tmp" "$file"
      }

      merge "$HOME/.claude/settings.json" '
        .spinnerTipsEnabled = false
        | .autoMemoryEnabled = false
        | .env.CLAUDE_CODE_DISABLE_AUTO_MEMORY = "1"
        | .env.ENABLE_CLAUDEAI_MCP_SERVERS = "false"
      '

      merge "$HOME/.claude.json" '
        .diffTool = "terminal"
        | .autoConnectIde = false
        | .autoInstallIdeExtension = false
        | .mcpServers.playwright = {
          type: "stdio",
          command: "${pkgs.playwright-mcp}/bin/playwright-mcp",
          args: [
            "--cdp-endpoint",
            "http://127.0.0.1:${toString pkgs.chromium-cdp.port}"
          ],
          env: {}
        }
      '
    ''}
  '';

  home.stateVersion = "26.05";
}
