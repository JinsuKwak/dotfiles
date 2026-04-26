#!/usr/bin/env python3
from __future__ import annotations

import argparse
import ast
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
THEME_FILE = ROOT / "theme" / "theme.toml"
TMUX_DEFAULT_STATUS_FORMAT = "#[align=left range=left #{E:status-left-style}]#[push-default]#{T;=/#{status-left-length}:status-left}#[pop-default]#[norange default]#[list=on align=#{status-justify}]#[list=left-marker]<#[list=right-marker]>#[list=on]#{W:#[range=window|#{window_index} #{E:window-status-style}#{?#{&&:#{window_last_flag},#{!=:#{E:window-status-last-style},default}}, #{E:window-status-last-style},}#{?#{&&:#{window_bell_flag},#{!=:#{E:window-status-bell-style},default}}, #{E:window-status-bell-style},#{?#{&&:#{||:#{window_activity_flag},#{window_silence_flag}},#{!=:#{E:window-status-activity-style},default}}, #{E:window-status-activity-style},}}]#[push-default]#{T:window-status-format}#[pop-default]#[norange default]#{?loop_last_flag,,#{window-status-separator}},#[range=window|#{window_index} list=focus #{?#{!=:#{E:window-status-current-style},default},#{E:window-status-current-style},#{E:window-status-style}}#{?#{&&:#{window_last_flag},#{!=:#{E:window-status-last-style},default}}, #{E:window-status-last-style},}#{?#{&&:#{window_bell_flag},#{!=:#{E:window-status-bell-style},default}}, #{E:window-status-bell-style},#{?#{&&:#{||:#{window_activity_flag},#{window_silence_flag}},#{!=:#{E:window-status-activity-style},default}}, #{E:window-status-activity-style},}}]#[push-default]#{T:window-status-current-format}#[pop-default]#[norange list=on default]#{?loop_last_flag,,#{window-status-separator}}}#[nolist align=right range=right #{E:status-right-style}]#[push-default]#{T;=/#{status-right-length}:status-right}#[pop-default]#[norange default]"


def parse_value(raw_value: str):
    if raw_value.startswith('"') and raw_value.endswith('"'):
        return ast.literal_eval(raw_value)

    lowered = raw_value.lower()
    if lowered == "true":
        return True
    if lowered == "false":
        return False
    if re.fullmatch(r"-?\d+", raw_value):
        return int(raw_value)
    if re.fullmatch(r"-?\d+\.\d+", raw_value):
        return float(raw_value)

    return raw_value


def load_theme(path: Path) -> dict:
    data: dict = {}
    current = data

    for raw_line in path.read_text().splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue

        if line.startswith("[") and line.endswith("]"):
            current = data
            for part in line[1:-1].split("."):
                current = current.setdefault(part, {})
            continue

        key, raw_value = (part.strip() for part in line.split("=", 1))
        current[key] = parse_value(raw_value)

    return data


def write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content.strip() + "\n")


def bool_str(value: bool) -> str:
    return "true" if value else "false"


def set_names(theme: dict) -> list[str]:
    return sorted(theme["sets"].keys())


def active_set(theme: dict) -> tuple[str, dict]:
    name = theme.get("active_set") or theme.get("default_set")
    sets = theme["sets"]
    if name not in sets:
        available = ", ".join(set_names(theme))
        raise SystemExit(f"Unknown active_set: {name}\nAvailable sets: {available}")
    return name, sets[name]


def resolve(value, tokens: dict):
    if isinstance(value, str) and value in tokens:
        return tokens[value]
    return value


def section_value(theme: dict, section: str, key: str, tokens: dict):
    return resolve(theme[section][key], tokens)


def tmux_style(fg: str, bg: str = "default") -> str:
    return f"#[fg={fg},bg={bg}]"


def tmux_pill(
    *,
    icon: str,
    text: str,
    icon_bg: str,
    icon_fg: str,
    text_bg: str,
    text_fg: str,
    left: str,
    right: str,
) -> str:
    return (
        f"{tmux_style(icon_bg)}{left}"
        f"{tmux_style(icon_fg, icon_bg)}{icon}"
        f"{tmux_style(icon_bg, icon_bg)} "
        f"{tmux_style(text_bg, text_bg)} "
        f"{tmux_style(text_fg, text_bg)}{text}"
        f"{tmux_style(text_bg)}{right}"
    )


