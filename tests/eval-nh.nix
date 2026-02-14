{ config, inputs, ... }:
let
  inherit (config) flake;
  inherit (inputs.nixpkgs) lib;
  cfg =
    (lib.nixosSystem {
      modules = [
        flake.modules.nixos.base
        flake.modules.nixos.nh
        { system.stateVersion = "25.05"; }
      ];
    }).config;
in
{
  perSystem =
    { pkgs, ... }:
    {
      checks.eval-nh = pkgs.runCommand "eval-nh" { } ''
        ${assert cfg.programs.nh.enable; ""}
        ${assert cfg.environment.shellAliases.ns == "nh os switch"; ""}
        ${assert cfg.environment.shellAliases.nb == "nh os boot"; ""}
        ${assert cfg.environment.shellAliases.nt == "nh os test"; ""}
        ${assert cfg.environment.shellAliases.nu == "nh os switch --update"; ""}
        touch $out
      '';
    };
}
