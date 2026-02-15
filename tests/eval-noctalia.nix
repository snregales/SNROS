{ config, inputs, ... }:
let
  inherit (config) flake;
  inherit (inputs.nixpkgs) lib;
  cfg =
    (lib.nixosSystem {
      modules = [
        flake.modules.nixos.base
        flake.modules.nixos.noctalia
        { system.stateVersion = "25.05"; }
      ];
    }).config;
in
{
  perSystem =
    { pkgs, ... }:
    {
      checks.eval-noctalia = pkgs.runCommand "eval-noctalia" { } ''
        ${assert cfg.services.noctalia-shell.enable; ""}
        touch $out
      '';
    };
}
