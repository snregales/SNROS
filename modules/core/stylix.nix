{ inputs, ... }:
{
  flake.modules.nixos.stylix =
    { pkgs, config, ... }:
    {
      imports = [ inputs.stylix.nixosModules.stylix ];
      stylix = {
        enable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
        image = config.lib.stylix.pixel "base0A";
        polarity = "dark";
        fonts.monospace = {
          package = pkgs.nerd-fonts.fira-code;
          name = "FiraCode Nerd Font Mono";
        };
      };
    };
}
