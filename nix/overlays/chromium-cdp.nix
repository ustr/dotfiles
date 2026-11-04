final: prev:
let
  name = "Chromium CDP";
  chromiumApp = "/Applications/Chromium.app";
  port = 9222;

  icon = prev.fetchurl {
    url = "https://raw.githubusercontent.com/chromium/chromium/150.0.7871.46/chrome/app/theme/chromium/mac/app.icns";
    hash = "sha256-ocKxcZEjTuSrElnU+1BW7zQMxkNFwafStQTGMoEv8GI=";
  };

  launcher = prev.writeText "chromium-cdp-launcher" ''
    #!/bin/sh
    if /usr/bin/pgrep -xq Chromium && ! /usr/bin/nc -z 127.0.0.1 ${toString port} >/dev/null 2>&1; then
      /usr/bin/osascript -e 'display notification "Chromium is running without a debugging port. Quit it and relaunch from this icon." with title "${name}"' >/dev/null 2>&1
    fi
    exec /usr/bin/open -a "${chromiumApp}" --args --remote-debugging-port=${toString port}
  '';

  infoPlist = prev.writeText "chromium-cdp-Info.plist" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleDevelopmentRegion</key>
      <string>en</string>
      <key>CFBundleDisplayName</key>
      <string>${name}</string>
      <key>CFBundleExecutable</key>
      <string>chromium-cdp</string>
      <key>CFBundleIconFile</key>
      <string>app</string>
      <key>CFBundleIdentifier</key>
      <string>local.chromium-cdp</string>
      <key>CFBundleInfoDictionaryVersion</key>
      <string>6.0</string>
      <key>CFBundleName</key>
      <string>${name}</string>
      <key>CFBundlePackageType</key>
      <string>APPL</string>
      <key>CFBundleShortVersionString</key>
      <string>1.0</string>
      <key>CFBundleVersion</key>
      <string>1</string>
      <key>LSMinimumSystemVersion</key>
      <string>11.0</string>
      <key>LSUIElement</key>
      <true/>
    </dict>
    </plist>
  '';
in
{
  chromium-cdp = prev.runCommand "chromium-cdp" { passthru = { inherit port; }; } ''
    app="$out/Applications/${name}.app"
    mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
    install -m755 ${launcher} "$app/Contents/MacOS/chromium-cdp"
    install -m644 ${infoPlist} "$app/Contents/Info.plist"
    install -m644 ${icon} "$app/Contents/Resources/app.icns"
  '';
}
