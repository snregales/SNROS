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
| `dell-xps-9640` | Dell XPS 16 9640 | Intel Arc (integrated) |

## Structure

```
modules/
├── configurations/   # Per-host machine definitions
├── core/             # System-level NixOS modules
├── drivers/          # GPU/CPU and VM driver modules
├── home/             # Home Manager modules (shell, apps, editor)
└── users/            # User account definitions
secrets/              # SOPS-encrypted secrets (age)
tests/                # Evaluation and integration tests
lib/                  # Shared library (Neovim config)
```

### Core modules

| Module | Purpose |
|--------|---------|
| `boot` | Zen kernel, systemd-boot, Plymouth, tmpfs `/tmp`, v4l2loopback |
| `networking` | NetworkManager + iwd backend, impala WiFi TUI, firewall |
| `impermanence` | Ephemeral root, `/persist` persistence |
| `lanzaboote` | Secure Boot |
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
just install <host> <ip>   # Deploy to target via SSH (requires live Linux on target)
```

## Adding a new host

1. Create `modules/configurations/<hostname>.nix`
2. Import `flake.modules.nixos.dell-xps` (or build a custom base)
3. Set `networking.hostName`, `networking.hostId`, and `snros.user.*`
4. Import the appropriate driver modules (`intel`, `nvidia`, `amd`)
5. Set GPU bus IDs from `lspci | grep -E "VGA|3D"` (convert `aa:bb.c` → `PCI:aa:bb:c`)
6. List `boot.initrd.availableKernelModules` for the hardware

```nix
configurations.nixos.my-host = {
  module = _: {
    imports = [
      flake.modules.nixos.dell-xps
      flake.modules.nixos.intel
    ];
    networking.hostName = "my-host";
    networking.hostId = "xxxxxxxx"; # head -c8 /etc/machine-id
    snros.user = {
      username = "myuser";
      name = "Full Name";
      email = "email@example.com";
      sshPublicKeys = [ "ssh-ed25519 ..." ];
    };
    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" ];
  };
};
```
