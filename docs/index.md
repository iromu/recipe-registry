# Documentation Index

Reference documentation for understanding and working with sparkrun recipes on DGX Spark.

## Quick Navigation

| Document | What it covers |
|----------|---------------|
| [Sparkrun Ecosystem](sparkrun-recipes.md) | What sparkrun is, how recipes work, registries, execution lifecycle, full v2 schema |
| [Recipe Overview](recipes-overview.md) | Recipe anatomy, runtimes, quantization formats, naming conventions |
| [vLLM Parameters](vllm-params.md) | Master reference of every `--flag` used in vLLM recipes, grouped by function |
| [Environment Variables](vllm-env-vars.md) | vLLM and PyTorch environment variables used across recipes |
| [Speculative Decoding](speculative-decoding.md) | MTP (Multi-Token Prediction) and DFlash deep dive — how they work, config format, tuning |
| [Quantization](quantization.md) | NVFP4, FP8, GGUF (Q8_0, Q4_K_S), INT4, MXFP4 — what they mean, trade-offs, when to use |
| [Benchmarking](benchmarking.md) | How benchmarks work, file formats (`benchy_*.json`, `spec_*.md`, `tool_*.md`), interpretation |

## How to Use This Documentation

- **Reading a recipe?** Start with [Sparkrun Ecosystem](sparkrun-recipes.md) → [Recipe Overview](recipes-overview.md) to understand the YAML structure and how sparkrun executes it.
- **Tuning a recipe?** Look up specific flags in [vLLM Parameters](vllm-params.md) and [Environment Variables](vllm-env-vars.md).
- **Adding a new recipe?** Read [Sparkrun Ecosystem](sparkrun-recipes.md) → [Recipe Overview](recipes-overview.md) → [Quantization](quantization.md) → [Speculative Decoding](speculative-decoding.md).
- **Understanding sparkrun itself?** Start with [Sparkrun Ecosystem](sparkrun-recipes.md) — it covers the 5-phase execution pipeline, config chain, registries, hooks, mods, container engine, and multi-node mode.
- **Interpreting results?** See [Benchmarking](benchmarking.md).