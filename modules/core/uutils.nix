{
  flake.modules.nixos.uutils = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      uutils-coreutils-noprefix
      uutils-findutils
      uutils-diffutils
    ];
  };
}
