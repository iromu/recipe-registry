# Environment Variables Reference

Environment variables injected into vLLM containers via the `env:` section of recipe YAMLs.
Grouped by purpose. Each entry explains **what it does**, **why it's needed**, and **when you might change it**.

---

## Table of Contents

- [CUDA / PyTorch Runtime](#cuda--pytorch-runtime)
- [FlashInfer](#flashinfer)
- [vLLM Internal](#vllm-internal)
- [NVFP4 / FP4 Specific](#nvfp4--fp4-specific)

---

## CUDA / PyTorch Runtime

### `TORCH_CUDA_ARCH_LIST`

```yaml
TORCH_CUDA_ARCH_LIST: 12.1a
```

Specifies the CUDA architecture(s) to compile PyTorch/CUDA kernels for.

**Value `12.1a`** = NVIDIA Blackwell (GB10) architecture. This is required for the DGX Spark's GPU.

**When to change:** Only if targeting a different GPU architecture (e.g., `8.9` for H100, `8.0` for A100).

---

### `PYTORCH_CUDA_ALLOC_CONF`

```yaml
PYTORCH_CUDA_ALLOC_CONF: expandable_segments:True
```

Enables PyTorch's expandable CUDA memory segments feature.

**What it does:** Allows the CUDA memory allocator to grow memory allocations dynamically instead of pre-allocating fixed pools. Reduces memory fragmentation and OOM errors.

**When to use:** Always enable on DGX Spark. Particularly important for workloads with variable-length sequences.

**Alternative:** `max_split_size_mb:128` — limits the size of free blocks that can be split, reducing fragmentation without expandable segments.

---

### `TORCH_MATMUL_PRECISION`

```yaml
TORCH_MATMUL_PRECISION: high
```

Controls the precision of matrix multiplication operations.

**Values:**
| Value | Meaning |
|-------|---------|
| `high` | Use the highest precision available on the hardware (e.g., TF32 on Ada, Tensor Cores on Blackwell) |
| `tensor_core` | Force Tensor Core usage even if it means reduced precision |
| `default` | Let PyTorch choose |

**When to use:** `high` is the recommended default. Use `tensor_core` only if you need maximum throughput and can tolerate precision loss.

---

### `NVIDIA_FORWARD_COMPAT`

```yaml
NVIDIA_FORWARD_COMPAT: 1
```

Enables NVIDIA forward compatibility mode.

**What it does:** Allows newer CUDA drivers to run with older compiled kernels. Useful when the driver version is newer than what the CUDA toolkit was compiled against.

**When needed:** Common on systems with rolling driver updates. Set to `1` if you see driver/kernel version mismatch errors.

---

### `NVIDIA_DISABLE_REQUIRE`

```yaml
NVIDIA_DISABLE_REQUIRE: 1
```

Disables NVIDIA driver requirement checks.

**What it does:** Skips strict version checks between the CUDA runtime and the installed driver.

**When needed:** Same as `NVIDIA_FORWARD_COMPAT` — for driver/kernel version mismatches. Often set alongside it.

---

## FlashInfer

### `FLASHINFER_DISABLE_VERSION_CHECK`

```yaml
FLASHINFER_DISABLE_VERSION_CHECK: 1
```

Disables FlashInfer's version compatibility check.

**What it does:** FlashInfer normally checks that the installed version matches the expected version at runtime. This flag skips that check.

**Why it's needed:** FlashInfer's version check can fail in development environments where the library is built from source or from nightly builds (`dgx-vllm-eugr-nightly`). The check is conservative and may reject valid builds.

**Risk:** If you disable this, FlashInfer may silently use incompatible kernels. Only disable when you're confident the build is correct.

---

### `VLLM_FLASHINFER_FORCE_TENSOR_CORES`

```yaml
VLLM_FLASHINFER_FORCE_TENSOR_CORES: 1
```

Forces FlashInfer to use Tensor Core operations even when the input dtype might suggest otherwise.

**What it does:** Tensor Cores are significantly faster than regular CUDA cores for matrix operations. This flag ensures they're used even for edge cases where FlashInfer might fall back.

**When to use:** Always enable on Blackwell/Ada GPUs. No downside.

---

### `VLLM_USE_FLASHINFER_SAMPLER`

```yaml
VLLM_USE_FLASHINFER_SAMPLER: 1
```

Uses FlashInfer's sampling kernel instead of vLLM's default sampler.

**What it does:** FlashInfer's sampler is optimized for the specific attention backend and can be faster, especially with FlashInfer attention.

**When to use:** Always enable when using `--attention-backend flashinfer`.

---

## vLLM Internal

### `VLLM_ATTENTION_BACKEND`

```yaml
VLLM_ATTENTION_BACKEND: flashinfer
```

Overrides the attention backend at the vLLM level (same as `--attention-backend` flag).

**Why set as env var:** Some models need the backend set before vLLM initializes its attention module. The command-line flag may not be sufficient for all models.

**Values:** `flashinfer`, `flash_attn`, `pallas`, `xformers`

---

### `VLLM_HTTP_TIMEOUT_KEEP_ALIVE`

```yaml
VLLM_HTTP_TIMEOUT_KEEP_ALIVE: <value>
```

Timeout for keep-alive HTTP connections.

**What it does:** Controls how long idle connections are kept open. Useful for long-running benchmarking sessions where connections may sit idle between requests.

**When to adjust:** Increase if you see connection timeout errors during long benchmark runs.

---

### `VLLM_MARLIN_USE_ATOMIC_ADD`

```yaml
VLLM_MARLIN_USE_ATOMIC_ADD: 1
```

Enables atomic add operations in the Marlin MoE kernel.

**What it does:** Marlin is NVIDIA's FP8/MoE kernel. Atomic add enables more accurate accumulation during MoE routing, at the cost of some performance.

**When to use:** Enable when you see numerical instability or incorrect results with MoE models. Disable for maximum performance if results are correct.

---

### `VLLM_MEMORY_PROFILER_ESTIMATE_CUDAGRAPHS`

```yaml
VLLM_MEMORY_PROFILER_ESTIMATE_CUDAGRAPHS: <value>
```

Controls how vLLM estimates CUDA graph memory usage during profiling.

**What it does:** CUDA graphs capture GPU execution for faster repeated inference. This env var controls the estimation strategy for memory allocation during graph capture.

**When to adjust:** Only if you see CUDA graph capture failures or memory estimation errors.

---

## NVFP4 / FP4 Specific

### `VLLM_NVFP4_GEMM_BACKEND`

```yaml
VLLM_NVFP4_GEMM_BACKEND: flashinfer-cutlass
```

Selects the GEMM (matrix multiply) backend for NVFP4 quantization.

**Values:**
| Value | Meaning |
|-------|---------|
| `flashinfer-cutlass` | FlashInfer's CUTLASS-based NVFP4 kernel (recommended for DGX Spark) |
| `triton` | Triton-based NVFP4 kernel (fallback) |
| `marlin` | Marlin NVFP4 kernel |

**Why it matters:** The NVFP4 GEMM backend is the most performance-critical component for NVFP4 models. `flashinfer-cutlass` is patched for sm_121a (Blackwell) and provides the best throughput.

**When to change:** Only if you encounter kernel-specific bugs. The default (`flashinfer-cutlass`) is the most tested path for DGX Spark.

---

### `VLLM_USE_FLASHINFER_MOE_FP4`

```yaml
VLLM_USE_FLASHINFER_MOE_FP4: 0
```

Disables FlashInfer's native MoE FP4 kernel.

**Why disabled:** FlashInfer's native MoE FP4 kernel may have bugs or incompatibilities with certain models or CUDA versions. Setting to `0` forces vLLM to use the Marlin or Triton MoE backend instead.

**When to enable:** If you're using a model that specifically benefits from FlashInfer's MoE FP4 kernel and you've verified it works on your setup.

---

### `VLLM_TEST_FORCE_FP8_MARLIN`

```yaml
VLLM_TEST_FORCE_FP8_MARLIN: 0
```

Forces the use of Marlin's FP8 kernel even when other quantization is specified.

**Why disabled:** Set to `0` in most recipes because the quantization is controlled by the `--quantization modelopt` flag. Forcing FP8 Marlin would override the recipe's intended quantization.

**When to enable:** Only for debugging or testing FP8 Marlin specifically.

---

### `CUTE_DSL_ARCH`

```yaml
CUTE_DSL_ARCH: sm_121a
```

Specifies the CUDA architecture for CUTLASS (CUDA Templates for Linear Algebra Subroutines) compilation.

**Value `sm_121a`** = Blackwell (GB10) architecture. Required for NVFP4 GEMM kernels on DGX Spark.

**When to change:** Only when targeting a different GPU architecture.

---

### `ENABLE_NVFP4_SM100`

```yaml
ENABLE_NVFP4_SM100: 0
```

Disables NVFP4 support for sm_100 (Hopper/H100) architecture.

**Why disabled:** DGX Spark uses sm_121a (Blackwell), not sm_100 (Hopper). Enabling sm_100 NVFP4 would cause compilation failures or runtime errors because the wrong kernels would be selected.

**When to enable:** Only when running on Hopper hardware (H100).

---

## Quick Reference Table

| Variable | Default | Category | Required? |
|----------|---------|----------|-----------|
| `TORCH_CUDA_ARCH_LIST` | `12.1a` | CUDA | Yes (for DGX Spark) |
| `PYTORCH_CUDA_ALLOC_CONF` | `expandable_segments:True` | CUDA | Recommended |
| `TORCH_MATMUL_PRECISION` | `high` | CUDA | Optional |
| `NVIDIA_FORWARD_COMPAT` | `1` | NVIDIA | Recommended |
| `NVIDIA_DISABLE_REQUIRE` | `1` | NVIDIA | Recommended |
| `FLASHINFER_DISABLE_VERSION_CHECK` | `1` | FlashInfer | For dev/nightly builds |
| `VLLM_FLASHINFER_FORCE_TENSOR_CORES` | `1` | FlashInfer | Always |
| `VLLM_USE_FLASHINFER_SAMPLER` | `1` | FlashInfer | With flashinfer backend |
| `VLLM_ATTENTION_BACKEND` | `flashinfer` | vLLM | For dev builds |
| `VLLM_MARLIN_USE_ATOMIC_ADD` | `1` | vLLM | For MoE models |
| `VLLM_NVFP4_GEMM_BACKEND` | `flashinfer-cutlass` | NVFP4 | For NVFP4 models |
| `VLLM_USE_FLASHINFER_MOE_FP4` | `0` | NVFP4 | Usually disabled |
| `VLLM_TEST_FORCE_FP8_MARLIN` | `0` | NVFP4 | Usually disabled |
| `CUTE_DSL_ARCH` | `sm_121a` | CUTLASS | Yes (for DGX Spark) |
| `ENABLE_NVFP4_SM100` | `0` | NVFP4 | Yes (for DGX Spark) |