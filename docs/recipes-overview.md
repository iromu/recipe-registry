# Recipe Overview

How sparkrun recipes are structured, the supported runtimes, and the quantization formats used in this registry.

---

## Recipe Anatomy

Each recipe is a **pair** of files in `recipes/<model-slug>/<name>.{yaml,sh}`:

```
recipes/
├── qwen3.6-35b-a3b/
│   ├── qwen3.6-35b-a3b-nvfp4-mtp-vllm.yaml   # Recipe definition
│   └── qwen3.6-35b-a3b-nvfp4-mtp-vllm.sh     # Launcher script
```

### YAML Definition

```yaml
recipe_version: "2"                    # Always "2"
model: nvidia/Qwen3.6-35B-A3B-NVFP4  # HuggingFace model ID
runtime: vllm                         # vllm | llama-cpp | atlas
container: ghcr.io/spark-arena/dgx-vllm-eugr-nightly:latest  # Optional Docker image

metadata:                             # Human-readable info
  description: |
    ✓ code @ d0  50.9 eff t/s  50.6 stream t/s  α=91.2%  waste=9%
    ...
  model_params: 35B
  model_dtype: NVFP4

defaults:                             # Default config values (see vllm-params.md)
  port: 8000
  host: 0.0.0.0
  tensor_parallel: 1
  gpu_memory_utilization: 0.52
  max_model_len: 131072
  kv_cache_dtype: fp8
  attention_backend: flashinfer
  tool_call_parser: qwen3_coder
  speculative_config: '{"method":"mtp",...}'

env:                                  # Environment variables (see vllm-env-vars.md)
  FLASHINFER_DISABLE_VERSION_CHECK: 1
  VLLM_MARLIN_USE_ATOMIC_ADD: 1

command: |                           # The actual server command
  vllm serve {model} \
    --host {host} \
    --port {port} \
    ...
```

**Template variables** in the `command` section (`{model}`, `{host}`, `{port}`, etc.) are replaced with values from `defaults:` at runtime.

### Shell Script

```bash
uvx sparkrun run qwen3.6-35b-a3b-nvfp4-mtp-vllm
```

Typically a single line. Some recipes include a stop-before-run:

```bash
uvx sparkrun stop qwen3.6-35b-a3b-nvfp4-mtp-vllm
uvx sparkrun run qwen3.6-35b-a3b-nvfp4-mtp-vllm
```

---

## Supported Runtimes

| Runtime | Description | Recipe Count | Use Case |
|---------|-------------|-------------|----------|
| **vLLM** | Primary runtime. PagedAttention, continuous batching, speculative decoding | 22 | Production inference |
| **llama-cpp** | llama.cpp via `llama-server`. GGUF models | 4 | GGUF-based inference, CPU fallback |
| **atlas** | NVIDIA Atlas runtime | 1 | Experimental / specific model requirements |

### vLLM Recipes

The dominant runtime. Uses the `vllm serve` command with various flags. Supports:
- Continuous batching (`--enable-chunked-prefill`)
- Speculative decoding (MTP, DFlash)
- KV cache prefix caching (`--enable-prefix-caching`)
- Async scheduling (`--async-scheduling`)

### llama-cpp Recipes

Uses `llama-server` from llama.cpp. GGUF models are loaded directly. Key differences:
- Quantization is in the model ID (`unsloth/...:Q8_0`)
- KV cache dtype via `--cache-type-k/v`
- GPU layer offloading via `--n-gpu-layers` (999 = all layers on GPU)
- No speculative decoding support
- No tool call parsing (native llama.cpp format)

---

## Naming Conventions

### Model Directory

Kebab-case model slug, derived from the HF model name:

| HF Model | Directory |
|----------|-----------|
| `nvidia/Qwen3.6-35B-A3B-NVFP4` | `qwen3.6-35b-a3b/` |
| `unsloth/Qwen3.6-27B-GGUF` | `qwen3.6-27b/` |
| `nvidia/Gemma-4-31B-IT-NVFP4` | `gemma-4-31b-it/` |

### Recipe Name

Pattern: `<model-slug>-<quant>-<feature>-<backend>`

| Component | Examples |
|-----------|----------|
| Model slug | `qwen3.6-35b-a3b`, `qwen3.6-27b` |
| Quantization | `nvfp4`, `fp8`, `q8_0`, `int4`, `bf16` |
| Feature | `mtp` (multi-token prediction), `dflash` (DFlash), `atlas` |
| Backend | `vllm`, `llama-cpp` |

**Examples:**
- `qwen3.6-35b-a3b-nvfp4-mtp-vllm` → Qwen3.6-35B-A3B, NVFP4 quantized, MTP speculative decoding, vLLM
- `qwen3.6-35b-a3b-q8_0-llama-cpp` → Qwen3.6-35B-A3B, Q8_0 GGUF, llama-cpp
- `qwen3.6-27b-fp8-mtp-vllm` → Qwen3.6-27B, FP8 quantized, MTP, vLLM

---

## Quantization Formats (Quick Summary)

| Format | Full Name | Runtimes | Memory Savings | Quality Impact |
|--------|-----------|----------|---------------|----------------|
| **NVFP4** | NVIDIA FP4 | vLLM | ~75% vs BF16 | Minimal (NVIDIA's quantization) |
| **FP8** | IEEE FP8 | vLLM | ~50% vs BF16 | Low |
| **Q8_0** | GGUF Q8_0 | llama-cpp | ~50% vs BF16 | Very low |
| **Q4_K_S** | GGUF Q4_K_S | llama-cpp | ~75% vs BF16 | Low-moderate |
| **INT4** | Autoround INT4 | vLLM | ~75% vs BF16 | Low-moderate |
| **MXFP4** | Mixed-precision FP4 | vLLM | ~75% vs BF16 | Minimal |
| **BF16** | Bfloat16 (baseline) | vLLM | None | None |

> See [Quantization Deep Dive](quantization.md) for detailed comparisons.

---

## Speculative Decoding (Quick Summary)

Two methods are used in this registry:

| Method | How It Works | Requires | Speedup |
|--------|-------------|----------|---------|
| **MTP** | Model's own MTP heads draft tokens | Model must have MTP heads | ~1.5–2x |
| **DFlash** | External draft model (e.g., DFlash) | External draft model | ~2–3x |

> See [Speculative Decoding Deep Dive](speculative-decoding.md) for full details.

---

## Experimental Recipes

Recipes in `experimental/` are work-in-progress. They may:
- Use custom container images (not yet stable)
- Target experimental vLLM builds
- Have unverified benchmark results
- Use features not yet in stable vLLM

Promote to `recipes/` once validated.

---

## Registry Metadata

The file `.sparkrun/registry.yaml` tells sparkrun where to find recipes:

```yaml
registries:
  - name: iromu
    description: Personal registry for sparkrun
    recipes: recipes        # Where recipe YAML files live
    tuning: tuning          # (optional) tuning configs
    benchmarks: benchmarking # (optional) benchmark data
    visible: true           # Show in `sparkrun list`
```

---

## Running a Recipe

```bash
# List available recipes
sparkrun list @iromu

# Run a recipe (starts the inference server)
sparkrun run qwen3.6-35b-a3b-nvfp4-mtp-vllm

# Stop a running recipe
sparkrun stop qwen3.6-35b-a3b-nvfp4-mtp-vllm

# Show recipe details (VRAM, config, etc.)
sparkrun show qwen3.6-35b-a3b-nvfp4-mtp-vllm
```

Recipes expose an OpenAI-compatible API at the configured port (default `http://localhost:8000`).