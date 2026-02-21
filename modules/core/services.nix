_: {
  flake.modules.nixos.services = _: {
    services = {
      libinput.enable = true; # Input Handling
      fstrim.enable = true; # SSD Optimizer
      gvfs.enable = true; # For Mounting USB & More
      openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };
    };
  };
}
