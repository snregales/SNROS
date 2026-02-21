{
  config,
  inputs,
  ...
}: let
  inherit (config) flake;
  inherit (inputs.nixpkgs) lib;
  cfg =
    (lib.nixosSystem {
      modules = [
        flake.modules.nixos.base
        flake.modules.nixos.desktop
        {system.stateVersion = "25.05";}
      ];
    }).config;
in {
  perSystem = {pkgs, ...}: {
    checks.eval-desktop = pkgs.runCommand "eval-desktop" {} ''
      ${assert cfg.services.blueman.enable; ""}
      ${assert cfg.services.tumbler.enable; ""}
      ${assert cfg.services.gnome.gnome-keyring.enable; ""}
      ${assert cfg.services.pipewire.enable; ""}
      ${assert cfg.services.pipewire.alsa.enable; ""}
      ${assert cfg.services.pipewire.alsa.support32Bit; ""}
      ${assert cfg.services.pipewire.pulse.enable; ""}
      ${assert cfg.services.pipewire.jack.enable; ""}
      touch $out
    '';
  };
}
