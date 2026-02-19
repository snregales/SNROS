{
  flake.modules.nixos.base = {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];
    nixpkgs.hostPlatform = "x86_64-linux";
    nixpkgs.config.allowUnfree = true;
  };
}
