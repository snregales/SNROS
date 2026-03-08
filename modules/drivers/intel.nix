_: {
  flake.modules.nixos.intel = {pkgs, ...}: {
    # i915 conflicts with xe on Intel Arc (Meteor Lake Xe-LPG); xe is the correct driver
    boot.blacklistedKernelModules = ["i915"];

    hardware = {
      enableRedistributableFirmware = true;

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
