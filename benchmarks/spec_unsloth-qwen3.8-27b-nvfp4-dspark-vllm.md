# Speculative Decoding Benchmark — unsloth/Qwen3.8-27B-NVFP4

- **Run ID**: `2026-08-17T23-30-00Z_7ae67f`
- **Date**: `2026-08-17T23:30:00.586382+00:00`
- **Mode**: spec-bench
- **Spec Method**: draft_model

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 33.6 | 33.4 | 25.3% | 75% | 3.5 | 14 | 103.0 | — | 8 | 3,815 | 128 |
| structured | 0 | 33.8 | 33.5 | 25.3% | 75% | 3.5 | 14 | 103.5 | — | 8 | 3,797 | 128 |
| code | 4096 | 34.4 | 34.1 | 25.3% | 75% | 3.5 | 14 | 105.3 | — | 7 | 3,731 | 128 |
| structured | 4096 | 33.7 | 33.5 | 25.3% | 75% | 3.5 | 14 | 103.3 | — | 7 | 3,803 | 128 |
| code | 8192 | 34.3 | 34.0 | 25.3% | 75% | 3.5 | 14 | 105.1 | — | 8 | 3,739 | 128 |
| structured | 8192 | 32.8 | 32.6 | 25.3% | 75% | 3.5 | 14 | 100.5 | — | 11 | 3,910 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     ██████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 25.3%
  structured d0     ██████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 25.3%
        code d4096  ██████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 25.3%
  structured d4096  ██████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 25.3%
        code d8192  ██████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 25.3%
  structured d8192  ██████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 25.3%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 34.1 | 33.8 | 25.3% | 75% | 104.4 |
| structured | 33.4 | 33.2 | 25.3% | 75% | 102.4 |

## Draft Efficiency

| Metric | Value |
|---|---|
| Avg Draft Window | 14 tokens/step |
| Avg Acceptance Length (τ) | 3.5 tokens/step |
| Window Utilization | 25% |
| Avg Waste | 75% |

> [!WARNING]
> Window utilization is low (25%). Only 3.5 of 14 drafted positions are accepted on average.
> Consider reducing `num_speculative_tokens` to ~5 for better GPU efficiency.

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
