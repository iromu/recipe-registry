ssh -T spark.local <<'EOF'
set -euxo pipefail

docker pull avarok/atlas-gb10:latest

docker rm -f atlas || true

docker run -d --name atlas \
  --restart unless-stopped \
  --network host --gpus all --ipc=host \
  -v $HOME/.cache/huggingface:/root/.cache/huggingface \
  avarok/atlas-gb10:latest \
  serve Qwen/Qwen3.6-35B-A3B-FP8 \
    --port 8000 \
    --max-seq-len 65536 \
    --kv-cache-dtype fp8 \
    --kv-high-precision-layers auto \
    --gpu-memory-utilization 0.90 \
    --scheduling-policy slai \
    --tool-call-parser qwen3_coder \
    --enable-prefix-caching \
    --speculative
EOF


# Using LiteLLM

#model_list:
#  - model_name: Qwen3.6-35B-A3B
#    litellm_params:
#      model: openai/Qwen/Qwen3.6-35B-A3B-FP8  # add openai/ prefix to route as OpenAI provider
#      custom_llm_provider: openai
#      api_base: http://localhost:8000/v1       # add api base for OpenAI compatible provider
#      api_key: dummy
#      temperature: 0.6
#      top_p: 0.95
#      extra_body:
#        top_k: 20
#        min_p: 0.0
#        repetition_penalty: 1.0
#        chat_template_kwargs:
#            preserve_thinking: true
