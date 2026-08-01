# Speculative Decoding Benchmark — shieldstar/Qwen3.5-122B-A10B-int4-AutoRound-EC

- **Run ID**: `2026-08-01T09-34-21Z_99dce9`
- **Date**: `2026-08-01T09:34:21.477221+00:00`
- **Mode**: spec-bench
- **Spec Method**: draft_model

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 37.4 | 37.1 | 78.1% | 22% | 2.3 | 3 | 33.3 | — | 89 | 3,511 | 128 |
| structured | 0 | 39.0 | 38.7 | 90.5% | 10% | 2.7 | 3 | 32.0 | — | 266 | 3,548 | 128 |
| code | 4096 | 38.2 | 37.9 | 81.1% | 19% | 2.4 | 3 | 33.1 | — | 82 | 3,430 | 128 |
| structured | 4096 | 39.0 | 38.7 | 90.5% | 10% | 2.7 | 3 | 32.0 | — | 17 | 3,301 | 128 |
| code | 8192 | 39.1 | 38.8 | 81.1% | 19% | 2.4 | 3 | 33.9 | — | 105 | 3,379 | 128 |
| structured | 8192 | 37.7 | 37.4 | 90.5% | 10% | 2.7 | 3 | 30.9 | — | 101 | 3,498 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     ███████████████████████████████░░░░░░░░░ 78.1%
  structured d0     ████████████████████████████████████░░░░ 90.5%
        code d4096  ████████████████████████████████░░░░░░░░ 81.1%
  structured d4096  ████████████████████████████████████░░░░ 90.5%
        code d8192  ████████████████████████████████░░░░░░░░ 81.1%
  structured d8192  ████████████████████████████████████░░░░ 90.5%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 38.2 | 37.9 | 80.1% | 20% | 33.5 |
| structured | 38.6 | 38.3 | 90.5% | 10% | 31.6 |

## Draft Efficiency

| Metric | Value |
|---|---|
| Avg Draft Window | 3 tokens/step |
| Avg Acceptance Length (τ) | 2.6 tokens/step |
| Window Utilization | 85% |
| Avg Waste | 15% |

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
