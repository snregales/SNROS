_: {
  flake.modules.nixos.boot = {pkgs, ...}: {
    boot = {
      kernelPackages = pkgs.linuxPackages_zen;
      kernelModules = ["v4l2loopback"];
      extraModulePackages = [pkgs.linuxPackages_zen.v4l2loopback];
      tmp.useTmpfs = true;
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
      kernel.sysctl."vm.max_map_count" = 262144;
      plymouth.enable = true;
    };
  };
}
