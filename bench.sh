MODEL_TAG="unsloth/Qwen3.6-35B-A3B-GGUF"
MODEL_RECIPE="qwen3.6-35b-a3b-mxfp4_moe-llama-cpp"
MODEL_PORT=8000

uvx tool-eval-bench --perf --model ${MODEL_TAG} --backend llamacpp  \
  --base-url http://spark.local:${MODEL_PORT}

latest_file=$(find runs -name '*.md' -type f | sort | tail -n1)
ln -sfn "../$latest_file" "benchmarks/tool_${MODEL_RECIPE}.md"

uvx llama-benchy \
  --base-url http://spark.local:${MODEL_PORT}/v1 \
  --model $MODEL_TAG \
  --depth 0 4096 8192 \
  --pp 2048 \
  --tg 128 \
  --enable-prefix-caching \
  --concurrency 1 2 4 \
  --save-result "benchmarks/benchy_${MODEL_RECIPE}.md" \
  --api-key=$OPENAI_API_KEY
