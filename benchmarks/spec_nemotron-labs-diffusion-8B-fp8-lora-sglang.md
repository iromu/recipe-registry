# Speculative Decoding Benchmark — nvidia/Nemotron-Labs-Diffusion-8B

- **Run ID**: `2026-05-30T09-04-21Z_05af93`
- **Date**: `2026-05-30T09:04:21.919553+00:00`
- **Mode**: spec-bench
- **Spec Method**: unknown

> [!NOTE]
> Acceptance rate metrics were not available from the server.
> Effective t/s (wall-clock based) still captures the real benefit
> of MTP / speculative decoding.

## Results

| Prompt | Depth | Eff t/s | Stream t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 56.4 | 56.0 | — | 162 | 2,433 | 128 |
| structured | 0 | 237.5 | 236.0 | — | 169 | 708 | 128 |
| code | 4096 | 55.8 | 55.4 | — | 148 | 2,442 | 128 |
| structured | 4096 | 238.5 | 237.3 | — | 163 | 699 | 128 |
| code | 8192 | 55.9 | 55.5 | — | 148 | 2,438 | 128 |
| structured | 8192 | 238.1 | 236.9 | — | 166 | 704 | 128 |

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste |
|---|---:|---:|---:|---:|
| code | 56.0 | 55.6 | — | — |
| structured | 238.0 | 236.8 | — | — |

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
