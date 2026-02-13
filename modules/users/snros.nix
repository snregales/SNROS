{config, ...}: let
  inherit (config) flake;
in {
  flake.modules.nixos.snros = {config, ...}: {
    imports = [ flake.modules.nixos.home-manager ];

    users.mutableUsers = false;

    sops.secrets."user-password".neededForUsers = true;

    users.users.snros = {
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets."user-password".path;
      extraGroups = ["wheel"];
    };

    home-manager.users.snros = {
      home.stateVersion = "25.05";
    };
  };
}
