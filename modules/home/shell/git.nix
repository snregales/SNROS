_: {
  flake.modules.homeManager.git = {osConfig, ...}: {
    programs = {
      git = {
        enable = true;
        userName = osConfig.snros.user.name;
        userEmail = osConfig.snros.user.email;
        signing = {
          format = "ssh";
          signByDefault = true;
        };
        settings = {
          init.defaultBranch = "main";
          pull.rebase = true;
          push.autoSetupRemote = true;
          fetch = {
            prune = true;
            fsckObjects = true;
          };
          merge.conflictStyle = "zdiff3";
          rerere.enabled = true;
          diff.algorithm = "histogram";
          transfer.fsckObjects = true;
          receive.fsckObjects = true;
          difftool.difftastic.cmd = "difft \"$LOCAL\" \"$REMOTE\"";
          alias.dft = "difftool --tool=difftastic";
        };
      };

      delta = {
        enable = true;
        enableGitIntegration = true;
        options = {
          navigate = true;
          side-by-side = true;
          line-numbers = true;
        };
      };

      difftastic = {
        enable = true;
        git.enable = false;
        options = {
          background = "dark";
        };
      };
    };
  };
}
