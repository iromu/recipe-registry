# Speculative Decoding Benchmark — Vontra/Qwen3.8-27B-MLX-4bit

- **Run ID**: `2026-10-05T07-18-49Z_fb6332`
- **Date**: `2026-10-05T07:18:49.064387+00:00`
- **Mode**: spec-bench
- **Spec Method**: unknown

> [!NOTE]
> Acceptance rate metrics were not available from the server.
> Effective t/s (wall-clock based) still captures the real benefit
> of MTP / speculative decoding.

## Results

| Prompt | Depth | Eff t/s | Stream t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 52.3 | 51.9 | — | 5 | 2,452 | 128 |
| structured | 0 | 94.7 | 94.1 | — | 10 | 1,361 | 128 |
| code | 4096 | 52.3 | 51.9 | — | 14 | 2,462 | 128 |
| structured | 4096 | 94.8 | 94.1 | — | 11 | 1,361 | 128 |
| code | 8192 | 52.2 | 51.9 | — | 12 | 2,461 | 128 |
| structured | 8192 | 95.0 | 94.3 | — | 12 | 1,359 | 128 |

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste |
|---|---:|---:|---:|---:|
| code | 52.3 | 51.9 | — | — |
| structured | 94.9 | 94.2 | — | — |

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
