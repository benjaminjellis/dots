
When clodning use the `--recursive` flag

```
git clone git@github.com:benjaminjellis/dots.git --recursive
```

To create symlinks using stow (`sudo pacman -S stow`) run:

```
stow . -t ~/.config
```

to update all submodules run:

```
git submodule update --remote
```

