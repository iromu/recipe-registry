MODEL_TAG="Qwen/Qwen3.6-35B-A3B-FP8"
MODEL_RECIPE="qwen3.6-35b-a3b-fp8-mtp-vllm"
MODEL_PORT=8000

uvx tool-eval-bench --perf --model ${MODEL_TAG} --backend llamacpp  \
  --base-url http://spark.local:${MODEL_PORT}

latest_file=$(find runs -name '*.md' -type f | sort | tail -n1)
#ln -sfn "../$latest_file" "benchmarks/tool_${MODEL_RECIPE}.md"
cp -f $latest_file "benchmarks/tool_${MODEL_RECIPE}.md"

uvx llama-benchy@latest \
  --base-url http://spark.local:${MODEL_PORT}/v1 \
  --model $MODEL_TAG \
  --depth 0 4096 8192 \
  --pp 2048 \
  --tg 128 \
  --enable-prefix-caching \
  --concurrency 1 2 4 \
  --format json \
  --save-result "benchmarks/benchy_${MODEL_RECIPE}.json" \
  --api-key=$OPENAI_API_KEY
