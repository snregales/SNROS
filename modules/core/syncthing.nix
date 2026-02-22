_: {
  flake.modules.nixos.syncthing = {config, ...}: {
    sops.secrets."syncthing-gui-password".owner = config.snros.user.username;

    services.syncthing = {
      enable = true;
      user = config.snros.user.username;
      openDefaultPorts = true;
      settings.gui.hashedPassword = config.sops.secrets."syncthing-gui-password".path;
    };

    environment.persistence."/persist".directories = [
      "/var/lib/syncthing"
    ];
  };
}
