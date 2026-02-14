{ config, inputs, ... }:
let
  inherit (config) flake;
  inherit (inputs.nixpkgs) lib;
  cfg =
    (lib.nixosSystem {
      modules = [
        flake.modules.nixos.base
        flake.modules.nixos.sops
        flake.modules.nixos.niri
        flake.modules.nixos.snros
        { system.stateVersion = "25.05"; }
      ];
    }).config;
in
{
  perSystem =
    { pkgs, ... }:
    {
      checks.eval-snros-user = pkgs.runCommand "eval-snros-user" { } ''
        ${assert cfg.users.mutableUsers == false; ""}
        ${assert cfg.users.users.snros.isNormalUser; ""}
        ${assert builtins.elem "wheel" cfg.users.users.snros.extraGroups; ""}
        touch $out
      '';
    };
}
