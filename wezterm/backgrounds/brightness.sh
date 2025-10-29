#!/usr/bin/env bash
# Brightness and opacity control for wezterm background
# Usage: brightness.sh [brighter|darker|more-opaque|less-opaque|reset]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$HOME/.config/wezterm/backgrounds/brightness_config.txt"

# Default values (from your current config)
DEFAULT_BRIGHTNESS="0.03"
DEFAULT_OPACITY="1.0"

# Step size for adjustments
BRIGHTNESS_STEP="0.02"
OPACITY_STEP="0.1"

# Read current settings
read_settings() {
    if [ -f "$CONFIG_FILE" ]; then
        IFS='|' read -r brightness opacity < "$CONFIG_FILE"
        echo "$brightness" "$opacity"
    else
        echo "$DEFAULT_BRIGHTNESS" "$DEFAULT_OPACITY"
    fi
}

# Write settings
write_settings() {
    local brightness=$1
    local opacity=$2
    echo "$brightness|$opacity" > "$CONFIG_FILE"
}

# Clamp value between min and max
clamp() {
    local value=$1
    local min=$2
    local max=$3

    if (( $(echo "$value < $min" | bc -l) )); then
        echo "$min"
    elif (( $(echo "$value > $max" | bc -l) )); then
        echo "$max"
    else
        echo "$value"
    fi
}

# Update wezterm config with new values
update_wezterm_config() {
    local brightness=$1
    local opacity=$2
    local config_file="$HOME/.config/wezterm/wezterm.lua"

    # Use awk to update ONLY the brightness in the hsb block (background image)
    # This avoids touching the inactive_pane_hsb brightness
    awk -v new_brightness="$brightness" '
        /config\.background = \{/ { in_bg=1 }
        in_bg && /brightness = [0-9.]+,/ {
            # Ensure proper decimal formatting (0.XX not .XX)
            formatted = sprintf("%.2f", new_brightness)
            sub(/brightness = [0-9.]+,/, "brightness = " formatted ",")
            in_bg=0
        }
        { print }
    ' "$config_file" > "$config_file.tmp" && mv "$config_file.tmp" "$config_file"

    # Trigger reload
    touch "$config_file"
}

# Get current settings
read brightness opacity <<< "$(read_settings)"

# Main command handling
ACTION=${1:-status}

case "$ACTION" in
    brighter)
        NEW_BRIGHTNESS=$(echo "$brightness + $BRIGHTNESS_STEP" | bc -l)
        NEW_BRIGHTNESS=$(clamp "$NEW_BRIGHTNESS" 0.0 1.0)
        write_settings "$NEW_BRIGHTNESS" "$opacity"
        update_wezterm_config "$NEW_BRIGHTNESS"
        echo "Brightness: $(printf '%.2f' $NEW_BRIGHTNESS)"
        ;;
    darker)
        NEW_BRIGHTNESS=$(echo "$brightness - $BRIGHTNESS_STEP" | bc -l)
        NEW_BRIGHTNESS=$(clamp "$NEW_BRIGHTNESS" 0.0 1.0)
        write_settings "$NEW_BRIGHTNESS" "$opacity"
        update_wezterm_config "$NEW_BRIGHTNESS"
        echo "Brightness: $(printf '%.2f' $NEW_BRIGHTNESS)"
        ;;
    more-opaque)
        # Decrease brightness = more opaque (darker background)
        NEW_BRIGHTNESS=$(echo "$brightness - $BRIGHTNESS_STEP" | bc -l)
        NEW_BRIGHTNESS=$(clamp "$NEW_BRIGHTNESS" 0.01 0.5)
        write_settings "$NEW_BRIGHTNESS" "$opacity"
        update_wezterm_config "$NEW_BRIGHTNESS"
        echo "More opaque (brightness: $(printf '%.2f' $NEW_BRIGHTNESS))"
        ;;
    less-opaque)
        # Increase brightness = less opaque (lighter background)
        NEW_BRIGHTNESS=$(echo "$brightness + $BRIGHTNESS_STEP" | bc -l)
        NEW_BRIGHTNESS=$(clamp "$NEW_BRIGHTNESS" 0.01 0.5)
        write_settings "$NEW_BRIGHTNESS" "$opacity"
        update_wezterm_config "$NEW_BRIGHTNESS"
        echo "Less opaque (brightness: $(printf '%.2f' $NEW_BRIGHTNESS))"
        ;;
    reset)
        write_settings "$DEFAULT_BRIGHTNESS" "$DEFAULT_OPACITY"
        update_wezterm_config "$DEFAULT_BRIGHTNESS"
        echo "Reset to default (brightness: $DEFAULT_BRIGHTNESS)"
        ;;
    status)
        echo "Current brightness: $(printf '%.2f' $brightness)"
        ;;
    *)
        echo "Usage: $0 [brighter|darker|more-opaque|less-opaque|reset|status]"
        exit 1
        ;;
esac

exit 0
