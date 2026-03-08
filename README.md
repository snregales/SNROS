# SNROS

Sharlon's NixOS system configuration — a modular, declarative setup for Dell XPS laptops built with Nix Flakes.

## Features

- **Ephemeral root** via ZFS + impermanence — clean slate on every boot, persistent data under `/persist`
- **Secure Boot** via lanzaboote with sbctl
- **Home Manager** for fully declarative user environments
- **SOPS + age** for system secrets, **1Password** for user secrets
- **Niri** Wayland compositor with Stylix theming (Ayu Dark)
- **Neovim IDE** via nvf with LSP, treesitter, and debugger
- **ZFS** with zstd compression, auto-scrub, and trim
- **Zen kernel** with Plymouth boot splash

## Hosts

| Host | Hardware | GPU |
|------|----------|-----|
| `dell-xps-9500` | Dell XPS 15 9500 | Intel UHD + NVIDIA GTX 1650 Ti (PRIME offload) |
| `dell-xps-9640` | Dell XPS 16 9640 | Intel Arc + NVIDIA (PRIME offload) |

## Structure

```
devices/              # Per-host hardware (hardware-configuration.nix, generated)
modules/
├── hosts/            # Per-host machine definitions
├── core/             # System-level NixOS modules
├── drivers/          # GPU/CPU and VM driver modules
├── home/             # Home Manager modules (shell, apps, editor)
└── users/            # User account definitions
hosts/                # Generated host files: SSH keys, secureboot keys
lib/                  # Shared library functions
secrets/              # SOPS-encrypted secrets (age)
tests/                # Evaluation and integration tests
```

### Core modules

| Module | Purpose |
|--------|---------|
| `boot` | Zen kernel, systemd-boot, Plymouth, tmpfs `/tmp`, v4l2loopback |
| `networking` | NetworkManager + iwd backend, impala WiFi TUI, firewall |
| `impermanence` | Ephemeral root, `/persist` persistence |
| `lanzaboote` | Secure Boot (opt-in per host) |
| `disko` | Declarative disk partitioning (GPT + ZFS) |
| `zfs` | ZFS pool, auto-scrub and trim |
| `sops` | Encrypted secrets via age |
| `ssh` | OpenSSH server + 1Password SSH agent (home-manager) |
| `1password` | 1Password CLI + GUI with polkit |
| `biometrics` | Fingerprint auth via fprintd (Goodix TOD) |
| `desktop` | PipeWire, Bluetooth (blueman + bluetui), keyring, image previews |
| `syncthing` | File sync with persisted state and SOPS-managed GUI password |
| `variables` | Shared options (`snros.user.*`, `snros.hardware.gpu.*`) |

### Driver modules

| Module | Purpose |
|--------|---------|
| `intel` | Intel graphics, VA-API, microcode updates |
| `nvidia` | NVIDIA open driver, PRIME offload, fine-grained power management |
| `amd` | AMD graphics, AMDVLK, ROCm OpenCL, microcode updates |
| `vm-services` | QEMU guest agent + SPICE (VM builds only) |

### Home modules

**Shell:** `zsh`, `atuin`, `starship`, `bat`, `eza`, `fzf`, `yazi`, `zoxide`, `direnv`, `zellij`

**Apps:** `brave` (SponsorBlock, Google Translate, 1Password, Vimium C), `foot`, `niri`, `nvf`, `himalaya` (Gmail)

## Secrets philosophy

| Secret type | Tool | Examples |
|------------|------|---------|
| System secrets | SOPS + age | User password, Syncthing GUI password |
| User secrets | 1Password (`op read`) | Git signing key, Gmail password, WiFi PSK |

## Usage

### Prerequisites

- 1Password CLI (`op`) authenticated
- SOPS age key accessible via `$SOPS_AGE_KEY_CMD`

### Development

```sh
just dev               # Launch Zellij environment (editor + shell + VM)
just format-nix        # Format all Nix files with alejandra
just check-flake       # Run all checks and tests
just update-flake      # Update all flake inputs
just edit-secrets      # Decrypt and edit secrets.yaml
```

### VM testing

```sh
just build-vm <host>   # Build a VM image
just run-vm <host>     # Build and run VM (SOPS key injected automatically)
```

### Deployment

```sh
# One-time setup per host (run before install)
just gen-host-key <host>            # Generate SSH host key, prints age public key
just gen-secureboot-keys <host>     # Generate secure boot keys (if using lanzaboote)

# Fetch hardware config from a live NixOS ISO booted on the target
just gen-hardware-config <host> <ip>          # Generate (skips if exists)
just gen-hardware-config <host> <ip> true     # Force regenerate

# Install
just install <host> <ip>            # Deploy via nixos-anywhere (requires NixOS live on target)

# First boot (hosts with lanzaboote)
# 1. Reboot into UEFI firmware (F2 on Dell)
# 2. Secure Boot: keep ENABLED, but clear/delete all keys — this enters Setup Mode
# 3. Save and boot back into NixOS, then run:
sudo sbctl enroll-keys --microsoft  # Enroll your keys + Microsoft's into UEFI firmware
# 4. Reboot — Secure Boot is now active with your custom keys
```

**Live ISO prerequisites** (on the target machine):
1. `passwd` — set a root password
2. `ip addr` — note the IP address
3. WiFi (if needed): `iwctl station wlan0 connect <SSID>`

## Adding a new host

1. Boot the target from a NixOS installer ISO
2. Run `just gen-hardware-config <hostname> <ip>` to capture hardware info
3. Run `just gen-host-key <hostname>` — add the printed age key to `.sops.yaml`, then `just re-encrypt-secrets`
4. Create `modules/hosts/<hostname>/configuration.nix`:
   - Import `flake.modules.nixos.dell-xps` (or build a custom base)
   - Import hardware config via `lib/mkHardwareConfig.nix`
   - Set `networking.hostName`, `networking.hostId`
   - Import driver modules (`intel`, `nvidia`, `amd`)
   - Set GPU bus IDs from `lspci | grep -E "VGA|3D"` (convert `aa:bb.c` → `PCI:aa:bb:c`)
5. Run `just install <hostname> <ip>`

```nix
{config, ...}: let
  inherit (config) flake;
  mkHardwareConfig = import ../../../lib/mkHardwareConfig.nix;
in {
  configurations.nixos.my-host = {
    module = _: {
      imports = [
        (mkHardwareConfig ../../../devices/my-host/hardware-configuration.nix)
        flake.modules.nixos.dell-xps
        flake.modules.nixos.intel
      ];
      networking = {
        hostName = "my-host";
        hostId = "xxxxxxxx"; # head -c8 /etc/machine-id
      };
    };
  };
}
```
