---
name: effective-macos
description: Use when the user asks how to set up, customize, or tune a macOS development environment — installing Homebrew, tweaking trackpad/keyboard defaults, configuring terminal tools (Ghostty, tmux, neovim, fzf, autojump, yazi, zim), enabling Touch ID for sudo, hiding the Dock, checking ports, or picking recommended apps/extensions. Triggers on phrases like "set up my mac", "macOS defaults write", "faster key repeat", "Touch ID sudo", "hide dock", or questions about `defaults write` commands.
---

# Effective macOS: Tips, Tools, and Customizations

## Preparation

### Homebrew

Homebrew is the de facto package manager for macOS.

**Install Homebrew:**

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Install software** — formulae (CLI) vs. casks (GUI apps):

```shell
brew install ripgrep          # formula
brew install --cask ghostty   # cask
```

## System Customizations

### Trackpad

- **Tap to Click:**

```shell
defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
```

- **Three-Finger Drag:**

```shell
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
```

### Keyboard

- **Full Keyboard Control** (Tab moves focus through all controls, not just text fields):

```shell
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
```

- **Enable key repeat** — disables the press-and-hold accent-character popup so holding a key (e.g. `j` in Vim) repeats it. Log out and back in to apply.

```shell
# Global
defaults write -g ApplePressAndHoldEnabled -bool false

# Per-app override (example: VS Code)
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
```

Revert by setting the value to `true` or running `defaults delete <domain> ApplePressAndHoldEnabled`.

### Emacs Keybindings

macOS supports most Emacs keybindings natively in text fields (e.g. `C-a`, `C-e`, `C-k`). See the [Emacs cheat sheet](https://www.gnu.org/software/emacs/refcards/pdf/refcard.pdf).

## GUI Tools

### Ghostty

```shell
brew install --cask ghostty
```

### Alfred

Productivity app for search and task automation.

```shell
brew install --cask alfred
```

## Command-Line Tools

### yazi

Terminal file manager. See https://yazi-rs.github.io/ for install.

### zim

Fast, modular zsh framework. See https://zimfw.sh/ for install.

### fzf

General-purpose fuzzy finder:

```shell
brew install fzf
# wire up keybindings (Ctrl-R history, Ctrl-T files) and completion:
"$(brew --prefix)/opt/fzf/install"
```

### gsed (GNU sed)

```shell
brew install coreutils
```

Example:

```shell
echo "a b\nc d" | gsed 's/a/aa/g'
# aa b
# c d
```

### pbcopy / pbpaste

Built-in clipboard I/O. `pbcopy` reads stdin to the clipboard; `pbpaste` writes clipboard to stdout.

```shell
# copy grep match to clipboard
cat /etc/hosts | rg '^\d' | pbcopy

# paste back into a file
pbpaste > snippet.txt
```

### autojump

```shell
brew install autojump
```

Add to `~/.zshrc`:

```shell
[[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh
```

Commands:

- `j [dir]` — jump to directory
- `jo [dir]` — open in Finder
- `j -s` — show database entries

### Tmux

```shell
brew install tmux
```

Config lives at `~/.tmux.conf`.

### Vim/Neovim

```shell
brew install neovim
```

Config lives at `~/.config/nvim`.

## Miscellaneous

### Check a port

```shell
lsof -i tcp:8080             # who's listening on 8080
lsof -nP -iTCP -sTCP:LISTEN  # all listening TCP sockets
netstat -anv -p tcp | grep 8080
```

### Hide the Dock permanently

Dock auto-hide must be on first (System Settings → Desktop & Dock, or `defaults write com.apple.dock autohide -bool true`). Then set a very long reveal delay so the Dock effectively never appears:

```shell
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 1000
killall Dock
```

Restore:

```shell
defaults delete com.apple.dock autohide-delay; killall Dock
```

### Touch ID for sudo

macOS Sonoma (14) and later ship `/etc/pam.d/sudo_local.template`. Enable it so `sudo` accepts Touch ID and survives OS updates:

```shell
sed "s/^#auth/auth/" /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local
```

On older macOS, you'd have to edit `/etc/pam.d/sudo` directly (not recommended — it gets overwritten by updates). See the [Apple StackExchange answer](https://apple.stackexchange.com/questions/259093/can-touch-id-on-mac-authenticate-sudo-in-terminal) for details.

## Recommended Applications

- **MediaMate** — media management
- **Stats** — system monitor

## Browser Extensions

### Tampermonkey

- **Enhanced Word Highlight** — customizable word highlighting

## References

- [Awesome macOS Command Line](https://git.herrbischoff.com/awesome-macos-command-line/about/)
