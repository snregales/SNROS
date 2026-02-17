{ inputs, ... }:
{
  flake.modules.nixos.niri =
    { ... }:
    {
      imports = [ inputs.niri.nixosModules.niri ];

      nixpkgs.overlays = [ inputs.niri.overlays.niri ];

      programs.niri.enable = true;
    };

  flake.modules.homeManager.niri = _: {
    programs.niri.settings = {};
  };
}
