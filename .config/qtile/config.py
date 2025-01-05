"""Qtile Config."""

import os
import re
import subprocess
from typing import List

from libqtile import bar, layout, widget
from libqtile.config import (Click, Drag, DropDown, Group, Key, KeyChord,
                             Match, ScratchPad, Screen)
from libqtile.lazy import lazy

import dynamic_screens
import gruvbox

MOD = "mod4"
TERMINAL = os.path.expanduser("~/.cargo/bin/alacritty")

keys = [
    # Switch between windows
    Key([MOD], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([MOD], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([MOD], "j", lazy.layout.down(), desc="Move focus down"),
    Key([MOD], "k", lazy.layout.up(), desc="Move focus up"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    KeyChord(
        [MOD],
        "s",
        [
            Key([], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
            Key([], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
            Key([], "j", lazy.layout.shuffle_down(), desc="Move window down"),
            Key([], "k", lazy.layout.shuffle_up(), desc="Move window up"),
            Key(["shift"], "h", lazy.layout.swap_column_left(), desc="Column left"),
            Key(["shift"], "l", lazy.layout.swap_column_right(), desc="Column right"),
            Key([], "t", lazy.layout.toggle_split(), desc="Toggle split"),
        ],
        mode=True,
        name="Shuffle Windows",
    ),
    Key([MOD], "Return", lazy.spawn(TERMINAL)),
    # Toggle between different layouts as defined below
    Key([MOD], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([MOD, "shift"], "c", lazy.window.kill(), desc="Kill focused window"),
    # KeyChord for Qtile management.
    KeyChord(
        [MOD],
        "q",
        [
            Key([], "q", lazy.reload_config(), desc="Reload the config"),
            Key([], "r", lazy.restart(), desc="Reload Qtile"),
            Key([], "s", lazy.shutdown(), desc="Shutdown Qtile"),
        ],
        name="Qtile Commander",
    ),
]

comms = [
    Match(title=re.compile(r"google\schat", flags=re.IGNORECASE)),
    Match(title=re.compile(r"google\scalendar", flags=re.IGNORECASE)),
    Match(title=re.compile(r"gmail.*inbox", flags=re.IGNORECASE)),
]
music = [Match(wm_class=re.compile("spotify", flags=re.IGNORECASE))]
graphics = [Match(wm_class=re.compile("gimp", flags=re.IGNORECASE))]

group_specs = {
    "1.COM": {"layout": "max", "matches": comms},
    "2.DEV": {"layout": "columns"},
    "3.FOC": {"layout": "columns"},
    "4.ONC": {"layout": "columns"},
    "5.PER": {"layout": "columns"},
    "6.NTE": {"layout": "columns"},
    "7.AUD": {"layout": "columns", "matches": music},
    "8.GFX": {"layout": "monadtall", "matches": graphics},
}

groups = [Group(name, **config) for name, config in group_specs.items()]

for i, g in enumerate(groups, start=1):
    keys.extend(
        [
            # mod+num of group = switch to group
            Key(
                [MOD],
                str(i),
                lazy.group[g.name].toscreen(),
                desc=f"Switch to group {g.name}",
            ),
            # mod+shift+num of group = switch to & move focused window to group
            Key(
                [MOD, "shift"],
                str(i),
                lazy.window.togroup(g.name),
                desc="Move focused window to group {}".format(g.name),
            ),
        ]
    )


float_rules = [
    # Load default float_rules.
    *layout.Floating.default_float_rules,
    # Run `xprop` and click on a X window to see the `wm_class`.
    Match(wm_class="confirmreset"),  # gitk
    Match(wm_class="makebranch"),  # gitk
    Match(wm_class="maketag"),  # gitk
    Match(wm_class="ssh-askpass"),  # ssh-askpass
    Match(title="branchdialog"),  # gitk
    Match(title="pinentry"),  # GPG key password entry
    Match(wm_class="Pavucontrol"),  # Pulse Audio Control
]

layout_theme = {
    "margin": 5,
    "border_width": 3,
    "border_focus": gruvbox.neutral_red,
    "border_normal": gruvbox.gray_245,
}

layouts = [
    # layout.Floating(float_rules=float_rules, **layout_theme),
    layout.Columns(**layout_theme),
    layout.Max(
        margin=0,
        border_width=1,
        border_focus=layout_theme["border_focus"],
        border_normal=layout_theme["border_normal"],
    ),
    layout.MonadTall(**layout_theme),
]

widget_defaults = dict(
    font="Hack Nerd Font",
    fontsize=16,
    padding=3,
    background=gruvbox.dark0,
    foreground=gruvbox.light1,
)

extension_defaults = widget_defaults.copy()

task_list_theme = dict(
    border=gruvbox.dark2,
    borderwidth=1,
    foreground=gruvbox.light1,
    highlight_method="block",
    spacing=1,
    theme_mode="fallback",
    title_width_method="uniform",
    urgent_border=gruvbox.neutral_orange,
)

groupbox_theme = dict(
    active=gruvbox.light4,
    block_highlight_text_color=gruvbox.light0,
    highlight_method="block",
    inactive=gruvbox.dark2,
    other_current_screen_border=gruvbox.dark3,
    other_screen_border=gruvbox.dark3,
    this_current_screen_border=gruvbox.faded_aqua,
    this_screen_border=gruvbox.dark3,
    urgent_alert_method="block",
    urgent_border=gruvbox.neutral_orange,
    urgent_text="**",
)

sep = widget.Sep(size_percent=50)
chord = widget.Chord(
    chords_colors={
        "Shuffle Windows": (gruvbox.neutral_green, gruvbox.light1),
        "Resize Windows": (gruvbox.neutral_blue, gruvbox.light1),
        "Qtile Commander": (gruvbox.neutral_red, gruvbox.light1),
    },
    name_transform=lambda name: name.upper(),
)

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.GroupBox(**groupbox_theme),
                sep,
                widget.TaskList(**task_list_theme),
                sep,
                chord,
                sep,
                widget.CurrentLayout(),
                sep,
                widget.Systray(),
                sep,
                widget.Clock(format="%Y-%m-%d %a %H:%M"),
                widget.CurrentLayoutIcon(),
            ],
            size=28,
            opacity=0.9,
        ),
    ),
]

monitors: int = dynamic_screens.get_num_monitors()
if monitors > 1:
    for m in range(monitors - 1):
        screens.append(
            Screen(
                top=bar.Bar(
                    widgets=[
                        widget.GroupBox(**groupbox_theme),
                        sep,
                        widget.TaskList(**task_list_theme),
                        sep,
                        chord,
                        sep,
                        widget.Wallpaper(
                            directory="~/Pictures/wallpapers/",
                            label="WP",
                            random_selection=True,
                        ),
                        sep,
                        widget.CurrentLayout(),
                        widget.CurrentLayoutIcon(),
                    ],
                    size=28,
                    opacity=0.9,
                ),
            ),
        )

# Drag floating layouts.
mouse = [
    Drag(
        [MOD],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [MOD], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click([MOD], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules: List = []
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(float_rules=float_rules)
auto_fullscreen = True
auto_minimize = True
focus_on_window_activation = "urgent"
reconfigure_screens = True

# java that happens to be on java's whitelist.
wmname = "LG3D"

################
# User additions
################


# Keybindings for general commands.
class Commands:
    rofi_combi = "rofi -show combi"
    rofi_run = "rofi -show run"
    rofi_windows = "rofi -show window"
    dunst_close_top = "dunstctl close"
    dunst_close_all = "dunstctl close-all"
    dunst_history = "dunstctl history-pop"
    emoji_picker = "env NO_CLEANUP=true emoji-picker --appimage-extract-and-run"
    filemgr = "nemo"


keys.extend(
    [
        Key([MOD], "r", lazy.spawn(Commands.rofi_combi)),
        Key([MOD, "shift"], "p", lazy.spawn(Commands.rofi_run)),
        Key([MOD, "control"], "p", lazy.spawn(Commands.rofi_windows)),
        Key([MOD], "space", lazy.spawn(Commands.dunst_close_top)),
        Key([MOD, "shift"], "space", lazy.spawn(Commands.dunst_close_all)),
        Key([MOD, "control"], "space", lazy.spawn(Commands.dunst_history)),
        Key([MOD], "e", lazy.spawn(Commands.emoji_picker)),
        Key([MOD], "f", lazy.spawn(Commands.filemgr)),
    ]
)


# ScratchPad and DropDown
groups.append(
    ScratchPad(
        name="scratchpad",
        dropdowns=[
            # drop down terminal
            DropDown(name="term", cmd=TERMINAL, opacity=0.95, height=0.55, width=0.80),
            # qshell terminal
            DropDown(
                name="qshell",
                cmd=f"{TERMINAL} --hold -e qtile shell",
                x=0.05,
                y=0.4,
                width=0.9,
                height=0.6,
                opacity=0.95,
                on_focus_lost_hide=True,
            ),
        ],
    )
)

# define keys to toggle the dropdown terminals
keys.extend(
    [
        Key([MOD], "F12", lazy.group["scratchpad"].dropdown_toggle("term")),
        Key([MOD], "F11", lazy.group["scratchpad"].dropdown_toggle("qshell")),
    ]
)


# Media Keys
keys.extend(
    [
        # Media Player
        Key([], "XF86AudioNext", lazy.spawn("mpc next")),
        Key([], "XF86AudioPrev", lazy.spawn("mpc prev")),
        Key([], "XF86AudioPlay", lazy.spawn("mpc toggle")),
        Key([], "XF86AudioStop", lazy.spawn("mpc stop")),
        Key([MOD], "XF86AudioRaiseVolume", lazy.spawn("mpc volume +5")),
        Key([MOD], "XF86AudioLowerVolume", lazy.spawn("mpc volume -5")),
        # General Volume Control
        Key(
            [],
            "XF86AudioRaiseVolume",
            lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%"),
        ),
        Key(
            [],
            "XF86AudioLowerVolume",
            lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%"),
        ),
        Key(
            [], "XF86AudioMute", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
        ),
        Key(
            [],
            "XF86AudioMicMute",
            lazy.spawn("pactl set-source-mute @DEFAULT_SOURCE@ toggle"),
        ),
        # Monitor Brightness
        Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl set +2%")),
        Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl set 2%-")),
        # Screenshot: Full screen
        Key(
            [MOD],
            "Print",
            lazy.spawn(
                "maim -u ~/Pictures/screenshots/screen_$(date +%Y-%m-%d-%T).png"
            ),
        ),
        # Screenshot: Select area
        Key(
            [MOD, "shift"],
            "Print",
            lazy.spawn("maim -s ~/Pictures/screenshots/area_$(date +%Y-%m-%d-%T).png"),
        ),
        # Screenshot: Active window
        Key(
            [MOD, "control"],
            "Print",
            lazy.spawn(
                "maim -u -i $(xdotool getactivewindow) ~/Pictures/screenshots/window_$(date +%Y-%m-%d-%T).png"
            ),
        ),
    ]
)

# Grow windows. If current window is on the edge of screen and direction
# will be to screen edge - window would shrink.
keys.extend(
    [
        KeyChord(
            [MOD],
            "w",
            [
                Key(
                    [],
                    "l",
                    lazy.layout.grow_right(),
                    lazy.layout.grow(),
                    lazy.layout.increase_ratio(),
                    lazy.layout.delete(),
                    desc="Grow window to the right",
                ),
                Key(
                    [],
                    "h",
                    lazy.layout.grow_left(),
                    lazy.layout.shrink(),
                    lazy.layout.decrease_ratio(),
                    lazy.layout.add(),
                    desc="Grow window to the left",
                ),
                Key(
                    [],
                    "k",
                    lazy.layout.grow_up(),
                    lazy.layout.grow(),
                    lazy.layout.decrease_nmaster(),
                    desc="Grow window up",
                ),
                Key(
                    [],
                    "j",
                    lazy.layout.grow_down(),
                    lazy.layout.shrink(),
                    lazy.layout.increase_nmaster(),
                    desc="Grow window down",
                ),
                Key(
                    [], "n", lazy.layout.normalize(), desc="Soft reset all window sizes"
                ),
                Key([], "r", lazy.layout.reset(), desc="Hard-reset all window sizes"),
            ],
            mode=True,
            name="Resize Windows",
        ),
        Key(
            [MOD],
            "z",
            lazy.window.toggle_fullscreen(),
            desc="Toggle window full-screen.",
        ),
        Key(
            [MOD, "shift"],
            "f",
            lazy.window.toggle_floating(),
            desc="Toggle window floating.",
        ),
    ]
)


def lock_screen(qtile):
    """Locks the screen."""
    cmd = os.path.expanduser("~/.config/qtile/screenlock.sh")
    subprocess.run(cmd, shell=True, check=True)


# Screen lock
keys.extend(
    [
        Key([MOD, "shift"], "l", lazy.function(lock_screen)),
    ]
)
