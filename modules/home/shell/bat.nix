_: {
  flake.modules.homeManager.bat = {pkgs, ...}: {
    programs.bat = {
      enable = true;
      config.pager = "less -FR";
    };

    home.packages = with pkgs.bat-extras; [
      batdiff
      batgrep
      batman
      batpipe
    ];

    programs.zsh.shellAliases = {
      cat = "bat";
      man = "batman";
      diff = "batdiff";
    };
  };
}
