# Dotfiles

My dotfiles - badass stuff for tmux and wezterm. Working on my neovim skills.

## What's Here

- **WezTerm**: Dynamic backgrounds (359 Unsplash photos, daily rotation), brightness controls, catppuccin-mocha
- **Tmux**: Custom keybindings, background switcher integration, popup menus
- **Neovim**: Work in progress

## Quick Setup

```bash
# WezTerm with backgrounds
mkdir -p ~/.config/wezterm/backgrounds/cache
cp wezterm/wezterm.lua ~/.config/wezterm/
cp -r wezterm/backgrounds ~/.config/wezterm/
chmod +x ~/.config/wezterm/backgrounds/*.sh

# Tmux
cp tmux/tmux.conf ~/.tmux.conf
tmux source-file ~/.tmux.conf
```

See `wezterm/README.md` for full background system docs.
