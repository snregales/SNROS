{inputs, ...}: {
  imports = [inputs.git-hooks.flakeModule];

  perSystem = {
    config,
    pkgs,
    system,
    ...
  }: let
    nvfSettings = import ../lib/nvf-settings.nix;
    ayuTheme = _: {
      config.vim.theme = {
        enable = true;
        name = "base16";
        base16-colors = {
          base00 = "#0b0e14";
          base01 = "#131721";
          base02 = "#202229";
          base03 = "#3e4b59";
          base04 = "#bfbdb6";
          base05 = "#e6e1cf";
          base06 = "#ece8db";
          base07 = "#f2f0e7";
          base08 = "#f07178";
          base09 = "#ff8f40";
          base0A = "#ffb454";
          base0B = "#aad94c";
          base0C = "#95e6cb";
          base0D = "#59c2ff";
          base0E = "#d2a6ff";
          base0F = "#e6b450";
        };
      };
    };
    neovimPackage = inputs.nvf.lib.neovimConfiguration {
      inherit pkgs;
      modules = [nvfSettings ayuTheme];
    };
  in {
    pre-commit.settings.hooks = {
      alejandra.enable = true;
      nil.enable = true;
      statix.enable = true;
      deadnix.enable = true;
    };

    devShells.default = pkgs.mkShell {
      shellHook = ''
        alias ,='comma'
        export SOPS_AGE_KEY_CMD="op read op://snros/sops-age-key/notesPlain"
        ${config.pre-commit.installationScript}
      '';
      packages = with pkgs;
        [
          alejandra
          nil
          git
          just
          fzf
          yazi
          zellij
          sops
          age
        ]
        ++ [
          inputs.nix-index-database.packages.${system}.comma-with-db
          inputs.nixgl.packages.${system}.nixGLIntel
          neovimPackage.neovim
        ];
    };
  };
}
