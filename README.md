To create symlinks using stow (`sudo pacman -S stow`) run:

```
stow . -t ~/.config
```

to set up required dirs run

```
sh init.sh
```

To install some basic deps

```
sudo pacman -S --needed - < packages.txt
```

then install paru

```
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

Once paru is installed then install some basic paru deps

```
paru -S --needed - < paru-packages.txt
```
