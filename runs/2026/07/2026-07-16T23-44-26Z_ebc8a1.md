# Speculative Decoding Benchmark — nvidia/Qwen3.6-35B-A3B-NVFP4

- **Run ID**: `2026-07-16T23-44-26Z_ebc8a1`
- **Date**: `2026-07-16T23:44:26.003160+00:00`
- **Mode**: spec-bench
- **Spec Method**: draft_model

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 80.8 | 80.2 | 82.9% | 17% | 2.5 | 3 | 70.1 | — | 60 | 1,644 | 128 |
| structured | 0 | 78.9 | 78.4 | 75.2% | 25% | 2.3 | 3 | 72.2 | — | 44 | 1,666 | 128 |
| code | 4096 | 128.2 | 127.4 | 91.2% | 9% | 2.7 | 3 | 102.2 | — | 77 | 1,075 | 128 |
| structured | 4096 | 98.8 | 98.0 | 75.2% | 25% | 2.3 | 3 | 90.3 | — | 85 | 1,381 | 128 |
| code | 8192 | 124.4 | 123.5 | 91.2% | 9% | 2.7 | 3 | 99.1 | — | 111 | 1,140 | 128 |
| structured | 8192 | 105.4 | 104.6 | 75.2% | 25% | 2.3 | 3 | 96.4 | — | 128 | 1,342 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     █████████████████████████████████░░░░░░░ 82.9%
  structured d0     ██████████████████████████████░░░░░░░░░░ 75.2%
        code d4096  ████████████████████████████████████░░░░ 91.2%
  structured d4096  ██████████████████████████████░░░░░░░░░░ 75.2%
        code d8192  ████████████████████████████████████░░░░ 91.2%
  structured d8192  ██████████████████████████████░░░░░░░░░░ 75.2%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 111.2 | 110.4 | 88.4% | 12% | 90.5 |
| structured | 94.4 | 93.7 | 75.2% | 25% | 86.3 |

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
