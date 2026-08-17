# See your Taskwarrior priorities in the Omarchy bar

Omarchy Tasks is a native Omarchy 4 shell plugin for Taskwarrior. It shows the number of actionable tasks in the bar, lists your next tasks on hover, and opens `taskwarrior-tui` with one click.

Your tasks stay in Taskwarrior. The plugin reads them through the `task` command and stores no separate data.

## What you get

- A red count for overdue tasks and tasks due today.
- A standard count when pending work has no immediate deadline.
- Up to 10 pending tasks in the tooltip, ranked by Taskwarrior urgency.
- One-click access to `taskwarrior-tui`.
- A right-click refresh and an IPC refresh command for scripts.

## Requirements

Install Taskwarrior and its terminal UI through Omarchy:

```bash
omarchy pkg add task taskwarrior-tui
```

## Install

```bash
omarchy plugin add https://github.com/janhesters/omarchy-tasks.git --enable
```

The widget starts in the center section. Move it with the standard Omarchy bar command:

```bash
omarchy bar move io.github.janhesters.tasks --section center --before omarchy.system-update
```

## Use

- Hover to see pending tasks ranked by urgency.
- Left-click to open `taskwarrior-tui`.
- Right-click to refresh now.

The plugin refreshes every 60 seconds by default. You can change the interval or hide the empty-state icon in the Omarchy bar settings.

Scripts can request an immediate refresh after changing a task:

```bash
omarchy-shell io.github.janhesters.tasks refresh
```

## Update or remove

```bash
omarchy plugin update io.github.janhesters.tasks
omarchy plugin remove io.github.janhesters.tasks
```

Removing the plugin leaves your Taskwarrior data untouched.

## Omarchy 3 migration

Version 2 replaces the old Waybar module. It no longer edits Waybar CSS, installs a helper in `~/.local/bin`, or adds a Hyprland keybinding. Keep your existing Taskwarrior data and add the plugin with the command above.

## License

MIT
