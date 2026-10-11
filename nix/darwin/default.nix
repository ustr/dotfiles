{ self, ... }:

{
  imports = [
    ./homebrew.nix
    ./macos.nix
    ./packages.nix
  ];

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  nix.settings.experimental-features = "nix-command flakes";
  nix.gc = {
    automatic = true;
    interval = { Weekday = 0; Hour = 3; Minute = 0; };
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true;
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.overlays = [
    (import ../overlays/pi-coding-agent.nix)
  ];

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.primaryUser = "user";
  system.stateVersion = 6;
  system.startup.chime = false;

  users.users.user = {
    name = "user";
    home = "/Users/user";
  };
}
