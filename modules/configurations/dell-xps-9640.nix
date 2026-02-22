{config, ...}: let
  inherit (config) flake;
in {
  configurations.nixos.dell-xps-9640 = {
    module = _: {
      imports = [
        flake.modules.nixos.dell-xps
        flake.modules.nixos.intel
      ];

      networking.hostName = "dell-xps-9640";
      networking.hostId = "22770b28";

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
    };
  };
}
