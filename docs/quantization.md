# Quantization Formats

Overview of the quantization formats used across recipes in this registry, with trade-offs and when to choose each.

---

## Quick Comparison

| Format | Bits/Param | Memory vs BF16 | Quality Impact | Runtimes | Speedup vs BF16 |
|--------|-----------|---------------|----------------|----------|-----------------|
| **BF16** | 16 | 100% (baseline) | None | vLLM | 1.0x |
| **FP8** | 8 | ~50% | Low | vLLM | ~1.0–1.1x |
| **Q8_0** | 8 | ~50% | Very low | llama-cpp | ~1.0–1.2x |
| **INT4** | 4 | ~75% | Low-moderate | vLLM | ~1.5–2.0x |
| **NVFP4** | 4 | ~75% | Minimal* | vLLM | ~2.0–3.0x |
| **MXFP4** | ~4 (mixed) | ~75% | Minimal* | vLLM | ~2.0–3.0x |

\* NVIDIA's NVFP4 uses specialized hardware (Tensor Cores on Blackwell) that preserves quality better than generic 4-bit quantization.

---

## BF16 (Bfloat16)

**Full name:** Brain floating point 16

**What it is:** The standard 16-bit floating point format used as the baseline for model weights and activations.

**When used:** BF16 recipes in this registry (e.g., `gemma3-12b-it-bf16-vllm`, `qwen3.5-0.8b-bf16-vllm`)

**Pros:**
- No quality loss — this is the native training format
- Maximum compatibility — works on all GPUs
- No quantization artifacts

**Cons:**
- Uses full memory (16 bits per parameter)
- Slower than quantized formats on hardware with dedicated quantized compute units

**Memory for Qwen3.6-35B-A3B:** ~70 GB for weights alone (35B params × 2 bytes × ~1 MoE expansion factor)

---

## FP8 (IEEE 754 E4M3 / E5M2)

**Full name:** IEEE 8-bit floating point

**What it is:** An IEEE-standardized 8-bit floating point format. Uses E4M3 (4 exponent, 3 mantissa) or E5M2 (5 exponent, 2 mantissa) encoding.

**How it's used in recipes:** Via NVIDIA's `--quantization modelopt` with `--kv-cache-dtype fp8`.

**Pros:**
- 50% memory reduction vs BF16
- Minimal quality impact — FP8 is well-aligned with transformer workloads
- Hardware support on Ada (RTX 40-series) and Blackwell (GB10) GPUs
- FP8 KV cache doubles effective context length

**Cons:**
- Requires GPU with FP8 tensor cores (Ada/Blackwell)
- Some models need calibration for optimal FP8 accuracy
- Not supported by llama.cpp (GGUF only has Q8_0)

**Memory for Qwen3.6-35B-A3B:** ~35 GB for weights (half of BF16)

**Recipe examples:**
- `qwen3.6-35b-a3b-fp8-mtp-vllm`
- `qwen3.6-35b-a3b-fp8-vllm`
- `qwen3.6-27b-fp8-mtp-vllm`

---

## NVFP4 (NVIDIA FP4)

**Full name:** NVIDIA FP4 (custom format, not IEEE)

**What it is:** NVIDIA's proprietary 4-bit floating point format, optimized for Blackwell (sm_121a) Tensor Cores. Different from generic INT4 — it uses a custom encoding that maps well to transformer activations.

**How it's used in recipes:** Via `--quantization modelopt` with `--kv-cache-dtype fp8` and NVFP4-specific environment variables.

**Pros:**
- 75% memory reduction vs BF16
- Minimal quality impact — NVIDIA's calibration preserves model quality better than generic 4-bit
- Hardware acceleration on Blackwell (GB10) — dedicated FP4 tensor cores
- Best throughput of any format on DGX Spark
- Works with speculative decoding (MTP/DFlash)

**Cons:**
- Requires Blackwell hardware (sm_121a) — won't work on older GPUs
- Requires NVIDIA Model Optimize toolkit
- Requires specific FlashInfer build with CUTLASS NVFP4 backend
- Not portable — recipes are DGX Spark-specific

**Memory for Qwen3.6-35B-A3B:** ~17.5 GB for weights (quarter of BF16)

