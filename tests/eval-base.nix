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
        {system.stateVersion = "25.05";}
      ];
    }).config;
in {
  perSystem = {pkgs, ...}: {
    checks.eval-base = pkgs.runCommand "eval-base" {} ''
      ${
        let
          features = cfg.nix.settings.experimental-features;
        in
          assert builtins.elem "nix-command" features;
          assert builtins.elem "flakes" features; ""
      }
      ${assert cfg.nixpkgs.config.allowUnfree; ""}
      ${assert cfg.nixpkgs.hostPlatform.system == "x86_64-linux"; ""}
      touch $out
    '';
  };
}
