{ ... }:

{
  # Upstream Home Manager module, backported for our pinned release.
  # https://github.com/nix-community/home-manager/blob/c58f54c733a7894d84fa2fdff26cc12088c4b78c/modules/programs/pi-coding-agent.nix
  imports = [ ./modules/pi-coding-agent.nix ];

  programs.pi-coding-agent = {
    enable = true;
    # Pi is already installed by the Darwin configuration.
    package = null;

    settings = {
      defaultProvider = "openai-codex";
      defaultModel = "gpt-6.1-sol";
      defaultThinkingLevel = "medium";
      packages = [ "npm:pi-web-access@0.38.0" ];
    };
  };
}
