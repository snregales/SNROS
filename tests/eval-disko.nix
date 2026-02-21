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
        flake.modules.nixos.disko
        {system.stateVersion = "25.05";}
      ];
    }).config;
  disko = cfg.disko.devices;
in {
  perSystem = {pkgs, ...}: {
    checks.eval-disko = pkgs.runCommand "eval-disko" {} ''
      ${assert disko.disk.main.type == "disk"; ""}
      ${assert disko.zpool.rpool.type == "zpool"; ""}
      ${assert disko.zpool.rpool.datasets ? "local/root"; ""}
      ${assert disko.zpool.rpool.datasets ? "local/nix"; ""}
      ${assert disko.zpool.rpool.datasets ? "safe/home"; ""}
      ${assert disko.zpool.rpool.datasets ? "safe/persist"; ""}
      ${assert disko.zpool.rpool.datasets."local/root".mountpoint == "/"; ""}
      touch $out
    '';
  };
}
