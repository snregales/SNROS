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
        flake.modules.nixos.biometrics
        {system.stateVersion = "25.05";}
      ];
    }).config;
in {
  perSystem = {pkgs, ...}: {
    checks.eval-biometrics = pkgs.runCommand "eval-biometrics" {} ''
      ${assert cfg.services.fprintd.enable; ""}
      ${assert cfg.services.fprintd.tod.enable; ""}
      touch $out
    '';
  };
}
