{ config, inputs, ... }:
let
  inherit (config) flake;
  inherit (inputs.nixpkgs) lib;
  cfg =
    (lib.nixosSystem {
      modules = [
        flake.modules.nixos.base
        flake.modules.nixos.impermanence
        { system.stateVersion = "25.05"; }
      ];
    }).config;
  persist = cfg.environment.persistence."/persist";
  dirPaths = persist.directories |> map (d: d.directory);
  filePaths = persist.files |> map (f: f.filePath);
in
{
  perSystem =
    { pkgs, ... }:
    {
      checks.eval-impermanence = pkgs.runCommand "eval-impermanence" { } ''
        ${assert cfg.fileSystems."/persist".neededForBoot; ""}
        ${assert persist.hideMounts; ""}
        ${assert builtins.elem "/var/log" dirPaths; ""}
        ${assert builtins.elem "/var/lib/nixos" dirPaths; ""}
        ${assert builtins.elem "/etc/machine-id" filePaths; ""}
        touch $out
      '';
    };
}
