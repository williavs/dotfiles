# Wezterm Dynamic Backgrounds

Dynamic background system for Wezterm with 359 Unsplash photos that rotate daily.

## Features

- Daily auto-rotation based on day of year (359-day cycle)
- Manual navigation: next, previous, random
- Brightness adjustment (0.0 to 1.0, default 0.03)
- Smart caching: only 1 image stored at a time (~2-3MB)
- Auto-resets to daily image at midnight
- Full-resolution images (query params stripped, profiles filtered)

## Installation

```bash
# Create directories
mkdir -p ~/.config/wezterm/backgrounds/cache

# Copy files
cp wezterm.lua ~/.config/wezterm/
cp -r backgrounds ~/.config/wezterm/
chmod +x ~/.config/wezterm/backgrounds/*.sh

# Copy tmux config (includes keybindings)
cp ../tmux/tmux.conf ~/.tmux.conf

# Reload
tmux source-file ~/.tmux.conf
```

## Keybindings

All keybindings work from any tmux session (no prefix needed unless specified).

### Image Navigation

- `ALT+N` - Next background
- `ALT+P` - Previous background
- `ALT+R` - Random background
- `ALT+D` - Reset to today's daily background

### Brightness Control

- `ALT+Up` - Brighter (increase by 0.02)
- `ALT+Down` - Darker (decrease by 0.02)
- `ALT+=` - Reset brightness to default (0.03)

### Menu Interface

- `Ctrl+b` then `b` - Opens background switcher menu

```
◈ Background Switcher
→ Next Background      (n)
← Previous Background  (p)
◉ Random Background    (r)
◷ Daily Background     (d)

☀ Brighter            (+)
☾ Darker              (-)
↻ Reset Brightness    (=)
```

## File Structure

```
~/.config/wezterm/
├── wezterm.lua                          # Main config
└── backgrounds/
    ├── manager.lua                      # Background manager
    ├── switch.sh                        # Image switcher
    ├── brightness.sh                    # Brightness control
    ├── images.json                      # 359 Unsplash URLs
    ├── state.txt                        # Current state (date|index)
    ├── brightness_config.txt            # Brightness settings
    └── cache/
        └── current.jpg                  # Currently displayed image
```

## How It Works

### Daily Rotation

1. On startup: Manager checks `state.txt` for saved date
2. If date matches today: Uses saved image index
3. If date is different: Calculates daily index from day-of-year and resets
4. Formula: `index = ((day_of_year - 1) % 359) + 1`

### Image Switching Flow

```
User presses ALT+N
  → switch.sh updates state.txt with new index
  → switch.sh downloads new image from images.json
  → switch.sh overwrites cache/current.jpg
  → switch.sh touches wezterm.lua (triggers reload)
  → Wezterm reloads and displays new image
```

### Brightness Adjustment Flow

```
User presses ALT+Up
  → brightness.sh reads current value from brightness_config.txt
  → brightness.sh calculates new value (current + 0.02)
  → brightness.sh updates brightness_config.txt
  → brightness.sh uses awk to update wezterm.lua
  → brightness.sh touches wezterm.lua (triggers reload)
  → Wezterm reloads with new brightness
```

## Configuration

### Adjust Brightness Step Size

Edit `~/.config/wezterm/backgrounds/brightness.sh`:

```bash
# Line 10
BRIGHTNESS_STEP="0.05"  # Default: 0.02
```

### Change Default Brightness

Edit `~/.config/wezterm/backgrounds/brightness.sh`:

```bash
# Line 8
DEFAULT_BRIGHTNESS="0.05"  # Default: 0.03
```

Or edit `wezterm.lua` directly:

```lua
# Line 41
brightness = 0.05,  # Default: 0.03
```

### Replace Image Collection

Replace `images.json` with your own:

```json
{
  "images": [
    "https://images.unsplash.com/photo-XXXXX",
    "https://images.unsplash.com/photo-YYYYY"
  ]
}
```

Requirements:
- Publicly accessible image URLs
- Direct image URLs (no query parameters needed)
- HTTPS recommended

### Add More Images

```bash
# Extract URLs from Unsplash HTML
rg -o 'src="https://images\.unsplash\.com/[^"]*"' page.html | \
  sed 's/src="//g' | sed 's/"//g' | \
  jq -R -s 'split("\n") | map(select(length > 0)) | map(split("?")[0]) | {images: .}' > new.json

# Merge with existing
jq -s '.[0].images + .[1].images | unique | {images: .}' \
  ~/.config/wezterm/backgrounds/images.json new.json > merged.json

mv merged.json ~/.config/wezterm/backgrounds/images.json
```

## Troubleshooting

### Background not changing

```bash
# Check if image downloaded
ls -lh ~/.config/wezterm/backgrounds/cache/current.jpg

# Check state file
cat ~/.config/wezterm/backgrounds/state.txt
# Should show: YYYY-MM-DD|INDEX

# Manually trigger switch
~/.config/wezterm/backgrounds/switch.sh next
```

### Brightness not changing

```bash
# Check brightness config
cat ~/.config/wezterm/backgrounds/brightness_config.txt

# Verify wezterm.lua was updated
rg "brightness" ~/.config/wezterm/wezterm.lua

# Test script directly
~/.config/wezterm/backgrounds/brightness.sh brighter
```

### Image URL download fails

```bash
# Test URL manually
curl -I "https://images.unsplash.com/photo-XXXXX"

# Check internet connection
ping -c 3 images.unsplash.com

# Verify curl installed
which curl
```

### Keybindings not working

```bash
# Reload tmux config
tmux source-file ~/.tmux.conf

# Check for conflicts
tmux list-keys | grep -E "M-N|M-P|M-R|M-Up|M-Down"

# Test from tmux command prompt
# Press Ctrl+b then :
run-shell "~/.config/wezterm/backgrounds/switch.sh next"
```

## Performance

- Disk usage: ~2-3MB (current cached image only)
- Network usage: ~2-3MB per image switch
- CPU impact: Minimal (download runs in background)
- Config reload: <100ms

## Customization Examples

### Weekly rotation instead of daily

Edit `manager.lua` line 89:

```lua
local function get_weekly_index(images)
  local week = tonumber(os.date('%V'))
  return ((week - 1) % #images) + 1
end
```

### Time-based brightness

Edit `brightness.sh`:

```bash
HOUR=$(date +%H)
if [ $HOUR -ge 9 ] && [ $HOUR -le 17 ]; then
    brightness="0.05"  # Daytime
else
    brightness="0.02"  # Night
fi
```

### Theme-based collections

Create multiple JSON files:

```bash
~/.config/wezterm/backgrounds/
├── images_nature.json
├── images_abstract.json
├── images_minimal.json
```

Add switching logic in `switch.sh`.
