# dotfiles

Personal configuration for zsh, tmux, Neovim, and Pi, managed with [GNU Stow](https://www.gnu.org/software/stow/).

Each top-level directory is a stow package whose contents mirror `$HOME`:

| Package | Provides |
|---------|----------|
| `zsh`   | `~/.zshrc`, `~/.p10k.zsh`, `~/.config/powerlevel10k` (submodule) |
| `tmux`  | `~/.config/tmux` |
| `nvim`  | `~/.config/nvim` (plugins via lazy.nvim, pinned in `lazy-lock.json`) |
| `pi`    | `~/.pi/agent/settings.json` |

Only Pi's portable configuration is tracked. Credentials (`auth.json`), sessions,
model caches, and installed package caches remain local and are ignored by Git.
After restoring on a new machine, use Pi's `/login` command to authenticate again.

## Setup on a new machine

Clone the repo (HTTPS works before any SSH key exists) and run the init
script:

```sh
git clone --recurse-submodules https://github.com/ValentinDold/dotfiles.git ~/repos/dotfiles
cd ~/repos/dotfiles
./init.sh
```

The script installs the required packages (Arch only), stows the packages
(backing up conflicting real files to `*.bak`), generates an ed25519 SSH key
if none exists, uploads it to GitHub via `gh` (interactive login on first
run), switches the `origin` remote to SSH, and makes zsh the login shell.
It is idempotent, so it can be re-run safely.

### Manual setup

1. Install the prerequisites:

   ```sh
   # Arch
   sudo pacman -S git stow zsh tmux neovim
   ```

2. Clone the repo (with submodules) and stow the packages:

   ```sh
   git clone --recurse-submodules git@github.com:ValentinDold/dotfiles.git ~/repos/dotfiles
   cd ~/repos/dotfiles
   mkdir -p ~/.pi/agent  # prevent Stow from placing Pi's local state in this repo
   stow -t ~ nvim tmux zsh pi
   ```

   If a real file already exists where a symlink should go (e.g. a default
   `~/.zshrc`), remove or back it up first — stow will refuse to overwrite it.

3. Make zsh the login shell:

   ```sh
   chsh -s "$(which zsh)"
   ```

Neovim installs its plugins automatically on first launch.

## Updating

After adding or changing files inside a package, re-run `stow -t ~ <package>`
from the repo root so new files get linked.

To remove a package's symlinks: `stow -D -t ~ <package>`.
