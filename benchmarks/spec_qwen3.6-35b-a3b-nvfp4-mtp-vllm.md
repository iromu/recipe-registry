# Speculative Decoding Benchmark — nvidia/Qwen3.6-35B-A3B-NVFP4

- **Run ID**: `2026-06-02T18-34-04Z_ebc8a1`
- **Date**: `2026-06-02T18:34:04.349699+00:00`
- **Mode**: spec-bench
- **Spec Method**: draft_model

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 94.3 | 93.6 | 90.5% | 10% | 2.7 | 3 | 77.4 | — | 10 | 1,368 | 128 |
| structured | 0 | 91.3 | 90.7 | 78.1% | 22% | 2.3 | 3 | 81.3 | — | 8 | 1,410 | 128 |
| code | 4096 | 122.6 | 121.7 | 82.0% | 18% | 2.5 | 3 | 106.3 | — | 8 | 1,052 | 128 |
| structured | 4096 | 113.6 | 112.8 | 74.2% | 26% | 2.2 | 3 | 106.5 | — | 8 | 1,135 | 128 |
| code | 8192 | 132.7 | 131.8 | 91.2% | 9% | 2.7 | 3 | 105.8 | — | 10 | 975 | 128 |
| structured | 8192 | 113.9 | 113.0 | 75.2% | 25% | 2.3 | 3 | 104.1 | — | 8 | 1,132 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     ████████████████████████████████████░░░░ 90.5%
  structured d0     ███████████████████████████████░░░░░░░░░ 78.1%
        code d4096  ████████████████████████████████░░░░░░░░ 82.0%
  structured d4096  █████████████████████████████░░░░░░░░░░░ 74.2%
        code d8192  ████████████████████████████████████░░░░ 91.2%
  structured d8192  ██████████████████████████████░░░░░░░░░░ 75.2%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 116.6 | 115.7 | 87.9% | 12% | 96.5 |
| structured | 106.3 | 105.5 | 75.8% | 24% | 97.3 |

## Draft Efficiency

| Metric | Value |
|---|---|
| Avg Draft Window | 3 tokens/step |
| Avg Acceptance Length (τ) | 2.5 tokens/step |
| Window Utilization | 82% |
| Avg Waste | 18% |

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
