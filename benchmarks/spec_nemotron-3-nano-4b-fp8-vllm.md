# Speculative Decoding Benchmark — nvidia/NVIDIA-Nemotron-3-Nano-4B-FP8

- **Run ID**: `2026-05-30T21-17-35Z_503435`
- **Date**: `2026-05-30T21:17:35.454286+00:00`
- **Mode**: spec-bench
- **Spec Method**: unknown

> [!NOTE]
> Acceptance rate metrics were not available from the server.
> Effective t/s (wall-clock based) still captures the real benefit
> of MTP / speculative decoding.

## Results

| Prompt | Depth | Eff t/s | Stream t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 45.6 | 45.3 | — | 8 | 2,815 | 128 |
| structured | 0 | 45.3 | 45.0 | — | 16 | 2,842 | 128 |
| code | 4096 | 45.3 | 45.0 | — | 9 | 2,833 | 128 |
| structured | 4096 | 45.1 | 44.7 | — | 9 | 2,850 | 128 |
| code | 8192 | 45.3 | 45.0 | — | 8 | 2,831 | 128 |
| structured | 8192 | 43.7 | 43.3 | — | 11 | 2,942 | 128 |

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste |
|---|---:|---:|---:|---:|
| code | 45.4 | 45.1 | — | — |
| structured | 44.7 | 44.3 | — | — |

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
