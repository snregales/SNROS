{ config, ... }:
{
  configurations.nixos.vm = {
    module = {
      imports = with config.flake.modules.nixos; [
        base
      ];

      networking.hostName = "snros-vm";

      virtualisation.vmVariant = {
        virtualisation = {
          memorySize = 2048;
          cores = 2;
          diskSize = 4096;
        };
      };

      users.users.snros = {
        isNormalUser = true;
        initialPassword = "nixos";
        extraGroups = [ "wheel" ];
      };

      system.stateVersion = "25.05";
    };
  };
}
