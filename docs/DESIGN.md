# upKep UI & Layout Design — Unified Reference (v3.0.1)

*Last updated 2025‑07‑29 – incorporates gap‑report fixes & utils parity*

---

## 1 Executive Summary

The v3.x series adopts a **builder‑based, JSON‑driven** renderer (Bash 5 + Python 3 std‑lib only) that unifies all CLI output—boxes, tables, progress—while guaranteeing Unicode alignment, ANSI reset, and colour‑blind accessibility. This document merges the low‑level layout spec with the higher‑level UX/CLI guidance previously found in v2.0.

---

## 2 Visual Identity & Accessibility

\### 2.1 Semantic Palettes

| Mode                                                                                                 | Emoji map           | Colour map          |
| ---------------------------------------------------------------------------------------------------- | ------------------- | ------------------- |
| **Default**                                                                                          | `EMOJI_MAP_DEFAULT` | `COLOR_MAP_DEFAULT` |
| **Colour‑blind**                                                                                     | `EMOJI_MAP_CB`      | `COLOR_MAP_CB`      |
| *Runtime toggle*: `UPKEP_COLORBLIND` env‑var **or** `--colorblind` CLI flag (flag takes precedence). |                     |                     |

\### 2.2 Contrast & Terminal Support

* ≥ 7 : 1 foreground/background ratio.
* Minimum terminal width **80 cols**; builder auto‑drops to ASCII borders when Unicode unsupported.

---

\## 3 Layout Builder Overview

| File               | Purpose                                                      |
| ------------------ | ------------------------------------------------------------ |
| `box_builder.sh`   | DSL primitives (`box_new`, `box_render`, `row_new`, …).      |
| `layout_loader.sh` | JSON → tokens → builder; caches `COLUMNS`, traps `SIGWINCH`. |
| `width_helpers.py` | `wcwidth` helper for display width.                          |
| `palette.sh`       | Emoji + colour maps & `choose_palette()`.                    |

\### 3.1 JSON Descriptor Schema (defaults)

| Key        | Type             | Default       | Notes                  |
| ---------- | ---------------- | ------------- | ---------------------- |
| `width`    | int              | `tput cols‑2` | Clamped to ≥80.        |
| `title`    | string           | `""`          | Centred in top border. |
| `style`    | enum             | `info`        | colour lookup.         |
| `gap`      | int              | **1**         | spaces between cols.   |
| `overflow` | `wrap\|ellipsis` | **ellipsis**  | cell‑wide default.     |
| `rows`     | array<Row>       | –             | required.              |

*Row* `{ "align":[…], "cells":[…] }`  *Cell* primitives `{"emoji":id}`, `{"text":str}`, `{"color":id}`, or `{"composite":[…],"overflow":"wrap"}`.

\### 3.2 Builder DSL (tokens)

```
box=$(box_new 0 "Title" info)
row=$(row_new)
row_add_cell "$row" "$(make_emoji success)"
row_add_cell "$row" "$(make_text 'OK')"
box_add_row  "$box" "$row"
box_render   "$box"        # always emits \e[0m to reset colour
```

*Helpers*: `make_text`, `make_emoji`, `make_color`, `fit_cell text width mode`.

\### 3.3 Sizing Algorithm

1. Natural width per cell ⇒ Python helper.
2. `col_min = max(natural widths)`; `total_min = Σ col_min + gap*(n‑1)`.
3. If `total_min ≤ box_inner` → distribute spare cols round‑robin.
4. Else shrink cols **proportionally but ≥ 5 chars** each.
5. Apply per‑cell overflow (wrap|ellipsis).

---

\## 4 Border & Section Styles

