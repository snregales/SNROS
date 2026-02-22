_: {
  flake.modules.nixos.intel = {pkgs, ...}: {
    hardware = {
      graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          intel-vaapi-driver
          libva-vdpau-driver
          libvdpau-va-gl
          vpl-gpu-rt
        ];
      };
      cpu.intel.updateMicrocode = true;
    };
  };
}
