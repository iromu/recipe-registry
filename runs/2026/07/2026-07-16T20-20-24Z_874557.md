# Speculative Decoding Benchmark — google/gemma-4-E4B-it

- **Run ID**: `2026-07-16T20-20-24Z_874557`
- **Date**: `2026-07-16T20:20:24.770845+00:00`
- **Mode**: spec-bench
- **Spec Method**: draft_model

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 83.1 | 85.7 | 42.9% | 57% | 3.0 | 7 | 145.3 | — | 9 | 1,550 | 128 |
| structured | 0 | 138.5 | 150.1 | 90.5% | 10% | 6.3 | 7 | 136.4 | — | 12 | 936 | 128 |
| code | 4096 | 71.7 | 73.1 | 34.6% | 65% | 2.4 | 7 | 149.1 | — | 69 | 1,853 | 128 |
| structured | 4096 | 140.1 | 149.5 | 90.5% | 10% | 6.3 | 7 | 138.0 | — | 15 | 928 | 128 |
| code | 8192 | 70.5 | 73.4 | 34.6% | 65% | 2.4 | 7 | 146.4 | — | 8 | 1,825 | 128 |
| structured | 8192 | 141.4 | 150.3 | 90.5% | 10% | 6.3 | 7 | 139.2 | — | 10 | 916 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     █████████████████░░░░░░░░░░░░░░░░░░░░░░░ 42.9%
  structured d0     ████████████████████████████████████░░░░ 90.5%
        code d4096  █████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░ 34.6%
  structured d4096  ████████████████████████████████████░░░░ 90.5%
        code d8192  █████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░ 34.6%
  structured d8192  ████████████████████████████████████░░░░ 90.5%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 75.1 | 77.4 | 37.3% | 63% | 147.0 |
| structured | 140.0 | 150.0 | 90.5% | 10% | 137.8 |

## Draft Efficiency

| Metric | Value |
|---|---|
| Avg Draft Window | 7 tokens/step |
| Avg Acceptance Length (τ) | 4.5 tokens/step |
| Window Utilization | 64% |
| Avg Waste | 36% |

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
