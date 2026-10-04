# Speculative Decoding Benchmark — Qwen3.8-Flash-Next-UD-IQ4_XS

- **Run ID**: `2026-10-04T21-55-10Z_426b2a`
- **Date**: `2026-10-04T21:55:10.267016+00:00`
- **Mode**: spec-bench
- **Spec Method**: unknown

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 13.4 | 13.3 | 65.1% | 35% | — | — | 11.1 | — | 3 | 9,520 | 128 |
| structured | 0 | 12.3 | 12.2 | 79.8% | 20% | — | — | 10.5 | — | 4 | 10,406 | 128 |
| code | 4096 | 13.4 | 13.3 | 67.6% | 32% | — | — | 11.0 | — | 4 | 9,521 | 128 |
| structured | 4096 | 12.8 | 12.7 | 80.9% | 19% | — | — | 11.0 | — | 4 | 9,968 | 128 |
| code | 8192 | 12.5 | 12.4 | 60.4% | 40% | — | — | 10.3 | — | 4 | 10,267 | 128 |
| structured | 8192 | 13.2 | 13.1 | 83.2% | 17% | — | — | 11.0 | — | 6 | 9,707 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     ██████████████████████████░░░░░░░░░░░░░░ 65.1%
  structured d0     ███████████████████████████████░░░░░░░░░ 79.8%
        code d4096  ███████████████████████████░░░░░░░░░░░░░ 67.6%
  structured d4096  ████████████████████████████████░░░░░░░░ 80.9%
        code d8192  ████████████████████████░░░░░░░░░░░░░░░░ 60.4%
  structured d8192  █████████████████████████████████░░░░░░░ 83.2%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 13.1 | 13.0 | 64.4% | 36% | 10.8 |
| structured | 12.8 | 12.7 | 81.3% | 19% | 10.8 |

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
