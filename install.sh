#!/usr/bin/env bash
# SNROS curl bootstrap
# Usage: curl -sSf https://raw.githubusercontent.com/snregales/snros/main/install.sh | sh -s -- <host>
set -euo pipefail

if ! command -v nix &>/dev/null; then
  echo "error: nix is not available. Boot from a NixOS live ISO." >&2
  exit 1
fi

exec nix run --refresh github:snregales/snros#install -- "$@"
