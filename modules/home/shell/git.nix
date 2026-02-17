_: {
  flake.modules.homeManager.git = {pkgs, ...}: {
    programs.git = {
      enable = true;
      signing = {
        format = "ssh";
        signByDefault = true;
      };
      settings = {
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
        fetch.prune = true;
        merge.conflictStyle = "zdiff3";
        rerere.enabled = true;
        diff.algorithm = "histogram";
        transfer.fsckObjects = true;
        receive.fsckObjects = true;
        fetch.fsckObjects = true;
        difftool.difftastic.cmd = "difft \"$LOCAL\" \"$REMOTE\"";
        alias.dft = "difftool --tool=difftastic";
      };
    };

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
      };
    };

    programs.difftastic = {
      enable = true;
      git.enable = false;
      options = {
        background = "dark";
      };
    };
  };
}
