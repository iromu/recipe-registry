# Speculative Decoding Benchmark — nvidia/Qwen3.8-27B-NVFP4

- **Run ID**: `2026-10-23T08-40-28.178957Z_bfcf8dc4`
- **Date**: `2026-10-23T08:40:28.179077+00:00`
- **Mode**: spec-bench
- **tool-eval-bench**: `v2.8.0`
- **Spec Method**: unknown
- **Runs per cell**: 3 (counters pooled, α range shown per row)
- **Temperature**: 0 (greedy: a ceiling for sampled workloads)
- **Acceptance Source**: prometheus

> [!NOTE]
> Acceptance counters are server-wide Prometheus deltas, so concurrent
> traffic during the run skews per-request values. vLLM can report exact
> per-request values with `--per-request-spec-decode-metrics`.

## Inference Engine

| Property | Value |
|---|---|
| Engine | vLLM 0.32.0rc1.dev301+g1ac942555.d20261016 |
| Max Model Length | 262,144 |
| Quantization | NVFP4 |
| Host | `pecera` |
| Platform | `Linux-7.0.0-38-generic-x86_64-with-glibc2.43` |
| Python | 3.13.10 |

## Results

| Prompt | Depth | Eff t/s | Stream t/s | α (accept) | Waste | τ (length) | Window | Draft t/s | Steps/s | Speedup | TTFT (ms) | Total (ms) | Tokens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| code | 0 | 32.9 | 32.9 | 78.9% (79–79) | 21% | 3.4 | 3 | 29.5 | 9.8 | — | 200 | 4,061 | 128 |
| structured | 0 | 34.3 | 34.3 | 87.0% (87–87) | 13% | 3.6 | 3 | 29.1 | 9.7 | — | 182 | 3,888 | 128 |
| code | 4096 | 30.9 | 30.9 | 72.5% (72–72) | 28% | 3.2 | 3 | 29.2 | 9.7 | — | 863 | 4,973 | 128 |
| structured | 4096 | 32.5 | 32.5 | 80.7% (81–81) | 19% | 3.4 | 3 | 29.1 | 9.7 | — | 440 | 4,352 | 128 |
| code | 8192 | 29.5 | 29.5 | 69.1% (68–71) | 31% | 3.1 | 3 | 29.0 | 9.7 | — | 850 | 5,161 | 128 |
| structured | 8192 | 36.2 | 36.2 | 92.2% (92–92) | 8% | 3.8 | 3 | 29.1 | 9.7 | — | 293 | 3,800 | 128 |

## Acceptance Rate by Prompt Type

```
        code d0     ███████████████████████████████░░░░░░░░░ 78.9%
  structured d0     ██████████████████████████████████░░░░░░ 87.0%
        code d4096  █████████████████████████████░░░░░░░░░░░ 72.5%
  structured d4096  ████████████████████████████████░░░░░░░░ 80.7%
        code d8192  ███████████████████████████░░░░░░░░░░░░░ 69.1%
  structured d8192  ████████████████████████████████████░░░░ 92.2%
```

## Per-Prompt-Type Summary

| Prompt Type | Avg Eff t/s | Avg Stream t/s | Avg α | Avg Waste | Avg Draft t/s |
|---|---:|---:|---:|---:|---:|
| code | 31.1 | 31.1 | 73.5% | 26% | 29.2 |
| structured | 34.3 | 34.3 | 86.6% | 13% | 29.1 |

## Draft Efficiency

| Metric | Value |
|---|---|
| Avg Draft Window | 3 tokens/step |
| Avg Acceptance Length (τ) | 3.4 tokens/step |
| Window Utilization | 80% |
| Avg Waste | 20% |

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
