# Speculative Decoding Benchmark — azampatti/Qwen3.8-Flash-Next-125B-A5B-INT4-AutoRound

- **Run ID**: `2026-10-12T19-07-43.302892Z_0694c122`
- **Date**: `2026-10-12T19:07:43.303141+00:00`
- **Mode**: spec-bench
- **tool-eval-bench**: `v2.8.0`
- **Spec Method**: unknown
- **Runs per cell**: 3 (counters pooled, α range shown per row)
- **Temperature**: 0 (greedy: a ceiling for sampled workloads)
- **Acceptance Source**: per-request response metrics (exact)

## Inference Engine

| Property | Value |
|---|---|
| Engine | TensorFold |
| Host | `pecera` |
| Platform | `Linux-7.0.0-38-generic-x86_64-with-glibc2.43` |
| Python | 3.13.10 |

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Steps/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 99.9 | 100.0 | 91.5% (92–92) | 8% | — | — | 83.4 | — | — | 210 | 1,482 | 128 |
| structured | 0 | 88.8 | 88.9 | 81.7% (82–82) | 18% | — | — | 80.4 | — | — | 337 | 1,768 | 128 |
| code | 4096 | 63.0 | 63.1 | 68.1% (68–68) | 32% | — | — | 56.1 | — | — | 726 | 2,740 | 128 |
| structured | 4096 | 107.9 | 108.1 | 87.8% (88–88) | 12% | — | — | 97.7 | — | — | 264 | 1,441 | 128 |
| code | 8192 | 106.3 | 106.5 | 94.3% (94–94) | 6% | — | — | 88.7 | — | — | 792 | 1,987 | 128 |
| structured | 8192 | 92.5 | 92.6 | 84.8% (85–85) | 15% | — | — | 81.5 | — | — | 292 | 1,666 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     ████████████████████████████████████░░░░ 91.5%
  structured d0     ████████████████████████████████░░░░░░░░ 81.7%
        code d4096  ███████████████████████████░░░░░░░░░░░░░ 68.1%
  structured d4096  ███████████████████████████████████░░░░░ 87.8%
        code d8192  █████████████████████████████████████░░░ 94.3%
  structured d8192  █████████████████████████████████░░░░░░░ 84.8%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 89.8 | 89.9 | 84.7% | 15% | 76.1 |
| structured | 96.4 | 96.5 | 84.8% | 15% | 86.5 |

## Interpretation Guide

- **Eff t/s** (Effective t/s): Tokens after the first ÷ wall-clock time after the first token, the same window a throughput baseline uses. This is what users experience. Higher is better.
- **Stream t/s**: Token generation rate measured from SSE stream timing. For standard decoding, this matches Eff t/s. For spec decode, Eff t/s is typically higher.
- **α (accept)**: Acceptance rate — % of draft tokens accepted by the verifier. Higher means the draft model/MTP heads predict well for this workload.
- **Waste**: Fraction of drafted tokens rejected (1 − α). Lower is better. High waste means the draft model is poorly aligned with the target.
- **τ (length)**: Average acceptance length, the tokens produced per speculative step, counting the verifier's own bonus token. Higher means more tokens generated per verification pass.
- **Window**: Average tokens drafted per speculative step (the configured draft window). Window utilization is (τ − 1) ÷ Window, the share of drafted positions accepted.
- **Draft t/s**: Rate at which draft tokens are generated, regardless of acceptance. Compare with Eff t/s to see draft overhead.
- **Steps/s**: Target-model verification passes per second. Without speculation each pass yields one token, and a verification pass costs at least a plain decode pass, so this is a lower bound on the no-spec decode rate and Eff t/s ÷ Steps/s (≈ τ) is a ceiling on the speedup. `--baseline-tgs` gives the measured figure.
- **Speedup**: Effective t/s ÷ baseline t/s. Values > 1.0x indicate spec decode is providing a benefit.

> [!TIP]
> Acceptance rates vary significantly by prompt type. Code and structured tasks
> typically show higher acceptance rates than creative/open-ended generation
> because future tokens are more predictable.
