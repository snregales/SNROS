{ config, inputs, ... }:
let
  inherit (config) flake;
  inherit (inputs.nixpkgs) lib;
  cfg =
    (lib.nixosSystem {
      modules = [
        flake.modules.nixos.base
        flake.modules.nixos.nix-index-database
        { system.stateVersion = "25.05"; }
      ];
    }).config;
in
{
  perSystem =
    { pkgs, ... }:
    {
      checks.eval-nix-index-database = pkgs.runCommand "eval-nix-index-database" { } ''
        ${assert cfg.programs.nix-index-database.comma.enable; ""}
        touch $out
      '';
    };
}
