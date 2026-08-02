```sh
sh <(curl -L https://nixos.org/nix/install)
nix-shell -p git --run 'git clone https://github.com/ibrah-m/dotfiles'
nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- build --flake dotfiles/
sudo ./result/sw/bin/darwin-rebuild switch --flake dotfiles/
```
