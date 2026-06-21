# omarchy-tasks

Show your [Taskwarrior](https://taskwarrior.org/) tasks on the [Omarchy](https://omarchy.org/) Waybar.

A lightweight Waybar module that displays the number of **actionable** tasks
(overdue + due today) in your bar. Hover to see what's next — your pending tasks
ranked by Taskwarrior urgency — and click (or press <kbd>Super</kbd> + <kbd>T</kbd>)
to open [`taskwarrior-tui`](https://github.com/kdheepak/taskwarrior-tui).

![bar: a tasks icon with a count, tooltip listing upcoming tasks by due date]

## What you get

- **At-a-glance count** in the bar — overdue + due-today tasks, styled when urgent.
- **Tooltip** — up to 10 upcoming tasks, ranked by urgency, with relative due times (`4h`, `1d`, `-2h` for overdue).
- **One-click / one-key** access to the full `taskwarrior-tui` board.

## Requirements

- [Omarchy](https://omarchy.org/) (Waybar + Hyprland)
- `task` (Taskwarrior) and `taskwarrior-tui`
- `jq`

On Omarchy: `omarchy pkg add task taskwarrior-tui` (jq ships by default).

## Install

```bash
git clone https://github.com/janhesters/omarchy-tasks.git ~/dev/omarchy-tasks
cd ~/dev/omarchy-tasks
./install.sh
```

The installer is **idempotent** and only touches `~/.config` and `~/.local/bin`:

- installs `tasks-indicator` to `~/.local/bin/`
- adds the `custom/tasks` module to `~/.config/waybar/config.jsonc`
- appends styling to `~/.config/waybar/style.css`
- adds a `Super + T` binding to `~/.config/hypr/bindings.conf`
- restarts Waybar and reloads Hyprland

## How it works

`tasks-indicator` queries Taskwarrior and prints Waybar JSON:

- **text** — `task status:pending due.before:tomorrow count` (overdue + today)
- **tooltip** — your pending tasks, sorted by `urgency-`
- **class** — `urgent` (something due/overdue), `pending`, or `clear`

The module polls every 60s and also refreshes on `SIGRTMIN+12`, so you can
force an immediate update after changing tasks:

```bash
pkill -RTMIN+12 waybar
```

## Uninstall

Remove the `custom/tasks` entry from `modules-center` and its definition in
`config.jsonc`, delete the `#custom-tasks` rules from `style.css`, remove the
`Super + T` line from `bindings.conf`, and `rm ~/.local/bin/tasks-indicator`.

## License

MIT
