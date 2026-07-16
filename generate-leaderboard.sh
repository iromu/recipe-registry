#!/usr/bin/env bash
# generate-leaderboard.sh — Parse `uvx tool-eval-bench --leaderboard` output into LEADERBOARD.md
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT="${SCRIPT_DIR}/LEADERBOARD.md"

# Capture raw output to a temp file, then parse with Python
TMPFILE="$(mktemp)"
trap 'rm -f "$TMPFILE"' EXIT

uvx tool-eval-bench --leaderboard 2>&1 > "$TMPFILE"

python3 << 'PYEOF' - "$TMPFILE" "$OUTPUT"
import sys

tmpfile = sys.argv[1]
output_path = sys.argv[2]

with open(tmpfile, "r", encoding="utf-8") as f:
    lines = f.read().splitlines()

BOX = "\u2502"  # │
SEPARATOR = "\u2500"  # ─

# Collect data rows (lines starting with │) and skip footer (lines starting with ╭ or ╰)
data_rows = []
in_footer = False
for line in lines:
    if line.startswith("\u256d") or line.startswith("\u2570"):  # ╭ or ╰
        in_footer = True
    if in_footer:
        continue
    if line.startswith(BOX):
        data_rows.append(line)

# Parse each row
rows = []
for row_str in data_rows:
    # Split on │ (U+2502), filter empty strings from leading/trailing │
    parts = [p.strip() for p in row_str.split(BOX) if p.strip()]
    if len(parts) >= 23:
        rows.append(parts[:23])

model_count = len(rows)

# Build markdown
md = []
md.append("# 🏆 Model Leaderboard")
md.append("")
from datetime import datetime
now = datetime.now().strftime("%Y-%m-%d %H:%M %Z")
md.append(f"> Auto-generated from `uvx tool-eval-bench --leaderboard` on {now}")
md.append("")
md.append("| # | Model | Score | Rating | P/F | Sel | Prm | Chn | Rst | Err | Loc | Rsn | Ins | Ctx | Cod | Saf | Scl | Pln | Crt | Out | N | Tokens | Run |")
md.append("|---|-------|-------|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|---|--------|-----|")

for r in rows:
    model = r[1].replace("|", "\\|")
    md.append(f"| {r[0]} | {model} | {r[2]} | {r[3]} | {r[4]} | {r[5]} | {r[6]} | {r[7]} | {r[8]} | {r[9]} | {r[10]} | {r[11]} | {r[12]} | {r[13]} | {r[14]} | {r[15]} | {r[16]} | {r[17]} | {r[18]} | {r[19]} | {r[20]} | {r[21]} | {r[22]} |")

md.append("")
md.append("### Column Definitions")
md.append("")
md.append("| Col | Meaning | Col | Meaning | Col | Meaning |")
md.append("|-----|---------|-----|---------|-----|---------|")
md.append("| Sel | Tool Selection | Prm | Param Precision | Chn | Multi-Step Chains |")
md.append("| Rst | Restraint | Err | Error Recovery | Loc | Localization |")
md.append("| Rsn | Reasoning | Ins | Instruction | Ctx | Context & State |")
md.append("| Cod | Code Patterns | Saf | Safety | Scl | Toolset Scale |")
md.append("| Pln | Planning | Crt | Creative | Out | Structured Output |")
md.append("")
md.append("**P/F** = ✅ Pass / ⚠️ Partial / ❌ Fail  •  **N** = Scenario count  •  **Scores**: 90+ 75+ 60+ 40+ <40  •  **★★★ⓢ** = Safety-capped")

with open(output_path, "w", encoding="utf-8") as f:
    f.write("\n".join(md) + "\n")

print(f"Generated {output_path} ({model_count} models)")
PYEOF