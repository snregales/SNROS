#!/usr/bin/env bash
# SNROS interactive installer
# Invoked via: curl -sSf https://raw.githubusercontent.com/snregales/snros/main/install.sh | sh -s -- <host>
# Or directly: nix run github:snregales/snros#install -- <host>

set -euo pipefail

# Ensure NixOS live ISO system tools are available alongside nix-provided runtimeInputs
export PATH="/run/current-system/sw/bin:${PATH}"

CLONE_DIR="/tmp/snros"
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
    --raw 2>/dev/null) && echo "$hosts" | sed 's/^/  /' || echo "  (could not enumerate hosts)"
  echo ""
  read -rp "Enter host name: " HOST
fi

if [[ -z "$HOST" ]]; then
  err "No host specified."
  exit 1
fi

info "Installing SNROS host: ${HOST}"

# --- Clone repo ---
info "Cloning repository to ${CLONE_DIR}..."
if [[ -d "$CLONE_DIR" ]]; then
  warn "${CLONE_DIR} already exists — removing and re-cloning (any previously generated keys or configs will be lost)"
  rm -rf "$CLONE_DIR"
fi
git clone --depth 1 https://github.com/snregales/snros "$CLONE_DIR"

# --- Validate host ---
if ! nix eval "${CLONE_DIR}#nixosConfigurations.${HOST}" --apply 'x: true' --raw &>/dev/null; then
  err "Host '${HOST}' not found in nixosConfigurations. Available hosts:"
  nix eval "${CLONE_DIR}#nixosConfigurations" \
    --apply 'x: builtins.concatStringsSep "\n" (builtins.attrNames x)' \
    --raw 2>/dev/null | sed 's/^/  /' || true
  exit 1
fi

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

# --- Install ---
info "Partitioning disk with disko..."
disko --mode disko --flake "${CLONE_DIR}#${HOST}"

info "Installing NixOS (this will take a while)..."
nixos-install --flake "${CLONE_DIR}#${HOST}" --no-root-passwd

# --- Done ---
echo ""
success "Installation complete!"
echo ""
echo -e "${BOLD}First boot — Secure Boot enrollment:${RESET}"
echo "  1. Reboot into UEFI firmware (F2 on Dell)"
echo "  2. Secure Boot: keep ENABLED, clear all keys → enters Setup Mode"
echo "  3. Save and boot into NixOS, then run:"
echo "       sudo sbctl enroll-keys --microsoft"
echo ""
