```sh
sh <(curl -L https://nixos.org/nix/install)
nix-shell -p git --run 'git clone https://github.com/ustr/dotfiles' .config
nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- build --flake .config/nix
sudo ./result/sw/bin/darwin-rebuild switch --flake .config/nix
```

## Pi

Pi settings and packages are declared in `nix/home/pi.nix`. The upstream
Home Manager Pi module is vendored in `nix/home/modules/pi-coding-agent.nix`
because our pinned Home Manager release does not include it.

Before the first switch, back up the existing unmanaged settings file
(Home Manager will refuse to overwrite it):

```sh
mv ~/.pi/agent/settings.json ~/.pi/agent/settings.json.pre-home-manager
```

Add new Nix files to Git before rebuilding so the flake can see them. Once
activated, change Pi settings in `nix/home/pi.nix`, not inside Pi. Credentials
and sessions remain unmanaged.
