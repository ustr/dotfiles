{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager }:
    let
      configuration = { pkgs, ... }: {
        environment.systemPackages =
          [
            pkgs.prismlauncher
            pkgs.vesktop
            pkgs.keepassxc
            pkgs.ghostty-bin
            pkgs.qbittorrent
            pkgs.mpv
            pkgs.git
            pkgs.gh
            pkgs.neovim
            pkgs.nixpkgs-fmt
            pkgs.shfmt
            (pkgs.texliveBasic.withPackages (ps: with ps; [
              preprint
              titlesec
              enumitem
              hyperref
            ]))
          ];

        homebrew = {
          enable = true;

          casks = [
            "ungoogled-chromium"
          ];

          brews = [
            "pi-coding-agent"
          ];

          onActivation.cleanup = "zap";
        };

        nix.settings.experimental-features = "nix-command flakes";

        environment.variables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
        };

        system.configurationRevision = self.rev or self.dirtyRev or null;

        system.stateVersion = 6;

        nixpkgs.hostPlatform = "aarch64-darwin";

        system.defaults = {
          NSGlobalDomain.ApplePressAndHoldEnabled = false;

          NSGlobalDomain._HIHideMenuBar = true;

          CustomUserPreferences.NSGlobalDomain.AppleMenuBarVisibleInFullscreen = 0;

          NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;

          CustomUserPreferences.NSGlobalDomain."com.apple.mouse.linear" = true;

          CustomUserPreferences.NSGlobalDomain."com.apple.mouse.scaling" = 0.6875;

          CustomUserPreferences.NSGlobalDomain.CGDisableCursorLocationMagnification = true;

          NSGlobalDomain."com.apple.swipescrolldirection" = false;

          trackpad.Clicking = true;

          trackpad.ActuationStrength = 0;

          trackpad.ActuateDetents = false;

          trackpad.FirstClickThreshold = 0;

          trackpad.ForceSuppressed = true;

          NSGlobalDomain.InitialKeyRepeat = 15;

          NSGlobalDomain.KeyRepeat = 2;

          dock.autohide = true;

          dock.autohide-delay = 0.0;

          dock.autohide-time-modifier = 0.0;

          dock.show-recents = false;

          dock.launchanim = false;

          dock.minimize-to-application = true;

          dock.mineffect = "scale";

          dock.persistent-apps = [
            "${pkgs.ghostty-bin}/Applications/Ghostty.app"
            "/Applications/Chromium.app"
            "${pkgs.vesktop}/Applications/Vesktop.app"
            "${pkgs.keepassxc}/Applications/KeepassXC.app"
          ];

          dock.persistent-others = [ ];

          universalaccess.reduceMotion = true;

          universalaccess.reduceTransparency = true;

          finder.AppleShowAllExtensions = true;

          finder.FXEnableExtensionChangeWarning = false;

          finder.AppleShowAllFiles = true;

          finder.FXPreferredViewStyle = "clmv";

          finder.CreateDesktop = false;

          finder.NewWindowTarget = "Home";

          finder.QuitMenuItem = true;

          finder.ShowPathbar = true;

          finder._FXEnableColumnAutoSizing = true;

          finder._FXShowPosixPathInTitle = true;

          finder._FXSortFoldersFirst = true;

          hitoolbox.AppleFnUsageType = "Do Nothing";

          loginwindow.GuestEnabled = false;

          NSGlobalDomain."com.apple.sound.beep.volume" = 0.0;

          WindowManager.EnableStandardClickToShowDesktop = false;

          WindowManager.StandardHideWidgets = true;

          controlcenter.BatteryShowPercentage = true;

          controlcenter.Sound = true;

          controlcenter.NowPlaying = false;

          NSGlobalDomain.AppleInterfaceStyle = "Dark";

          CustomUserPreferences."com.apple.dock".enterMissionControlByTopWindowDrag = false;

          dock.wvous-br-corner = 1;
        };

        system.primaryUser = "user";
        users.users."user" = {
          name = "user";
          home = "/Users/user";
        };

        system.startup.chime = false;
      };
    in
    {
      darwinConfigurations."macos" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              user = "user";
            };
          }
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users."user" = { ... }: {
              imports = [
                ./home/zsh.nix
                ./home/starship.nix
              ];

              home.stateVersion = "26.05";
            };
          }
        ];
      };
    };
}
