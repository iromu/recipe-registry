# Speculative Decoding Benchmark — Intel/Qwen3.6-27B-int4-AutoRound

- **Run ID**: `2026-05-28T20-23-36Z_66fbc9`
- **Date**: `2026-05-28T20:23:36.759685+00:00`
- **Mode**: spec-bench
- **Spec Method**: mtp

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 26.8 | 26.6 | 87.6% | 12% | 2.6 | 3 | 22.0 | — | 11 | 4,779 | 128 |
| structured | 0 | 26.4 | 26.2 | 87.6% | 12% | 2.6 | 3 | 21.7 | — | 9 | 4,849 | 128 |
| code | 4096 | 28.7 | 28.5 | 87.6% | 12% | 2.6 | 3 | 23.6 | — | 119 | 4,571 | 128 |
| structured | 4096 | 26.6 | 26.4 | 87.6% | 12% | 2.6 | 3 | 21.9 | — | 14 | 4,817 | 128 |
| code | 8192 | 28.5 | 28.3 | 87.6% | 12% | 2.6 | 3 | 23.4 | — | 69 | 4,565 | 128 |
| structured | 8192 | 25.1 | 24.9 | 87.6% | 12% | 2.6 | 3 | 20.6 | — | 20 | 5,118 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     ███████████████████████████████████░░░░░ 87.6%
  structured d0     ███████████████████████████████████░░░░░ 87.6%
        code d4096  ███████████████████████████████████░░░░░ 87.6%
  structured d4096  ███████████████████████████████████░░░░░ 87.6%
        code d8192  ███████████████████████████████████░░░░░ 87.6%
  structured d8192  ███████████████████████████████████░░░░░ 87.6%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 28.0 | 27.8 | 87.6% | 12% | 23.0 |
| structured | 26.1 | 25.9 | 87.6% | 12% | 21.4 |

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
