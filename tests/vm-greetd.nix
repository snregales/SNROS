{ config, ... }:
let
  inherit (config) flake;
in
{
  perSystem =
    { pkgs, ... }:
    {
      checks.vm-greetd = pkgs.testers.runNixOSTest {
        name = "greetd";
        nodes.machine =
          { ... }:
          {
            imports = [ flake.modules.nixos.greetd ];
            system.stateVersion = "25.05";
          };
        testScript = ''
          machine.wait_for_unit("multi-user.target")
          machine.succeed("systemctl is-enabled greetd.service")
        '';
      };
    };
}
