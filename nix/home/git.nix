{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name = "ustr";
      user.email = "139663719+ustr@users.noreply.github.com";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };
}