**Recipe examples:**
- `qwen3.6-35b-a3b-nvfp4-mtp-vllm`
- `qwen3.6-35b-a3b-nvfp4-dflash-vllm`
- `qwen3.6-27b-nvfp4-mtp-vllm`
- `qwen3.5-0.8b-nvfp4-mtp-vllm`

**Key environment variables:**
- `VLLM_NVFP4_GEMM_BACKEND: flashinfer-cutlass` — the CUTLASS-based NVFP4 GEMM kernel
- `VLLM_USE_FLASHINFER_MOE_FP4: 0` — disable native FP4 MoE (use Marlin instead)
- `CUTE_DSL_ARCH: sm_121a` — Blackwell architecture target
- `ENABLE_NVFP4_SM100: 0` — disable Hopper FP4 (wrong architecture)

---

## MXFP4 (Mixed-Precision FP4)

**Full name:** Mixed-precision FP4

**What it is:** A variant of NVFP4 where only certain layers are quantized to FP4, while critical layers (e.g., first/last, attention) remain at higher precision (FP8 or BF16).

**How it's used in recipes:** Via `--quantization modelopt` with MXFP4-specific load format.

**Pros:**
- Slightly better quality than full NVFP4
- Still ~75% memory reduction (most layers at FP4, some at higher precision)
- Hardware acceleration on Blackwell

**Cons:**
- More complex calibration
- Slightly slower than full NVFP4 (mixed precision requires dispatch)
- DGX Spark-specific

**Recipe example:**
- `qwen3.6-35b-a3b-mxfp4_moe-llama-cpp` — uses llama-cpp backend with MXFP4

---

## INT4 (Autoround)

**Full name:** 4-bit integer quantization via AutoRound

**What it is:** Generic 4-bit integer quantization using the AutoRound algorithm. Different from NVFP4 — it's a post-training quantization (PTQ) method that works on any model, not just NVIDIA-calibrated ones.

**How it's used in recipes:** Via `--quantization modelopt` with INT4 load format.

**Pros:**
- Works on any model (not just NVIDIA-calibrated)
- 75% memory reduction
- Works on any GPU with INT4 tensor cores (Ada, Blackwell, and newer)

**Cons:**
- More quality loss than NVFP4 (generic 4-bit vs NVIDIA-optimized)
- Requires calibration dataset
- Not hardware-accelerated on older GPUs

**Recipe examples:**
- `qwen3.6-27b-int4-autorun-mtp-vllm`
- `qwen3.5-122b-a10b-int4-autoround-mtp-vllm`

---

## GGUF Formats (llama.cpp)

GGUF (GGML Universal Format) is llama.cpp's model format. Quantization is specified in the model ID suffix.

### Q8_0

**Full name:** GGUF Q8_0 (8-bit integer with per-block scaling)

**What it is:** The highest-quality GGUF quantization. Uses 8-bit integers with per-block scaling factors.

**Memory:** ~50% of BF16

**Quality:** Very low quality loss — typically within 1–2% of BF16 on most benchmarks.

**Recipe examples:**
- `qwen3.6-35b-a3b-q8_0-llama-cpp`
- `qwen3.6-27b-q8_0-llama-cpp`

**When to use:** When you need near-BF16 quality but want reduced memory. Good for models that don't fit in GPU memory at BF16.

### Q4_K_S

**Full name:** GGUF Q4_K_S (4-bit K-quants, small)

**What it is:** A 4-bit quantization using K-quants (a sophisticated quantization scheme bygger). The "S" suffix means "small" variant.

**Memory:** ~75% of BF16

**Quality:** Low-moderate quality loss. Acceptable for many use cases but noticeable on benchmarks.

**Recipe examples:**
- `qwopus3.6-27b-coder-compat-mtp-q4_k_s-llamacpp`

**When to use:** When memory is very constrained and you can tolerate some quality loss.

---

## Choosing a Quantization

### Decision Tree

```
Need maximum quality?
├── Yes → BF16 (no quantization)
└── No → Need 50%+ memory reduction?
    ├── No → FP8 (half memory, minimal quality loss)
    └── Yes → Have Blackwell GPU?
        ├── Yes → NVFP4 (best throughput on DGX Spark)
        └── No → INT4 (generic 4-bit, works on any GPU)
```

