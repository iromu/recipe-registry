MODEL_TAG="Qwen3.6-35B-A3B"
MODEL_RECIPE="qwen3.6-35b-a3b-fp8-mtp-atlas"
MODEL_PORT=4000

uvx tool-eval-bench --perf --model ${MODEL_TAG} --backend vllm  \
  --base-url http://spark.local:${MODEL_PORT}

latest_file=$(find runs -name '*.md' -type f | sort | tail -n1)
ln -sfn "../$latest_file" "benchmarks/tool_${MODEL_RECIPE}.md"

#uvx llama-benchy \
#  --base-url http://spark.local:${MODEL_PORT}/v1 \
#  --model $MODEL_TAG \
#  --depth 0 4096 8192 \
#  --pp 2048 \
#  --tg 128 \
#  --enable-prefix-caching \
#  --concurrency 1 2 4 \
#  --save-result "benchmarks/benchy_${MODEL_RECIPE}.md"
