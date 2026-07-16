# Speculative Decoding Benchmark — nvidia/Gemma-4-31B-IT-NVFP4

- **Run ID**: `2026-07-16T22-56-37Z_f290e8`
- **Date**: `2026-07-16T22:56:37.475005+00:00`
- **Mode**: spec-bench
- **Spec Method**: draft_model

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 25.3 | 26.4 | 47.0% | 53% | 4.7 | 10 | 45.4 | — | 11 | 5,076 | 128 |
| structured | 0 | 43.1 | 46.7 | 93.8% | 6% | 9.4 | 10 | 43.8 | — | 8 | 2,975 | 128 |
| code | 4096 | 24.8 | 26.2 | 47.0% | 53% | 4.7 | 10 | 44.6 | — | 13 | 5,171 | 128 |
| structured | 4096 | 42.7 | 47.7 | 93.8% | 6% | 9.4 | 10 | 43.4 | — | 11 | 3,006 | 128 |
| code | 8192 | 24.8 | 26.3 | 47.0% | 53% | 4.7 | 10 | 44.6 | — | 9 | 5,161 | 128 |
| structured | 8192 | 41.3 | 45.9 | 93.8% | 6% | 9.4 | 10 | 41.9 | — | 12 | 3,114 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     ██████████████████░░░░░░░░░░░░░░░░░░░░░░ 47.0%
  structured d0     █████████████████████████████████████░░░ 93.8%
        code d4096  ██████████████████░░░░░░░░░░░░░░░░░░░░░░ 47.0%
  structured d4096  █████████████████████████████████████░░░ 93.8%
        code d8192  ██████████████████░░░░░░░░░░░░░░░░░░░░░░ 47.0%
  structured d8192  █████████████████████████████████████░░░ 93.8%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 25.0 | 26.3 | 47.0% | 53% | 44.9 |
| structured | 42.4 | 46.8 | 93.8% | 6% | 43.0 |

## Draft Efficiency

| Metric | Value |
|---|---|
| Avg Draft Window | 10 tokens/step |
| Avg Acceptance Length (τ) | 7.0 tokens/step |
| Window Utilization | 70% |
| Avg Waste | 30% |

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
