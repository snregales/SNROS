_: {
  flake.modules.nixos.desktop = _: {
    services = {
      blueman.enable = true; # Bluetooth Support
      tumbler.enable = true; # Image/video preview
      gnome.gnome-keyring.enable = true;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
    };
  };
}
