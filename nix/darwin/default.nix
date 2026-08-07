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
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.primaryUser = "user";
  system.stateVersion = 6;
  system.startup.chime = false;

  users.users.user = {
    name = "user";
    home = "/Users/user";
  };
}
