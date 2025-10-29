#!/usr/bin/env bash
# Background switcher for wezterm via tmux
# Usage: switch.sh [next|prev|random|daily]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_FILE="$SCRIPT_DIR/state.txt"
IMAGES_FILE="$SCRIPT_DIR/images.json"
CACHE_DIR="$SCRIPT_DIR/cache"
CURRENT_BG="$CACHE_DIR/current.jpg"

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"

# Load images count
TOTAL_IMAGES=$(jq -r '.images | length' "$IMAGES_FILE")

# Get current date and day of year
CURRENT_DATE=$(date +%Y-%m-%d)
DAY_OF_YEAR=$(date +%j)

# Read current state (format: date|index)
read_state() {
    if [ -f "$STATE_FILE" ]; then
        IFS='|' read -r saved_date saved_index < "$STATE_FILE"
        echo "$saved_date" "$saved_index"
    else
        echo "" ""
    fi
}

# Write state
write_state() {
    local date=$1
    local index=$2
    echo "$date|$index" > "$STATE_FILE"
}

# Get daily index (based on day of year)
get_daily_index() {
    echo $(( ((10#$DAY_OF_YEAR - 1) % TOTAL_IMAGES) + 1 ))
}

# Download image
download_image() {
    local index=$1
    local url=$(jq -r ".images[$((index - 1))]" "$IMAGES_FILE")

    # Remove old image
    rm -f "$CURRENT_BG"

    # Download new image
    curl -s -o "$CURRENT_BG" "$url"

    if [ $? -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# Get current index (with daily reset logic)
get_current_index() {
    read saved_date saved_index <<< "$(read_state)"

    # If date changed, reset to daily
    if [ "$saved_date" != "$CURRENT_DATE" ]; then
        local daily_index=$(get_daily_index)
        write_state "$CURRENT_DATE" "$daily_index"
        echo "$daily_index"
    elif [ -n "$saved_index" ]; then
        echo "$saved_index"
    else
        local daily_index=$(get_daily_index)
        write_state "$CURRENT_DATE" "$daily_index"
        echo "$daily_index"
    fi
}

# Switch to specific index
switch_to_index() {
    local index=$1

    # Wrap around
    if [ $index -lt 1 ]; then
        index=$TOTAL_IMAGES
    elif [ $index -gt $TOTAL_IMAGES ]; then
        index=1
    fi

    write_state "$CURRENT_DATE" "$index"
    download_image "$index"

    echo "$index"
}

# Main command handling
ACTION=${1:-next}

case "$ACTION" in
    next)
        CURRENT=$(get_current_index)
        NEW_INDEX=$(switch_to_index $((CURRENT + 1)))
        echo "Background $NEW_INDEX/$TOTAL_IMAGES"
        ;;
    prev)
        CURRENT=$(get_current_index)
        NEW_INDEX=$(switch_to_index $((CURRENT - 1)))
        echo "Background $NEW_INDEX/$TOTAL_IMAGES"
        ;;
    random)
        RANDOM_INDEX=$((RANDOM % TOTAL_IMAGES + 1))
        NEW_INDEX=$(switch_to_index $RANDOM_INDEX)
        echo "Random background $NEW_INDEX/$TOTAL_IMAGES"
        ;;
    daily)
        DAILY_INDEX=$(get_daily_index)
        NEW_INDEX=$(switch_to_index $DAILY_INDEX)
        echo "Daily background $NEW_INDEX/$TOTAL_IMAGES"
        ;;
    *)
        echo "Usage: $0 [next|prev|random|daily]"
        exit 1
        ;;
esac

# Trigger wezterm config reload
# Use wezterm CLI to reload all windows
if command -v wezterm &> /dev/null; then
    # Send reload config command to all wezterm windows
    wezterm cli reload-configuration 2>/dev/null || true

    # Alternative: touch a file that wezterm watches
    touch ~/.config/wezterm/wezterm.lua
fi

exit 0
