# upKep UI & Layout Design (v3.0)

*Last updated 2025‑07‑27 – supersedes all prior versions*

---

## 1 Executive Summary

The v3.0 design formalises a **builder‑based, JSON‑driven** layout engine that renders responsive Unicode boxes, tables and progress indicators while remaining 100 % Bash 5 + Python 3‑std‑lib only. It replaces the legacy component‑string system and fixes historical emoji‑width and colour‑bleed issues.

---

## 2 Visual Identity & Accessibility

### 2.1 Semantic Palettes

| Palette          | Source map                               | Notes                                       |
| ---------------- | ---------------------------------------- | ------------------------------------------- |
| **Default**      | `EMOJI_MAP_DEFAULT`, `COLOR_MAP_DEFAULT` | Full‑colour glyphs & ANSI codes             |
| **Colour‑blind** | `EMOJI_MAP_CB`, `COLOR_MAP_CB`           | Text/symbol fallbacks, high‑contrast ANSI‑8 |

A global flag `UPKEP_COLORBLIND` (config + CLI) instructs the renderer to pick the CB palette at runtime.

### 2.2 Contrast targets

* Min. 7:1 background/foreground ratio 【8†file-HtBczns8113i69vBiLLJ5W†L53-L58】.

---

## 3 Layout Builder Overview

All CLI output is produced by four core files:

```
scripts/core/
  ├─ box_builder.sh      # DSL primitives (box_new … box_render)
  ├─ layout_loader.sh    # JSON→tokens→builder + SIGWINCH + overflow
  ├─ width_helpers.py    # wcwidth‑based display‑width helper
  └─ palette.sh          # colour & emoji maps (default + CB)
```

A complete spec lives in **docs/layout\_builder\_spec.md**.

### 3.1 JSON descriptor (inline heredoc)

```bash
cat <<'JSON' | render_layout_from_stdin
{
  "title": "System Update",
  "style": "info",
  "gap": 1,
  "rows": [
    { "cells": [ { "emoji":"running" },
                  { "text":"Fetching package lists…" } ] },
    { "cells": [ { "emoji":"success" },
                  { "text":"APT: 45 upgraded" } ] },
    { "cells": [ { "emoji":"warning" },
                  { "composite": [
                      { "color":"warning" }, { "text":"Snap " },
                      { "color":"error"   }, { "text":"held back" },
                      { "color":"reset"   } ] } ] }
  ]
}
JSON
```

### 3.2 Builder DSL

```bash
box=$(box_new 0 "Maintenance" info)  # width 0 ⇒ auto tput cols
row=$(row_new)
row_add_cell "$row" "$(make_emoji success)"
row_add_cell "$row" "$(make_text 'All good')"
box_add_row  "$box" "$row"
box_render   "$box"
```

---

## 4 Responsive Rules

* **Box width** = `tput cols` – 2 unless `width` specified.
* **Column sizing** – natural width + gap; proportional shrink if overflow.
* **Breakpoints** – if terminal < 100 cols, auto‑switch to compact header set.

---

## 5 Border & Section Styles

| Preset     | Chars     | Use                                      |
| ---------- | --------- | ---------------------------------------- |
| `major`    | ╭─╮ │ ╰─╯ | Top‑level modules / ASCII header wrapper |
| `minor`    | ┌─┐ │ └─┘ | Sub‑tables                               |
| `emphasis` | ▓█        | Result blocks                            |

Modules call `box_set_style box_id major|minor|emphasis`.

---

## 6 Progress & Animation

* Spinner – 200 ms / frame (`🔄` or `~` in CB mode).
* Progress bar – 50‑cell row inside builder box; obeys colour palette.
* When `--quiet` or non‑TTY: static dots instead of animation.

---

## 7 ASCII Art Header

Stored in `scripts/helpers/ascii_header.txt` and rendered via:

```bash
header=$(<scripts/helpers/ascii_header.txt)
render_layout_from_stdin <<< "{\"style\":\"major\",\"rows\":[{\"cells\":[{\"text\":$header}] }] }"
```

This ensures centring & palette compliance.

---

## 8 Testing Targets (Bats)

1. Emoji width alignment without width hints.
2. Colour bleed prevention.
3. Wrap vs ellipsis overflow.
4. Composite mixed‑colour cell rendering.
5. SIGWINCH resize 80 → 120.

---

## 9 Migration Notes

* Tag `v0.2.0-pre-refactor` is the last version using the legacy formatter.
* `create_status_line`, `draw_box`, etc. now call the builder internally – existing modules remain functional.

---

## 10 Roadmap (excerpt)

* **v3.1** – rich progress bars & interactive filters.
* **v3.2** – event‑loop dashboard (planned Q4 2025).
