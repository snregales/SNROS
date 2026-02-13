{ inputs, ... }:
{
  perSystem =
    { pkgs, config, system, ... }:
    {
      devShells.default = pkgs.mkShell {
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
          inputs.nixgl.packages.${system}.nixGLIntel
          config.packages.neovim
        ];
      };
    };
}
