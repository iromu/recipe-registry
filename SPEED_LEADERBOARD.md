# ⚡ Speed Leaderboard

> Auto-generated from `benchmarks/benchy*.json` on 2026-07-30 18:53 

Generation throughput (tokens/sec) at **concurrency=1, context_size=0** (prompt=2048, response=128).
Each recipe is listed independently — the same model with different configs appears as separate rows.

| # | Recipe | Spec | Model | Tokens/sec | Benchmark Date |
|---|--------|------|-------|-----------:|----------------|
| 1 | lfm2.5-350m-bf16-vllm |  | LiquidAI/LFM2.5-350M | 237.0 ±0.9 | 2026-05-31 07:36:28Z |
| 2 | mellum2-12b-a2.5b-awq4-vllm |  | cyankiwi/Mellum2-12B-A2.5B-Thinking-AWQ-INT4 | 124.2 ±4.4 | 2026-06-06 12:37:26Z |
| 3 | qwen3.6-35b-a3b-nvfp4-mtp-vllm | 📐 | nvidia/Qwen3.6-35B-A3B-NVFP4 | 96.5 ±6.5 | 2026-07-16 23:59:46Z |
| 4 | qwen3.6-35b-a3b-fp8-dflash-vllm | 🔥 | Qwen/Qwen3.6-35B-A3B-FP8 | 79.5 ±13.7 | 2026-05-26 09:00:31Z |
| 5 | qwen3.6-35b-a3b-fp8-dflash | 🔥 | Qwen/Qwen3.6-35B-A3B-FP8 | 61.7 ±2.1 | 2026-05-16 13:27:51Z |
| 6 | qwen3.6-35b-a3b-fp8-mtp-vllm | 📐 | Qwen/Qwen3.6-35B-A3B-FP8 | 61.3 ±4.0 | 2026-06-15 23:58:07Z |
| 7 | nemotron-3-nano-30b-a3b-nvfp4-vllm |  | nvidia/NVIDIA-Nemotron-3-Nano-30B-A3B-NVFP4 | 59.3 ±0.7 | 2026-06-10 08:39:55Z |
| 8 | qwen3.6-35b-a3b-fp8-vllm |  | Qwen/Qwen3.6-35B-A3B-FP8 | 52.8 ±0.0 | 2026-05-17 00:24:46Z |
| 9 | qwen3.5-0.8b-nvfp4-mtp-vllm | 📐 | AxionML/Qwen3.5-0.8B-NVFP4 | 48.7 ±3.6 | 2026-06-11 22:01:12Z |
| 10 | nemotron-3-nano-4b-fp8-vllm |  | nvidia/NVIDIA-Nemotron-3-Nano-4B-FP8 | 45.1 ±0.1 | 2026-05-30 21:38:06Z |
| 11 | gemma-4-e4b-it-bf16-mtp-vllm | 📐 | google/gemma-4-E4B-it | 42.3 ±1.1 | 2026-07-16 20:30:26Z |
| 12 | qwen3.5-122b-a10b-int4-autoround-mtp-vllm | 📐 | Intel/Qwen3.5-122B-A10B-int4-AutoRound | 40.7 ±2.3 | 2026-05-14 13:20:10Z |
| 13 | nvidia-nemotron-labs-3-puzzle-75b-a9b-nvfp4-mtp-vllm | 📐 | nvidia/NVIDIA-Nemotron-Labs-3-Puzzle-75B-A9B-NVFP4 | 34.4 ±1.6 | 2026-07-08 23:15:24Z |
| 14 | qwen3.6-27b-fp8-dflash-vllm | 🔥 | Qwen/Qwen3.6-27B-FP8 | 32.9 ±7.9 | 2026-05-26 11:54:43Z |
| 15 | qwen3.5-122b-a10b-nvfp4-mtp-vllm | 📐 | nvidia/Qwen3.5-122B-A10B-NVFP4 | 29.5 ±2.1 | 2026-06-06 23:30:21Z |
| 16 | qwen3.6-27b-nvfp4-mtp-vllm | 📐 | nvidia/Qwen3.6-27B-NVFP4 | 29.4 ±1.4 | 2026-07-30 15:24:33Z |
| 17 | qwen3.6-27b-nvfp4-dflash-docker | 🔥 | Qwen3.6-27B-AEON-NVFP4-XS | 29.3 ±1.5 | 2026-05-16 09:25:13Z |
| 18 | qwen3.6-27b-int4-autorun-mtp-vllm | 📐 | Intel/Qwen3.6-27B-int4-AutoRound | 26.7 ±1.3 | 2026-05-28 22:11:07Z |
| 19 | nvidia-qwen3.6-27b-nvfp4-mtp-vllm | 📐 | nvidia/Qwen3.6-27B-NVFP4 | 24.1 ±3.8 | 2026-07-06 20:13:31Z |
| 20 | qwopus3.6-27b-coder-compat-mtp-q4_k_s-llamacpp | 📐 | Jackrong/Qwopus3.6-27B-Coder-Compat-MTP-GGUF | 18.9 ±3.1 | 2026-06-23 20:36:13Z |
| 21 | gemma-4-e4b-it-bf16-vllm |  | google/gemma-4-E4B-it | 18.8 ±0.0 | 2026-07-16 20:07:38Z |
| 22 | gemma4-31b-it-nvfp4-mtp-vllm | 📐 | nvidia/Gemma-4-31B-IT-NVFP4 | 11.4 ±2.5 | 2026-07-16 23:33:59Z |
| 23 | qwen3.6-27b-fp8-mtp-vllm | 📐 | Qwen/Qwen3.6-27B-FP8 | 10.2 ±0.8 | 2026-05-26 14:13:20Z |
| 24 | qwen3.6-27b-q8_0-llama-cpp |  | unsloth/Qwen3.6-27B-GGUF | 8.5 ±0.4 | 2026-05-09 11:03:35Z |
| 25 | gemma3-12b-it-bf16-vllm |  | google/gemma-3-12b-it | 8.0 ±0.0 | 2026-05-12 21:45:06Z |

### Notes

- **Tokens/sec** = `tg_throughput.mean` from the first benchmark entry (concurrency=1, context_size=0)
- **Std Dev** = `tg_throughput.std` from the same entry
- **Recipe** = benchmark filename (without `benchy_` prefix and `.json` suffix)
- **Speculative decoding**: 🔥 = DFlash, 📐 = MTP
