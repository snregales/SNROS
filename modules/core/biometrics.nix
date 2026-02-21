# Facial recognition (howdy) was investigated for XPS 9500 and XPS 9640 but not added:
#
# - XPS 9500: IR camera hardware present, but not reliably detected by howdy out of the box.
#   Requires manual device configuration with no guarantee of stability.
#   See: https://lightrun.com/answers/boltgolt-howdy-dell-xps-9500-ir-camera-not-recognized
#
# - XPS 9640: IR camera present but Linux support is limited. The ArchWiki page makes no
#   mention of IR/facial recognition. The webcam (Intel IPU6) only works from kernel 6.17+,
#   and the IR camera has been reported broken after updates even on Windows.
#   See: https://wiki.archlinux.org/title/Dell_XPS_16_(9640)
#
# Fingerprint (fprintd) is used instead as it has solid Linux support on both models.
# Revisit facial recognition if kernel/driver support improves.
_: {
  flake.modules.nixos.biometrics = {pkgs, ...}: {
    systemd.services.fprintd = {
      wantedBy = ["multi-user.target"];
      serviceConfig.Type = "simple";
    };
    services.fprintd = {
      enable = true;
      tod = {
        enable = true;
        driver = pkgs.libfprint-2-tod1-goodix;
      };
    };
  };
}
