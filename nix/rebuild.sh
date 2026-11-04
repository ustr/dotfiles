#!/usr/bin/env bash
set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
flake="$repo/nix"
git -C "$repo" symbolic-ref --quiet --short HEAD >/dev/null

update=false
git_status=$(git -C "$repo" status --porcelain --untracked-files=all)
if [[ -z $git_status ]]; then
  update=true
  if [[ ${RB_PULLED_REPO:-} != "$repo" ]]; then
    git -C "$repo" pull --ff-only
    # Reload the script in case the pull updated it.
    RB_PULLED_REPO="$repo" exec bash "$repo/nix/rebuild.sh" "$@"
  fi
else
  echo "Working tree is dirty; skipping pull, flake/profile updates, commit, and push."
fi
unset RB_PULLED_REPO

roots="${XDG_STATE_HOME:-$HOME/.local/state}/nix/roots"
mkdir -p "$roots"

if [[ $update == true ]]; then
  nix flake update --flake "path:$flake"
fi
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
system=""
if [[ $# -eq 0 ]]; then
  system=$(nix eval --raw "path:$flake#darwinConfigurations.macos.system.outPath")
fi

if [[ -n $system && $system == "$(readlink /run/current-system || true)" ]]; then
  needs_activation=false
  brew_config=$(nix eval --json "path:$flake#darwinConfigurations.macos.config.homebrew" \
    --apply 'cfg: { inherit (cfg) enable prefix user brewfile; inherit (cfg.onActivation) autoUpdate upgrade cleanup extraEnv; }')

  if [[ $(jq -r '.enable' <<< "$brew_config") == true ]]; then
    brew="$(jq -r '.prefix' <<< "$brew_config")/bin/brew"
    if [[ ! -x $brew || $(jq -r '.user' <<< "$brew_config") != "$(id -un)" ]]; then
      needs_activation=true
    else
      brew_env=(HOMEBREW_NO_AUTO_UPDATE=1)
      while IFS= read -r -d '' entry; do
        brew_env+=("$entry")
      done < <(jq -j '.extraEnv | to_entries[] | "\(.key)=\(.value)\u0000"' <<< "$brew_config")
      run_brew() {
        env "${brew_env[@]}" HOMEBREW_NO_AUTO_UPDATE=1 "$brew" "$@"
      }

      if [[ $(jq -r '.autoUpdate' <<< "$brew_config") == true ]]; then
        run_brew update
      fi
      brewfile=$(mktemp "${TMPDIR:-/tmp}/rb-Brewfile.XXXXXX")
      trap 'rm -f "$brewfile"' EXIT
      jq -r '.brewfile' <<< "$brew_config" > "$brewfile"
      brew_check=(bundle check --file="$brewfile")
      if [[ $(jq -r '.upgrade' <<< "$brew_config") != true ]]; then
        brew_check+=(--no-upgrade)
      fi
      if ! run_brew "${brew_check[@]}" >/dev/null 2>&1; then
        needs_activation=true
      elif [[ $(jq -r '.cleanup' <<< "$brew_config") != none ]] &&
        ! run_brew bundle cleanup --file="$brewfile" </dev/null >/dev/null 2>&1; then
        needs_activation=true
      fi
      rm -f "$brewfile"
      trap - EXIT
    fi
  fi
else
  nix build "path:$flake#darwinConfigurations.macos.system" --out-link "$roots/darwin-system" "$@"
  system="$roots/darwin-system"
  needs_activation=true
fi

if [[ $needs_activation == true ]]; then
  sudo "$system/sw/bin/darwin-rebuild" activate
else
  echo "Nix system and Homebrew are current; skipping rebuild and activation."
fi
if [[ $update == true ]]; then
  nix profile upgrade --all

  if ! git -C "$repo" diff --quiet HEAD -- nix/flake.lock; then
    git -C "$repo" commit --only --allow-empty-message -m "" -- nix/flake.lock
  fi
  git -C "$repo" push
fi
