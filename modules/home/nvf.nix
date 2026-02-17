{inputs, ...}: let
  nvfSettings = import ../../lib/nvf-settings.nix;
in {
  flake.modules.homeManager.nvf = _: {
    imports = [inputs.nvf.homeManagerModules.default];
    programs.nvf = {
      enable = true;
      enableManpages = true;
      settings = nvfSettings;
    };
  };

  perSystem = {system, ...}: let
    pkgs = inputs.nixpkgs.legacyPackages.${system};
    neovimPackage = inputs.nvf.lib.neovimConfiguration {
      inherit pkgs;
      modules = [nvfSettings];
    };
  in {
    packages.neovim = neovimPackage.neovim;
  };
}
