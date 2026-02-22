_: {
  flake.modules.nixos.amd = {pkgs, ...}: {
    hardware = {
      graphics = {
        enable = true;
        extraPackages = [
          pkgs.amdvlk
          pkgs.rocmPackages.clr.icd
        ];
      };
      cpu.amd.updateMicrocode = true;
      amdgpu.opencl.enable = true;
    };
  };
}
