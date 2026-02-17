_: {
  flake.modules.homeManager.eza = _: {
    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      colors = "always";
      icons = "auto";
      git = true;
      extraOptions = [
        "--group-directories-first"
        "--no-quotes"
        "--git-ignore"
      ];
    };

    programs.zsh.shellAliases = {
      ls = "eza --oneline";
      l = "eza --long --binary --header --classify=auto";
      la = "eza --all --oneline";
      ll = "eza --long --all --binary --header";
      tree = "eza --tree";
    };
  };
}
