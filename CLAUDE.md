# dotfiles

## GNU Stow packages

- Most dotfiles in this repo are managed as stow packages.
- Read `.stowrc` at the depot root for default stow flags.
- Each package's `dot-config/` maps to `~/.config/`,
  e.g. `~/.config/niri/config.kdl` is a symlink to
  `niri/dot-config/niri/config.kdl` in this repo.
- Edit the real files here; never write through the `~/.config` symlinks
  (the tooling refuses symlink writes).
