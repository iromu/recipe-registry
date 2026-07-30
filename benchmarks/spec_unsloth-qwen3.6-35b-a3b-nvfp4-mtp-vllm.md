# Speculative Decoding Benchmark — unsloth/Qwen3.6-35B-A3B-NVFP4-Fast

- **Run ID**: `2026-07-30T18-24-29Z_c52ec7`
- **Date**: `2026-07-30T18:24:29.777759+00:00`
- **Mode**: spec-bench
- **Spec Method**: draft_model

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 114.5 | 113.6 | 97.0% | 3% | 2.9 | 3 | 88.5 | — | 55 | 1,173 | 128 |
| structured | 0 | 109.5 | 108.7 | 94.9% | 5% | 2.8 | 3 | 84.7 | — | 9 | 1,178 | 128 |
| code | 4096 | 106.9 | 106.1 | 88.6% | 11% | 2.7 | 3 | 87.7 | — | 7 | 1,205 | 128 |
| structured | 4096 | 93.2 | 92.6 | 72.5% | 28% | 2.2 | 3 | 87.4 | — | 10 | 1,383 | 128 |
| code | 8192 | 110.0 | 109.2 | 93.1% | 7% | 2.8 | 3 | 87.7 | — | 11 | 1,174 | 128 |
| structured | 8192 | 99.9 | 99.1 | 82.9% | 17% | 2.5 | 3 | 86.6 | — | 10 | 1,291 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     ██████████████████████████████████████░░ 97.0%
  structured d0     █████████████████████████████████████░░░ 94.9%
        code d4096  ███████████████████████████████████░░░░░ 88.6%
  structured d4096  █████████████████████████████░░░░░░░░░░░ 72.5%
        code d8192  █████████████████████████████████████░░░ 93.1%
  structured d8192  █████████████████████████████████░░░░░░░ 82.9%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 110.4 | 109.6 | 92.9% | 7% | 87.9 |
| structured | 100.9 | 100.1 | 83.4% | 17% | 86.2 |

## Draft Efficiency

| Metric | Value |
|---|---|
| Avg Draft Window | 3 tokens/step |
| Avg Acceptance Length (τ) | 2.6 tokens/step |
| Window Utilization | 88% |
| Avg Waste | 12% |

## Interpretation Guide

- **Eff t/s** (Effective t/s): Output tokens ÷ wall-clock generation time. This is what users experience. Higher is better.
- **Stream t/s**: Token generation rate measured from SSE stream timing. For standard decoding, this matches Eff t/s. For spec decode, Eff t/s is typically higher.
- **α (accept)**: Acceptance rate — % of draft tokens accepted by the verifier. Higher means the draft model/MTP heads predict well for this workload.
- **Waste**: Fraction of drafted tokens rejected (1 − α). Lower is better. High waste means the draft model is poorly aligned with the target.
- **τ (length)**: Average acceptance length — tokens accepted per speculative step. Higher means more tokens generated per verification pass.
- **Window**: Average tokens drafted per speculative step (the configured draft window). Compare with τ to see window utilization.
- **Draft t/s**: Rate at which draft tokens are generated, regardless of acceptance. Compare with Eff t/s to see draft overhead.
- **Speedup**: Effective t/s ÷ baseline t/s. Values > 1.0x indicate spec decode is providing a benefit.

> [!TIP]
> Acceptance rates vary significantly by prompt type. Code and structured tasks
> typically show higher acceptance rates than creative/open-ended generation
> because future tokens are more predictable.
