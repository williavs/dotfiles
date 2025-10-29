# Wezterm Dynamic Background System

A sophisticated background management system for Wezterm that provides:
- **359 curated Unsplash photos** that rotate daily
- **Manual controls** to browse through the collection
- **Brightness adjustment** for optimal readability
- **Automatic daily rotation** at midnight
- **Efficient caching** - only 1 image stored at a time

## Features

### 🖼️ Dynamic Backgrounds
- Daily auto-rotation based on day of year (359-day cycle)
- Manual navigation: next, previous, random
- Full-resolution Unsplash images (query parameters stripped)
- Profile images filtered out (photos only)

### ☀️ Brightness Control
- Adjust background brightness from 0.0 to 1.0
- Default: 0.03 (very dark, optimal for terminal readability)
- Real-time updates via tmux keybindings
- Preserves inactive pane brightness separately

### 💾 Smart Caching
- Downloads images on-demand
- Keeps only current image (~2-3MB)
- Auto-deletes previous image when switching
- No disk space bloat

### 🔄 Auto-Reset Logic
- At midnight, automatically resets to daily image
- Manual changes during the day don't persist overnight
- Consistent experience across all sessions

## Installation

### 1. Copy Files to Config Directory

```bash
# Create directory structure
mkdir -p ~/.config/wezterm/backgrounds/cache

# Copy configuration files
cp wezterm.lua ~/.config/wezterm/
cp backgrounds/* ~/.config/wezterm/backgrounds/

# Make scripts executable
chmod +x ~/.config/wezterm/backgrounds/*.sh

# Copy tmux config (includes keybindings)
cp ../tmux/tmux.conf ~/.tmux.conf
```

### 2. Reload Configurations

```bash
# Reload tmux (if already running)
tmux source-file ~/.tmux.conf

# Restart wezterm or it will auto-reload
```

### 3. Verify Installation

```bash
# Check that images.json is present
ls -lh ~/.config/wezterm/backgrounds/images.json

# Test the switch script
~/.config/wezterm/backgrounds/switch.sh next

# Check cache directory
ls -lh ~/.config/wezterm/backgrounds/cache/
```

## File Structure

```
~/.config/wezterm/
├── wezterm.lua                          # Main wezterm config
└── backgrounds/
    ├── manager.lua                      # Background manager (Lua)
    ├── switch.sh                        # Image switcher (Bash)
    ├── brightness.sh                    # Brightness control (Bash)
    ├── images.json                      # 359 Unsplash photo URLs
    ├── state.txt                        # Current state (date|index)
    ├── brightness_config.txt            # Current brightness settings
    └── cache/
        └── current.jpg                  # Currently displayed image
```

## Keybindings

All keybindings are configured in `tmux.conf` and work from any tmux session.

### Image Navigation (No Prefix Required)

| Keybinding | Action |
|------------|--------|
| `ALT+N` | Next background |
| `ALT+P` | Previous background |
| `ALT+R` | Random background |
| `ALT+D` | Reset to today's daily background |

### Brightness Control (No Prefix Required)

| Keybinding | Action |
|------------|--------|
| `ALT+Up` | Brighter (increase by 0.02) |
| `ALT+Down` | Darker (decrease by 0.02) |
| `ALT+=` | Reset brightness to default (0.03) |

### Menu Interface (Prefix + b)

Press `Ctrl+b` then `b` to open the background switcher menu with visual options:

```
🖼️  Background Switcher
─────────────────────────
→ Next Background      (n)
← Previous Background  (p)
🎲 Random Background   (r)
📅 Daily Background    (d)

☀️  Brighter           (+)
🌙 Darker              (-)
↻ Reset Brightness     (=)
```

## How It Works

### Daily Rotation Logic

1. **On wezterm startup**: Manager checks `state.txt` for saved date
2. **If date matches today**: Uses saved image index
3. **If date is different**: Calculates daily index from day-of-year and resets
4. **Formula**: `index = ((day_of_year - 1) % 359) + 1`

This ensures:
- Same image all day long (unless manually changed)
- Automatic reset at midnight
- Consistent rotation cycle

### Image Switching Flow

```
User presses ALT+N
    ↓
switch.sh updates state.txt with new index
    ↓
switch.sh downloads new image from images.json
    ↓
switch.sh overwrites cache/current.jpg
    ↓
switch.sh touches wezterm.lua (triggers reload)
    ↓
Wezterm reloads config and displays new image
```

### Brightness Adjustment Flow

```
User presses ALT+Up
    ↓
brightness.sh reads current brightness from brightness_config.txt
    ↓
brightness.sh calculates new value (current + 0.02)
    ↓
brightness.sh updates brightness_config.txt
    ↓
brightness.sh uses awk to update wezterm.lua (background hsb.brightness)
    ↓
brightness.sh touches wezterm.lua (triggers reload)
    ↓
Wezterm reloads config with new brightness
```

## Configuration

### Adjusting Brightness Step Size

Edit `~/.config/wezterm/backgrounds/brightness.sh`:

