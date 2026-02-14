{ inputs, ... }:
{
  perSystem =
    { pkgs, config, system, ... }:
    {
      devShells.default = pkgs.mkShell {
        shellHook = ''
          alias ,='comma'
        '';
        packages = [
          pkgs.alejandra
          pkgs.nil
          pkgs.git
          pkgs.just
          pkgs.fzf
          pkgs.yazi
          pkgs.zellij
          pkgs.sops
          pkgs.age
          inputs.nix-index-database.packages.${system}.comma-with-db
          inputs.nixgl.packages.${system}.nixGLIntel
          config.packages.neovim
        ];
      };
    };
}
