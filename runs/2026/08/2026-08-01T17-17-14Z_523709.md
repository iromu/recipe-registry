# Speculative Decoding Benchmark — DeepSeek-V4-Flash-IQ2XXS-w2Q2K-AProjQ8-SExpQ8-OutQ8-chat-v2-imatrix-0731

- **Run ID**: `2026-08-01T17-17-14Z_523709`
- **Date**: `2026-08-01T17:17:14.504367+00:00`
- **Mode**: spec-bench
- **Spec Method**: unknown

> [!NOTE]
> Acceptance rate metrics were not available from the server.
> Effective t/s (wall-clock based) still captures the real benefit
> of MTP / speculative decoding.

## Results

| Prompt | Depth | Eff t/s | Stream t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 14.0 | 13.9 | — | 728 | 9,860 | 128 |
| structured | 0 | 18.7 | 18.5 | — | 1,074 | 7,934 | 128 |
| code | 4096 | 15.4 | 15.3 | — | 766 | 9,052 | 128 |
| structured | 4096 | 18.2 | 18.0 | — | 778 | 7,817 | 128 |
| code | 8192 | 13.3 | 13.2 | — | 776 | 10,368 | 128 |
| structured | 8192 | 21.1 | 20.9 | — | 658 | 6,732 | 128 |

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste |
|---|---:|---:|---:|---:|
| code | 14.3 | 14.2 | — | — |
| structured | 19.3 | 19.2 | — | — |

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
