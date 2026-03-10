#!/usr/bin/env bash
# SNROS interactive installer
# Invoked via: curl -sSf https://raw.githubusercontent.com/snregales/snros/main/install.sh | sh -s -- [--dry-run] <host>
# Or directly: nix run github:snregales/snros#install -- [--dry-run] <host>
# --dry-run: generate prerequisites (SSH key, hardware config, secureboot keys) but skip disk wipe and nixos-install

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "error: this installer must be run as root (try: sudo $0 $*)" >&2
  exit 1
fi

# Ensure NixOS live ISO system tools are available alongside nix-provided runtimeInputs
export PATH="/run/current-system/sw/bin:${PATH}"

# Allow tests to inject a pre-populated clone directory (skips git clone)
CLONE_DIR="${SNROS_CLONE_DIR:-/tmp/snros}"

DRY_RUN=false
args=()
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    *) args+=("$arg") ;;
  esac
done
if [[ ${#args[@]} -gt 0 ]]; then
  set -- "${args[@]}"
else
  set --
fi

BOLD="\033[1m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

info()    { echo -e "${BOLD}==> $*${RESET}"; }
success() { echo -e "${GREEN}==> $*${RESET}"; }
warn()    { echo -e "${YELLOW}==> WARNING: $*${RESET}"; }
err()     { echo -e "${RED}==> ERROR: $*${RESET}" >&2; }

# --- Host selection ---
HOST="${1:-}"

if [[ -z "$HOST" ]]; then
  echo ""
  echo "Available hosts:"
  hosts=$(nix eval "github:snregales/snros#nixosConfigurations" \
    --apply 'x: builtins.concatStringsSep "\n" (builtins.attrNames x)' \
    --raw 2>/dev/null) && while IFS= read -r line; do echo "  $line"; done <<<"$hosts" || echo "  (could not enumerate hosts)"
  echo ""
  read -rp "Enter host name: " HOST < /dev/tty
fi

if [[ -z "$HOST" ]]; then
  err "No host specified."
  exit 1
fi

if $DRY_RUN; then
  info "[DRY RUN] Installing SNROS host: ${HOST}"
else
  info "Installing SNROS host: ${HOST}"
fi

# --- Clone repo ---
if [[ -n "${SNROS_CLONE_DIR:-}" ]]; then
  info "Using pre-populated repository at ${CLONE_DIR} (SNROS_CLONE_DIR is set)"
else
  info "Cloning repository to ${CLONE_DIR}..."
  if [[ -d "$CLONE_DIR" ]]; then
    warn "${CLONE_DIR} already exists — removing and re-cloning (any previously generated keys or configs will be lost)"
    rm -rf "$CLONE_DIR"
  fi
  git clone --depth 1 https://github.com/snregales/snros "$CLONE_DIR"
fi

# --- Activate devshell for 1Password/SOPS environment ---
if [[ -z "${SNROS_IN_DEVSHELL:-}" ]]; then
  info "Activating devshell in ${CLONE_DIR} for 1Password/SOPS integration..."
  cd "$CLONE_DIR"
  _install_args=("$HOST")
  $DRY_RUN && _install_args+=("--dry-run")
  exec nix develop \
    --command env \
    "SNROS_IN_DEVSHELL=1" \
    "SNROS_CLONE_DIR=${CLONE_DIR}" \
    bash "$(readlink -f "$0")" "${_install_args[@]}"
fi

# --- Validate host ---
# Host validation is skipped when SNROS_CLONE_DIR is set (test mode: no network available)
if [[ -z "${SNROS_CLONE_DIR:-}" ]]; then
  if ! nix eval "${CLONE_DIR}#nixosConfigurations.${HOST}" --apply 'x: "ok"' --raw &>/dev/null; then
    err "Host '${HOST}' not found in nixosConfigurations. Available hosts:"
    nix eval "${CLONE_DIR}#nixosConfigurations" \
      --apply 'x: builtins.concatStringsSep "\n" (builtins.attrNames x)' \
      --raw 2>/dev/null | while IFS= read -r line; do echo "  $line"; done || true
    exit 1
  fi
fi

# Prerequisites run in both normal and dry-run modes — config generation is safe and non-destructive.
# --- Prerequisite: hardware config ---
HW_CONFIG="${CLONE_DIR}/devices/${HOST}/hardware-configuration.nix"

if [[ ! -f "$HW_CONFIG" ]]; then
  info "Hardware config not found — generating..."
  mkdir -p "$(dirname "$HW_CONFIG")"
  nixos-generate-config --show-hardware-config > "$HW_CONFIG"
  success "Hardware config written to ${HW_CONFIG}"
fi

# --- Prerequisite: secureboot keys ---
SB_KEYS="${CLONE_DIR}/modules/hosts/${HOST}/persist/secureboot/keys"

if [[ ! -d "$SB_KEYS" ]]; then
  info "Secureboot keys not found — generating..."
  mkdir -p "${CLONE_DIR}/modules/hosts/${HOST}/persist/secureboot"
  sbctl create-keys --export "$SB_KEYS" --disable-landlock
  success "Secureboot keys generated"
  warn "Secureboot keys are in ${SB_KEYS} — back them up before rebooting (they will be lost when the live ISO shuts down)"
fi

# --- Disk confirmation ---
if $DRY_RUN; then
  info "[DRY RUN] Would show disk layout and prompt for confirmation"
else
  echo ""
  info "Disk layout — the following will be ERASED"
  echo ""
  lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
  echo ""
  read -rp "Type 'yes' to confirm disk wipe and continue: " CONFIRM < /dev/tty
  if [[ "$CONFIRM" != "yes" ]]; then
    err "Aborted."
    exit 1
  fi
fi

# --- Install ---
if $DRY_RUN; then
  info "[DRY RUN] Would run: disko --mode disko --flake ${CLONE_DIR}#${HOST}"
  info "[DRY RUN] Would run: nixos-install --flake ${CLONE_DIR}#${HOST} --no-root-passwd"
else
  info "Partitioning disk with disko..."
  disko --mode disko --flake "${CLONE_DIR}#${HOST}"

  # --- Stage SSH host key ---
  # Written to /persist (impermanence bind-mounts it on every boot) and also to the
  # root dataset directly (for activation scripts that run before impermanence).
  info "Generating SSH host key..."
  mkdir -p /mnt/persist/etc/ssh
  ssh-keygen -q -t ed25519 -f /mnt/persist/etc/ssh/ssh_host_ed25519_key -N "" -C "$HOST"
  chmod 600 /mnt/persist/etc/ssh/ssh_host_ed25519_key
  chmod 644 /mnt/persist/etc/ssh/ssh_host_ed25519_key.pub

  # --- Stage SOPS age key ---
  # sops-nix reads /var/lib/sops-nix/key.txt; /var/lib/sops-nix is an impermanence directory
  # so writing to /persist/var/lib/sops-nix makes it available after the bind-mount.
  # The admin age key is already a recipient in .sops.yaml so it can decrypt secrets.yaml.
  info "Staging SOPS age key..."
  _age_key=""

  if [[ -n "${SOPS_AGE_KEY:-}" ]]; then
    # Caller pre-fetched the key and exported it before sudo
    _age_key="$SOPS_AGE_KEY"
  elif [[ -n "${SUDO_USER:-}" ]] && [[ -n "${SOPS_AGE_KEY_CMD:-}" ]]; then
    # Running under sudo: invoke op as the original user so it reaches their GUI socket.
    # Redirect stdin to /dev/null so op cannot prompt interactively.
    _uid=$(id -u "$SUDO_USER")
    _socket="/run/user/${_uid}/com.1password/socket"
    # Prefer the system wrapper (/run/wrappers/bin/op) which has --socket-path baked in;
    # fall back to whichever op is on PATH.
    _op_bin="${_op_bin:-}"
    for _candidate in /run/wrappers/bin/op "$(command -v op 2>/dev/null)"; do
      [[ -x "${_candidate:-}" ]] && { _op_bin="$_candidate"; break; }
    done
    if [[ -n "$_op_bin" ]]; then
      _age_key=$(sudo -u "$SUDO_USER" \
        env "OP_SOCKET_PATH=${_socket}" "$_op_bin" \
        read op://snros/sops-age-key/notesPlain </dev/null 2>/dev/null) || true
    fi
  fi

  if [[ -z "${_age_key:-}" ]]; then
    warn "Could not retrieve SOPS age key automatically."
    echo ""
    echo "In a separate terminal, run as your normal user:"
    echo "  op read op://snros/sops-age-key/notesPlain"
    echo ""
    read -rsp "Paste the age key here (input hidden): " _age_key < /dev/tty
    echo ""
  fi

  if [[ -z "${_age_key:-}" ]]; then
    err "No SOPS age key provided — cannot continue."
    exit 1
  fi

  # sops.age.keyFile = "/persist/var/lib/sops-nix/key.txt" — direct persist path,
  # no impermanence bind-mount involved so no activation-ordering dependency.
  mkdir -p /mnt/persist/var/lib/sops-nix
  printf '%s\n' "$_age_key" > /mnt/persist/var/lib/sops-nix/key.txt
  chmod 600 /mnt/persist/var/lib/sops-nix/key.txt
  unset _age_key _uid _socket _op_bin

  # --- Stage secureboot keys ---
  # lanzaboote.pkiBundle = "/persist/secureboot"; keys were generated into the clone dir.
  info "Staging secureboot keys..."
  cp -r "${CLONE_DIR}/modules/hosts/${HOST}/persist/secureboot" /mnt/persist/

  info "Installing NixOS (this will take a while)..."
  nixos-install --flake "${CLONE_DIR}#${HOST}" --no-root-passwd
fi

# --- Done ---
echo ""
if $DRY_RUN; then
  success "[DRY RUN] Dry run complete — no disk changes were made"
else
  success "Installation complete!"
  echo ""
  echo -e "${BOLD}First boot — Secure Boot enrollment:${RESET}"
  echo "  1. Reboot into UEFI firmware (F2 on Dell)"
  echo "  2. Secure Boot: keep ENABLED, clear all keys → enters Setup Mode"
  echo "  3. Save and boot into NixOS, then run:"
  echo "       sudo sbctl enroll-keys --microsoft"
fi
echo ""