### By Model Size

| Model | BF16 Weights | FP8 Weights | NVFP4 Weights | Q8_0 (GGUF) | Recommendation |
|-------|-------------|-------------|---------------|-------------|---------------|
| Qwen3.6-35B-A3B | ~70 GB | ~35 GB | ~17.5 GB | ~35 GB | NVFP4 (fits easily on 128GB Spark) |
| Qwen3.6-27B | ~54 GB | ~27 GB | ~13.5 GB | ~27 GB | NVFP4 or FP8 |
| Qwen3.5-122B-A10B | ~244 GB | ~122 GB | ~61 GB | ~122 GB | FP8 or INT4 (NVFP4 may not fit) |
| Qwen3.5-4B | ~8 GB | ~4 GB | ~2 GB | ~4 GB | Any format |
| Qwen3.5-0.8B | ~2 GB | ~1 GB | ~0.5 GB | ~1 GB | Any format (memory not a constraint) |

### By Use Case

| Use Case | Recommended Format | Why |
|----------|-------------------|-----|
| Maximum throughput on DGX Spark | NVFP4 | Hardware-accelerated, 75% memory reduction |
| Good throughput, broader compatibility | FP8 | 50% memory reduction, works on Ada+ GPUs |
| Near-BF16 quality, half memory | FP8 or Q8_0 | Minimal quality loss |
| Maximum memory efficiency | NVFP4 or INT4 | 75% memory reduction |
| llama.cpp / CPU fallback | Q8_0 (GGUF) | Best quality among GGUF formats |
| Models without NVFP4 support | INT4 (Autoround) | Generic 4-bit, works everywhere |

---

## Quantization in Recipes

### vLLM Recipes

In vLLM recipes, quantization is controlled by:

```yaml
# 1. The model ID (includes quantization info)
model: nvidia/Qwen3.6-35B-A3B-NVFP4

# 2. The quantization flag
defaults:
  quantization: modelopt

# 3. The KV cache dtype
defaults:
  kv_cache_dtype: fp8

# 4. The load format
defaults:
  load_format: instanttensor   # or safetensors

# 5. Environment variables (for NVFP4)
env:
  VLLM_NVFP4_GEMM_BACKEND: flashinfer-cutlass
  VLLM_USE_FLASHINFER_MOE_FP4: 0
  VLLM_TEST_FORCE_FP8_MARLIN: 0
  CUTE_DSL_ARCH: sm_121a
  ENABLE_NVFP4_SM100: 0
```

### llama-cpp Recipes

In llama-cpp recipes, quantization is in the model ID and controlled via:

```yaml
# 1. The model ID (includes GGUF quantization tag)
model: unsloth/Qwen3.6-35B-A3B-GGUF:Q8_0

# 2. KV cache dtype
defaults:
  kv_cache_dtype: q8_0

# 3. GPU layer offloading
defaults:
  n_gpu_layers: 999   # all layers on GPU
```

---

## Quantization Benchmark Signals

When comparing quantized recipes, look at:

1. **Eff t/s (Effective throughput)** — higher is better. NVFP4 should significantly outperform BF16 on DGX Spark.
2. **Acceptance rate (α)** — speculative decoding acceptance may vary by quantization. NVFP4 typically has similar or better α than BF16.
3. **Memory usage** — check that `gpu_memory_utilization` can be higher for quantized models (more KV cache available).
4. **Max context length** — quantized models can support longer contexts for the same GPU memory.

### Example: Qwen3.6-35B-A3B Comparison

| Recipe | Format | Eff t/s (code, d0) | Eff t/s (code, d4096) | Acceptance (α) |
|--------|--------|-------------------|----------------------|----------------|
| NVFP4 + MTP | NVFP4 | 50.9 t/s | 127.3 t/s | 91.2% |
| FP8 + MTP | FP8 | ~45 t/s | ~110 t/s | ~85% |
| Q8_0 + llama-cpp | Q8_0 | ~30 t/s | ~60 t/s | N/A |

> **Note:** These are example values from the registry's benchmarks. Actual numbers vary by workload.