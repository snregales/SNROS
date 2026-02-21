_: {
  flake.modules.homeManager.git = {osConfig, ...}: {
    # Use 1Password SSH agent for signing
    programs.ssh.extraConfig = ''
      Host *
        IdentityAgent ~/.1password/agent.sock
    '';

    programs = {
      git = {
        enable = true;
        signing = {
          format = "ssh";
          key = "key::${builtins.head osConfig.snros.user.sshPublicKeys}";
          signByDefault = true;
        };
        settings = {
          user.name = osConfig.snros.user.name;
          user.email = osConfig.snros.user.email;
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
