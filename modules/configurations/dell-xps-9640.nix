{config, ...}: let
  inherit (config) flake;
in {
  configurations.nixos.dell-xps-9640 = {
    module = _: {
      imports = [
        flake.modules.nixos.dell-xps
      ];

      networking.hostName = "dell-xps-9640";
      networking.hostId = "22770b28";
    };
  };
}
