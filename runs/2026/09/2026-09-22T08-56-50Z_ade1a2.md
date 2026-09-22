# Speculative Decoding Benchmark — nvidia/Qwen3.8-27B-NVFP4

- **Run ID**: `2026-09-22T08-56-50Z_ade1a2`
- **Date**: `2026-09-22T08:56:50.606764+00:00`
- **Mode**: spec-bench
- **Spec Method**: draft_model

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 29.6 | 29.4 | 72.5% | 28% | 2.2 | 3 | 27.8 | — | 13 | 4,332 | 128 |
| structured | 0 | 32.6 | 32.3 | 87.6% | 12% | 2.6 | 3 | 26.7 | — | 15 | 3,944 | 128 |
| code | 4096 | 29.3 | 29.1 | 72.5% | 28% | 2.2 | 3 | 27.5 | — | 14 | 4,384 | 128 |
| structured | 4096 | 32.7 | 32.5 | 87.6% | 12% | 2.6 | 3 | 26.8 | — | 15 | 3,926 | 128 |
| code | 8192 | 29.3 | 29.1 | 72.5% | 28% | 2.2 | 3 | 27.5 | — | 16 | 4,384 | 128 |
| structured | 8192 | 32.7 | 32.4 | 87.6% | 12% | 2.6 | 3 | 26.8 | — | 23 | 3,941 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     █████████████████████████████░░░░░░░░░░░ 72.5%
  structured d0     ███████████████████████████████████░░░░░ 87.6%
        code d4096  █████████████████████████████░░░░░░░░░░░ 72.5%
  structured d4096  ███████████████████████████████████░░░░░ 87.6%
        code d8192  █████████████████████████████░░░░░░░░░░░ 72.5%
  structured d8192  ███████████████████████████████████░░░░░ 87.6%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 29.4 | 29.2 | 72.5% | 28% | 27.6 |
| structured | 32.7 | 32.4 | 87.6% | 12% | 26.8 |

## Draft Efficiency

| Metric | Value |
|---|---|
| Avg Draft Window | 3 tokens/step |
| Avg Acceptance Length (τ) | 2.4 tokens/step |
| Window Utilization | 80% |
| Avg Waste | 20% |

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
