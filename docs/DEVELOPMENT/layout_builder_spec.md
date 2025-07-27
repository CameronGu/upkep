Below is a ready-to-commit **`docs/layout_builder_spec.md`**.
Copy it into your repo (next to `DESIGN.md`) before starting the Cursor AI session.

````md
# Layout Builder v1.0 — Specification  
*(upKep Linux CLI Output System)*

---

## 0  Purpose

Introduce a **declarative, responsive, accessibility-aware** layout engine that
renders Unicode boxes, tables, and status lines from inline JSON.  
This replaces the brittle “component-string” approach while maintaining
zero external runtime dependencies (Bash 5 + Python 3.8 std-lib only).

---

## 1  File Overview

| Path | Role |
|------|------|
| `scripts/core/box_builder.sh` | Low-level DSL: create boxes, rows, cells. |
| `scripts/core/layout_loader.sh` | JSON → tokens → builder; handles width calc, SIGWINCH, overflow. |
| `scripts/core/width_helpers.py` | One‐liner helper returning display width via `wcwidth`. |
| `scripts/core/palette.sh` | Colour & emoji maps (normal + colour-blind). |
| `docs/layout_builder_spec.md` | **This document**. |
| `tests/layout_*.bats` | Acceptance tests. |
| `examples/update_module.sh` | Minimal demo using inline JSON. |

---

## 2  Colour & Emoji Palettes

### 2.1  Emoji (no width hints)

```bash
# scripts/core/palette.sh
declare -Ag EMOJI_MAP_DEFAULT=(
  [success]="✅"  [error]="❌"  [warning]="❗"
  [running]="🔄"  [pending]="⏳"
)

declare -Ag EMOJI_MAP_CB=(
  [success]="✔"  [error]="✖"  [warning]="!"   # text fallbacks
  [running]="~"  [pending]="…"
)
````

### 2.2  Colours (ANSI 8-color for CB compatibility)

```bash
declare -Ag COLOR_MAP_DEFAULT=(
  [success]="32"  [error]="31"  [warning]="33"
  [info]="36"     [pending]="35" [reset]="0"
)

declare -Ag COLOR_MAP_CB=(
  [success]="37;1"  # bright white
  [error]="31;1"    # bold red
  [warning]="34"    # blue
  [info]="37"       # white
  [pending]="35"    # magenta
  [reset]="0"
)
```

*Helper `choose_palette()` selects DEFAULT vs CB based on
`UPKEP_COLORBLIND=1` (set via config or `--colorblind` flag).*

---

## 3  JSON Descriptor Schema

### 3.1  Top-level keys

| Key        | Type                     | Default         | Notes                      |
| ---------- | ------------------------ | --------------- | -------------------------- |
| `width`    | int                      | `tput cols – 2` | Clamped to terminal width. |
| `title`    | string                   | `""`            | Centred inside top border. |
| `style`    | enum                     | `"info"`        | Lookup in colour map.      |
| `gap`      | int                      | `1`             | Spaces between columns.    |
| `overflow` | `"wrap"` \| `"ellipsis"` | `"ellipsis"`    | Cell-wide default.         |
| `rows`     | array<Row>               | **required**    | See below.                 |

### 3.2  Row object

```jsonc
{
  "align": ["left","right",...],   // optional per-column
  "cells": [ Cell, Cell, … ]
}
```

### 3.3  Cell variants

*Single component*

```json
{ "emoji": "success" }
{ "text" : "APT 45 pkgs" }
{ "color": "error" }
```

*Composite (ordered mix)*

```json
{ "composite": [
    { "color":"success" }, { "text":"Snap " },
    { "color":"error"   }, { "text":"held back" },
    { "color":"reset"   }
  ],
  "overflow": "wrap"   // optional override
}
```

---

## 4  Builder DSL (API)

```bash
# Box & rows ----------------------------------------------------------
box_new       width title style          → box_id
row_new                                       → row_id
row_add_cell row_id cell_token
box_add_row  box_id row_id
box_render   box_id                           # → prints box

# Tokens ----------------------------------------------------------------
make_text   "string"          → "text;<payload>"
make_emoji  success           → "emoji;success"
make_color  success|reset     → "color;success"
```

After render, the engine **always emits `\e[0m`** to reset colour.

---

## 5  Layout Algorithms

### 5.1  Terminal width & resize

```bash
_term_cols() { COLUMNS=$(tput cols); }
trap _term_cols SIGWINCH
_term_cols   # initial cache
```

### 5.2  Column sizing

1. **Natural width** of each cell ↦ `width_helpers.py`.
2. `col_min = max(natural widths)`
   `total_min = ∑col_min + gap*(n_cols-1)`
3. If `total_min ≤ box_inner_width`
   *distribute* extra space evenly (round-robin).
4. Else shrink columns proportionally down to 5 chars min.
5. Apply per-cell overflow policy.

### 5.3  Overflow

*Bash wrapper around Python*

```bash
fit_cell text width mode   # mode = wrap|ellipsis
```

`ellipsis` appends `"…"`; `wrap` uses `textwrap.fill`.

---

## 6  Border Styles

| Name       | Characters                             |
| ---------- | -------------------------------------- |
| `major`    | `╭─╮ │ ╰─╯`                            |
| `minor`    | `┌─┐ │ └─┘`                            |
| `emphasis` | Blocks `█` top/bottom, light verticals |

Helper: `box_set_style box_id major|minor|emphasis`

---

## 7  Colour-blind Mode

```bash
if [[ $UPKEP_COLORBLIND == 1 ]]; then
  COLOR_MAP=COLOR_MAP_CB
  EMOJI_MAP=EMOJI_MAP_CB
else
  COLOR_MAP=COLOR_MAP_DEFAULT
  EMOJI_MAP=EMOJI_MAP_DEFAULT
fi
```

*Must be evaluated **once per render** so toggling via sub-command
takes effect in the same session.*

---

## 8  Progress Indicators (Phase 1)

* Spinner (200 ms) → prints `"🔄"` → backspace → next char.
* Progress bar → boxed row, 50 cells wide, uses style colour.
* When `--quiet` or `NO_TTY`, fall back to static dots.

---

## 9  Acceptance Tests (Bats)

| Test ID            | Description                                      |
| ------------------ | ------------------------------------------------ |
| `emoji_width`      | All icons align in a 3-row table.                |
| `color_bleed`      | Border chars retain default colour.              |
| `wrap_vs_ellipsis` | Long text wraps or truncates per descriptor.     |
| `composite_mixed`  | Colour switches inside cell render correctly.    |
| `sigwinch_resize`  | Render widths adjust after `COLUMNS=80` → `120`. |

---

## 10  Example Snippet

```bash
cat <<'JSON' | render_layout_from_stdin
{
  "title": "System Update",
  "style": "info",
  "rows": [
    { "cells": [ { "emoji":"running" },
                 { "text":"Fetching package lists…" } ] },
    { "cells": [ { "emoji":"success" },
                 { "text":"APT: 45 upgraded" } ] },
    { "cells": [ { "emoji":"warning" },
                 { "composite":[
                     { "color":"warning" }, { "text":"Snap: " },
                     { "color":"error"   }, { "text":"3 held back" },
                     { "color":"reset"   } ] } ] }
  ]
}
JSON
```

---

## 11  Open Items (future phases)

* Rich progress bars per-module.
* Interactive filters & drill-down once event loop is added.
* Configurable font (ASCII vs Unicode) for minimal terminals.

---

> **Spec version:** 1.0 • Author: upKep dev team • Last updated: 2025-07-27
