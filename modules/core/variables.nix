_: {
  flake.modules.nixos.variables = {lib, ...}: {
    options.snros = {
      hardware.gpu = {
        intel.busId = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "PCI bus ID for Intel GPU (e.g. \"PCI:0:2:0\")";
        };
        nvidia.busId = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "PCI bus ID for NVIDIA GPU (e.g. \"PCI:1:0:0\")";
        };
        amd.busId = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "PCI bus ID for AMD GPU (e.g. \"PCI:5:0:0\")";
        };
      };
      user = {
        username = lib.mkOption {
          type = lib.types.str;
          description = "System username";
        };
        name = lib.mkOption {
          type = lib.types.str;
          description = "Full name for use in git commits and other tools";
        };
        email = lib.mkOption {
          type = lib.types.str;
          description = "Email for use in git commits and other tools";
        };
        sshPublicKeys = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "SSH public keys for authorizing login";
        };
      };
    };
  };
}
