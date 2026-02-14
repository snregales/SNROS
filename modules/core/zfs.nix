{
  flake.modules.nixos.zfs = {
    boot.supportedFilesystems = ["zfs"];
    boot.zfs.forceImportRoot = false;

    services.zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };
  };
}
