{inputs, ...}: {
  flake.modules.nixos.sops = _: {
    imports = [inputs.sops-nix.nixosModules.sops];

    sops = {
      defaultSopsFile = ../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
      age = {
        sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        keyFile = "/persist/var/lib/sops-nix/key.txt";
        generateKey = false;
      };
    };
  };
}
