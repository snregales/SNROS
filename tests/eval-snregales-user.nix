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
        flake.modules.nixos.snregales
        { system.stateVersion = "25.05"; }
      ];
    }).config;
in
{
  perSystem =
    { pkgs, ... }:
    {
      checks.eval-snregales-user = pkgs.runCommand "eval-snregales-user" { } ''
        ${assert cfg.users.mutableUsers == false; ""}
        ${assert cfg.users.users.snregales.isNormalUser; ""}
        ${assert builtins.elem "wheel" cfg.users.users.snregales.extraGroups; ""}
        touch $out
      '';
    };
}
