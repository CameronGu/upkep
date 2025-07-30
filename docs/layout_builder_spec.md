# Layout Builder v1.2 — Specification

*(upKep Linux CLI Output System – supersedes v1.1, 2025‑07‑29)*

> **Why this revision?** Adds the concrete code snippets, JSON examples, roadmap, and ASCII‑fallback rules that existed in v1.0 but were trimmed in v1.1, while keeping all gap‑fixes from the July 2025 audit.

---

## 0 Purpose

Provide a **declarative, responsive, accessibility‑aware** engine for rendering Unicode **or ASCII‑fallback** boxes, tables, progress widgets, and status lines from inline JSON — **Bash 5 + Python 3 std‑lib only**.

---

## 1 File Overview

| Path                            | Role                                                                   |
| ------------------------------- | ---------------------------------------------------------------------- |
| `scripts/core/box_builder.sh`   | DSL primitives: `box_new`, `row_new`, `box_render`, style helpers      |
| `scripts/core/layout_loader.sh` | JSON → tokens → builder; width cache; traps `SIGWINCH`                 |
| `scripts/core/width_helpers.py` | `wcwidth`‑based display‑width helper                                   |
| `scripts/core/palette.sh`       | Emoji & colour maps (default + colour‑blind)                           |
| `utils.sh` (legacy bridge)      | `create_box()` / `create_summary_box()` proxy to builder (kept ≤ v3.1) |
| `docs/layout_builder_spec.md`   | **This document**                                                      |
| `tests/layout_*.bats`           | Acceptance tests                                                       |
| `examples/update_module.sh`     | Minimal demo using inline JSON                                         |

---

## 2 Colour & Emoji Palettes

### 2.1 Semantic Maps

```bash
# scripts/core/palette.sh
declare -Ag EMOJI_MAP_DEFAULT=(
  [success]="✅"  [error]="❌"  [warning]="❗"
  [running]="🔄"  [pending]="⏳"
)

declare -Ag EMOJI_MAP_CB=(
  [success]="✔"  [error]="✖"  [warning]="!"
  [running]="~"  [pending]="…"
)

declare -Ag COLOR_MAP_DEFAULT=(
  [success]="32" [error]="31" [warning]="33"
  [info]="36"   [pending]="35" [reset]="0"
)

declare -Ag COLOR_MAP_CB=(
  [success]="97;1" [error]="31;1" [warning]="34"
  [info]="37"    [pending]="35" [reset]="0"
)
```

### 2.2 Raw ANSI Constants

`utils.sh` also exposes `RED`, `GREEN`, `YELLOW`, `BLUE`, `MAGENTA`, `CYAN`, `WHITE`, and `NC` (no‑color). The builder resolves **semantic → raw** at render‑time so both layers remain usable.

---

## 3 JSON Descriptor Schema

| Key        | Type                   | Default         | Notes                   |
| ---------- | ---------------------- | --------------- | ----------------------- |
| `width`    | int                    | `tput cols – 2` | Clamped **≥ 80 cols**.  |
| `title`    | string                 | `""`            | Centred in top border.  |
| `style`    | enum                   | `"info"`        | Palette lookup.         |
| `gap`      | int                    | `1`             | Spaces between columns. |
| `overflow` | `"wrap" \| "ellipsis"` | `"ellipsis"`    | Cell‑wide default.      |
| `rows`\*   | array<Row>             | —               | **Required**.           |

`Row` may specify an `align` array (`["left","right",…]`).

### 3.3 Cell Variants

*Single component*

```json
{ "emoji": "success" }
{ "text" : "APT 45 pkgs" }
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

## 4 Builder DSL (Shell API)

```bash
# Box & rows ----------------------------------------------------------
box_new       width title style         → box_id
row_new                                     → row_id
row_add_cell row_id cell_token
box_add_row  box_id row_id
box_render   box_id                        # prints box & \e[0m

# Tokens --------------------------------------------------------------
make_text  "string"        → "text;<payload>"
make_emoji success         → "emoji;success"
make_color success|reset   → "color;success"
```

`make_color reset` **must** emit ANSI `0` to guarantee colour reset after every render.

---

## 5 Layout Algorithms

### 5.1 Terminal Width & Resize

```bash
_term_cols() { COLUMNS=$(tput cols); }
trap _term_cols SIGWINCH
_term_cols   # initial cache
```

* Builder enforces a **minimum 80‑column** viewport; if narrower, it switches to compact mode.

### 5.2 Column Sizing

1. Compute **natural width** of each cell → `col_min` via `width_helpers.py`.
2. `total_min = Σ col_min + gap*(n‑1)`.
3. *If* `total_min ≤ box_inner` → distribute extra space **round‑robin**.
4. *Else* shrink columns proportionally **down to a 5‑char floor**.
5. Apply per‑cell overflow policy.

### 5.3 Overflow

```bash
fit_cell text width mode   # mode = wrap|ellipsis
```

* `ellipsis` appends `"…"`.
* `wrap` uses Python `textwrap.fill` (respecting word boundaries).

---

## 6 Border Styles

| DSL        | Glyphs (`TL‑H‑TR │ BL‑B‑BR`)       | ASCII Fallback | Legacy alias  |
| ---------- | ---------------------------------- | -------------- | ------------- |
| `major`    | `╭─╮ │ ╰─╯`                        | `+‑+ │ +‑+`    | *double‑line* |
| `minor`    | `┌─┐ │ └─┘`                        | `+-+ │ +-+`    | *single‑line* |
| `emphasis` | block `█` top/bot, light verticals | `###` rows     | *block*       |

