MODEL_TAG="sakamakismile/Huihui-Qwen3.5-4B-abliterated-NVFP4"
MODEL_RECIPE="qwen3.5-4b-nvfp4-vllm"

# vLLM (:8000), llama.cpp (:8080), SGLang (:30000), LiteLLM (:4000), Ollama (:11434), or TGI (:5000)
MODEL_PORT=8001

# --backend: vllm, litellm, llamacpp
#uvx tool-eval-bench \
#  --spec-bench --spec-method auto --spec-prompts "code,structured" \
#  --model ${MODEL_TAG} --backend vllm  \
#  --base-url http://spark.local:${MODEL_PORT} && \
#  latest_file=$(find runs -name '*.md' -type f | sort | tail -n1) && \
#  cp -f $latest_file "benchmarks/spec_${MODEL_RECIPE}.md"

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
