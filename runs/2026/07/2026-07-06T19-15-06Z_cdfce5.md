# Speculative Decoding Benchmark — nvidia/Qwen3.6-27B-NVFP4

- **Run ID**: `2026-07-06T19-15-06Z_cdfce5`
- **Date**: `2026-07-06T19:15:06.989152+00:00`
- **Mode**: spec-bench
- **Spec Method**: draft_model

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 30.3 | 30.1 | 93.1% | 7% | 2.8 | 3 | 24.2 | — | 15 | 4,234 | 128 |
| structured | 0 | 25.2 | 25.0 | 73.3% | 27% | 2.2 | 3 | 23.6 | — | 7 | 5,081 | 128 |
| code | 4096 | 31.7 | 31.5 | 93.1% | 7% | 2.8 | 3 | 25.3 | — | 7 | 4,046 | 128 |
| structured | 4096 | 26.5 | 26.2 | 73.3% | 27% | 2.2 | 3 | 24.8 | — | 9 | 4,848 | 128 |
| code | 8192 | 32.2 | 32.0 | 93.1% | 7% | 2.8 | 3 | 25.7 | — | 9 | 3,980 | 128 |
| structured | 8192 | 26.4 | 26.2 | 73.3% | 27% | 2.2 | 3 | 24.8 | — | 14 | 4,857 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     █████████████████████████████████████░░░ 93.1%
  structured d0     █████████████████████████████░░░░░░░░░░░ 73.3%
        code d4096  █████████████████████████████████████░░░ 93.1%
  structured d4096  █████████████████████████████░░░░░░░░░░░ 73.3%
        code d8192  █████████████████████████████████████░░░ 93.1%
  structured d8192  █████████████████████████████░░░░░░░░░░░ 73.3%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 31.4 | 31.2 | 93.1% | 7% | 25.0 |
| structured | 26.0 | 25.8 | 73.3% | 27% | 24.4 |

## Draft Efficiency

| Metric | Value |
|---|---|
| Avg Draft Window | 3 tokens/step |
| Avg Acceptance Length (τ) | 2.5 tokens/step |
| Window Utilization | 83% |
| Avg Waste | 17% |

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
