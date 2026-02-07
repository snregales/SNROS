dev:
    zellij --layout .zellij/layouts/dev.kdl

build-vm:
    nix build .#nixosConfigurations.vm.config.system.build.vm

run-vm: build-vm
    ./result/bin/run-snros-vm-vm

update:
    nix flake update

fmt:
    nix fmt

check:
    nix flake check
