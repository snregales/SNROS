{
  lib,
  config,
  ...
}: {
  options.configurations.nixos = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options.module = lib.mkOption {
          type = lib.types.deferredModule;
        };
      }
    );
  };

  config.flake.nixosConfigurations =
    config.configurations.nixos
    |> lib.mapAttrs (
      _: {module}:
        lib.nixosSystem {
          modules = [module];
        }
    );
}
