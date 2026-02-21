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
        flake.modules.nixos.services
        {system.stateVersion = "25.05";}
      ];
    }).config;
in {
  perSystem = {pkgs, ...}: {
    checks.eval-services = pkgs.runCommand "eval-services" {} ''
      ${assert cfg.services.openssh.enable; ""}
      ${assert cfg.services.openssh.settings.PermitRootLogin == "no"; ""}
      ${assert !cfg.services.openssh.settings.PasswordAuthentication; ""}
      ${assert !cfg.services.openssh.settings.KbdInteractiveAuthentication; ""}
      ${assert cfg.services.libinput.enable; ""}
      ${assert cfg.services.fstrim.enable; ""}
      ${assert cfg.services.gvfs.enable; ""}
      touch $out
    '';
  };
}
