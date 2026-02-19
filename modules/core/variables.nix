_: {
  flake.modules.nixos.variables = {lib, ...}: {
    options.snros = {
      user = {
        name = lib.mkOption {
          type = lib.types.str;
          description = "Full name for use in git commits and other tools";
        };
        email = lib.mkOption {
          type = lib.types.str;
          description = "Email for use in git commits and other tools";
        };
      };
    };
  };
}
