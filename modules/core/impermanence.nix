{inputs, ...}: {
  flake.modules.nixos.impermanence = {...}: {
    imports = [inputs.impermanence.nixosModules.impermanence];

    fileSystems."/persist".neededForBoot = true;

    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/lib/sops-nix"
      ];
      files = [
        "/etc/machine-id"
      ];
    };
  };
}
