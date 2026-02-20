{config, ...}: let
  inherit (config) flake;
in {
  flake.modules.nixos.snregales = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      flake.modules.nixos.home-manager
      flake.modules.nixos.variables
    ];

    users.mutableUsers = false;

    sops.secrets."user-password".neededForUsers = true;
    sops.secrets."git-ssh" = {
      owner = "snregales";
      mode = "0600";
    };

    services.openssh.enable = true;

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
        direnv
        eza
        foot
        fzf
        git
        niri
        noctalia
        nvf
        starship
        yazi
        zellij
        zoxide
        zsh
      ];
      home.stateVersion = "25.05";
    };
  };
}
