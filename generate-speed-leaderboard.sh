#!/usr/bin/env bash
# generate-speed-leaderboard.sh — Read benchmarks/benchy*.json and create SPEED_LEADERBOARD.md
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BENCHMARK_DIR="${SCRIPT_DIR}/benchmarks"
OUTPUT="${SCRIPT_DIR}/SPEED_LEADERBOARD.md"

python3 << 'PYEOF' - "$BENCHMARK_DIR" "$OUTPUT"
import json, glob, os, sys
from datetime import datetime

benchmark_dir = sys.argv[1]
output_path = sys.argv[2]

# Collect all benchy JSON files
files = sorted(glob.glob(os.path.join(benchmark_dir, "benchy*.json")))

# The recipe key is the benchmark filename without 'benchy_' prefix and '.json' suffix.
# This allows the same model (different recipe/config) to appear multiple times.
entries = []

for fpath in files:
    try:
        with open(fpath) as f:
            data = json.load(f)
    except (json.JSONDecodeError, OSError):
        continue

    model = data.get("model", "unknown")
    timestamp = data.get("timestamp", "")

    # Find tg_throughput at concurrency=1, context_size=0
    tg_tps = None
    tg_std = None
    for bench in data.get("benchmarks", []):
        if (bench.get("concurrency") == 1
                and bench.get("context_size") == 0
                and bench.get("tg_throughput")
                and bench["tg_throughput"].get("mean") is not None):
            tg_tps = bench["tg_throughput"]["mean"]
            tg_std = bench["tg_throughput"].get("std")
            break

    if tg_tps is None:
        continue

    # Recipe key = filename without 'benchy_' prefix and '.json' suffix
    fname = os.path.basename(fpath)
    recipe = fname.replace("benchy_", "").replace(".json", "")

    entries.append({
        "recipe": recipe,
        "model": model,
        "tps": tg_tps,
        "std": tg_std,
        "timestamp": timestamp,
    })

# Sort by tps descending
entries.sort(key=lambda x: x["tps"], reverse=True)

now = datetime.now().strftime("%Y-%m-%d %H:%M %Z")

md = []
md.append("# ⚡ Speed Leaderboard")
md.append("")
md.append("> Auto-generated from `benchmarks/benchy*.json` on {0}".format(now))
md.append("")
md.append("Generation throughput (tokens/sec) at **concurrency=1, context_size=0** (prompt=2048, response=128).")
md.append("Each recipe is listed independently — the same model with different configs appears as separate rows.")
md.append("")
md.append("| # | Recipe | Spec | Model | Tokens/sec | Benchmark Date |")
md.append("|---|--------|------|-------|-----------:|----------------|")

spec_mark = {"dflash": "🔥", "mtp": "📐"}

for rank, e in enumerate(entries, 1):
    tps_str = "{0:.1f}".format(e["tps"])
    if e["std"] is not None:
        tps_str += " ±{0:.1f}".format(e["std"])
    # Speculative decoding marker
    spec = ""
    for kw, emoji in spec_mark.items():
        if kw in e["recipe"]:
            spec = emoji
            break
    md.append("| {0} | {1} | {2} | {3} | {4} | {5} |".format(
        rank, e["recipe"], spec, e["model"], tps_str, e["timestamp"]
    ))

md.append("")
md.append("### Notes")
md.append("")
md.append("- **Tokens/sec** = `tg_throughput.mean` from the first benchmark entry (concurrency=1, context_size=0)")
md.append("- **Std Dev** = `tg_throughput.std` from the same entry")
md.append("- **Recipe** = benchmark filename (without `benchy_` prefix and `.json` suffix)")
md.append("- **Speculative decoding**: 🔥 = DFlash, 📐 = MTP")

with open(output_path, "w", encoding="utf-8") as f:
    f.write("\n".join(md) + "\n")

print(f"Generated {output_path} ({len(entries)} recipes)")
PYEOF