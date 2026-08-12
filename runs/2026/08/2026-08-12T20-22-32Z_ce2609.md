# Speculative Decoding Benchmark — nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4

- **Run ID**: `2026-08-12T20-22-32Z_ce2609`
- **Date**: `2026-08-12T20:22:32.092335+00:00`
- **Mode**: spec-bench
- **Spec Method**: draft_model

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 113.0 | 112.3 | 76.1% | 24% | 2.3 | 3 | 103.3 | — | 8 | 1,140 | 128 |
| structured | 0 | 113.4 | 112.6 | 77.8% | 22% | 2.3 | 3 | 103.6 | — | 8 | 1,137 | 128 |
| code | 4096 | 130.6 | 129.7 | 84.3% | 16% | 2.5 | 3 | 110.2 | — | 7 | 988 | 128 |
| structured | 4096 | 110.1 | 109.4 | 67.4% | 33% | 2.0 | 3 | 111.0 | — | 11 | 1,173 | 128 |
| code | 8192 | 130.1 | 129.2 | 85.2% | 15% | 2.6 | 3 | 109.8 | — | 7 | 991 | 128 |
| structured | 8192 | 119.0 | 118.2 | 77.8% | 22% | 2.3 | 3 | 108.8 | — | 11 | 1,087 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     ██████████████████████████████░░░░░░░░░░ 76.1%
  structured d0     ███████████████████████████████░░░░░░░░░ 77.8%
        code d4096  █████████████████████████████████░░░░░░░ 84.3%
  structured d4096  ██████████████████████████░░░░░░░░░░░░░░ 67.4%
        code d8192  ██████████████████████████████████░░░░░░ 85.2%
  structured d8192  ███████████████████████████████░░░░░░░░░ 77.8%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 124.6 | 123.7 | 81.8% | 18% | 107.8 |
| structured | 114.2 | 113.4 | 74.3% | 26% | 107.8 |

## Draft Efficiency

| Metric | Value |
|---|---|
| Avg Draft Window | 3 tokens/step |
| Avg Acceptance Length (τ) | 2.3 tokens/step |
| Window Utilization | 78% |
| Avg Waste | 22% |

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
