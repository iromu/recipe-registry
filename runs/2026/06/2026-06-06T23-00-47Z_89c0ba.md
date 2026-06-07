# Speculative Decoding Benchmark — nvidia/Qwen3.5-122B-A10B-NVFP4

- **Run ID**: `2026-06-06T23-00-47Z_89c0ba`
- **Date**: `2026-06-06T23:00:47.085488+00:00`
- **Mode**: spec-bench
- **Spec Method**: draft_model

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 29.6 | 29.3 | 82.0% | 18% | 2.5 | 3 | 25.6 | — | 9 | 4,341 | 128 |
| structured | 0 | 31.0 | 30.8 | 92.2% | 8% | 2.8 | 3 | 24.7 | — | 9 | 4,136 | 128 |
| code | 4096 | 28.9 | 28.6 | 78.9% | 21% | 2.4 | 3 | 25.7 | — | 9 | 4,444 | 128 |
| structured | 4096 | 27.5 | 27.3 | 76.1% | 24% | 2.3 | 3 | 25.1 | — | 10 | 4,670 | 128 |
| code | 8192 | 28.8 | 28.6 | 79.8% | 20% | 2.4 | 3 | 25.7 | — | 10 | 4,449 | 128 |
| structured | 8192 | 28.8 | 28.5 | 82.0% | 18% | 2.5 | 3 | 24.9 | — | 9 | 4,460 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     ████████████████████████████████░░░░░░░░ 82.0%
  structured d0     ████████████████████████████████████░░░░ 92.2%
        code d4096  ███████████████████████████████░░░░░░░░░ 78.9%
  structured d4096  ██████████████████████████████░░░░░░░░░░ 76.1%
        code d8192  ███████████████████████████████░░░░░░░░░ 79.8%
  structured d8192  ████████████████████████████████░░░░░░░░ 82.0%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 29.1 | 28.9 | 80.3% | 20% | 25.7 |
| structured | 29.1 | 28.9 | 83.4% | 17% | 24.9 |

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
