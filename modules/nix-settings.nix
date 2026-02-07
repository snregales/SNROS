{
  flake.modules.nixos.base = {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    nixpkgs.hostPlatform = "x86_64-linux";
    nixpkgs.config.allowUnfree = true;
  };
}
