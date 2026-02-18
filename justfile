# list available recipes
default:
    @echo "SNROS - NixOS Configuration Management"
    @echo "Available hosts: $(nix eval .#nixosConfigurations --apply 'x: builtins.concatStringsSep ", " (builtins.attrNames x)' --raw)"
    @echo ""
    @just --list
    @echo ""
    @echo "Examples:"
    @echo "  just build-vm vm"
    @echo "  just run-vm dell-xps-9640"

# open the development environment using the zellij terminal multiplexer
dev:
    zellij --layout .zellij/layouts/dev.kdl

# compile a NixOS virtual machine image for the given host configuration
build-vm host:
    nix build .#nixosConfigurations.{{host}}.config.system.build.vm

# build then launch a NixOS VM
run-vm host: (build-vm host)
    SOPS_AGE_KEY_DIR="$PWD/secrets/vm-key" nixGLIntel ./result/bin/run-{{host}}-vm

# pull the latest versions of all flake inputs (nixpkgs, home-manager, etc.)
update-flake:
    nix flake update

# auto-format all nix files in the project using the configured formatter
format-nix:
    nix fmt

# evaluate the flake and run all checks (builds, tests, linting)
check-flake:
    nix flake check

# install NixOS on a target machine via SSH (requires a live Linux environment on the target)
install host ip:
    nix run github:nix-community/nixos-anywhere -- --flake .#{{host}} root@{{ip}}

# decrypt and open secrets.yaml in your editor for editing via sops
edit-secrets:
    sops secrets/secrets.yaml
