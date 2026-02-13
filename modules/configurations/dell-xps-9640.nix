{config, ...}: let
  inherit (config) flake;
in {
  configurations.nixos.dell-xps-9640 = {
    module = {config, ...}: {
      imports = with flake.modules.nixos; [
        base
        niri
        sops
      ];

      networking.hostName = "dell-xps-9640";

      virtualisation.vmVariant = {
        virtualisation = {
          memorySize = 8192;
          cores = 4;
          diskSize = 32768;

          qemu.options = [
            "-device virtio-vga-gl"
            "-display gtk,gl=on"
          ];

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
