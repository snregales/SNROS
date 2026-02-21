{config, ...}: let
  inherit (config) flake;
in {
  flake.modules.nixos.snregales = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      flake.modules.nixos.desktop
      flake.modules.nixos.home-manager
      flake.modules.nixos.services
      flake.modules.nixos.variables
    ];

    users.mutableUsers = false;

    sops.secrets."user-password".neededForUsers = true;
    sops.secrets."git-ssh" = {
      owner = "snregales";
      mode = "0600";
    };
    programs.zsh.enable = true;

    users.users.snregales = {
      isNormalUser = true;
      description = config.snros.user.name;
      shell = pkgs.zsh;
      hashedPasswordFile = config.sops.secrets."user-password".path;
      extraGroups = ["wheel"];
      openssh.authorizedKeys.keys = config.snros.user.sshPublicKeys;
    };

    home-manager.users.snregales = {
      imports = with flake.modules.homeManager; [
        atuin
        bat
        brave
        direnv
        eza
        foot
        fzf
        git
        himalaya
        niri
        noctalia
        nvf
        starship
        yazi
        zellij
        zoxide
        zsh
      ];
      home.stateVersion = "26.05";
    };
  };
}
