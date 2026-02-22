_: {
  flake.modules.nixos.vm-services = _: {
    services = {
      qemuGuest.enable = true;
      spice-vdagentd.enable = true;
    };
    virtualisation.spiceUSBRedirection.enable = true;
  };
}
