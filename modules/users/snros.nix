{config, ...}: let
  inherit (config) flake;
in {
  flake.modules.nixos.snros = {config, pkgs, ...}: {
    imports = [ flake.modules.nixos.home-manager ];

    users.mutableUsers = false;

    sops.secrets."user-password".neededForUsers = true;

    programs.zsh.enable = true;

    users.users.snros = {
      isNormalUser = true;
      shell = pkgs.zsh;
      hashedPasswordFile = config.sops.secrets."user-password".path;
      extraGroups = ["wheel"];
    };

    home-manager.users.snros = {
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
