<p align="center">
  <img src="assets/community-banner.svg" alt="sparkrun — Personal Recipe Registry" width="560" />
</p>

<p align="center">
  <a href="https://github.com/spark-arena/sparkrun"><img src="https://img.shields.io/badge/sparkrun-CLI-1e40af" alt="sparkrun CLI" /></a>
  <a href="https://sparkrun.dev"><img src="https://img.shields.io/badge/docs-sparkrun.dev-1e40af" alt="Documentation" /></a>
  <a href="https://spark-arena.com"><img src="https://img.shields.io/badge/Spark_Arena-community-76b900" alt="Spark Arena" /></a>

[//]: # (  <a href="https://recipes.sparkrun.dev"><img src="https://img.shields.io/badge/browse-recipes-76b900" alt="Browse Recipes" /></a>)
</p>

<h3 align="center">Custom inference recipes for NVIDIA DGX Spark</h3>

<p align="center">
  Share your optimized model configs, discover what others are running, and benchmark on <a href="https://spark-arena.com">Spark Arena</a>.
</p>

---

## Run Recipes

! If there is no recorded benchmark data, the recipe failed to run.

```bash
# Add this registry
sparkrun registry add https://github.com/iromu/recipe-registry.git
sparkrun update
  
# List available community recipes
sparkrun list @iromu

# Run a community recipe
sparkrun run @iromu/my-awesome-recipe

# Check VRAM requirements before launching
sparkrun show @iromu/my-awesome-recipe
```

## 🏆 Model Leaderboard                                                                                                        
| # | Model | Score | Rating | P/F | Sel | Prm | Chn | Rst | Err | Loc | Rsn | Ins | Ctx | Cod | Saf | Scl | Pln | Crt | Out | N | Tokens | Runs |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 🥇 | unsloth/Qwen3.6-35B-A3B-GGUF | 95 | ★★★★★ | 62/7/0 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 85 | 100 | 92 | 100 | 83 | 83 | 100 | 69 | 265K | 4 |
| 🥈 | Intel/Qwen3.5-122B-A10B-int4-AutoRound | 94 | ★★★★★ | 62/6/1 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 90 | 83 | 85 | 100 | 83 | 100 | 100 | 69 | 237K | 2 |
| 🥉 | nvidia/Qwen3.6-35B-A3B-NVFP4 | 93 | ★★★★★ | 61/6/2 | 100 | 100 | 100 | 83 | 100 | 100 | 100 | 80 | 95 | 83 | 88 | 88 | 100 | 83 | 100 | 69 | 281K | 6 |
| 4 | Qwen/Qwen3.6-35B-A3B-FP8 | 93 | ★★★★★ | 62/4/3 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 80 | 95 | 67 | 88 | 100 | 83 | 83 | 100 | 69 | 285K | 17 |
| 5 | Qwen/Qwen3.6-27B-FP8 | 92 | ★★★★★ | 61/5/3 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 90 | 100 | 85 | 88 | 67 | 67 | 100 | 69 | 256K | 5 |
| 6 | nvidia/Qwen3.6-27B-NVFP4 | 90 | ★★★★★ | 57/10/2 | 100 | 100 | 100 | 83 | 100 | 100 | 100 | 100 | 80 | 100 | 85 | 88 | 100 | 83 | 75 | 69 | 253K | 1 |
| 7 | Qwen3.6-27B-Text-NVFP4-MTP | 90 | ★★★★★ | 60/4/5 | 100 | 100 | 75 | 100 | 100 | 100 | 100 | 100 | 70 | 100 | 85 | 100 | 83 | 83 | 100 | 69 | 219K | 1 |
| 8 | nvidia/Qwen3.5-122B-A10B-NVFP4 | 89 | ★★★★ | 58/7/4 | 100 | 100 | 75 | 100 | 83 | 100 | 100 | 80 | 95 | 83 | 77 | 100 | 67 | 100 | 100 | 69 | 223K | 1 |
| 9 | Qwen3.6-35B-A3B | 89 | ★★★★ | 59/5/5 | 100 | 100 | 75 | 100 | 100 | 100 | 100 | 80 | 80 | 100 | 88 | 100 | 67 | 100 | 83 | 69 | 248K | 3 |
| 10 | Jackrong/Qwopus3.6-27B-Coder-Compat… | 88 | ★★★★ | 56/10/3 | 100 | 100 | 75 | 83 | 100 | 100 | 100 | 80 | 80 | 100 | 85 | 88 | 67 | 100 | 100 | 69 | 211K | 1 |
| 11 | sakamakismile/Qwen3.6-27B-Text-NVFP… | 87 | ★★★★ | 55/10/4 | 100 | 100 | 75 | 83 | 100 | 100 | 100 | 80 | 75 | 100 | 85 | 88 | 67 | 83 | 100 | 69 | 241K | 3 |
| 12 | aeon-ultimate-xs | 85 | ★★★★ | 54/9/6 | 100 | 100 | 100 | 83 | 100 | 100 | 100 | 100 | 90 | 100 | 50 | 88 | 67 | 67 | 100 | 69 | 279K | 3 |
| 13 | Intel/Qwen3.6-27B-int4-AutoRound | 83 | ★★★★ | 52/10/7 | 100 | 100 | 75 | 83 | 100 | 100 | 100 | 80 | 70 | 100 | 85 | 62 | 50 | 83 | 83 | 69 | 218K | 1 |
| 14 | nvidia/NVIDIA-Nemotron-3-Nano-4B-FP8 | 80 | ★★★★ | 50/11/8 | 100 | 67 | 75 | 83 | 50 | 83 | 100 | 100 | 85 | 83 | 65 | 88 | 83 | 83 | 83 | 69 | 354K | 2 |
| 15 | nvidia/NVIDIA-Nemotron-3-Nano-30B-A… | 77 | ★★★★ | 50/6/13 | 100 | 67 | 100 | 67 | 33 | 100 | 100 | 100 | 80 | 67 | 58 | 100 | 50 | 67 | 83 | 69 | 371K | 1 |
| 16 | Qwen3.6-27B-AEON-NVFP4-XS | 76 | ★★★ⓢ | 46/13/10 | 100 | 100 | 75 | 50 | 67 | 100 | 100 | 100 | 85 | 83 | 46 | 88 | 33 | 83 | 83 | 69 | 305K | 1 |
| 17 | nvidia/NVIDIA-Nemotron-Labs-3-Puzzl… | 70 | ★★★ⓢ | 42/13/14 | 100 | 67 | 100 | 100 | 83 | 100 | 100 | 80 | 80 | 50 | 42 | 50 | 67 | 83 | 42 | 69 | 383K | 1 |
| 18 | google/gemma-4-E4B-it | 68 | ★★★ | 39/16/14 | 67 | 67 | 62 | 83 | 83 | 83 | 100 | 100 | 55 | 67 | 54 | 62 | 17 | 83 | 83 | 69 | 123K | 2 |
| 19 | Qwen/Qwen3.5-0.8B | 62 | ★★★ | 35/16/18 | 67 | 67 | 50 | 50 | 17 | 83 | 50 | 60 | 65 | 83 | 73 | 62 | 33 | 67 | 67 | 69 | 512K | 1 |
| 20 | LiquidAI/LFM2.5-350M | 51 | ★★ | 29/13/27 | 83 | 67 | 25 | 50 | 33 | 67 | 67 | 40 | 50 | 50 | 58 | 50 | 0 | 50 | 67 | 69 | 110K | 2 |
| 21 | Jackrong/Qwopus3.6-35B-A3B-v1 | 48 | ★★ | 29/8/32 | 100 | 67 | 0 | 100 | 0 | 17 | 67 | 40 | 25 | 50 | 62 | 62 | 33 | 33 | 67 | 69 | 186K | 1 |
| 22 | unsloth/Qwen3.6-27B-NVFP4 | 37 | ★★★ⓢ | 24/3/42 | 100 | 100 | 75 | 83 | 83 | 100 | 100 | 60 | 25 | 0 | 0 | 0 | 0 | 0 | 0 | 69 | 65K | 1 |
| 23 | AxionML/Qwen3.5-0.8B-NVFP4 | 33 | ★★★ⓢ | 18/9/42 | 67 | 33 | 25 | 67 | 0 | 17 | 67 | 60 | 30 | 33 | 42 | 25 | 17 | 0 | 0 | 69 | 497K | 1 |
| 24 | google/gemma-3-12b-it | 33 | ★ | 18/9/42 | 17 | 0 | 0 | 100 | 0 | 17 | 67 | 60 | 25 | 33 | 54 | 25 | 17 | 0 | 25 | 69 | 8K | 1 |
| 25 | cyankiwi/Mellum2-12B-A2.5B-Thinking… | 16 | ★★★ⓢ | 8/6/55 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 50 | 15 | 33 | 46 | 0 | 0 | 0 | 0 | 69 | 150K | 1 |
| 26 | RedHatAI/Qwen3.6-35B-A3B-NVFP4 | 9 | ★★★ⓢ | 1/10/58 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 20 | 0 | 0 | 38 | 0 | 0 | 0 | 0 | 69 | — | 1 |
| Sel=Tool Selection  Prm=Param Precision  Chn=Multi-Step Chains  Rst=Restraint  Err=Error Recovery  Loc=Localization  Rsn=Reasoning  Ins=Insatruction  Ctx=Context & State  Cod=Code Patterns  Saf=Safety  Scl=Toolset Scale |
| Pln=Planning  Crt=Creative  Out=Structured Output |
|  |
| P/F = ✅pass / ⚠️partial / ❌fail | N = scenario count | Scores: 90+ 75+ 60+ 40+ <40 | ★★★ⓢ = safety-capped |

## Links

- [sparkrun](https://github.com/spark-arena/sparkrun) — the tool that runs recipes
- [sparkrun docs](https://sparkrun.dev) — full documentation
- [Spark Arena](https://spark-arena.com) — community hub and benchmarking

[//]: # (- [Recipe Explorer]&#40;https://recipes.sparkrun.dev&#41; — browse and filter all recipes)

