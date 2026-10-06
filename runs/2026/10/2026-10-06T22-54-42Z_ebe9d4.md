# Speculative Decoding Benchmark — Vontra/Qwen3.8-Flash-Next-MLX-4bit-MTP

- **Run ID**: `2026-10-06T22-54-42Z_ebe9d4`
- **Date**: `2026-10-06T22:54:42.754599+00:00`
- **Mode**: spec-bench
- **Spec Method**: mtp

> [!NOTE]
> Acceptance rate metrics were not available from the server.
> Effective t/s (wall-clock based) still captures the real benefit
> of MTP / speculative decoding.

## Results

| Prompt | Depth | Eff t/s | Stream t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 47.9 | 47.6 | — | 10 | 2,681 | 128 |
| structured | 0 | 61.6 | 61.2 | — | 8 | 2,084 | 128 |
| code | 4096 | 57.3 | 56.9 | — | 6 | 2,238 | 128 |
| structured | 4096 | 84.7 | 84.0 | — | 6 | 1,518 | 128 |
| code | 8192 | 57.8 | 57.4 | — | 5 | 2,218 | 128 |
| structured | 8192 | 85.3 | 84.7 | — | 9 | 1,509 | 128 |

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste |
|---|---:|---:|---:|---:|
| code | 54.4 | 54.0 | — | — |
| structured | 77.2 | 76.6 | — | — |

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
