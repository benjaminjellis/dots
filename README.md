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
