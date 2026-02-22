{
  config,
  inputs,
  ...
}: let
  inherit (config) flake;
in {
  configurations.nixos.dell-xps-9500 = {
    module = _: {
      imports = [
        inputs.nixos-hardware.nixosModules.dell-xps-15-9500-nvidia
        flake.modules.nixos.dell-xps
        flake.modules.nixos.intel
        flake.modules.nixos.nvidia
      ];

      networking.hostName = "dell-xps-9500";
      networking.hostId = "99a0aaa7";

      snros.hardware.gpu = {
        intel.busId = "PCI:0:2:0";
        nvidia.busId = "PCI:1:0:0";
      };
    };
  };
}
