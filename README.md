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
