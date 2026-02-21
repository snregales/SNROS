_: {
  flake.modules.nixos.ssh = _: {
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
  };

  flake.modules.homeManager.ssh = _: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*".identityAgent = "~/.1password/agent.sock";
    };
    home.file.".config/1Password/ssh/agent.toml".text = ''
      [[ssh-keys]]
      vault = "snros"
    '';
  };
}
