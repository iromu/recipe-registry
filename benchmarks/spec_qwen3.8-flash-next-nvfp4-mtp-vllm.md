# Speculative Decoding Benchmark — qwen3.8-flash-next

- **Run ID**: `2026-09-11T07-50-16Z_7c5682`
- **Date**: `2026-09-11T07:50:16.983475+00:00`
- **Mode**: spec-bench
- **Spec Method**: draft_model

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 30.2 | 29.9 | 70.7% | 29% | 2.1 | 3 | 29.0 | — | 118 | 4,359 | 128 |
| structured | 0 | 31.0 | 30.8 | 78.9% | 21% | 2.4 | 3 | 27.6 | — | 192 | 4,319 | 128 |
| code | 4096 | 38.2 | 37.9 | 70.7% | 29% | 2.1 | 3 | 36.7 | — | 14 | 3,367 | 128 |
| structured | 4096 | 39.2 | 38.9 | 78.9% | 21% | 2.4 | 3 | 34.9 | — | 14 | 3,280 | 128 |
| code | 8192 | 38.0 | 37.8 | 70.7% | 29% | 2.1 | 3 | 36.6 | — | 14 | 3,378 | 128 |
| structured | 8192 | 39.0 | 38.7 | 78.9% | 21% | 2.4 | 3 | 34.8 | — | 12 | 3,292 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     ████████████████████████████░░░░░░░░░░░░ 70.7%
  structured d0     ███████████████████████████████░░░░░░░░░ 78.9%
        code d4096  ████████████████████████████░░░░░░░░░░░░ 70.7%
  structured d4096  ███████████████████████████████░░░░░░░░░ 78.9%
        code d8192  ████████████████████████████░░░░░░░░░░░░ 70.7%
  structured d8192  ███████████████████████████████░░░░░░░░░ 78.9%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 35.5 | 35.2 | 70.7% | 29% | 34.1 |
| structured | 36.4 | 36.1 | 78.9% | 21% | 32.4 |

## Draft Efficiency

| Metric | Value |
|---|---|
| Avg Draft Window | 3 tokens/step |
| Avg Acceptance Length (τ) | 2.2 tokens/step |
| Window Utilization | 75% |
| Avg Waste | 25% |

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
