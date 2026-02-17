{ inputs, ... }:
{
  flake.modules.nixos.noctalia = _: {
      imports = [ inputs.noctalia.nixosModules.default ];

      services.noctalia-shell.enable = true;
    };

  flake.modules.homeManager.noctalia = _: {
      imports = [ inputs.noctalia.homeModules.default ];

      programs.noctalia-shell.enable = true;
    };
}
