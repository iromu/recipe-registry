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
[LEADERBOARD.md](LEADERBOARD.md)

## Links

- [sparkrun](https://github.com/spark-arena/sparkrun) — the tool that runs recipes
- [sparkrun docs](https://sparkrun.dev) — full documentation
- [Spark Arena](https://spark-arena.com) — community hub and benchmarking

[//]: # (- [Recipe Explorer]&#40;https://recipes.sparkrun.dev&#41; — browse and filter all recipes)

