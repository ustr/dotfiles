#!/usr/bin/env bash
set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
flake="$repo/nix"
roots="${XDG_STATE_HOME:-$HOME/.local/state}/nix/roots"
mkdir -p "$roots"
git -C "$repo" symbolic-ref --quiet --short HEAD >/dev/null

nix flake update --flake "path:$flake"
vm_package=$(nix eval --raw "path:$flake#darwinConfigurations.macos.config.programs.nixos-macos-vm" \
  --apply 'cfg: if cfg.enable then cfg.package.outPath else ""')
if [[ -n $vm_package ]] && ! nix path-info "$vm_package" >/dev/null 2>&1; then
  vm_revision=$(NIXOS_VM_FLAKE_LOCK="$flake/flake.lock" nix eval --impure --raw --expr '
    let
      lock = builtins.fromJSON (builtins.readFile (builtins.getEnv "NIXOS_VM_FLAKE_LOCK"));
      root = builtins.getAttr lock.root lock.nodes;
      node = builtins.getAttr root.inputs.nixos-macos-vm lock.nodes;
    in node.locked.rev
  ')
  nix run "git+https://github.com/ustr/nixos-macos-vm?rev=$vm_revision#prefetch" -- "$vm_revision" "$vm_package"
fi
nix build "path:$flake#darwinConfigurations.macos.system" --out-link "$roots/darwin-system" "$@"
sudo "$roots/darwin-system/sw/bin/darwin-rebuild" activate
nix profile upgrade --all

if ! git -C "$repo" diff --quiet HEAD -- nix/flake.lock; then
  git -C "$repo" commit --only --allow-empty-message -m "" -- nix/flake.lock
fi
git -C "$repo" push
