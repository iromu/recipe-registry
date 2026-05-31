---
name: convert-recipe-to-v2
description: Convert recipe from v1 to v2 format matching other recipes in the registry
source: auto-skill
extracted_at: '2026-05-31T07:12:05.081Z'
---

## Procedure

When converting a recipe file from the old v1 format to the new v2 format, follow these steps:

### 1. Identify the target format
Read a few existing recipes in the same category (e.g., `recipes/qwen3.5-0.8b/qwen3.5-0.8b-bf16-vllm.yaml`, `recipes/gemma-3-12b-it/gemma3-12b-it-bf16-vllm.yaml`) to confirm the standard v2 structure. All recipes in the repo should use `recipe_version: "2"`.

### 2. Apply the v2 transformation
The v2 format has these key structural changes:

- **`recipe_version: "2"`** — first line, always double-quoted
- **`model:`** — move to top-level right after `recipe_version` (was previously at the bottom)
- **`runtime: vllm`** — add this field after `model:`
- **`container:`** — move up near the top, after `runtime:`
- **`metadata:`** — new section containing `description:` (was previously a top-level `description:` field)
- **`mods: []`** — new empty list section (or with relevant mod entries if applicable)
- **`defaults:`** — keep as-is, preserve all default values
- **`env:`** — keep as-is, preserve all environment variables
- **`command:`** — replace the hardcoded model path with `{model}` placeholder
- **Remove** `name:`, `solo_only:`, `cluster_only:` — these fields no longer exist in v2

### 3. Preserve existing values
- Keep the container image tag exactly as-is (e.g., `:latest` or `:20260428`)
- Preserve all default values, env vars, and command arguments
- Keep the same model name and description

### 4. Verify
After conversion, run `cat` on the file to verify the YAML structure matches the v2 pattern used by other recipes in the repo.
