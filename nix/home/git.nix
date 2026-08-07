{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "ibrah-m";
        email = "139663719+ibrah-m@users.noreply.github.com";
      };

      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };
}