| Alias (v3)                 | Glyphs    | Legacy name (v2) |
| -------------------------- | --------- | ---------------- |
| `major`                    | ╭─╮ │ ╰─╯ | double‑line      |
| `minor`                    | ┌─┐ │ └─┘ | single‑line      |
| `emphasis`                 | ▓ █       | block            |
| \`box\_set\_style id major | minor     | emphasis\`       |

Legacy helpers `create_box()` & `create_summary_box()` now proxy to `box_builder.sh` and keep existing `BOX_*` glyph variables for drop‑in compatibility (supported at least until v3.1).

---

\## 5 Responsive Rules

* Default width = `tput cols‑2`.
* **Breakpoints**: `<100 cols` → compact headers; `≥100` full headers; no max but layout caps at 140 cols for readability.
* ASCII fallback when Unicode unavailable.

---

\## 6 Progress & Animation

* **Spinner**: Braille set ⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏, **100 ms/frame** (utils parity); `~` in CB mode.
* **Progress bar**: 50 cells (`█`/`░`), colour inherits parent style.
* Non‑TTY or `--quiet` → static dots, cursor remains visible.

---

\## 7 Core UI Components & Interaction Model
\### 7.1 Components

* **Module Overview Table** – columns *Module · Last Run · Status · Next Due* plus indented children.
* **Execution Summary Boxes** – success/warning/error variants with counts, duration, next‑due.
* **Progress Indicators** – live spinner/bar & per‑step log lines.
* **Dashboard Status Display** – system snapshot + quick actions + “Due Now/Recent Success”.

\### 7.2 CLI Commands (high‑level)

```
upkep run [--all|group]   # maintenance operations
upkep status [--json]     # dashboard / machine output
upkep dash                # interactive dashboard
upkep config [...]        # settings wizard / edit
```

Contextual suggestions & interactive filters mirror v2.0 behaviour.

---

\## 8 UX Enhancement Principles

* Category grouping, emoji+colour semantics.
* Time‑to‑complete estimation, performance deltas.
* Timeline preview (upcoming vs history) & smart hints.

---

\## 9 Logging & Diagnostics
Structured logging via `log_message()` in `utils.sh`.

* Levels: `DEBUG INFO WARN ERROR SUCCESS`  → filtered by `UPKEP_LOGGING_LEVEL`.
* Console always; optional file logging when `UPKEP_LOG_TO_FILE=true` (path `UPKEP_LOG_FILE`, default `~/.upkep/upkep.log`).
* Logs include timestamp, coloured level tag, optional context.

---

\## 10 Environment Variables (partial)

| Var                     | Purpose          | Default              |
| ----------------------- | ---------------- | -------------------- |
| `UPKEP_COLORBLIND`      | switch palette   | 0                    |
| `UPKEP_LOGGING_LEVEL`   | log filter       | INFO                 |
| `UPKEP_LOG_TO_FILE`     | enable file log  | false                |
| `UPKEP_LOG_FILE`        | file path        | `~/.upkep/upkep.log` |
| `UPKEP_DRY_RUN`         | simulate actions | false                |
| `UPKEP_FORCE`           | ignore intervals | false                |
| `UPKEP_UPDATE_INTERVAL` | override days    | config value         |

---

\## 11 Testing Targets (Bats)

1. Emoji width alignment.
2. ANSI reset (no colour bleed).
3. Wrap vs ellipsis overflow.
4. Mixed‑colour composite cells.
5. `SIGWINCH` resize 80→120.
6. Spinner cadence @ 100 ms.

---

\## 12 Migration Notes

* Final legacy formatter tag: **`v0.2.0-pre-refactor`**.
* Legacy helpers proxy until v3.1; migration checklist:

  1. Replace `draw_box`/`create_status_line` with JSON descriptors.
  2. Remove manual width guesses; rely on builder.
  3. Honour colour‑blind toggle via builder only.

---

\## 13 Roadmap (excerpt)

* **v3.1** – richer progress bars, column filters, deprecate legacy helpers.
* **v3.2** – event‑loop dashboard (Q4 2025).
* **v3.3** – aggregated multi‑host monitoring.

---

\### Key Constraints & Assumptions

* Runtime stack: Bash 5 + Python 3 std‑lib only.
* Builder recalculates widths on every resize; emits `\e[0m` after each render.
* Colour‑blind mode selectable without restart (per render eval).
