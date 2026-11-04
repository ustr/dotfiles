final: prev:
let
  name = "Chromium CDP";
  chromiumApp = "/Applications/Chromium.app";
  port = 9222;

  icon = ./chromium.icns;

  launcher = prev.writeText "chromium-cdp-launcher.c" ''
    #include <stdio.h>
    #include <stdlib.h>
    #include <unistd.h>

    int main(int argc, char **argv) {
      char **args = calloc((size_t)argc + 2, sizeof(*args));
      if (args == NULL) {
        perror("calloc");
        return EXIT_FAILURE;
      }
      args[0] = "${chromiumApp}/Contents/MacOS/Chromium";
      args[1] = "--remote-debugging-port=${toString port}";
      for (int i = 1; i < argc; ++i) {
        args[i + 1] = argv[i];
      }
      execv(args[0], args);
      perror("Could not launch Chromium");
      return EXIT_FAILURE;
    }
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
      <string>io.ungoogled-software.ungoogled-chromium</string>
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
      <key>LSArchitecturePriority</key>
      <array>
        <string>arm64</string>
      </array>
      <key>LSMinimumSystemVersion</key>
      <string>11.0</string>
    </dict>
    </plist>
  '';
in
{
  chromium-cdp = prev.runCommand "chromium-cdp" {
    nativeBuildInputs = [ prev.stdenv.cc ];
    passthru = { inherit port; };
  } ''
    app="$out/Applications/${name}.app"
    mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
    $CC -O2 -Wall -Wextra ${launcher} -o "$app/Contents/MacOS/chromium-cdp"
    install -m644 ${infoPlist} "$app/Contents/Info.plist"
    install -m644 ${icon} "$app/Contents/Resources/app.icns"
  '';
}
