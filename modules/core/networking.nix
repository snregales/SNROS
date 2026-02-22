_: {
  flake.modules.nixos.networking = {pkgs, ...}: {
    environment.systemPackages = [pkgs.impala];

    networking = {
      networkmanager = {
        enable = true;
        wifi.backend = "iwd";
      };
      wireless.iwd = {
        enable = true;
        settings.General.EnableNetworkConfiguration = true;
      };
      firewall = {
        enable = true;
        allowedTCPPorts = [22 80 443 8080];
        allowedUDPPorts = [];
      };
    };
  };
}
