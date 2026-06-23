# Speculative Decoding Benchmark — Jackrong/Qwopus3.6-27B-Coder-Compat-MTP-GGUF

- **Run ID**: `2026-06-23T19-30-29Z_559239`
- **Date**: `2026-06-23T19:30:29.753337+00:00`
- **Mode**: spec-bench
- **Spec Method**: unknown

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 22.7 | 22.5 | 81.8% | 18% | — | — | 19.5 | — | 192 | 5,835 | 128 |
| structured | 0 | 23.2 | 23.0 | 91.2% | 9% | — | — | 18.5 | — | 307 | 5,825 | 128 |
| code | 4096 | 23.6 | 23.4 | 81.8% | 18% | — | — | 20.2 | — | 383 | 5,817 | 128 |
| structured | 4096 | 23.6 | 23.4 | 91.2% | 9% | — | — | 18.8 | — | 337 | 5,763 | 128 |
| code | 8192 | 24.0 | 23.8 | 81.8% | 18% | — | — | 20.6 | — | 685 | 6,014 | 128 |
| structured | 8192 | 23.8 | 23.6 | 91.2% | 9% | — | — | 19.0 | — | 438 | 5,815 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     ████████████████████████████████░░░░░░░░ 81.8%
  structured d0     ████████████████████████████████████░░░░ 91.2%
        code d4096  ████████████████████████████████░░░░░░░░ 81.8%
  structured d4096  ████████████████████████████████████░░░░ 91.2%
        code d8192  ████████████████████████████████░░░░░░░░ 81.8%
  structured d8192  ████████████████████████████████████░░░░ 91.2%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 23.4 | 23.2 | 81.8% | 18% | 20.1 |
| structured | 23.5 | 23.3 | 91.2% | 9% | 18.8 |

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
