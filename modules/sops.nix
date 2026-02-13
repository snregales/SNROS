{ inputs, ... }:
{
  flake.modules.nixos.sops =
    { ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops = {
        defaultSopsFile = ../secrets/secrets.yaml;
        defaultSopsFormat = "yaml";
        age = {
          keyFile = "/var/lib/sops-nix/key.txt";
          generateKey = false;
        };
      };
    };
}
