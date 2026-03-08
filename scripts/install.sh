#!/usr/bin/env bash
# SNROS interactive installer
# Invoked via: curl -sSf https://raw.githubusercontent.com/snregales/snros/main/install.sh | sh -s -- [--dry-run] <host>
# Or directly: nix run github:snregales/snros#install -- [--dry-run] <host>
# --dry-run: generate prerequisites (SSH key, hardware config, secureboot keys) but skip disk wipe and nixos-install

set -euo pipefail

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
  read -rp "Enter host name: " HOST
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

# --- Validate host ---
# Host validation is skipped when SNROS_CLONE_DIR is set (test mode: no network available)
if [[ -z "${SNROS_CLONE_DIR:-}" ]]; then
  if ! nix eval "${CLONE_DIR}#nixosConfigurations.${HOST}" --apply 'x: true' --raw &>/dev/null; then
    err "Host '${HOST}' not found in nixosConfigurations. Available hosts:"
    nix eval "${CLONE_DIR}#nixosConfigurations" \
      --apply 'x: builtins.concatStringsSep "\n" (builtins.attrNames x)' \
      --raw 2>/dev/null | while IFS= read -r line; do echo "  $line"; done || true
    exit 1
  fi
fi

# Prerequisites run in both normal and dry-run modes — key/config generation is safe and non-destructive.
# --- Prerequisite: SSH host key ---
HOST_KEY="${CLONE_DIR}/modules/hosts/${HOST}/etc/ssh/ssh_host_ed25519_key"

if [[ ! -f "$HOST_KEY" ]]; then
  info "SSH host key not found — generating..."
  mkdir -p "$(dirname "$HOST_KEY")"
  ssh-keygen -t ed25519 -f "$HOST_KEY" -N "" -C "$HOST"
  chmod 600 "$HOST_KEY"
  AGE_KEY=$(ssh-to-age < "${HOST_KEY}.pub")
  echo ""
  echo -e "${BOLD}Action required before continuing:${RESET}"
  echo ""
  echo "  Age public key for ${HOST}:"
  echo -e "  ${BOLD}${AGE_KEY}${RESET}"
  echo ""
  echo "  On your dev machine:"
  echo "    1. Add the age key above to .sops.yaml"
  echo "    2. Run:  just re-encrypt-secrets"
  echo "    3. Run:  git add modules/hosts/${HOST}/etc/ssh/ && git commit -m 'chore: add ${HOST} host key' && git push"
  echo "    4. Re-run this installer"
  echo ""
  exit 0
fi

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
  read -rp "Type 'yes' to confirm disk wipe and continue: " CONFIRM
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
