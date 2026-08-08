# dotfiles

Personal desktop dotfiles managed by [chezmoi](https://www.chezmoi.io/).

## Supported environments

- macOS desktop
- Ubuntu desktop
- Ubuntu on WSL2

Headless Linux servers, non-Ubuntu Linux distributions, WSL1, and a Linux
replacement for Hammerspoon are intentionally out of scope. Hammerspoon stays
macOS-only.

## Bootstrap

Install `git` and `chezmoi`, then initialize and apply the repository:

```sh
chezmoi init --apply jwoo0122
```

The first apply installs the native package manifest for the detected platform.
On Ubuntu and WSL it also bootstraps `mise` from its official installer when
needed and changes the login shell to zsh. Log out and back in after the first
apply. Subsequent updates are handled by `dotsync`.

## Daily use

Install and remove software with the platform's normal commands:

```sh
# macOS
brew install shellcheck

# Ubuntu or WSL
sudo apt install shellcheck

# managed runtimes
mise use -g go@latest
```

Then synchronize everything:

```sh
dotsync
```

`dotsync` fetches the remote, captures managed files and the native package
manifest, commits local changes, rebases onto the upstream branch, applies the
result, installs packages and mise runtimes, and pushes when the local branch is
ahead. It never force-pushes or guesses through a Git conflict.

Conflict recovery and inspection:

```sh
dotsync --continue  # continue after resolving a rebase conflict
dotsync --abort     # abort the active rebase
dotsync --dry-run   # inspect Git and chezmoi state without changing it
dotsync --offline   # capture and apply without fetch or push
dotsync --no-push   # synchronize locally but leave commits unpushed
```

## Native state

| Environment | Installation state | Configuration |
| --- | --- | --- |
| macOS | `~/.config/brew/Brewfile` | chezmoi-managed files under `~` |
| Ubuntu desktop | `~/.config/apt/ubuntu-desktop.txt` | chezmoi-managed files under `~` |
| WSL2 | `~/.config/apt/wsl.txt` | chezmoi-managed files under `~` |
| All profiles | `~/.config/mise/config.toml` | mise-managed runtimes |

The apt manifests are sorted output from `apt-mark showmanual`. Package removal
is derived from the difference between the last successfully applied Git commit
and the new commit. `apt autoremove` and `brew bundle cleanup --force` are never
run automatically.

Important application configuration:

| Tool | Configuration | Profiles |
| --- | --- | --- |
| Neovim | `~/.config/nvim/init.lua` | all |
| tmux | `~/.tmux.conf` | all |
| Ghostty | `~/.config/ghostty/config` | macOS, Ubuntu desktop |
| Zed | `~/.config/zed` | macOS, Ubuntu desktop |
| Hammerspoon | `~/.hammerspoon/init.lua` | macOS only |
| mise | `~/.config/mise/config.toml` | all |

Existing agent permission behavior is intentional and is preserved across all
profiles.
