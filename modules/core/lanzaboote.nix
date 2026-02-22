{inputs, ...}: {
  flake.modules.nixos.lanzaboote = {
    lib,
    pkgs,
    ...
  }: {
    imports = [inputs.lanzaboote.nixosModules.lanzaboote];

    environment.systemPackages = [pkgs.sbctl];

    boot = {
      loader = {
        systemd-boot.enable = lib.mkForce false;
      };

      lanzaboote = {
        enable = true;
        pkiBundle = "/persist/secureboot";
      };
    };
  };
}
