# Speculative Decoding Deep Dive

Speculative decoding speeds up inference by using a "draft" mechanism to predict multiple tokens at once, then verifying them in parallel with the main model. This registry uses two methods: **MTP** (Multi-Token Prediction) and **DFlash**.

---

## Table of Contents

- [How Speculative Decoding Works](#how-speculative-decoding-works)
- [MTP (Multi-Token Prediction)](#mtp-multi-token-prediction)
- [DFlash](#dflash)
- [Speculative Config Format](#speculative-config-format)
- [Benchmark Interpretation](#benchmark-interpretation)
- [Tuning Guide](#tuning-guide)

---

## How Speculative Decoding Works

Standard autoregressive decoding generates **one token per forward pass**:

```
[Token 1] → [Token 2] → [Token 3] → [Token 4] → [Token 5]
  1 pass      1 pass      1 pass      1 pass      1 pass
  = 5 passes total
```

Speculative decoding uses a **draft** to predict multiple tokens ahead, then verifies them all in one pass:

```
[Token 1] → [Token 2→3→4→5] → [Token 6]
  1 pass      draft + verify      1 pass
  = 3 passes (vs 6 in standard)
```

**The trade-off:** Drafting has overhead, and not all draft tokens are accepted. The speedup depends on the **acceptance rate** — how many draft tokens the main model agrees with.

### Key Metrics

| Metric | Symbol | Meaning | Good Value |
|--------|--------|---------|------------|
| Acceptance rate | α | % of draft tokens accepted | > 70% |
| Average acceptance length | τ | Tokens accepted per speculative step | > 2.0 |
| Window | — | Draft tokens per step (n) | 3–12 |
| Window utilization | τ/n | How well the window is used | > 60% |
| Waste | 1−α | % of draft tokens rejected | < 30% |
| Speedup | Eff t/s ÷ baseline | Effective speedup | > 1.0x |

---

## MTP (Multi-Token Prediction)

### What It Is

MTP uses the **model's own auxiliary heads** (trained alongside the main output head) to draft tokens. No external model is needed — the same model produces both the main prediction and the draft.

**How it works:**
1. The model processes the prompt and produces the first token.
2. The MTP heads simultaneously predict the next 3 tokens (for `num_speculative_tokens: 3`).
3. All 4 tokens are verified in a single forward pass by the main head.
4. Accepted tokens are output; rejected tokens trigger a re-draft.

### Recipe Examples

**Qwen3.6-35B-A3B NVFP4 (MTP, draft window 3):**
```yaml
speculative_config: '{"method":"mtp","num_speculative_tokens":3,"moe_backend":"triton"}'
```

**Qwen3.6-27B NVFP4 (MTP, draft window 3):**
```yaml
speculative_config: '{"method":"mtp","num_speculative_tokens":3}'
```

### The `moe_backend` Parameter

Qwen3.6-35B-A3B is a **Mixture-of-Experts (MoE)** model. When using MTP on MoE models, the draft tokens go through the MoE routing, which requires a specific backend:

| `moe_backend` value | Meaning |
|---------------------|---------|
| `triton` | Triton-based MoE kernel for MTP drafting |
| `marlin` | Marlin MoE kernel for verification |
| `flashinfer_cutlass` | FlashInfer + CUTLASS hybrid |

**Why MTP needs `moe_backend`:** The MTP heads draft tokens by routing through the MoE layers. The Triton backend handles this drafting efficiently. The verification uses a different backend (Marlin).

### MTP Pros and Cons

| Pros | Cons |
|------|------|
| No external model needed | Requires MTP-trained model |
| Draft and verify share the same KV cache | Draft quality depends on MTP head training |
| Low latency (same model, same memory) | Draft window limited by MTP head depth |
| Works well on quantized models (NVFP4) | MoE models need extra backend config |

### MTP Benchmark Results (from this registry)

**Qwen3.6-35B-A3B NVFP4 (draft window 3):**

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window |
|--------|-------|---------|------------|------------|-------|------------|--------|
| code | 0 | 50.9 | 50.6 | 91.2% | 9% | 2.7 | 3 |
| structured | 0 | 56.4 | 56.0 | 72.4% | 28% | 2.2 | 3 |
| code | 4096 | 127.3 | 126.4 | 89.5% | 10% | 2.7 | 3 |
| structured | 4096 | 109.8 | 109.0 | 74.2% | 26% | 2.2 | 3 |
| code | 8192 | 124.3 | 123.5 | 85.2% | 15% | 2.6 | 3 |
| structured | 8192 | 109.5 | 108.7 | 72.5% | 28% | 2.2 | 3 |

**Key observations:**
- **Code prompts** have much higher acceptance rates (~85–91%) than structured prompts (~72%)
- **Long context** (4096/8192) maintains high acceptance for code but not for structured
- **Effective throughput** for code at 4096 context: 127.3 t/s (significant speedup over baseline)
- **Window utilization** is excellent: τ=2.7 out of window=3 means 90% of draft tokens are accepted for code

---

## DFlash

### What It Is

DFlash uses an **external draft model** (`z-lab/Qwen3.6-27B-DFlash`) to predict tokens, which are then verified by the main model. This is different from MTP because the drafter is a separate model entirely.

**How it works:**
1. The main model processes the prompt and produces the first token.
2. The DFlash draft model predicts the next 12 tokens (for `num_speculative_tokens: 12`).
3. The main model verifies all 13 tokens in a single forward pass.
4. Accepted tokens are output; rejected tokens trigger a new draft.

### Recipe Example

**AEON-7 XS (DFlash, draft window 12):**
```yaml
speculative_config: '{"method":"dflash","model":"z-lab/Qwen3.6-27B-DFlash","num_speculative_tokens":12}'
```

### DFlash Pros and Cons

| Pros | Cons |
|------|------|
| Larger draft window (n=12 vs n=3 for MTP) | Requires downloading and loading a second model |
| External drafter can be specialized | Higher memory usage (two models in memory) |
| Can be swapped without retraining the main model | Draft model may not align well with main model |
| Good for models without MTP heads | Higher latency per step (draft model inference) |

### DFlash Specifics

**Long-context behavior:** The DFlash drafter uses sliding-window attention (window 2048). This means:
- Draft acceptance is stable for contexts < 2048 tokens
- For contexts > 2048 tokens, acceptance drops **unless** vLLM PR #40898 is applied (proper SWA handling)
- vLLM PR #41703 makes prefix caching corruption-immune with DFlash

**Acceptance rates by category (short context, n=12):**
| Category | Acceptance Rate |
|----------|----------------|
| Math | ~50% |
| Reasoning | ~50% |
| Extraction | ~40% |
| Coding | ~38% |
| Natural | ~25% |
| Prose | ~18% |

---

## Speculative Config Format

The `speculative_config` is a JSON string passed to `--speculative-config`:

```json
{
  "method": "mtp",                    // "mtp" or "dflash"
  "num_speculative_tokens": 3,        // draft window size (n)
  "moe_backend": "triton"             // only for MTP on MoE models
}
```

**DFlash variant:**
```json
{
  "method": "dflash",
  "model": "z-lab/Qwen3.6-27B-DFlash",  // external draft model ID
  "num_speculative_tokens": 12           // draft window size (n)
}
```

### Field Descriptions

| Field | Required | Description |
|-------|----------|-------------|
| `method` | Yes | `"mtp"` for MTP, `"dflash"` for DFlash |
| `num_speculative_tokens` | Yes | Number of draft tokens per speculative step (window size n) |
| `moe_backend` | MTP only | MoE kernel backend for MTP drafting on MoE models (`triton`, `marlin`, `flashinfer_cutlass`) |
| `model` | DFlash only | HuggingFace model ID of the external draft model |

### Tuning `num_speculative_tokens`

| Value | Best For | Trade-off |
|-------|----------|-----------|
| 2–3 | MTP (shallow draft heads) | Low overhead, moderate speedup |
| 4–6 | Balanced | Good speedup with moderate draft overhead |
| 8–12 | DFlash (external drafter) | High speedup potential, higher draft overhead |

**Rule of thumb:** The optimal window size depends on the acceptance rate. If α ≈ 80%, a window of 4–6 is optimal. If α ≈ 50%, a window of 8–12 is better (more drafts compensate for lower acceptance).

---

## Benchmark Interpretation

Speculative decoding benchmarks are stored in `benchmarks/spec_<recipe-name>.md`.

### Key Sections

1. **Results table** — acceptance rate, throughput, and speedup by prompt type and context depth
2. **Acceptance rate by prompt type** — visual bar chart showing α for each combination
3. **Per-prompt-type summary** — aggregated metrics by prompt category
4. **Draft efficiency** — window utilization metrics
5. **Interpretation guide** — explains each metric

### How to Read the Results

**Effective throughput (Eff t/s):** The key metric. This is output tokens per second including all speculative overhead. Higher = faster.

**Acceptance rate (α):** The probability that a draft token is accepted. The single most important factor for speedup.

**Speedup:** `Eff t/s ÷ baseline t/s`. Values > 1.0x mean speculative decoding is helping. Values < 1.0x mean the draft overhead outweighs the benefit.

### When Speculative Decoding Hurts

Speculative decoding can **reduce** throughput when:
1. **Acceptance rate is too low** (< 30%): Draft overhead exceeds benefit
2. **Window is too large**: More draft tokens = more wasted computation
3. **Prompt length mismatch**: DFlash sliding window doesn't match context length
4. **Model mismatch**: DFlash drafter not aligned with main model's token distribution

---

## Tuning Guide

### If Acceptance Rate Is Low

1. **Increase draft window** (for DFlash): Try `num_speculative_tokens: 12` → `16`
2. **Switch drafter** (for DFlash): Try a different draft model
3. **Check alignment**: Ensure the draft model was trained for the target model family
4. **Verify vLLM version**: Ensure PR #40898 (SWA fix) and PR #41703 (prefix caching fix) are included

### If Throughput Is Low

1. **Reduce draft window** (for MTP): Try `num_speculative_tokens: 2` → `3`
2. **Check MoE backend**: Ensure `moe_backend` matches your quantization (triton for NVFP4 MTP)
3. **Increase GPU memory**: Higher `gpu_memory_utilization` allows larger batches
4. **Enable CUDA graphs**: Set `VLLM_MEMORY_PROFILER_ESTIMATE_CUDAGRAPHS` for graph capture

### If You See OOM Errors

1. **Reduce `gpu_memory_utilization`**: 0.52 → 0.30
2. **Reduce `max_model_len`**: 131072 → 32768
3. **Reduce `max_num_seqs`**: 4 → 2
4. **Reduce draft window**: `num_speculative_tokens: 12` → `3`

### MTP vs DFlash: Which to Choose?

| Factor | Choose MTP | Choose DFlash |
|--------|-----------|---------------|
| Model has MTP heads | ✅ Yes | ❌ No need |
| Memory constrained | ✅ Shared KV cache | ❌ Two models |
| Need large draft window | ❌ Limited by head depth | ✅ n=12+ |
| Model trained with MTP | ✅ Optimal | ⚠️ Suboptimal |
| Multimodal model | ⚠️ May not support | ✅ AEON-7 XS works |
| External drafter available | ⚠️ Unnecessary | ✅ Use it |