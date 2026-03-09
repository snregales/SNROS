# SNROS

> Sharlon's NixOS flake config for Dell XPS laptops — ephemeral root, sops-nix,
> and flake-parts.

[![NixOS Unstable](https://img.shields.io/badge/NixOS-unstable-5277C3?logo=nixos&logoColor=white)](https://nixos.org)

## Hosts

| Host            | Hardware         | GPU                                                |
| --------------- | ---------------- | -------------------------------------------------- |
| `dell-xps-9500` | Dell XPS 15 9500 | Intel UHD 630 + NVIDIA GTX 1650 Ti (PRIME offload) |
| `dell-xps-9640` | Dell XPS 16 9640 | Intel Arc Xe-LPG + NVIDIA (PRIME offload)          |

## Installation

### Prerequisites

- [Nix](https://nixos.org/download) with flakes enabled — add to
  `/etc/nix/nix.conf` or `~/.config/nix/nix.conf`:

  ```nix
  experimental-features = nix-command flakes pipe-operators
  ```

- [1Password CLI](https://developer.1password.com/docs/cli/) (`op`)
  authenticated
- SOPS age key accessible — in the dev shell, `$SOPS_AGE_KEY_CMD` reads it from
  1Password automatically

### Curl install (live ISO)

The fastest path from bare metal to a running system. Boot the target from a
[NixOS live ISO](https://nixos.org/download), then run:

```sh
curl -sSf https://raw.githubusercontent.com/snregales/snros/main/install.sh | sudo sh -s -- <host>
```

The installer will:

1. Generate hardware config automatically if not already in the repo
2. Generate secureboot keys if not already in the repo
3. Confirm the disk to wipe, then run disko and `nixos-install`

### Remote install (nixos-anywhere)

The primary path for deploying to a bare-metal machine. Requires the target to
be booted into a NixOS live ISO.

**On the target (live ISO):**

```sh
# Authorize your SSH key (root password auth is disabled in the config)
mkdir -p /root/.ssh
echo "ssh-ed25519 AAAA... your-key" >> /root/.ssh/authorized_keys

ip addr                                  # note the IP
systemctl start sshd                     # if not already running
iwctl station wlan0 connect <SSID>       # WiFi, if needed
```

**One-time setup per new host (run from your dev machine):**

```sh
just gen-host-key <host>             # generates SSH host key, prints age public key
# → add the printed age key to .sops.yaml, then:
just re-encrypt-secrets

just gen-secureboot-keys <host>      # generates lanzaboote secure boot keys
just gen-hardware-config <host> <ip> # fetches hardware-configuration.nix from target
```

**Deploy:**

```sh
just deploy <host> <ip>
```

**First boot (hosts with lanzaboote):**

1. Reboot into UEFI firmware (F2 on Dell)
2. Secure Boot: keep **enabled**, clear all keys → enters Setup Mode
3. Save and boot into NixOS, then:

```sh
sudo sbctl enroll-keys --microsoft
```

### Existing NixOS system

If NixOS is already installed on the target, clone the repo and switch:

```sh
git clone https://github.com/snregales/snros
cd snros
nix develop                              # enter dev shell
sudo nixos-rebuild switch --flake .#<host>
```

> The SOPS age key must be present at `/var/lib/sops-nix/key.txt` or derivable
> from the SSH host key at `/etc/ssh/ssh_host_ed25519_key`. On first activation,
> `sops-nix` generates the age key automatically from the host SSH key.

### VM (local testing)

Builds and launches a QEMU VM for any host. Useful for testing configuration
changes without touching hardware.

```sh
nix develop                              # dev shell required
just run-vm <host>                       # builds VM image, then launches it
```

The VM variant disables disko, impermanence, and biometrics. `just run-vm`
automatically injects the SOPS age key (read from 1Password via
`$SOPS_AGE_KEY_CMD`) into the VM via a shared directory — do not launch the VM
binary directly. Requires `nixGLIntel` (included in the dev shell) for
GPU-accelerated rendering.

The installer script also supports a `--dry-run` flag that skips disk
partitioning and NixOS installation while running all other steps (key
generation, hardware detection):

```sh
nix run github:snregales/snros#install -- --dry-run <host>
```

## Project Structure

```
.
├── devices/          # Per-host generated hardware configs (outside module tree)
├── docs/             # Design documents and implementation plans
├── lib/              # Shared Nix functions (imported directly by path)
├── modules/
│   ├── core/         # System-level NixOS modules
│   ├── drivers/      # GPU and VM driver modules
│   ├── home/         # Home Manager modules (shell, apps, editor)
│   ├── hosts/        # Per-host machine definitions
│   └── users/        # User account definitions
├── secrets/          # SOPS-encrypted secrets
└── tests/            # Nixt evaluation and integration tests
```

### Dendritic pattern

`flake.nix` uses [`import-tree`](https://github.com/vic/import-tree) to
automatically load every `.nix` file under `modules/` and `tests/`. There is no
central imports list — placing a file in `modules/` is sufficient to activate
it. `devices/` and `lib/` live outside this tree intentionally: hardware configs
are generated and never manually edited; library functions are imported by
relative path.

### Module conventions

Each module registers itself on the flake under `flake.modules.nixos.<name>`:

```nix
_: {
  flake.modules.nixos.my-module = { pkgs, ... }: {
    # NixOS module options here
  };
}
```

Hosts compose modules explicitly by importing from `flake.modules.nixos.*`.
Nothing is implicit — every module in a host's configuration is a deliberate
choice.

The `configurations.nixos.<hostname>` option (defined in
`modules/hosts/nixos.nix`) converts host definitions into
`flake.nixosConfigurations` entries automatically.

## Development

### Entering the shell

```sh
nix develop
```

The dev shell provides: `alejandra`, `nil`, `just`, `sops`, `age`, `ssh-to-age`,
`sbctl`, `fzf`, `yazi`, `zellij`, `comma`, `nixGLIntel`, and a pre-configured
Neovim with LSP and the Ayu Dark theme. Pre-commit hooks are installed
automatically on shell entry.

Alternatively, launch the full Zellij layout (editor + shell panes):

```sh
just dev
```

### Available recipes

```sh
just               # list all recipes with descriptions
just format-nix    # format all .nix files with alejandra
just check-flake   # evaluate flake and run all checks
just update-flake  # update all flake inputs
just edit-secrets  # decrypt and edit secrets/secrets.yaml via sops
just re-encrypt-secrets  # re-encrypt after key changes
```

### Pre-commit hooks

Hooks run automatically on `git commit`:

| Hook        | Purpose                                   |
| ----------- | ----------------------------------------- |
| `alejandra` | Nix formatter — enforces consistent style |
| `nil`       | Nix LSP — catches type errors             |
| `statix`    | Nix linter — flags anti-patterns          |
| `deadnix`   | Removes unused bindings                   |

## Philosophy

### Erasing Your Darlings

The root filesystem (`/`) is a ZFS dataset that is rolled back to a blank
snapshot on every boot. Nothing survives reboot unless it is explicitly declared
in the impermanence configuration under `/persist`.

This forces intentionality about state: if something matters, it must be named.
Configuration drift, forgotten dotfiles, and accumulated cruft are structurally
impossible. The cost is having to think once about what to keep. The benefit is
a system that behaves the same on day one and day one thousand.

Persisted paths are declared in `modules/core/impermanence.nix`. Per-user
persistence is managed by Home Manager.

### ZFS

Disk layout is managed by [`disko`](https://github.com/nix-community/disko): a
GPT disk with a 512M FAT32 EFI partition and a ZFS pool (`rpool`) filling the
remainder. The pool uses `zstd` compression, `ashift=12`, and `autotrim`.

Datasets are separated by durability:

| Dataset              | Mount      | Survives reboot              |
| -------------------- | ---------- | ---------------------------- |
| `rpool/local/root`   | `/`        | No — rolled back to `@blank` |
| `rpool/local/nix`    | `/nix`     | Yes                          |
| `rpool/safe/home`    | `/home`    | Yes                          |
| `rpool/safe/persist` | `/persist` | Yes                          |

### Secrets

Two-tier secrets model:

| Type           | Tool                  | Examples                                     |
| -------------- | --------------------- | -------------------------------------------- |
| System secrets | SOPS + age            | User password hash, Syncthing GUI password   |
| User secrets   | 1Password (`op read`) | Git signing key, WiFi PSK, Gmail credentials |

System secrets are encrypted with age keys derived from SSH host keys. Rotating
or adding a host requires running `just gen-host-key <host>` and re-encrypting
with `just re-encrypt-secrets`. No plaintext secrets exist in the repository.

### Modularity

Configuration is composed, not inherited. The `dell-xps` base module assembles a
set of named modules from `flake.modules.nixos.*` — including secure boot via
Lanzaboote, ZFS, and impermanence. Each host then imports that base and adds
only what differs: hardware config, GPU bus IDs, and host-specific SSH keys.

## Contributing

### Adding a new host

1. Boot the target from a NixOS installer ISO and set up SSH access (see
   [Remote install](#remote-install-nixos-anywhere))
2. `just gen-hardware-config <host> <ip>` — captures hardware config to
   `devices/<host>/hardware-configuration.nix`
3. `just gen-host-key <host>` — generates SSH host key, prints the age public
   key. Add it to `.sops.yaml`, then run `just re-encrypt-secrets`
4. `just gen-secureboot-keys <host>` — generates lanzaboote secure boot keys
5. Create `modules/hosts/<host>/configuration.nix`:

```nix
{config, ...}: let
  inherit (config) flake;
  mkHardwareConfig = import ../../../lib/mkHardwareConfig.nix;
in {
  configurations.nixos.<host> = {
    module = _: {
      imports = [
        (mkHardwareConfig ../../../devices/<host>/hardware-configuration.nix)
        flake.modules.nixos.dell-xps
        flake.modules.nixos.intel
        flake.modules.nixos.nvidia  # if applicable
      ];
      networking = {
        hostName = "<host>";
        hostId = "<8 hex chars from: head -c8 /etc/machine-id>";
      };
      snros.user.sshPublicKeys = [
        "<your SSH public key>"  # required — password auth is disabled
      ];
      snros.hardware.gpu = {
        intel.busId = "PCI:0:2:0";   # from: lspci | grep -E "VGA|3D"
        nvidia.busId = "PCI:1:0:0";  # convert aa:bb.c → PCI:aa:bb:c
      };
    };
  };
}
```

6. `just deploy <host> <ip>`

### Adjusting the development shell

The dev shell is defined in `modules/devshell.nix`. To add a package, append it
to the existing `packages` list inside `mkShell`. The list uses `++` to
concatenate nixpkgs packages with flake-sourced ones — add new nixpkgs tools to
the first segment:

```nix
packages = with pkgs;
  [
    # existing tools ...
    my-new-tool   # ← add here
  ]
  ++ [
    # flake-sourced tools (comma, nixGLIntel, neovim) — leave unchanged
  ];
```

To add a pre-commit hook, extend `pre-commit.settings.hooks` in the same file.
Available hooks are listed in the
[git-hooks.nix documentation](https://github.com/cachix/git-hooks.nix).

## License

MIT — see [LICENSE](LICENSE).
