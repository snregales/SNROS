dev:
    zellij --layout .zellij/layouts/dev.kdl

build-vm:
    nix build .#nixosConfigurations.vm.config.system.build.vm

run-vm: build-vm
    SOPS_AGE_KEY_DIR="$PWD/secrets/vm-key" nixGLIntel ./result/bin/run-snros-vm-vm

build-dell-xps-9640:
    nix build .#nixosConfigurations.dell-xps-9640.config.system.build.vm

run-dell-xps-9640: build-dell-xps-9640
    SOPS_AGE_KEY_DIR="$PWD/secrets/vm-key" nixGLIntel ./result/bin/run-dell-xps-9640-vm

update:
    nix flake update

fmt:
    nix fmt

check:
    nix flake check

edit-secrets:
    sops secrets/secrets.yaml
