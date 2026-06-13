#!/usr/bin/env bash
#
# check-vllm-health.sh — Monitors a vLLM endpoint and auto-restarts it when down.
#
# Usage:  bash check-vllm-health.sh
#
# Designed to run from crontab every 1–2 minutes:
#   */2 * * * * /home/wantez/source/github/iromu/recipe-registry/check-vllm-health.sh >> /home/wantez/source/github/iromu/recipe-registry/vllm-health.log 2>&1

set -euo pipefail

# ── Configuration ──────────────────────────────────────────────────────────────
# Try /health first (vLLM-specific), fall back to /v1/models (OpenAI-compatible)
HEALTH_URLS=(
  "http://localhost:8000/health"
  "http://localhost:8000/v1/models"
)
RESTART_DIR="/home/wantez/source/github/iromu/recipe-registry/recipes/qwen3.6-35b-a3b"
RESTART_CMD="uvx sparkrun run qwen3.6-35b-a3b-nvfp4-mtp-vllm"
STATE_DIR="$HOME/.local/share/vllm-health"
STATE_FILE="$STATE_DIR/restart.state"
COOLDOWN_SECONDS=600   # 10 min — skip checks right after a restart
CHECK_TIMEOUT=10        # seconds — max wait for HTTP response
# ───────────────────────────────────────────────────────────────────────────────

mkdir -p "$STATE_DIR"

log() { printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$STATE_DIR/vllm-health.log"; }

# ── 1. Check whether we are still in the startup cooldown window ───────────────
now_epoch=$(date +%s)

if [[ -f "$STATE_FILE" ]]; then
    restart_epoch=$(cat "$STATE_FILE")
    elapsed=$(( now_epoch - restart_epoch ))

    if (( elapsed < COOLDOWN_SECONDS )); then
        log "INFO  — in cooldown ($elapsed/${COOLDOWN_SECONDS}s), skipping health check"
        exit 0
    else
        log "INFO  — cooldown expired (${elapsed}s elapsed)"
    fi
fi

# ── 2. Probe the vLLM health endpoint ─────────────────────────────────────────
http_code=""
for url in "${HEALTH_URLS[@]}"; do
  http_code=$(curl -s -o /dev/null -w '%{http_code}' --max-time "$CHECK_TIMEOUT" "$url" 2>/dev/null) || true
  if [[ "$http_code" == "200" ]]; then
    break
  fi
done

if [[ "$http_code" == "200" ]]; then
  log "OK    — vLLM healthy (HTTP $http_code)"
  exit 0
fi

log "WARN  — vLLM unhealthy (HTTP $http_code), restarting…"

# ── 3. Launch the restart command ─────────────────────────────────────────────
# sparkrun run detaches by default (no --foreground), so no nohup needed.
# Redirect output to log file and close stdin — completely headless.
( cd "$RESTART_DIR" && exec $RESTART_CMD ) > "$STATE_DIR/restart.out.log" 2>&1 < /dev/null &

# Record restart timestamp for the cooldown window.
echo "$now_epoch" > "$STATE_FILE"

log "RESTART — launched in background, cooldown set for ${COOLDOWN_SECONDS}s"
