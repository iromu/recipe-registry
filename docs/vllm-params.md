# vLLM Parameters Reference

Master reference of every `--flag` used in vLLM recipes across this registry.
Flags are grouped by functional category. Each entry shows the **default value** used in these recipes, and **what it does** in plain terms.

> **Note:** This registry targets NVIDIA DGX Spark (GB10, 128 GB unified memory, sm_121a). Some parameter defaults are tuned for this hardware.

---

## Table of Contents

- [Model & Serving](#model--serving)
- [Memory & Capacity](#memory--capacity)
- [Quantization](#quantization)
- [Attention & Compute](#attention--compute)
- [Speculative Decoding](#speculative-decoding)
- [Tool & Reasoning Parsers](#tool--reasoning-parsers)
- [Scheduling & Performance](#scheduling--performance)
- [Generation Config](#generation-config)
- [Chat Templates](#chat-templates)
- [Other / Infra](#other--infra)

---

## Model & Serving

### `--served-model-name`

```yaml
--served-model-name Qwen3.6-35B-A3B Qwen3.6-35B-A3B-NVFP4 nvidia/Qwen3.6-35B-A3B-NVFP4
```

Registers alternative names the model can be addressed by in API calls. Multiple names are space-separated.

**Why:** Clients may reference the model by different names (human-readable, quantized variant, or full HF path). This lets any of them work.

**Default in recipes:** Varies per model. Usually includes a human-readable alias + quantized variant + full HF path.

---

### `--trust-remote-code`

```yaml
--trust-remote-code
```

Allows vLLM to download and execute custom Python code from the HuggingFace model repo (e.g., custom model classes, tokenizers).

**When needed:** Required for models with custom architecture files not in vLLM's built-in support. Almost all recipes in this registry use it.

**Risk:** Only use with models from trusted sources. Executes arbitrary code from the HF repo.

---

### `--language-model-only`

```yaml
--language-model-only
```

Tells vLLM to load only the language model weights, skipping vision/encoder components.

**When to use:** For pure text models (Qwen3.5, Qwen3.6, etc.) that don't need multimodal components. Reduces memory usage and startup time.

**When NOT to use:** For multimodal models (e.g., AEON-7 XS) that need vision encoding.

---

## Memory & Capacity

### `--gpu-memory-utilization`

```yaml
# In defaults:
gpu_memory_utilization: 0.52
```

Fraction of GPU memory reserved for the KV cache and model weights. Range: 0.0–1.0 (default 0.9).

**Impact:**
- **Higher** (0.8–0.95): More KV cache → longer context batches → higher throughput but risk of OOM
- **Lower** (0.3–0.5): Less KV cache → shorter batches → lower throughput but more headroom

**Recipe values observed:**
| Value | Multiplier | Use case |
|-------|-----------|----------|
| 0.30 | 1.4x | Conservative, many concurrent requests |
| 0.52 | 4.1x | Balanced — common default |
| 0.75 | 7.5x | Aggressive — fewer concurrent requests |
| 0.80 | 7.5x | High utilization |
| 0.90 | 8.7x | Maximum — tightest margin before OOM |

**How to tune:** Start at 0.52, increase if throughput is low and you have GPU memory headroom. Decrease if you see OOM errors.

---

### `--max-model-len`

```yaml
max_model_len: 131072
```

Maximum total sequence length (input prompt + output tokens) in tokens.

**Default values observed:**
| Model | Default | Rationale |
|-------|---------|-----------|
| Qwen3.6-35B-A3B | 131,072 | Large context, DGX Spark has 128GB memory |
| Qwen3.6-27B | 131,072 | Same |
| Qwen3.5-0.8B | 8,192 | Small model, limited context needed |
| Qwen3.5-4B | 8,192 | Small model |
| Qwen3.5-122B-A10B | 8,192 | Large model, memory-constrained context |
| Gemma-4-31B | 8,192 | Conservative for multimodal |
| LFM2.5-350M | 8,192 | Tiny model |

**How to tune:** Increase if you need longer contexts. The KV cache grows linearly with this value × batch size × hidden dim.

---

### `--max-num-batched-tokens`

```yaml
max_num_batched_tokens: 8192
```

Hard cap on total tokens per batch (sum of all input + output tokens across all requests).

**Relationship to `max-model-len`:** `max-num-batched-tokens` ≤ `max-model-len` × batch size. This limits how many tokens the scheduler will queue at once.

**Default observed:** 8,192 in most recipes. Some use 32,768 for larger models or higher throughput.

---

### `--max-num-seqs`

```yaml
--max-num-seqs 4
```

Maximum number of concurrent requests (sequences) in the batch.

**Default observed:** 4 for most models. Some recipes (e.g., AEON-7 XS) use 64 for higher concurrency.

**How to tune:** Higher = more concurrent requests but more memory per request. Limited by `gpu-memory-utilization` and `max-model-len`.

---

## Quantization

### `--quantization`

```yaml
--quantization modelopt
```

Quantization scheme for model weights. Controls how model weights are stored and computed.

**Values observed:**
| Value | Meaning | Used by |
|-------|---------|---------|
| `modelopt` | NVIDIA Model Optimize quantization (NVFP4/FP8) | NVFP4 and FP8 vLLM recipes |
| *(not set)* | Default (BF16/FP16) | BF16 recipes |

**Note:** For llama-cpp recipes, quantization is specified in the model ID (e.g., `unsloth/...:Q8_0`) and controlled via `--cache-type-k/v` and `--n-gpu-layers` instead.

---

### `--kv-cache-dtype`

```yaml
kv_cache_dtype: fp8
```

Data type for KV cache storage.

**Values observed:**
| Value | Meaning |
|-------|---------|
| `fp8` | FP8 KV cache — lower memory, slight precision loss |
| `auto` | Let vLLM choose based on hardware (default) |
| `q8_0` | GGUF Q8_0 — used by llama-cpp recipes |

**Trade-off:** FP8 KV cache uses half the memory of BF16, allowing longer contexts or larger batches. The precision loss is usually negligible for inference.

---

### `--load-format`

```yaml
load_format: instanttensor
```

How model weights are loaded from disk.

**Values observed:**
| Value | Meaning |
|-------|---------|
| `instanttensor` | NVIDIA InstantTensor format — fast loading, requires pre-converted weights |
| `safetensors` | Standard safetensors format — universal compatibility |
| *(not set)* | Default (usually `pt` or `safetensors`) |

**Note:** `instanttensor` is significantly faster for loading but requires the weights to be pre-converted to the InstantTensor format.

---

## Attention & Compute

### `--attention-backend`

```yaml
attention_backend: flashinfer
```

Implementation of the attention mechanism.

**Values observed:**
| Value | Meaning | Best for |
|-------|---------|----------|
| `flashinfer` | FlashInfer kernels — fastest on Ada/Blackwell GPUs | DGX Spark (sm_121a) |
| `flash_attn` | FlashAttention-2 — good compatibility | Older GPUs, multimodal models |
| `pallas` | Pallas/XLA kernels | TPU, experimental |
| `xformers` | Facebook Xformers — fallback | Legacy GPUs |

**Note:** FlashInfer is the default for DGX Spark. FlashAttention is used when FlashInfer is incompatible (e.g., some multimodal models).

---

### `--moe-backend`

```yaml
--moe-backend marlin
```

Backend for Mixture-of-Experts (MoE) routing computation. Only relevant for MoE models (e.g., Qwen3.6-35B-A3B is a mixture-of-experts model).

**Values observed:**
| Value | Meaning |
|-------|---------|
| `marlin` | Marlin FP8/MoE kernel — fast on Ada/Blackwell |
| `triton` | Triton-based MoE kernel |
| `flashinfer_cutlass` | FlashInfer + CUTLASS hybrid |

**Recipe-specific:**
- Qwen3.6-35B-A3B NVFP4: `marlin` or `triton` (depends on speculative config)
- Qwen3.6-35B-A3B FP8: `flashinfer_cutlass`
- Qwen3.6-35B-A3B MXFP4 MoE: `llama-cpp` (separate backend)

---

### `--tensor-parallel-size` / `--tp`

```yaml
--tensor-parallel-size 1
```

Number of GPUs to split the model across.

**Default:** 1 (single GPU). DGX Spark has a single unified memory chip, so TP=1 is always used.

**When to increase:** For models too large to fit on one GPU (e.g., Qwen3.5-122B-A10B on multi-GPU setups).

---

### `--pipeline-parallel-size` / `--pp`

```yaml
--pipeline-parallel 1
```

Number of pipeline stages to split the model across.

**Default:** 1. Only used in multi-GPU setups.

---

## Speculative Decoding

### `--speculative-config`

```yaml
speculative_config: '{"method":"mtp","num_speculative_tokens":3,"moe_backend":"triton"}'
```

JSON string configuring speculative decoding. This is the most complex parameter — see [Speculative Decoding Deep Dive](speculative-decoding.md) for full details.

**Structure:**
```json
{
  "method": "mtp",              // "mtp" or "dflash"
  "num_speculative_tokens": 3,  // draft window size (n)
  "moe_backend": "triton"       // only for MTP on MoE models
}
```

**Methods:**
- **`mtp`** (Multi-Token Prediction): Uses the model's own MTP heads to draft tokens. No external model needed.
- **`dflash`** (DFlash): Uses an external draft model (e.g., `z-lab/Qwen3.6-27B-DFlash`).

**Common configs:**
| Method | Config | Draft window | Used by |
|--------|--------|-------------|---------|
| MTP | `{"method":"mtp","num_speculative_tokens":3,"moe_backend":"triton"}` | 3 | Qwen3.6-35B-A3B NVFP4 |
| MTP | `{"method":"mtp","num_speculative_tokens":3}` | 3 | Qwen3.6-27B NVFP4 |
| DFlash | `{"method":"dflash","model":"z-lab/Qwen3.6-27B-DFlash","num_speculative_tokens":12}` | 12 | AEON-7 XS |

---

## Tool & Reasoning Parsers

### `--tool-call-parser`

```yaml
tool_call_parser: qwen3_coder
```

How the model's tool call format is parsed from the output.

**Values observed:**
| Value | Meaning | Models |
|-------|---------|--------|
| `qwen3_coder` | Qwen3 Coder tool calling format | Qwen3.x Coder models |
| `qwen3` | Qwen3 standard tool calling | Qwen3.x base models |
| `function_calling` | OpenAI-style function calling | Gemma, generic |

**Why it matters:** Different model families use different formats for tool/function calls. The parser must match the model's training format.

---

### `--reasoning-parser`

```yaml
reasoning_parser: qwen3
```

How the model's `<thinking>` / reasoning blocks are extracted.

**Values observed:**
| Value | Models |
|-------|--------|
| `qwen3` | Qwen3.x models (extracts `<thinking>...</thinking>` blocks) |

---

### `--enable-auto-tool-choice`

```yaml
--enable-auto-tool-choice
```

Automatically selects tools when the model's output indicates a tool call is needed. Without this, the model may output tool call instructions in natural language rather than structured tool calls.

**Recommended:** Enable for models trained with tool-use (Qwen3 Coder, etc.).

---

## Scheduling & Performance

### `--enable-chunked-prefill`

```yaml
--enable-chunked-prefill
```

Splits long prompts into smaller chunks for processing, reducing latency spikes and memory pressure.

**When to use:** Always enable for production workloads with variable-length prompts. Reduces "tail latency" (the worst-case latency for long prompts).

**Trade-off:** Slight overhead for very short prompts (< 512 tokens). Benefit grows with prompt length.

---

### `--enable-prefix-caching`

```yaml
--enable-prefix-caching
```

Caches the KV cache of repeated prompt prefixes (e.g., system prompts, common prefixes). Subsequent requests with the same prefix skip computation.

**When to use:** Always enable when you have repeated prompts (system prompts, shared context). Provides free speedup for prefix overlap.

**When NOT to use:** DFlash recipes sometimes disable it due to a known vLLM bug (PR #41703 fixed this in newer builds).

---

### `--async-scheduling`

```yaml
--async-scheduling
```

Uses asynchronous request scheduling instead of synchronous (blocking) scheduling.

**Effect:** The scheduler doesn't block on each request. Improves throughput for concurrent workloads.

**Default:** Enabled in most vLLM recipes. Not used in llama-cpp recipes.

---

## Generation Config

### `--generation-config` / `--override-generation-config`

```yaml
--generation-config vllm
--override-generation-config '{"temperature": 0.6, "top_p": 0.95, "top_k": 20, "min_p": 0.0, "presence_penalty": 0.0, "repetition_penalty": 1.0}'
```

Sets the decoding parameters for text generation.

**Parameters explained:**
| Parameter | Default | Range | Effect |
|-----------|---------|-------|--------|
| `temperature` | 0.6 | 0.0–2.0 | Higher = more random, lower = more deterministic |
| `top_p` | 0.95 | 0.0–1.0 | Nucleus sampling: only consider tokens with cumulative probability ≥ p |
| `top_k` | 20 | 0–∞ | Only consider the top-k most likely next tokens |
| `min_p` | 0.0 | 0.0–1.0 | Minimum probability relative to the most likely token |
| `presence_penalty` | 0.0 | -2.0–2.0 | Penalize tokens already in the output (encourages diversity) |
| `repetition_penalty` | 1.0 | 1.0–2.0 | >1.0 penalizes repetition; 1.0 = no penalty |

**Recipe default:** `{"temperature": 0.6, "top_p": 0.95, "top_k": 20, "min_p": 0.0, "presence_penalty": 0.0, "repetition_penalty": 1.0}`

---

## Chat Templates

### `--chat-template`

```yaml
--chat-template unsloth.jinja
```

Jinja template for formatting chat messages. Different models expect different formats.

**Values observed:**
| Template | Models |
|----------|--------|
| `unsloth.jinja` | Qwen3.5-0.8B, Qwopus3.6-35B-A3B-v1 |
| `fixed_chat_template.jinja` | Qwen3.6-27B FP8, Qwen3.6-27B NVFP4 |
| *(not set)* | Uses vLLM's built-in template for the model |

---

### `--default-chat-template-kwargs`

```yaml
--default-chat-template-kwargs '{"preserve_thinking":true}'
```

Extra arguments passed to the chat template Jinja rendering.

**Common kwargs:**
| Key | Value | Effect |
|-----|-------|--------|
| `preserve_thinking` | `true` | Keep the model's `<thinking>` blocks in the output |

---

## Other / Infra

### `--host` / `--port`

```yaml
--host 0.0.0.0
--port 8000
```

Network binding for the vLLM API server.

**Defaults:** `0.0.0.0:8000` (all interfaces, standard OpenAI-compatible API port).

---

### `--dtype`

```yaml
--dtype bfloat16
```

Compute data type for forward passes.

**Values observed:**
| Value | Meaning |
|-------|---------|
| `auto` | Let vLLM choose based on hardware (default for quantized models) |
| `bfloat16` | Explicit BF16 compute |

**Note:** For quantized models (NVFP4, FP8), use `auto` — vLLM will use the quantized compute path.

---

### `--max-cudagraph-capture-size`

```yaml
--max-cudagraph-capture-size <N>
```

Maximum batch size for CUDA graph capture. CUDA graphs cache the kernel launch sequence for faster repeated inference.

**Effect:** Larger values capture more batch sizes but use more memory and increase startup time.

---

### `--repeat-penalty` / `--spec-draft-n-max` / `--spec-type` / `--reasoning-parser-plugin`

These flags appear in some recipes but are less commonly used. They relate to repetition penalty configuration, speculative decoding draft parameters, and plugin-based reasoning parsing respectively.

---

## llama-cpp Specific Flags

For `llama-cpp` runtime recipes, the following llama.cpp-specific flags are used instead of vLLM flags:

| Flag | Meaning |
|------|---------|
| `--ctx-size` | Context window size (maps to vLLM's `--max-model-len`) |
| `--cache-type-k` / `--cache-type-v` | KV cache data type |
| `--n-gpu-layers` | Number of layers to offload to GPU (999 = all) |
| `--flash-attn` | Enable FlashAttention |
| `--jinja` | Enable Jinja chat templates |
| `--no-webui` | Run without web UI |
| `--no-mmap` | Don't use memory-mapped file loading |
| `--alias` | Alternative model name for the API |
| `--temp` | Temperature (generation parameter) |
| `--top-p` | Top-p (nucleus sampling) |
| `--top-k` | Top-k sampling |
| `--min-p` | Min-p sampling |
| `--repeat-penalty` | Repetition penalty |