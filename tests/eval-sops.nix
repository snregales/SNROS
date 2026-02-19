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
        flake.modules.nixos.sops
        {system.stateVersion = "25.05";}
      ];
    }).config;
in {
  perSystem = {pkgs, ...}: {
    checks.eval-sops = pkgs.runCommand "eval-sops" {} ''
      ${assert cfg.sops.defaultSopsFormat == "yaml"; ""}
      ${assert cfg.sops.age.keyFile == "/var/lib/sops-nix/key.txt"; ""}
      ${assert !cfg.sops.age.generateKey; ""}
      touch $out
    '';
  };
}
