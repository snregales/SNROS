_: {
  flake.modules.homeManager.direnv = _: {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
