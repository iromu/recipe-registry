# Speculative Decoding Benchmark — RedHatAI/Qwen3.6-35B-A3B-NVFP4

- **Run ID**: `2026-05-31T08-04-27Z_f9a0ea`
- **Date**: `2026-05-31T08:04:27.109417+00:00`
- **Mode**: spec-bench
- **Spec Method**: mtp

> [!NOTE]
> Acceptance rate metrics were not available from the server.
> Effective t/s (wall-clock based) still captures the real benefit
> of MTP / speculative decoding.

## Results

| Prompt | Depth | Eff t/s | Stream t/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 102.4 | 251.8 | — | 4 | 2,388 | 244 |
| structured | 0 | 99.6 | 265.6 | — | 3 | 2,454 | 244 |
| code | 4096 | 103.7 | 261.3 | — | 34 | 2,386 | 244 |
| structured | 4096 | 99.7 | 260.2 | — | 3 | 2,451 | 244 |
| code | 8192 | 100.8 | 102.5 | — | 2 | 4,707 | 474 |
| structured | 8192 | 92.9 | 96.1 | — | 4 | 3,749 | 348 |

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste |
|---|---:|---:|---:|---:|
| code | 102.3 | 205.2 | — | — |
| structured | 97.4 | 207.3 | — | — |

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
