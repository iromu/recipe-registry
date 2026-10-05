# Speculative Decoding Benchmark — Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M

- **Run ID**: `2026-10-04T23-38-00Z_168e4a`
- **Date**: `2026-10-04T23:38:00.914545+00:00`
- **Mode**: spec-bench
- **Spec Method**: unknown

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 20.4 | 20.3 | 70.6% | 29% | — | — | 16.3 | — | 3 | 6,272 | 128 |
| structured | 0 | 19.4 | 19.2 | 70.6% | 29% | — | — | 18.0 | — | 4 | 6,608 | 128 |
| code | 4096 | 19.6 | 19.5 | 68.6% | 31% | — | — | 15.6 | — | 3 | 6,531 | 128 |
| structured | 4096 | 19.4 | 19.2 | 72.9% | 27% | — | — | 17.8 | — | 4 | 6,618 | 128 |
| code | 8192 | 20.0 | 19.9 | 68.6% | 31% | — | — | 16.0 | — | 4 | 6,389 | 128 |
| structured | 8192 | 19.8 | 19.7 | 78.3% | 22% | — | — | 18.6 | — | 4 | 6,464 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     ████████████████████████████░░░░░░░░░░░░ 70.6%
  structured d0     ████████████████████████████░░░░░░░░░░░░ 70.6%
        code d4096  ███████████████████████████░░░░░░░░░░░░░ 68.6%
  structured d4096  █████████████████████████████░░░░░░░░░░░ 72.9%
        code d8192  ███████████████████████████░░░░░░░░░░░░░ 68.6%
  structured d8192  ███████████████████████████████░░░░░░░░░ 78.3%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 20.0 | 19.9 | 69.3% | 31% | 16.0 |
| structured | 19.5 | 19.4 | 73.9% | 26% | 18.1 |

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
