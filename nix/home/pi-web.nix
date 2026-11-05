{ config, lib, pkgs, ... }:

let
  version = "0.0.1-beta.38";
  source = "npm:@ygncode/pi-web@${version}";
  piWeb = pkgs.stdenvNoCC.mkDerivation {
    pname = "pi-web";
    inherit version;
    src = pkgs.fetchurl {
      url = "https://github.com/ygncode/pi-web/releases/download/v${version}/pi-web-darwin-arm64";
      hash = "sha256-1ByXPYDMqMmXfGIkG2imofVHva8ZWIw9Ti7CTAx79G4=";
    };
    dontUnpack = true;
    dontStrip = true;
    installPhase = ''
      install -Dm755 "$src" "$out/bin/pi-web"
    '';
    meta.mainProgram = "pi-web";
  };
  start = pkgs.writeShellScript "pi-web-lan" ''
    set -euo pipefail
    export PATH="${lib.makeBinPath [ pkgs.pi-coding-agent pkgs.nodejs pkgs.git pkgs.openssh ]}:/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    set -a
    . "$HOME/.config/pi-web/env"
    set +a
    host=$(/usr/sbin/ipconfig getifaddr en0)
    exec ${lib.getExe piWeb} --host "$host" -p 31415
  '';
  link = pkgs.writeShellScriptBin "pi-web-link" ''
    set -euo pipefail
    . "$HOME/.config/pi-web/env"
    host=$(/usr/sbin/ipconfig getifaddr en0)
    printf 'http://%s:31415/?token=%s\n' "$host" "$PI_WEB_TOKEN"
  '';
in
{
  home.packages = [ piWeb link ];
  home.file.".pi/agent/bin/pi-web".source = "${piWeb}/bin/pi-web";
  home.file.".pi/agent/bin/pi-web-link".source = "${link}/bin/pi-web-link";

  home.activation.configurePiWeb = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.writeShellScript "configure-pi-web" ''
      set -euo pipefail
      export PATH="${lib.makeBinPath [ pkgs.nodejs pkgs.git pkgs.coreutils ]}:/usr/bin:/bin"
      umask 077
      mkdir -p "$HOME/.config/pi-web"
      chmod 700 "$HOME/.config/pi-web"
      if [[ ! -s "$HOME/.config/pi-web/env" ]]; then
        printf 'PI_WEB_TOKEN=%s\n' "$(${pkgs.openssl}/bin/openssl rand -hex 32)" > "$HOME/.config/pi-web/env"
      fi
      chmod 600 "$HOME/.config/pi-web/env"
      export npm_config_ignore_scripts=true
      ${lib.getExe pkgs.pi-coding-agent} install ${lib.escapeShellArg source}
    ''}
  '';

  launchd.agents.pi-web = {
    enable = true;
    config = {
      Label = "com.pi-web";
      ProgramArguments = [ "${start}" ];
      EnvironmentVariables.HOME = config.home.homeDirectory;
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 15;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/pi-web.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/pi-web-error.log";
    };
  };
}
