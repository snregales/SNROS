_: {
  flake.modules.nixos.variables = {lib, ...}: {
    options.snros = {
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
