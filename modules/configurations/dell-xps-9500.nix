{config, inputs, ...}: let
  inherit (config) flake;
in {
  configurations.nixos.dell-xps-9500 = {
    module = {
      config,
      lib,
      ...
    }: {
      imports = with flake.modules.nixos; [
        inputs.nixos-hardware.nixosModules.dell-xps-15-9500
        base
        cachix
        disko
        greetd
        impermanence
        nh
        niri
        nix-index-database
        noctalia
        snregales
        sops
        stylix
        zfs
      ];

      networking.hostName = "dell-xps-9500";
      networking.hostId = "99a0aaa7";

      # Boot loader
      boot.loader.limine.enable = true;
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
        boot.loader.limine.enable = lib.mkForce false;
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

      system.stateVersion = "25.05";
    };
  };
}
