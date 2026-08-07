{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    sessionVariables = {
      PI_ROTATOR_TELEMETRY = "off";
    };

    shellAliases.vim = "nvim";
  };
}
