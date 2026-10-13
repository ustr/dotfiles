{ ... }:

{
  imports = [
    ./zsh.nix
  ];

  home.file.".pi/agent/settings.json" = {
    force = true;
    text = builtins.toJSON {
      defaultProvider = "openai-codex";
      defaultModel = "gpt-6.1-sol";
      defaultThinkingLevel = "medium";
      packages = [ "npm:pi-web-access@0.38.0" ];
    };
  };

  home.stateVersion = "26.05";
}
