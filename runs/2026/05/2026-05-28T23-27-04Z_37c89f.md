# Speculative Decoding Benchmark — Qwen/Qwen3.6-35B-A3B-FP8

- **Run ID**: `2026-05-28T23-27-04Z_37c89f`
- **Date**: `2026-05-28T23:27:04.339967+00:00`
- **Mode**: spec-bench
- **Spec Method**: mtp

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 72.0 | 71.5 | 86.1% | 14% | 2.6 | 3 | 60.8 | — | 9 | 1,786 | 128 |
| structured | 0 | 67.6 | 67.1 | 78.1% | 22% | 2.3 | 3 | 60.2 | — | 11 | 1,904 | 128 |
| code | 4096 | 71.9 | 71.3 | 86.1% | 14% | 2.6 | 3 | 60.6 | — | 9 | 1,790 | 128 |
| structured | 4096 | 67.7 | 67.2 | 78.1% | 22% | 2.3 | 3 | 60.3 | — | 10 | 1,901 | 128 |
| code | 8192 | 72.0 | 71.5 | 86.1% | 14% | 2.6 | 3 | 60.8 | — | 9 | 1,787 | 128 |
| structured | 8192 | 67.6 | 67.1 | 78.1% | 22% | 2.3 | 3 | 60.2 | — | 8 | 1,901 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     ██████████████████████████████████░░░░░░ 86.1%
  structured d0     ███████████████████████████████░░░░░░░░░ 78.1%
        code d4096  ██████████████████████████████████░░░░░░ 86.1%
  structured d4096  ███████████████████████████████░░░░░░░░░ 78.1%
        code d8192  ██████████████████████████████████░░░░░░ 86.1%
  structured d8192  ███████████████████████████████░░░░░░░░░ 78.1%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 72.0 | 71.4 | 86.1% | 14% | 60.7 |
| structured | 67.6 | 67.1 | 78.1% | 22% | 60.2 |

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
