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
        flake.modules.nixos.zfs
        {system.stateVersion = "25.05";}
      ];
    }).config;
in {
  perSystem = {pkgs, ...}: {
    checks.eval-zfs = pkgs.runCommand "eval-zfs" {} ''
      ${assert !cfg.boot.zfs.forceImportRoot; ""}
      ${assert cfg.services.zfs.autoScrub.enable; ""}
      ${assert cfg.services.zfs.trim.enable; ""}
      touch $out
    '';
  };
}
