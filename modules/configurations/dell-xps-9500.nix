{
  config,
  inputs,
  ...
}: let
  inherit (config) flake;
in {
  configurations.nixos.dell-xps-9500 = {
    module = {lib, ...}: {
      imports = with flake.modules.nixos; [
        inputs.nixos-hardware.nixosModules.dell-xps-15-9500
        _1password
        base
        cachix
        disko
        keyboard
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

      snros.user = {
        name = "Sharlon N. Regales";
        email = "sharlonregales@gmail.com";
      };

      networking.hostName = "dell-xps-9500";
      networking.hostId = "99a0aaa7";

      # Boot loader
      boot.loader = {
        limine.enable = true;
        efi.canTouchEfiVariables = true;
      };

      # VM variant overrides
      virtualisation.vmVariant = {
        disko.enableConfig = false;
        boot = {
          initrd.postDeviceCommands = lib.mkForce "";
          loader = {
            limine.enable = lib.mkForce false;
            efi.canTouchEfiVariables = lib.mkForce false;
          };
        };
        environment.persistence = lib.mkForce {};
        fileSystems."/persist" = lib.mkForce {
          device = "tmpfs";
          fsType = "tmpfs";
        };

        virtualisation = {
          memorySize = 8192;
          cores = 4;
          diskSize = 32768;

          qemu.options = [
            "-device virtio-vga-gl"
            "-display gtk,gl=on"
          ];

          sharedDirectories.sops-key = {
            source = ''"''${SOPS_AGE_KEY_DIR}"'';
            target = "/var/lib/sops-nix";
            securityModel = "none";
          };
        };
      };

      system.stateVersion = "25.05";
    };
  };
}
