{config, ...}: let
  inherit (config) flake;
in {
  configurations.nixos.vm = {
    module = {config, ...}: {
      imports = with flake.modules.nixos; [
        base
        sops
      ];

      networking.hostName = "snros-vm";

      virtualisation.vmVariant = {
        virtualisation = {
          memorySize = 2048;
          cores = 2;
          diskSize = 4096;

          sharedDirectories.sops-key = {
            source = ''"''${SOPS_AGE_KEY_DIR:-$PWD/secrets/vm-key}"'';
            target = "/var/lib/sops-nix";
            securityModel = "none";
          };
        };
      };

      users.mutableUsers = false;

      sops.secrets."user-password".neededForUsers = true;

      users.users.snros = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets."user-password".path;
        extraGroups = ["wheel"];
      };

      system.stateVersion = "25.05";
    };
  };
}
