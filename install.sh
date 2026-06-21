#!/bin/bash

# omarchy-tasks — show your Taskwarrior tasks on the Omarchy Waybar.
#
# Adds a Waybar module that displays the number of actionable (overdue +
# due-today) tasks, with the next tasks (ranked by urgency) in the tooltip.
# Click it — or press Super + T — to open taskwarrior-tui.
#
# Idempotent and safe to re-run. Only touches ~/.config and ~/.local/bin.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
BINDINGS="$HOME/.config/hypr/bindings.conf"
BIN_DIR="$HOME/.local/bin"
INDICATOR="$BIN_DIR/tasks-indicator"

echo "[tasks] Setting up Taskwarrior waybar module..."

# 1. Dependencies (informational — install via omarchy on Omarchy)
for dep in task jq; do
  command -v "$dep" >/dev/null 2>&1 || echo "  ! missing dependency: $dep (install it, e.g. 'omarchy pkg add $dep')"
done

# 2. Install the indicator script
mkdir -p "$BIN_DIR"
install -m 0755 "$SCRIPT_DIR/bin/tasks-indicator" "$INDICATOR"
echo "  -> Installed $INDICATOR"

# 3. Add the waybar module
if [[ -f "$WAYBAR_CONFIG" ]]; then
  if grep -q 'custom/tasks' "$WAYBAR_CONFIG"; then
    echo "  -> Waybar already has tasks module, skipping."
  else
    # Add to modules-center, right after the stock notification-silencing-indicator
    sed -i'' -e '/modules-center/s/"custom\/notification-silencing-indicator"/"custom\/notification-silencing-indicator", "custom\/tasks"/' "$WAYBAR_CONFIG"

    # Add the module definition (before the tray definition)
    sed -i'' -e '/"tray": {/i\
  "custom/tasks": {\
    "exec": "~/.local/bin/tasks-indicator",\
    "return-type": "json",\
    "interval": 60,\
    "signal": 12,\
    "tooltip": true,\
    "on-click": "omarchy-launch-or-focus-tui taskwarrior-tui"\
  },' "$WAYBAR_CONFIG"

    echo "  -> Added tasks module to waybar"
  fi
fi

# 4. Add waybar styling
if [[ -f "$WAYBAR_STYLE" ]]; then
  if grep -q '#custom-tasks' "$WAYBAR_STYLE"; then
    echo "  -> Waybar style already has tasks rule, skipping."
  else
    cat >> "$WAYBAR_STYLE" <<'CSSEOF'

#custom-tasks {
  margin-left: 5px;
  margin-right: 0;
}

#custom-tasks.urgent {
  color: #cc8888;
}

#custom-tasks.clear {
  opacity: 0.55;
}
CSSEOF
    echo "  -> Added tasks styling"
  fi
fi

# 5. Add the Super + T keybinding to open taskwarrior-tui
if [[ -f "$BINDINGS" ]]; then
  if grep -q 'omarchy-launch-or-focus-tui taskwarrior-tui' "$BINDINGS"; then
    echo "  -> Keybinding already present, skipping."
  else
    printf '\n# omarchy-tasks: open the Taskwarrior TUI\nbindd = SUPER, T, Tasks, exec, omarchy-launch-or-focus-tui taskwarrior-tui\n' >> "$BINDINGS"
    echo "  -> Added Super + T -> taskwarrior-tui"
  fi
fi

# 6. Apply
omarchy-restart-waybar 2>/dev/null || true
hyprctl reload >/dev/null 2>&1 || true

echo "[tasks] Done."
echo ""
echo "  Waybar shows the count of overdue + due-today tasks."
echo "  Hover for what's next; click or press Super + T to open taskwarrior-tui."
