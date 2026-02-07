{ ... }:
{
  perSystem =
    { pkgs, config, ... }:
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
          config.packages.neovim
        ];
      };
    };
}
