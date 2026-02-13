{config, ...}: let
  inherit (config) flake;
in {
  configurations.nixos.dell-xps-9640 = {
    module = {
      config,
      lib,
      ...
    }: {
      imports = with flake.modules.nixos; [
        base
        disko
        impermanence
        niri
        sops
        zfs
      ];

      networking.hostName = "dell-xps-9640";
      networking.hostId = "22770b28";

      # Boot loader
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # VM variant overrides
      virtualisation.vmVariant = {
        disko.enableConfig = false;
        boot.initrd.postDeviceCommands = lib.mkForce "";
        environment.persistence = lib.mkForce {};
        fileSystems."/persist" = lib.mkForce {
          device = "tmpfs";
          fsType = "tmpfs";
        };
        boot.loader.systemd-boot.enable = lib.mkForce false;
        boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

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
