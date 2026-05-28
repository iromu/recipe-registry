# Speculative Decoding Benchmark — sakamakismile/Qwen3.6-27B-Text-NVFP4-MTP

- **Run ID**: `2026-05-28T06-34-55Z_e487f3`
- **Date**: `2026-05-28T06:34:55.087033+00:00`
- **Mode**: spec-bench
- **Spec Method**: mtp

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 28.8 | 28.6 | 87.1% | 13% | 3.5 | 4 | 26.1 | — | 16 | 4,453 | 128 |
| structured | 0 | 25.4 | 25.2 | 74.2% | 26% | 3.0 | 4 | 25.4 | — | 20 | 5,063 | 128 |
| code | 4096 | 28.8 | 28.6 | 87.1% | 13% | 3.5 | 4 | 26.1 | — | 10 | 4,450 | 128 |
| structured | 4096 | 25.4 | 25.2 | 74.2% | 26% | 3.0 | 4 | 25.4 | — | 11 | 5,059 | 128 |
| code | 8192 | 28.8 | 28.6 | 87.1% | 13% | 3.5 | 4 | 26.1 | — | 10 | 4,454 | 128 |
| structured | 8192 | 25.4 | 25.2 | 74.2% | 26% | 3.0 | 4 | 25.4 | — | 13 | 5,056 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     ██████████████████████████████████░░░░░░ 87.1%
  structured d0     █████████████████████████████░░░░░░░░░░░ 74.2%
        code d4096  ██████████████████████████████████░░░░░░ 87.1%
  structured d4096  █████████████████████████████░░░░░░░░░░░ 74.2%
        code d8192  ██████████████████████████████████░░░░░░ 87.1%
  structured d8192  █████████████████████████████░░░░░░░░░░░ 74.2%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 28.8 | 28.6 | 87.1% | 13% | 26.1 |
| structured | 25.4 | 25.2 | 74.2% | 26% | 25.4 |

## Draft Efficiency

| Metric | Value |
|---|---|
| Avg Draft Window | 4 tokens/step |
| Avg Acceptance Length (τ) | 3.2 tokens/step |
| Window Utilization | 81% |
| Avg Waste | 19% |

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
