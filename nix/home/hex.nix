{ lib, pkgs, ... }:

let
  settings = {
    "dictation_processing.default_mode" = {
      name = "Global";
      applications = [ ];
      browser_hosts = [ ];
      replacements = [ ];
      post_processing = {
        enabled = false;
      };
      transformations = [ "lowercase" "no-trailing-punctuation" ];
    };
    "labs.live_text" = false;
    show_dock_icon = false;
  };
in
{
  home.activation.configureHex = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    hex=/Applications/Hex.app/Contents/MacOS/hex
    if [[ -x $hex ]]; then
      run "$hex" settings apply ${pkgs.writeText "hex-settings.json" (builtins.toJSON settings)} \
        || warnEcho "Could not apply Hex settings"
    else
      warnEcho "Hex is not installed; skipping its settings"
    fi
  '';
}
