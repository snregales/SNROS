{config, ...}: let
  inherit (config) flake;
in {
  flake.modules.nixos.dell-xps = {lib, ...}: {
    imports = with flake.modules.nixos; [
      _1password
      base
      biometrics
      lanzaboote
      networking
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

    # WiFi — profile created post-login via 1Password so op is authenticated
    home-manager.users.snregales.home.activation.wifiNewYorkQuarterMaster = {
      after = ["writeBoundary"];
      before = [];
      data = ''
        if ! nmcli connection show "NewYorkQuarterMaster" &>/dev/null; then
          psk=$(op read "op://snros/NewYorkQuarterMaster/password")
          nmcli connection add \
            type wifi \
            con-name "NewYorkQuarterMaster" \
            ssid "NewYorkQuarterMaster" \
            wifi-sec.key-mgmt wpa-psk \
            wifi-sec.psk "$psk"
        fi
      '';
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
