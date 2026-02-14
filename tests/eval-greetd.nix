{ config, inputs, ... }:
let
  inherit (config) flake;
  inherit (inputs.nixpkgs) lib;
  cfg =
    (lib.nixosSystem {
      modules = [
        flake.modules.nixos.base
        flake.modules.nixos.greetd
        { system.stateVersion = "25.05"; }
      ];
    }).config;
in
{
  perSystem =
    { pkgs, ... }:
    {
      checks.eval-greetd = pkgs.runCommand "eval-greetd" { } ''
        ${assert cfg.services.greetd.enable; ""}
        ${assert builtins.isString cfg.services.greetd.settings.default_session.command; ""}
        ${assert lib.hasInfix "tuigreet" cfg.services.greetd.settings.default_session.command; ""}
        ${assert cfg.services.greetd.settings.default_session.user == "greeter"; ""}
        touch $out
      '';
    };
}