### 6.1 Legacy Helpers

Variables such as `BOX_TOP_LEFT`, `BOX_HORIZONTAL`, etc. remain in `utils.sh`; `create_box()` / `create_summary_box()` transparently call the builder so existing scripts keep working **until v3.1**.

### 6.2 ASCII‑Fallback Rendering

If `UPKEP_ASCII=1` **or** the locale is non‑UTF‑8, the loader substitutes the fallback glyph set above. Add acceptance test `ascii_mode` for coverage.

---

## 7 Colour‑blind Mode

```bash
choose_palette() {
  if [[ $UPKEP_COLORBLIND == 1 ]]; then
    COLOR_MAP=COLOR_MAP_CB ; EMOJI_MAP=EMOJI_MAP_CB
  else
    COLOR_MAP=COLOR_MAP_DEFAULT ; EMOJI_MAP=EMOJI_MAP_DEFAULT
  fi
}
```

*Must run **once per `box_render`** to honour live toggles (CLI flag or env‑var).*

---

## 8 Progress Indicators

| Widget             | Frames / cadence                    | Behaviour                                                                                      |
| ------------------ | ----------------------------------- | ---------------------------------------------------------------------------------------------- |
| **Spinner**        | Braille `⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏`, **100 ms**    | Hides cursor, prints glyph → **backspace** → next glyph while PID alive, then restores cursor. |
| **Progress bar**   | 50 cells `█/░`, update every 100 ms | Rendered as a row inside the current box; inherits style colour.                               |
| **Quiet / no‑TTY** | static `…` dots, no animation       |                                                                                                |

---

## 9 Environment Variables (Appendix)

| Var                   | Purpose (default)                    |
| --------------------- | ------------------------------------ |
| `UPKEP_COLORBLIND`    | `1` = colour‑blind palette           |
| `UPKEP_ASCII`         | Force ASCII glyphs                   |
| `UPKEP_FORCE`         | Skip interval checks                 |
| `UPKEP_DRY_RUN`       | Print actions without executing      |
| `UPKEP_LOGGING_LEVEL` | `DEBUG` → `ERROR` (threshold `INFO`) |
| `UPKEP_LOG_TO_FILE`   | `true` enables file logging          |
| `UPKEP_LOG_FILE`      | Path (`~/.upkep/upkep.log`)          |

---

## 10 Acceptance Tests (Bats)

| ID                 | Objective                                            |
| ------------------ | ---------------------------------------------------- |
| `emoji_width`      | Icons align in 3‑row table                           |
| `color_bleed`      | Reset after each cell; borders remain default colour |
| `wrap_vs_ellipsis` | Cell overflow obeys descriptor                       |
| `composite_mixed`  | Colour switches inside composite cells               |
| `sigwinch_resize`  | Re‑render widths 80 → 120                            |
| `spinner_cadence`  | 10 frames ≈ 1 s (100 ms each)                        |
| `ascii_mode`       | Render using ASCII fallback                          |
| `palette_toggle`   | Render twice with CB env‑var flip                    |

---

## 11 Open Items (Future Phases)

* **Rich progress bars** per‑module (v3.1).
* **Interactive filters & drill‑down** once event loop is added (v3.1+).
* **Structured logging** JSON file output (planned v3.2).
* **Event‑loop dashboard** for live module status (Q4 2025).

---

## 12 Deprecation & Migration

Helpers `create_status_line`, `draw_box`, `create_box`, `create_summary_box` **proxy to builder until v3.1**. After that they emit a deprecation warning; removal slated for v3.2.

---

## 13 Example Snippet

```bash
cat <<'JSON' | render_layout_from_stdin
{
  "title": "System Update",
  "style": "info",
  "rows": [
    { "cells": [ { "emoji":"running" }, { "text":"Fetching package lists…" } ] },
    { "cells": [ { "emoji":"success" }, { "text":"APT: 45 upgraded" } ] },
    { "cells": [ { "emoji":"warning" }, { "composite": [
        { "color":"warning" }, { "text":"Snap: " },
        { "color":"error"   }, { "text":"3 held back" },
        { "color":"reset" } ] } ] }
  ]
}
JSON
```

---

## 14 Rich Visual Examples

The Layout Builder produces sophisticated, beautiful output that matches the visual quality of Taskmaster. Here are detailed examples of the intended visual design:

### Module Overview Table (Hierarchical)