def tmux_window_pill(
    *,
    number_bg: str,
    number_fg: str,
    text_bg: str,
    text_fg: str,
    text: str,
    left: str,
    right: str,
) -> str:
    return (
        f"{tmux_style(number_bg)}{left}"
        f"{tmux_style(number_fg, number_bg)}#I"
        f"{tmux_style(number_bg, number_bg)} "
        f"{tmux_style(text_bg, text_bg)} "
        f"{tmux_style(text_fg, text_bg)}{text}"
        f"{tmux_style(text_bg)}{right}"
    )


def update_active_set(name: str) -> None:
    theme = load_theme(THEME_FILE)
    if name not in theme["sets"]:
        available = ", ".join(set_names(theme))
        raise SystemExit(f"Unknown theme set: {name}\nAvailable sets: {available}")

    text = THEME_FILE.read_text()
    text = re.sub(r'^active_set\s*=\s*"[^"]+"', f'active_set = "{name}"', text, count=1, flags=re.M)
    THEME_FILE.write_text(text)


def build_ghostty(theme: dict, tokens: dict) -> str:
    ui = theme["ui"]
    ghostty = theme["ghostty"]
    return f"""
theme = dark:{resolve(ghostty["theme_dark"], tokens)},light:{resolve(ghostty["theme_light"], tokens)}
font-family = {ui["font_family"]}
font-size = {ui["font_size"]}
background = {resolve(ghostty["background"], tokens)}
foreground = {resolve(ghostty["foreground"], tokens)}
background-opacity = {ui["background_opacity"]}
background-blur = {ui["background_blur"]}
background-opacity-cells = {bool_str(ui["background_opacity_cells"])}
title = "{ui["title"]}"
macos-option-as-alt = {ui["macos_option_as_alt"]}
mouse-hide-while-typing = {bool_str(ui["mouse_hide_while_typing"])}
copy-on-select = {ui["copy_on_select"]}
clipboard-read = {ui["clipboard_read"]}
clipboard-write = {ui["clipboard_write"]}
window-decoration = {ui["window_decoration"]}
macos-window-buttons = {ui["macos_window_buttons"]}
macos-titlebar-proxy-icon = {ui["macos_titlebar_proxy_icon"]}
window-padding-x = {ui["window_padding_x"]}
window-padding-y = {ui["window_padding_y"]}
shell-integration = {ui["shell_integration"]}
shell-integration-features = {ui["shell_integration_features"]}
keybind = {ui["quick_terminal_keybind"]}
keybind = {ui["new_tab_keybind"]}
keybind = {ui["close_surface_keybind"]}
keybind = {ui["fullscreen_keybind"]}
"""


