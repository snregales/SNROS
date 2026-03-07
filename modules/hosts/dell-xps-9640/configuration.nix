{config, ...}: let
  inherit (config) flake;
  mkHardwareConfig = import ../../../lib/mkHardwareConfig.nix;
in {
  configurations.nixos.dell-xps-9640 = {
    module = _: {
      imports = [
        (mkHardwareConfig ../../../devices/dell-xps-9640/hardware-configuration.nix)
        flake.modules.nixos.dell-xps
        flake.modules.nixos.intel
        flake.modules.nixos.nvidia
      ];
      networking = {
        hostName = "dell-xps-9640";
        hostId = "22770b28";
      };

      snros.user.sshPublicKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDhtw4fusrRcLZE/LU0Dn8ObWldYAF6yFrkk5vsCF5VZ dell-xps-9640"
      ];

      snros.hardware.gpu = {
        intel.busId = "PCI:0:2:0";
        nvidia.busId = "PCI:1:0:0";
      };
    };
  };
}
