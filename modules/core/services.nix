_: {
  flake.modules.nixos.services = _: {
    services = {
      libinput.enable = true; # Input Handling
      fstrim.enable = true; # SSD Optimizer
      gvfs.enable = true; # For Mounting USB & More
    };
  };
}
