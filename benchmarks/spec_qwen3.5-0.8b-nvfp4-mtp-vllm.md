# Speculative Decoding Benchmark — AxionML/Qwen3.5-0.8B-NVFP4

- **Run ID**: `2026-06-11T21-32-01Z_884796`
- **Date**: `2026-06-11T21:32:01.745895+00:00`
- **Mode**: spec-bench
- **Spec Method**: draft_model

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 222.3 | 231.2 | 77.0% | 23% | 1.5 | 2 | 173.7 | — | 17 | 593 | 128 |
| structured | 0 | 230.6 | 243.0 | 86.2% | 14% | 1.7 | 2 | 169.4 | — | 10 | 565 | 128 |
| code | 4096 | 218.5 | 228.5 | 77.0% | 23% | 1.5 | 2 | 170.7 | — | 8 | 594 | 128 |
| structured | 4096 | 232.5 | 244.8 | 86.2% | 14% | 1.7 | 2 | 170.7 | — | 8 | 558 | 128 |
| code | 8192 | 220.1 | 229.5 | 77.0% | 23% | 1.5 | 2 | 171.9 | — | 9 | 590 | 128 |
| structured | 8192 | 228.8 | 241.1 | 86.2% | 14% | 1.7 | 2 | 168.0 | — | 9 | 569 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     ██████████████████████████████░░░░░░░░░░ 77.0%
  structured d0     ██████████████████████████████████░░░░░░ 86.2%
        code d4096  ██████████████████████████████░░░░░░░░░░ 77.0%
  structured d4096  ██████████████████████████████████░░░░░░ 86.2%
        code d8192  ██████████████████████████████░░░░░░░░░░ 77.0%
  structured d8192  ██████████████████████████████████░░░░░░ 86.2%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 220.3 | 229.7 | 77.0% | 23% | 172.1 |
| structured | 230.7 | 243.0 | 86.2% | 14% | 169.4 |

## Draft Efficiency

| Metric | Value |
|---|---|
| Avg Draft Window | 2 tokens/step |
| Avg Acceptance Length (τ) | 1.6 tokens/step |
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
