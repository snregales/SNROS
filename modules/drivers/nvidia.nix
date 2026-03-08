_: {
  flake.modules.nixos.nvidia = {
    lib,
    config,
    ...
  }: let
    ifSet = busId: lib.mkIf (busId != null) busId;
    inherit (config.snros.hardware) gpu;
  in {
    # Required to load nvidia kernel modules (even on Wayland-only setups)
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = true;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      powerManagement = {
        enable = true;
        finegrained = true;
      };
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = ifSet gpu.intel.busId;
        amdgpuBusId = ifSet gpu.amd.busId;
        nvidiaBusId = ifSet gpu.nvidia.busId;
      };
    };
  };
}
