MODEL_TAG="sakamakismile/Qwen3.6-27B-Text-NVFP4-MTP"
MODEL_RECIPE="qwen3.6-27b-nvfp4-mtp-vllm"
# Ports:s
#   vllm 8000
#   litellm 4000
MODEL_PORT=8000

# --backend: vllm, litellm, llamacpp
uvx tool-eval-bench \
  --spec-bench --spec-method mtp --spec-prompts "code,structured" \
  --model ${MODEL_TAG} --backend vllm  \
  --base-url http://spark.local:${MODEL_PORT} && \
  latest_file=$(find runs -name '*.md' -type f | sort | tail -n1) && \
  cp -f $latest_file "benchmarks/spec_${MODEL_RECIPE}.md"

uvx tool-eval-bench \
  --perf \
  --model ${MODEL_TAG} --backend vllm  \
  --base-url http://spark.local:${MODEL_PORT} && \
  latest_file=$(find runs -name '*.md' -type f | sort | tail -n1) && \
  cp -f $latest_file "benchmarks/tool_${MODEL_RECIPE}.md"

uvx llama-benchy \
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
