{config, ...}: let
  inherit (config) flake;
in {
  flake.modules.nixos.dell-xps = {lib, ...}: {
    imports = with flake.modules.nixos; [
      _1password
      base
      biometrics
      lanzaboote
      cachix
      packages
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
      sshPublicKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGtZXJQLbehQuw2Dsmjy2Ko3yimTZr/GljTooplRgH9v snregales@git"
      ];
    };

    # Boot loader
    boot.loader = {
      limine.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # VM variant overrides
    virtualisation.vmVariant = {
      services.fprintd.enable = lib.mkForce false;
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

    system.stateVersion = "26.05";
  };
}