```bash
╭─────────────── SYSTEM MAINTENANCE STATUS ────────────────╮
│ Module                │ Last Run    │ Status  │ Next Due │
├───────────────────────┼─────────────┼─────────┼──────────┤
│ Package Updates       │             │         │          │
│ ├─ APT                │ 2 days ago  │ ✅ Done │ 5 days   │
│ ├─ Snap               │ 2 days ago  │ ✅ Done │ 5 days   │
│ └─ Flatpak            │ 6 days ago  │ ⚠️  Due │ Now      │
│ System Cleanup        │             │         │          │
│ ├─ Package Cache      │ 1 day ago   │ ✅ Done │ 2 days   │
│ └─ Temp Files         │ 4 days ago  │ ⚠️  Due │ Now      │
│ Custom Modules        │             │         │          │
│ └─ Docker Cleanup     │ Never       │ 📋 New  │ Setup    │
╰───────────────────────┴─────────────┴─────────┴──────────╯
```

### Execution Summary Boxes

**Success Box:**
```bash
╭─────────────────── APT UPDATE COMPLETE ───────────────────╮
│                                                           │
│ ✅ 12 packages updated successfully                       │
│ ⏱️  Execution time: 42 seconds                            │
│ 📦 Updates: firefox (91.0), git (2.34), python3 (3.9.7)   │
│ 🔄 3 packages held back due to dependencies               │
│                                                           │
│ Next update due: 5 days (based on 7-day interval)         │
╰───────────────────────────────────────────────────────────╯
```

**Warning Box:**
```bash
╭─────────────────── FLATPAK UPDATE SKIPPED ────────────────╮
│                                                           │
│ ⚠️  Skipped - Last update was 2 days ago                  │
│ 📅 Configured interval: 7 days                            │
│ ⏭️  Next update scheduled: 5 days from now                │
│                                                           │
│ Use --force to override interval checking                 │
╰───────────────────────────────────────────────────────────╯
```

**Error Box:**
```bash
╭──────────────────── SNAP UPDATE FAILED ───────────────────╮
│                                                           │
│ ❌ Failed to refresh snaps                                │
│ ⏱️  Execution time: 15 seconds                            │
│ 🔍 Error: network timeout during download                 │
│ 💡 Suggestion: Check internet connection and retry        │
│                                                           │
│ View detailed logs: ~/.upkep/logs/snap_update.log         │
╰───────────────────────────────────────────────────────────╯
```

### Progress Indicators

**Real-time Execution:**
```bash
🔄 Updating APT repositories...
├─ Reading package lists... ✅ Done
├─ Building dependency tree... 🔄 In progress
└─ Reading state information... ⏳ Waiting

📦 Installing updates (12 packages)...
██████████▓▓▓▓▓▓▓▓▓▓ 52% (6/12) - Installing firefox...
```

**Step-by-Step Results:**
```bash
🔧 System Cleanup Operations:
├─ 🗑️  Removing unused packages... ✅ 23 packages removed
├─ 🧹 Cleaning package cache... ✅ 147MB freed  
├─ 📁 Emptying temp directories... ⚠️ 2 files skipped (in use)
└─ 🔄 Updating locate database... ✅ Complete

📊 Total space freed: 231MB
```

### Dashboard Status Display

```bash
╭───────────────────── upKep System Status ─────────────────────╮
│                                                               │
│ 🖥️  System: Ubuntu 22.04 LTS │ 🖥️ Last run: 2 hours ago       │
│ 💾 Disk: 89.4GB free         │ 📊 Total modules: 7            │
│                                                               │
╰───────────────────────────────────────────────────────────────╯

⚡ Quick Actions:
├─ upkep run           # Run all due operations
├─ upkep run --force   # Force run all operations  
├─ upkep status        # Show detailed status
└─ upkep config        # Configure settings

🎯 Due Now (2):
├─ Flatpak Update      │ Last run: 8 days ago
└─ Docker Cleanup      │ Last run: Never

✅ Recent Success (3):
├─ APT Update          │ 12 packages updated (2 hours ago)
├─ Package Cleanup     │ 23 packages removed (2 hours ago)
└─ System Files        │ 147MB freed (2 hours ago)
```

### ASCII Art Header

```bash
                                888 88P                  
            8888 8888 888 888e  888 8P   ,e e,  888 888e  
            8888 8888 888  888b 888 K   d88 88b 888  888b 
            Y888 888P 888  888P 888 8b  888   , 888  888P 
             "88 88"  888 888"  888 88b  "YeeP" 888 888"  
                      888                       888      
                      888                       888      
                        -upKep Linux Maintainer-
                              by CameronGu
```

### Section Headers & Dividers

```bash
═══════════════════ PACKAGE UPDATES ═══════════════════

─────────────────── System Cleanup ───────────────────

▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ EXECUTION RESULTS ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
```

**Visual Design Principles:**
- **Rich Unicode borders** with proper corner characters
- **Semantic color coding** for immediate status recognition
- **Hierarchical information** with clear visual grouping
- **Emoji icons** for quick visual scanning
- **Proper spacing** and alignment for readability
- **Consistent visual language** across all components

---

## 15 Spec Metadata

*Version 1.2 • Authors: upKep dev team • Last updated: 2025‑07‑29*