```bash
# Line 10 - Change from 0.02 to your preferred step
BRIGHTNESS_STEP="0.05"  # Larger steps for faster adjustment
```

### Changing Default Brightness

Edit `~/.config/wezterm/backgrounds/brightness.sh`:

```bash
# Line 8 - Change default value
DEFAULT_BRIGHTNESS="0.05"  # Brighter default
```

Or edit `wezterm.lua` directly:

```lua
-- Line 41
brightness = 0.05,  -- Your preferred default
```

### Modifying Image Collection

Replace `images.json` with your own collection:

```bash
# Backup original
cp ~/.config/wezterm/backgrounds/images.json{,.backup}

# Edit images.json
vim ~/.config/wezterm/backgrounds/images.json
```

**Format:**
```json
{
  "images": [
    "https://images.unsplash.com/photo-XXXXX",
    "https://images.unsplash.com/photo-YYYYY",
    ...
  ]
}
```

**Requirements:**
- Must be publicly accessible image URLs
- Direct image URLs (no query parameters needed)
- HTTPS URLs recommended

### Adding More Images

```bash
# Scrape new images from Unsplash search page
# Save HTML, then extract URLs:

rg -o 'src="https://images\.unsplash\.com/[^"]*"' page.html | \
  sed 's/src="//g' | sed 's/"//g' | \
  jq -R -s 'split("\n") | map(select(length > 0)) | map(split("?")[0]) | {images: .}' > new_images.json

# Merge with existing
jq -s '.[0].images + .[1].images | unique | {images: .}' \
  ~/.config/wezterm/backgrounds/images.json new_images.json > merged.json

mv merged.json ~/.config/wezterm/backgrounds/images.json
```

## Troubleshooting

### Background not changing

1. **Check if image downloaded:**
   ```bash
   ls -lh ~/.config/wezterm/backgrounds/cache/current.jpg
   ```

2. **Check state file:**
   ```bash
   cat ~/.config/wezterm/backgrounds/state.txt
   # Should show: YYYY-MM-DD|INDEX
   ```

3. **Manually trigger switch:**
   ```bash
   ~/.config/wezterm/backgrounds/switch.sh next
   ```

4. **Check wezterm logs:**
   ```bash
   # Look for errors in wezterm output
   wezterm --version
   ```

### Brightness not changing

1. **Check brightness config:**
   ```bash
   cat ~/.config/wezterm/backgrounds/brightness_config.txt
   ```

2. **Verify wezterm.lua was updated:**
   ```bash
   rg "brightness" ~/.config/wezterm/wezterm.lua
   # Should show background brightness AND inactive_pane brightness
   ```

3. **Test script directly:**
   ```bash
   ~/.config/wezterm/backgrounds/brightness.sh brighter
   ```

### Image URL download fails

1. **Test URL manually:**
   ```bash
   curl -I "https://images.unsplash.com/photo-XXXXX"
   # Should return 200 OK
   ```

2. **Check internet connection**

3. **Verify curl is installed:**
   ```bash
   which curl
   ```

### Keybindings not working

1. **Reload tmux config:**
   ```bash
   tmux source-file ~/.tmux.conf
   ```

2. **Check for keybinding conflicts:**
   ```bash
   tmux list-keys | grep -E "M-N|M-P|M-R|M-Up|M-Down"
   ```

3. **Test from tmux command prompt:**
   ```bash
   # Press Ctrl+b then :
   run-shell "~/.config/wezterm/backgrounds/switch.sh next"
   ```

## Performance Notes

- **Disk usage**: ~2-3MB for current cached image
- **Network usage**: ~2-3MB per image switch
- **CPU impact**: Minimal (image download runs in background)
- **Config reload**: <100ms (wezterm auto-reload is fast)

## Customization Ideas

### Weekly rotation instead of daily

Edit `manager.lua` line 89:

```lua
-- Get weekly index (based on week of year)
local function get_weekly_index(images)
  local week = tonumber(os.date('%V'))  -- ISO week number
  return ((week - 1) % #images) + 1
end
```

### Different brightness for different times of day

Edit `brightness.sh` to add time-based logic:

```bash
# Add to update_wezterm_config function
HOUR=$(date +%H)
if [ $HOUR -ge 9 ] && [ $HOUR -le 17 ]; then
    # Daytime - brighter
    brightness="0.05"
else
    # Evening/Night - darker
    brightness="0.02"
fi
```

### Add theme-based collections

Create multiple JSON files:

```bash
~/.config/wezterm/backgrounds/
├── images_nature.json
├── images_abstract.json
├── images_minimal.json
```

Add switching logic in `switch.sh`.

## Credits

- **Unsplash**: All images sourced from [unsplash.com](https://unsplash.com)
- **Wezterm**: Terminal emulator by [@wez](https://github.com/wez/wezterm)
- **Catppuccin**: Color scheme used in terminal

## License

Scripts and configuration files are freely usable and modifiable.

Image content is subject to [Unsplash License](https://unsplash.com/license).
