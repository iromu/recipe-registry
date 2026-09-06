# Speculative Decoding Benchmark — qwen3.8-flash-next

- **Run ID**: `2026-09-06T00-38-48Z_0cff24`
- **Date**: `2026-09-06T00:38:48.095014+00:00`
- **Mode**: spec-bench
- **Spec Method**: draft_model

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 24.7 | 24.5 | 46.5% | 53% | 1.4 | 3 | 30.7 | — | 6 | 5,192 | 128 |
| structured | 0 | 30.8 | 30.5 | 69.9% | 30% | 2.1 | 3 | 29.6 | — | 7 | 4,167 | 128 |
| code | 4096 | 31.1 | 30.8 | 51.6% | 48% | 1.5 | 3 | 37.1 | — | 9 | 4,129 | 128 |
| structured | 4096 | 37.3 | 37.1 | 69.9% | 30% | 2.1 | 3 | 35.9 | — | 6 | 3,435 | 128 |
| code | 8192 | 32.8 | 32.5 | 58.2% | 42% | 1.7 | 3 | 36.1 | — | 9 | 3,913 | 128 |
| structured | 8192 | 35.6 | 35.3 | 65.1% | 35% | 2.0 | 3 | 35.9 | — | 10 | 3,606 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     ██████████████████░░░░░░░░░░░░░░░░░░░░░░ 46.5%
  structured d0     ███████████████████████████░░░░░░░░░░░░░ 69.9%
        code d4096  ████████████████████░░░░░░░░░░░░░░░░░░░░ 51.6%
  structured d4096  ███████████████████████████░░░░░░░░░░░░░ 69.9%
        code d8192  ███████████████████████░░░░░░░░░░░░░░░░░ 58.2%
  structured d8192  ██████████████████████████░░░░░░░░░░░░░░ 65.1%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 29.5 | 29.3 | 52.1% | 48% | 34.6 |
| structured | 34.6 | 34.3 | 68.3% | 32% | 33.8 |

## Draft Efficiency

| Metric | Value |
|---|---|
| Avg Draft Window | 3 tokens/step |
| Avg Acceptance Length (τ) | 1.8 tokens/step |
| Window Utilization | 60% |
| Avg Waste | 40% |

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
