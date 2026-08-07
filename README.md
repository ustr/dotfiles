```sh
sh <(curl -L https://nixos.org/nix/install)
nix-shell -p git --run 'git clone https://github.com/ibrah-m/dotfiles' .config
nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- build --flake .config/nix
sudo ./result/sw/bin/darwin-rebuild switch --flake .config/nix
```
