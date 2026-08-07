{ pkgs, ... }:

{
  system.defaults = {
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
    NSGlobalDomain.ApplePressAndHoldEnabled = false;
    NSGlobalDomain.InitialKeyRepeat = 15;
    NSGlobalDomain.KeyRepeat = 2;
    NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
    NSGlobalDomain._HIHideMenuBar = true;
    NSGlobalDomain."com.apple.sound.beep.volume" = 0.0;
    NSGlobalDomain."com.apple.swipescrolldirection" = false;

    CustomUserPreferences.NSGlobalDomain.AppleMenuBarVisibleInFullscreen = 0;
    CustomUserPreferences.NSGlobalDomain.CGDisableCursorLocationMagnification = true;
    CustomUserPreferences.NSGlobalDomain."com.apple.mouse.linear" = true;
    CustomUserPreferences.NSGlobalDomain."com.apple.mouse.scaling" = 0.6875;
    CustomUserPreferences."com.apple.dock".enterMissionControlByTopWindowDrag = false;

    WindowManager.EnableStandardClickToShowDesktop = false;
    WindowManager.StandardHideWidgets = true;

    controlcenter.BatteryShowPercentage = true;
    controlcenter.NowPlaying = false;
    controlcenter.Sound = true;

    dock.autohide = true;
    dock.autohide-delay = 0.0;
    dock.autohide-time-modifier = 0.0;
    dock.launchanim = false;
    dock.mineffect = "scale";
    dock.minimize-to-application = true;
    dock.persistent-apps = [
      "${pkgs.ghostty-bin}/Applications/Ghostty.app"
      "/Applications/Chromium.app"
      "${pkgs.vesktop}/Applications/Vesktop.app"
      "${pkgs.keepassxc}/Applications/KeepassXC.app"
    ];
    dock.persistent-others = [ ];
    dock.show-recents = false;
    dock.wvous-br-corner = 1;

    finder.AppleShowAllExtensions = true;
    finder.AppleShowAllFiles = true;
    finder.CreateDesktop = false;
    finder.FXEnableExtensionChangeWarning = false;
    finder.FXPreferredViewStyle = "clmv";
    finder.NewWindowTarget = "Home";
    finder.QuitMenuItem = true;
    finder.ShowPathbar = true;
    finder._FXEnableColumnAutoSizing = true;
    finder._FXShowPosixPathInTitle = true;
    finder._FXSortFoldersFirst = true;

    hitoolbox.AppleFnUsageType = "Do Nothing";
    loginwindow.GuestEnabled = false;

    trackpad.ActuateDetents = false;
    trackpad.ActuationStrength = 0;
    trackpad.Clicking = true;
    trackpad.FirstClickThreshold = 0;
    trackpad.ForceSuppressed = true;

    universalaccess.reduceMotion = true;
    universalaccess.reduceTransparency = true;
  };
}
