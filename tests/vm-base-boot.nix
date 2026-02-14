{
  perSystem =
    { pkgs, ... }:
    {
      checks.vm-base-boot = pkgs.testers.runNixOSTest {
        name = "base-boot";
        nodes.machine =
          { ... }:
          {
            # Cannot import flake.modules.nixos.base directly: runNixOSTest
            # owns nixpkgs.config and nixpkgs.hostPlatform as read-only.
            # Inline the nix settings from base to verify they work at boot.
            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];
            system.stateVersion = "25.05";
          };
        testScript = ''
          machine.wait_for_unit("multi-user.target")
          machine.succeed("nix --version")
        '';
      };
    };
}
