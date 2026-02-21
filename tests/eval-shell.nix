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
        flake.modules.nixos.home-manager
        {
          system.stateVersion = "25.05";
          users.users.test.isNormalUser = true;
          home-manager.users.test = {
            imports = with flake.modules.homeManager; [
              atuin
              bat
              direnv
              eza
              fzf
              git
              starship
              yazi
              zellij
              zoxide
              zsh
            ];
            home.stateVersion = "25.05";
          };
        }
      ];
    }).config;
  hmCfg = cfg.home-manager.users.test;
in {
  perSystem = {pkgs, ...}: {
    checks.eval-shell = pkgs.runCommand "eval-shell" {} ''
      ${assert hmCfg.programs.atuin.enable; ""}
      ${assert hmCfg.programs.bat.enable; ""}
      ${assert hmCfg.programs.direnv.enable; ""}
      ${assert hmCfg.programs.eza.enable; ""}
      ${assert hmCfg.programs.fzf.enable; ""}
      ${assert hmCfg.programs.git.enable; ""}
      ${assert hmCfg.programs.starship.enable; ""}
      ${assert hmCfg.programs.yazi.enable; ""}
      ${assert hmCfg.programs.zellij.enable; ""}
      ${assert hmCfg.programs.zoxide.enable; ""}
      ${assert hmCfg.programs.zsh.enable; ""}
      touch $out
    '';
  };
}