def build_tmux_theme(theme: dict, tokens: dict) -> str:
    tmux = theme["tmux"]
    icon_fg = resolve(tmux["icon_fg"], tokens)
    text_fg = resolve(tmux["text_fg"], tokens)
    text_bg = resolve(tmux["text_bg"], tokens)
    left = tmux["pill_left"]
    right = tmux["pill_right"]
    gap = tmux["pill_gap"]

    session = tmux_pill(
        icon=tmux["session_icon"],
        text=tmux["session_text"],
        icon_bg=resolve(tmux["session_icon_bg"], tokens),
        icon_fg=icon_fg,
        text_bg=text_bg,
        text_fg=text_fg,
        left=left,
        right=right,
    )
    directory = tmux_pill(
        icon=tmux["directory_icon"],
        text=tmux["directory_text"],
        icon_bg=resolve(tmux["directory_icon_bg"], tokens),
        icon_fg=icon_fg,
        text_bg=text_bg,
        text_fg=text_fg,
        left=left,
        right=right,
    )
    time = tmux_pill(
        icon=tmux["time_icon"],
        text=tmux["time_text"],
        icon_bg=resolve(tmux["time_icon_bg"], tokens),
        icon_fg=icon_fg,
        text_bg=text_bg,
        text_fg=text_fg,
        left=left,
        right=right,
    )
    spinner_fg = resolve(tmux["command_spinner_fg"], tokens)
    spinner = (
        f"#{{?#{{@pane_command_spinner}},"
        f"{gap}#[bg=default]#[fg={spinner_fg}]#{{@pane_command_spinner}}#[fg={text_fg}]#[bg=default]{tmux['status_right_padding']},"
        f"{tmux['status_right_padding']}}}"
    )
    window = tmux_window_pill(
        number_bg=resolve(tmux["window_icon_bg"], tokens),
        number_fg=icon_fg,
        text_bg=text_bg,
        text_fg=text_fg,
        text=tmux["window_text"],
        left=left,
        right=right,
    )
    current_window = tmux_window_pill(
        number_bg=resolve(tmux["window_current_icon_bg"], tokens),
        number_fg=icon_fg,
        text_bg=text_bg,
        text_fg=text_fg,
        text=tmux["window_current_text"],
        left=left,
        right=right,
    )

    return f"""
set -g @catppuccin_flavor "{resolve(tmux["flavor"], tokens)}"

set -g status 2
set -g status-style "fg={text_fg},bg=default"
set -g status-format[0] "{TMUX_DEFAULT_STATUS_FORMAT}"
set -g status-format[1] ""
set -g status-left-length 100
set -g status-right-length 100
set -g status-left "{tmux["status_left_padding"]}{session}{gap}"
set -g status-right "{directory}{gap}{time}{spinner}"
setw -g window-status-separator "{gap}"
setw -g window-status-format "{window}"
setw -g window-status-current-format "{current_window}"
"""


def build_nvim_theme(theme: dict, tokens: dict) -> str:
    ui = theme["ui"]
    colorscheme = section_value(theme, "nvim", "colorscheme", tokens)
    return f"""
return {{
  colorscheme = "{colorscheme}",
  transparent_background = {str(ui["nvim_transparent_background"]).lower()},
}}
"""


def update_tv_config(theme: dict, tokens: dict) -> None:
    config_path = ROOT / "television" / ".config" / "television" / "config.toml"
    text = config_path.read_text()

    tv = theme["tv"]
    start = "# @generated theme:start"
    end = "# @generated theme:end"
    generated = f"""{start}
theme = "{resolve(tv["theme"], tokens)}"
[ui.theme_overrides]
background = "{resolve(tv["background"], tokens)}"
text_fg = "{resolve(tv["text_fg"], tokens)}"
selection_bg = "{resolve(tv["selection_bg"], tokens)}"
{end}"""

    if start not in text or end not in text:
        text = text.replace('theme = "catppuccin"', generated, 1)
    else:
        text = re.sub(rf"{re.escape(start)}.*?{re.escape(end)}", generated, text, flags=re.S)

    config_path.write_text(text)


def render(theme: dict) -> None:
    _, tokens = active_set(theme)
    write(ROOT / "ghostty" / ".config" / "ghostty" / "config", build_ghostty(theme, tokens))
    write(ROOT / "tmux" / ".config" / "tmux" / "theme.conf", build_tmux_theme(theme, tokens))
    write(ROOT / "nvim" / ".config" / "nvim" / "lua" / "config" / "theme.lua", build_nvim_theme(theme, tokens))
    update_tv_config(theme, tokens)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate app configs from theme/theme.toml token sets")
    parser.add_argument("--list", action="store_true", help="List available theme sets")
    parser.add_argument("--set", dest="theme_set", help="Switch active_set and render")
    parser.add_argument("--preset", dest="legacy_preset", help="Alias for --set")
    parser.add_argument("--reset", action="store_true", help="Switch back to default_set and render")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    theme = load_theme(THEME_FILE)

    if args.list:
        for name in set_names(theme):
            print(name)
        return

    selected = args.theme_set or args.legacy_preset
    if args.reset:
        selected = theme["default_set"]

    if selected:
        update_active_set(selected)
        theme = load_theme(THEME_FILE)

    render(theme)


if __name__ == "__main__":
    try:
        main()
    except BrokenPipeError:
        sys.exit(0)
