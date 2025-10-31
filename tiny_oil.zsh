#!/bin/zsh
# tiny_oil.zsh - Wayland/XWayland auto-clicker for POE

# -------------------------
# CONFIG
# -------------------------
INV_X=3831
INV_Y=587
SLOT_WIDTH=53
SLOT_HEIGHT=53
COLUMNS=12
ROWS=5
CLICK_DELAY_MS=20       # milliseconds per slot
MOVE_DELAY=0.007        # seconds after moving before clicking
POE_WINDOW_NAME="Path of Exile"  # adjust to your window title/class

# -------------------------
# IGNORE SLOTS (comma separated, numbered top-left = 0, counting vertically)
# Example: IGNORE_SLOTS="0,1,2,3"
# -------------------------
IGNORE_SLOTS="0,1,2,3"          # leave empty for none
typeset -A IGNORE_MAP
if [[ -n "$IGNORE_SLOTS" ]]; then
    for i in ${(s/,/)IGNORE_SLOTS}; do
        IGNORE_MAP[$i]=1
    done
fi

# -------------------------
# FUNCTIONS
# -------------------------
focus_poe_window() {
    POE_WIN=$(xdotool search --name "$POE_WINDOW_NAME" | head -1)
    if [[ -z "$POE_WIN" ]]; then
        echo "POE window not found!"
        exit 1
    fi
    xdotool windowactivate "$POE_WIN"
    sleep 0.2
}

move_mouse() {
    local X=$1
    local Y=$2
    xdotool mousemove "$X" "$Y"
    sleep "$MOVE_DELAY"
}

click_mouse() {
    xdotool mousedown 1
    sleep 0.01
    xdotool mouseup 1
}

click_slot() {
    local col=$1
    local row=$2
    local slot_number=$((col * ROWS + row))

    # Skip ignored slots
    if [[ -n "${IGNORE_MAP[$slot_number]}" ]]; then
        echo "Skipping slot $slot_number ($col,$row)"
        return
    fi

    # Click in the center of the slot
    local x=$((INV_X + col * SLOT_WIDTH + SLOT_WIDTH/2))
    local y=$((INV_Y + row * SLOT_HEIGHT + SLOT_HEIGHT/2))
    echo "Clicking slot $slot_number ($col,$row) at ($x,$y)"
    move_mouse "$x" "$y"
    click_mouse
    sleep $(echo "scale=3; $CLICK_DELAY_MS/1000" | bc)
}

# -------------------------
# MAIN
# -------------------------
echo "Focusing POE window..."
focus_poe_window

for ((col=0; col<COLUMNS; col++)); do
    for ((row=0; row<ROWS; row++)); do
        click_slot "$col" "$row"
    done
done

echo "Finished clicking all slots!"
exit 0
