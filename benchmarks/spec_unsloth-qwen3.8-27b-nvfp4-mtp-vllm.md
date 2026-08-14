# Speculative Decoding Benchmark — unsloth/Qwen3.8-27B-NVFP4

- **Run ID**: `2026-08-14T19-15-16Z_7ae67f`
- **Date**: `2026-08-14T19:15:16.406398+00:00`
- **Mode**: spec-bench
- **Spec Method**: draft_model

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 24.0 | 23.9 | 65.1% | 35% | 2.0 | 3 | 24.2 | — | 168 | 5,492 | 128 |
| structured | 0 | 25.6 | 25.4 | 73.3% | 27% | 2.2 | 3 | 24.0 | — | 532 | 5,538 | 128 |
| code | 4096 | 23.8 | 23.6 | 65.1% | 35% | 2.0 | 3 | 24.0 | — | 11 | 5,387 | 128 |
| structured | 4096 | 24.7 | 24.5 | 73.3% | 27% | 2.2 | 3 | 23.2 | — | 11 | 5,186 | 128 |
| code | 8192 | 23.8 | 23.6 | 65.1% | 35% | 2.0 | 3 | 24.0 | — | 11 | 5,390 | 128 |
| structured | 8192 | 25.3 | 25.1 | 73.3% | 27% | 2.2 | 3 | 23.7 | — | 17 | 5,076 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     ██████████████████████████░░░░░░░░░░░░░░ 65.1%
  structured d0     █████████████████████████████░░░░░░░░░░░ 73.3%
        code d4096  ██████████████████████████░░░░░░░░░░░░░░ 65.1%
  structured d4096  █████████████████████████████░░░░░░░░░░░ 73.3%
        code d8192  ██████████████████████████░░░░░░░░░░░░░░ 65.1%
  structured d8192  █████████████████████████████░░░░░░░░░░░ 73.3%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 23.9 | 23.7 | 65.1% | 35% | 24.1 |
| structured | 25.2 | 25.0 | 73.3% | 27% | 23.6 |

## Draft Efficiency

| Metric | Value |
|---|---|
| Avg Draft Window | 3 tokens/step |
| Avg Acceptance Length (τ) | 2.1 tokens/step |
| Window Utilization | 69% |
| Avg Waste | 31% |

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
