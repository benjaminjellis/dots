To create symlinks using stow (`sudo pacman -S stow`) run:

```
stow . -t ~/.config
```

To install some basic deps (linux only)

```
sudo pacman -S --needed - < packages.txt
```

then install paru (linux only)

```
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

Once paru is installed then install some basic paru deps (linux only)

```
paru -S --needed - < paru-packages.txt
```

Japanese romaji input on Arch + Hyprland uses Fcitx5 with Mozc:

```
sudo pacman -S --needed fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-mozc fcitx5-qt
```

This repo starts `fcitx5 -d` from Hyprland and sets the Fcitx environment
variables in `hypr/lua/settings.lua`. After installing, restart Hyprland, run
`fcitx5-configtool`, add Mozc, then switch input methods with `Ctrl+Space`.
