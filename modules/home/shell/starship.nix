_: {
  flake.modules.homeManager.starship = _:
    {
      programs.starship = {
        enable = true;
        enableZshIntegration = true;
      };
    };
}
