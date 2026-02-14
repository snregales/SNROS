{ config, inputs, ... }:
let
  inherit (config) flake;
  inherit (inputs.nixpkgs) lib;
  cfg =
    (lib.nixosSystem {
      modules = [
        flake.modules.nixos.base
        flake.modules.nixos.home-manager
        { system.stateVersion = "25.05"; }
      ];
    }).config;
in
{
  perSystem =
    { pkgs, ... }:
    {
      checks.eval-home-manager = pkgs.runCommand "eval-home-manager" { } ''
        ${assert cfg.home-manager.useGlobalPkgs; ""}
        ${assert cfg.home-manager.useUserPackages; ""}
        touch $out
      '';
    };
}
