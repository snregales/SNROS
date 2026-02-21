_: {
  flake.modules.homeManager.foot = _: {
    programs.foot = {
      enable = true;
      server.enable = true;
    };
  };
}
