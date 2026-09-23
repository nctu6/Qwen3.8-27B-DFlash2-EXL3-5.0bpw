#!/usr/bin/env bash
# Runtime mapping of start.sh .env knobs -> tools/serve_openai.py flags.
set -euo pipefail

MODEL_DIR="${MODEL_DIR:-/models}"
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-8976}"
CONTEXT_SIZE="${CONTEXT_SIZE:-262144}"
GPU_MEM_GB="${GPU_MEM_GB:-100}"
CACHE_QUANT="${CACHE_QUANT:-nvfp4}"
CPU_CACHE_GB="${CPU_CACHE_GB:-0}"
DRAFT="$(echo "${DRAFT:-mtp}" | tr '[:upper:]' '[:lower:]')"
DRAFT_DIR="${DRAFT_DIR:-/draft}"

if [ ! -f "$MODEL_DIR/config.json" ]; then
  echo "MODEL_DIR missing config.json: $MODEL_DIR" >&2
  echo "Mount EXL3 target weights (Mia-AiLab/Qwen3.8-27B-EXL3-3.5bpw) at /models." >&2
  exit 1
fi

cmd=(python -u /app/tools/serve_openai.py
  --model "$MODEL_DIR"
  --host "$HOST"
  --port "$PORT"
  --cache_size "$CONTEXT_SIZE"
  --grid_size "$GPU_MEM_GB")

if [ "$CACHE_QUANT" != "none" ] && [ -n "$CACHE_QUANT" ]; then
  cmd+=(--cache_quant "$CACHE_QUANT")
fi

case "$DRAFT" in
  mtp)     cmd+=(--draft_model mtp) ;;
  dflash2)
    if [ ! -f "$DRAFT_DIR/config.json" ]; then
      echo "DRAFT=dflash2 but DRAFT_DIR missing config.json: $DRAFT_DIR" >&2
      exit 1
    fi
    cmd+=(--draft_model "$DRAFT_DIR")
    ;;
  none)    cmd+=(--draft_model none) ;;
  *)
    echo "DRAFT must be mtp, dflash2, or none (got: $DRAFT)" >&2
    exit 1
    ;;
esac

if [ "$CPU_CACHE_GB" != "0" ]; then
  cmd+=(--cpu_cache_size "$CPU_CACHE_GB")
fi

echo "Starting: ${cmd[*]}"
exec "${cmd[@]}"
