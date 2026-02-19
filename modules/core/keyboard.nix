_: {
  flake.modules.nixos.keyboard = {pkgs, ...}: {
    console.keyMap = "dvorak";
    services.xserver.xkb = {
      layout = "us";
      variant = "dvorak-classic";
    };
    environment.systemPackages = with pkgs; [
      keymapp # ZSA keyboard tooling
    ];
    hardware.keyboard = {
      zsa.enable = true;
      qmk.enable = true;
    };
  };
}
