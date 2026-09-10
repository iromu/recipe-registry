#!/bin/bash
# sparkrun mod: qwen38fn-ple-disk
#
# Installs the single-spark-vllm-tp1 vLLM patch set inside the container
# before serve: disk-backed PLE n-gram table (preadv reader), staged gather
# (model_state.py), reduced-vocabulary MTP draft, the one-line
# compilation.py split-op registration, and the pinned upstream overlays.
#
# Idempotent: every file is copied only when the target differs (cmp),
# so re-running this mod in the same container is a no-op.
#
# Env gates (all optional):
#   QWEN38FN_OVERLAYS  "1" (default) installs upstream-overlays/*;
#                      "0" skips them (use with newer images that already
#                      contain PR #55375 / #54846).
#   QWEN4EXP_DRAFT_VOCAB  when "0" or unset, the mtp.py overlay is still
#                      installed (it is a no-op without the env var).
set -euo pipefail

MOD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERLAYS="${QWEN38FN_OVERLAYS:-1}"

# Locate the vLLM package inside the container (do not hardcode python3.12:
# eugr-derived images may use a different minor version).
VP="$(python3 -c 'import vllm, os; print(os.path.dirname(vllm.__file__))')"
if [ ! -d "$VP/models/qwen4_exp/nvidia" ]; then
  echo "[qwen38fn-ple-disk] vLLM qwen4_exp model dir not found under $VP" >&2
  exit 1
fi
echo "[qwen38fn-ple-disk] vLLM package at $VP"

# The patch touches root-owned site-packages. The recipe runs the container
# as root (executor_config user "0:0", same as the bash launcher); fail
# with a clear hint when we cannot write.
if [ ! -w "$VP/models/qwen4_exp/nvidia" ]; then
  echo "[qwen38fn-ple-disk] target $VP/models/qwen4_exp/nvidia is not writable." >&2
  echo "[qwen38fn-ple-disk] Run the container as root (executor_config user: \"0:0\"" >&2
  echo "[qwen38fn-ple-disk] or launch with --rootful) so the patch can be installed." >&2
  exit 1
fi

install_file() {
  local src="$1" dst="$2" label="$3"
  if [ ! -f "$src" ]; then
    echo "[qwen38fn-ple-disk] mod source missing: $src" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$dst")"
  if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
    echo "[qwen38fn-ple-disk] SKIP $label (already installed)"
  else
    cp "$src" "$dst"
    echo "[qwen38fn-ple-disk] INSTALLED $label"
  fi
}

# --- Our patch files (written for this lane; see patch/ple_layer.diff) ---
install_file "$MOD_DIR/ple_layer.py"  "$VP/models/qwen4_exp/nvidia/ple_layer.py"        "ple_layer.py (1-row placeholder + shard drop + staged hooks)"
install_file "$MOD_DIR/ple_mmap.py"   "$VP/models/qwen4_exp/nvidia/ops/ple_mmap.py"     "ops/ple_mmap.py (preadv disk reader, new file)"
install_file "$MOD_DIR/model_state.py" "$VP/models/qwen4_exp/nvidia/model_state.py"    "model_state.py (staged gather in prepare_inputs)"
install_file "$MOD_DIR/mtp.py"        "$VP/models/qwen4_exp/nvidia/mtp.py"              "mtp.py (reduced-vocab draft overlay)"
install_file "$MOD_DIR/compilation.py" "$VP/config/compilation.py"                      "config/compilation.py (+1 split-op line)"

# --- Pinned upstream overlays (base = nightly 8a728663; see PROVENANCE.md) ---
if [ "$OVERLAYS" = "1" ]; then
  install_file "$MOD_DIR/upstream-overlays/ops_ple.py"             "$VP/models/qwen4_exp/nvidia/ops/ple.py"              "upstream PR #55375 (PLE conv state-index stride fix)"
  install_file "$MOD_DIR/upstream-overlays/ops_qsa.py"             "$VP/models/qwen4_exp/nvidia/ops/qsa.py"              "upstream PR #54846 (FP8/NVFP4 KV on QSA path)"
  install_file "$MOD_DIR/upstream-overlays/qsa.py"                 "$VP/models/qwen4_exp/nvidia/qsa.py"                  "upstream PR #54846 (QSA)"
  install_file "$MOD_DIR/upstream-overlays/platforms_interface.py" "$VP/platforms/interface.py"                         "upstream PR #54846 (platforms interface)"
  install_file "$MOD_DIR/upstream-overlays/modelopt.py"            "$VP/model_executor/layers/quantization/modelopt.py" "modelopt.py (our two MTP-loading fixes)"
else
  echo "[qwen38fn-ple-disk] SKIP upstream overlays (QWEN38FN_OVERLAYS=0)"
fi

# Drop stale bytecode so the new sources are what Python imports.
find "$VP/models/qwen4_exp" "$VP/config" "$VP/platforms" "$VP/model_executor/layers/quantization" \
  -name '__pycache__' -type d -prune -exec rm -rf {} + 2>/dev/null || true

echo "[qwen38fn-ple-disk] done. PLE_MODE staged=$([ "${QWEN4EXP_PLE_STAGED:-0}" = "1" ] && echo on || echo off), DRAFT_VOCAB=${QWEN4EXP_DRAFT_VOCAB:-0}"
