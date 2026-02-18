{inputs, ...}: {
  flake.modules.nixos.stylix = {
    pkgs,
    config,
    ...
  }: {
    imports = [inputs.stylix.nixosModules.stylix];
    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
      image = config.lib.stylix.pixel "base0A";
      polarity = "dark";
      opacity.terminal = .7;
      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.fira-code;
          name = "FiraCode Nerd Font Mono";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
        sizes = {
          applications = 10;
          terminal = 10;
          desktop = 10;
          popups = 10;
        };
      };
      autoEnable = true;
    };
  };
}
