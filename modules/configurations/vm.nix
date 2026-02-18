{config, ...}: let
  inherit (config) flake;
in {
  configurations.nixos.vm = {
    module = {config, ...}: {
      imports = with flake.modules.nixos; [
        base
        niri
        sops
      ];

      networking.hostName = "snros-vm";

      virtualisation.vmVariant = {
        virtualisation = {
          memorySize = 4096;
          cores = 2;
          diskSize = 4096;

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

      users.users.snregales = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets."user-password".path;
        extraGroups = ["wheel"];
      };

      # Minimal boot config required to pass NixOS assertions.
      # The vmVariant overrides these at runtime.
      fileSystems."/" = {
        device = "/dev/vda";
        fsType = "ext4";
      };
      boot.loader.grub.device = "/dev/vda";

      system.stateVersion = "25.05";
    };
  };
}
