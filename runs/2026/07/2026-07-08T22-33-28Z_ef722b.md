# Speculative Decoding Benchmark — nvidia/NVIDIA-Nemotron-Labs-3-Puzzle-75B-A9B-NVFP4

- **Run ID**: `2026-07-08T22-33-28Z_ef722b`
- **Date**: `2026-07-08T22:33:28.647964+00:00`
- **Mode**: spec-bench
- **Spec Method**: draft_model

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 30.2 | 30.0 | 62.9% | 37% | 1.9 | 3 | 31.2 | — | 9 | 4,241 | 128 |
| structured | 0 | 31.1 | 30.9 | 75.2% | 25% | 2.3 | 3 | 28.4 | — | 13 | 4,129 | 128 |
| code | 4096 | 31.9 | 31.7 | 60.7% | 39% | 1.8 | 3 | 33.7 | — | 9 | 4,017 | 128 |
| structured | 4096 | 35.6 | 35.3 | 76.9% | 23% | 2.3 | 3 | 32.5 | — | 8 | 3,605 | 128 |
| code | 8192 | 34.2 | 33.9 | 69.0% | 31% | 2.1 | 3 | 33.6 | — | 13 | 3,760 | 128 |
| structured | 8192 | 28.3 | 28.1 | 51.6% | 48% | 1.5 | 3 | 33.9 | — | 7 | 4,522 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     █████████████████████████░░░░░░░░░░░░░░░ 62.9%
  structured d0     ██████████████████████████████░░░░░░░░░░ 75.2%
        code d4096  ████████████████████████░░░░░░░░░░░░░░░░ 60.7%
  structured d4096  ██████████████████████████████░░░░░░░░░░ 76.9%
        code d8192  ███████████████████████████░░░░░░░░░░░░░ 69.0%
  structured d8192  ████████████████████░░░░░░░░░░░░░░░░░░░░ 51.6%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 32.1 | 31.9 | 64.2% | 36% | 32.8 |
| structured | 31.7 | 31.4 | 67.9% | 32% | 31.6 |

## Draft Efficiency

| Metric | Value |
|---|---|
| Avg Draft Window | 3 tokens/step |
| Avg Acceptance Length (τ) | 2.0 tokens/step |
| Window Utilization | 66% |
| Avg Waste | 34% |

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
