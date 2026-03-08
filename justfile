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
    #!/usr/bin/env bash
    key_dir=$(mktemp -d /run/user/$(id -u)/sops-vm.XXXXXX)
    trap "rm -rf $key_dir" EXIT
    $SOPS_AGE_KEY_CMD > "$key_dir/key.txt"
    SOPS_AGE_KEY_DIR="$key_dir" nixGLIntel ./result/bin/run-{{host}}-vm

# pull the latest versions of all flake inputs (nixpkgs, home-manager, etc.)
update-flake:
    nix flake update

# auto-format all nix files in the project using the configured formatter
format-nix:
    nix fmt

# evaluate the flake and run all checks (builds, tests, linting)
check-flake:
    nix flake check

# run the installer integration test in a NixOS VM (requires KVM)
test-installer:
    nix build .#checks.x86_64-linux.installer-dry-run -L

# generate a pre-install SSH host key for a host and print its age public key
# run once per host, then add the age key to .sops.yaml and re-encrypt secrets
gen-host-key host:
    #!/usr/bin/env bash
    set -euo pipefail
    key=modules/hosts/{{host}}/etc/ssh/ssh_host_ed25519_key
    if [ -f "$key" ]; then
      echo "Key already exists at $key — delete it first to regenerate"
      exit 1
    fi
    mkdir -p "$(dirname $key)"
    ssh-keygen -t ed25519 -f "$key" -N "" -C "{{host}}"
    chmod 600 "$key"
    age_key=$(ssh-to-age < "$key.pub")
    echo ""
    echo "Age public key for {{host}}:"
    echo "  $age_key"
    echo ""
    echo "Next steps:"
    echo "  1. Uncomment and fill in &{{host}} in .sops.yaml"
    echo "  2. just re-encrypt-secrets"
    echo "  3. git add hosts/{{host}}/etc/ssh/ssh_host_ed25519_key.pub"
    echo "  4. just install {{host}} <ip>"

# generate secure boot keys for a host using sbctl and store them in hosts/<host>/persist/secureboot
# run once per host, then run just install <host> <ip>
gen-secureboot-keys host:
    #!/usr/bin/env bash
    set -euo pipefail
    out="{{justfile_directory()}}/modules/hosts/{{host}}/persist/secureboot"
    if [ -d "$out/keys" ]; then
      echo "Secure boot keys already exist at $out — delete them first to regenerate"
      exit 1
    fi
    mkdir -p "$out"
    sbctl create-keys --export "$out/keys" --disable-landlock
    chown -R "$(stat -c '%U:%G' "{{justfile_directory()}}")" "$out"
    echo ""
    echo "Secure boot keys generated at $out"
    echo ""
    echo "Next steps:"
    echo "  1. just install {{host}} <ip>"
    echo "  2. After first boot, enroll keys: sbctl enroll-keys --microsoft"

# fetch hardware-configuration.nix from a target machine booted into a NixOS live environment
# outputs to modules/hosts/<host>/hardware-configuration.nix
# pass force=true to overwrite an existing file
gen-hardware-config host ip force="false":
    #!/usr/bin/env bash
    set -euo pipefail
    out="{{justfile_directory()}}/devices/{{host}}"
    file="$out/hardware-configuration.nix"
    if [ -f "$file" ] && [ "{{force}}" != "true" ]; then
      echo "hardware-configuration.nix already exists for {{host}}. Use 'just gen-hardware-config {{host}} {{ip}} true' to overwrite."
      exit 0
    fi
    mkdir -p "$out"
    ssh root@{{ip}} "nixos-generate-config --show-hardware-config" > "$file"
    echo "Hardware config written to $file"

# install NixOS on a target machine via SSH (requires a live Linux environment on the target)
# run just gen-host-key <host> and just gen-secureboot-keys <host> first
install host ip:
    nix run github:nix-community/nixos-anywhere -- \
      --extra-files modules/hosts/{{host}} \
      --flake .#{{host}} root@{{ip}}

# decrypt and open secrets.yaml in your editor for editing via sops
edit-secrets:
    sops secrets/secrets.yaml

# re-encrypt secrets.yaml via sops
re-encrypt-secrets:
    sops updatekeys secrets/secrets.yaml
