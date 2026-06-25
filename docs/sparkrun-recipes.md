# Sparkrun Recipes

How sparkrun works, what recipes are, how they execute, and how this recipe-registry fits into the broader ecosystem.

---

## Table of Contents

- [What is Sparkrun?](#what-is-sparkrun)
- [What is Spark Arena?](#what-is-spark-arena)
- [Recipe Registries](#recipe-registries)
- [How `sparkrun run` Works](#how-sparkrun-run-works)
- [Recipe Schema (v2)](#recipe-schema-v2)
- [Execution Lifecycle](#execution-lifecycle)
- [Config Chain](#config-chain)
- [Container Engine](#container-engine)
- [Multi-Node / Cluster Mode](#multi-node--cluster-mode)
- [Hooks & Mods](#hooks--mods)
- [VRAM Estimation](#vram-estimation)
- [Default Registries](#default-registries)

---

## What is Sparkrun?

**Sparkrun** is an open-source (Apache 2.0) Python CLI tool by [scitrera.ai](https://scitrera.ai) for launching, managing, and stopping LLM inference workloads on **NVIDIA DGX Spark** systems.

**Key design principles:**
- **No Slurm, no Kubernetes** — purpose-built for DGX Spark's unique single-GPU-per-node architecture
- **One command** — `sparkrun run <recipe-name>` handles everything from container orchestration to model distribution
- **Recipe registries** — git-based collections of reusable, shareable recipe definitions

**Installation:**
```bash
uvx sparkrun setup   # installs sparkrun + guided setup wizard
```

**What it does:**
- Resolves and loads recipes from registries or local files
- Pulls/bundles container images
- Distributes model weights to cluster nodes
- Configures InfiniBand/RDMA networking automatically
- Launches inference containers (vLLM, SGLang, llama.cpp, TensorRT-LLM, Atlas)
- Runs health checks and post-launch hooks
- Tails logs (Ctrl+C detaches safely without killing the job)

**Key commands:**
```bash
sparkrun run <recipe>           # launch a workload
sparkrun stop <recipe>          # stop a workload
sparkrun show <recipe>          # VRAM estimation & config preview
sparkrun status                 # list running workloads
sparkrun logs <recipe>          # re-attach to logs
sparkrun list                   # list all recipes from all registries
sparkrun list @iromu            # list recipes from a specific registry
sparkrun registry add <url>     # add a custom registry
```

---

## What is Spark Arena?

**Spark Arena** ([spark-arena.com](https://spark-arena.com)) is an **LLM Performance Leaderboard** for comparing model performance specifically on **NVIDIA DGX Spark** hardware.

**Features:**
- Real benchmarks derived from actual `llama-benchy` runs on DGX Spark
- Multi-runtime comparison (vLLM, SGLang, TensorRT-LLM, llama.cpp, Atlas)
- Full transparency — view complete recipes, configurations, and detailed results
- Community-driven — maintained by the same team as sparkrun

**Relationship to sparkrun:** Sparkrun is the CLI tool used to run Spark Arena recipes on actual DGX Spark hardware. This recipe-registry is a custom registry that can be added to sparkrun for personal use.

---

## Recipe Registries

A **registry** is a git repository containing sparkrun recipe YAML files, discovered by sparkrun via a `.sparkrun/registry.yaml` manifest.

### Adding a Registry

```bash
sparkrun registry add https://github.com/iromu/recipe-registry.git
sparkrun update
```

### Recipe Discovery

Sparkrun searches for recipes in this order:
1. `@registry/name` — scoped lookup in a specific registry
2. URL — direct recipe URL
3. File path — local `.yaml` file
4. CWD scan — local `recipes/` directory
5. Registry search — search across all registries

### Listing Recipes

```bash
sparkrun list                    # list all recipes from all registries
sparkrun list @iromu            # list recipes from the iromu registry
sparkrun list @iromu/qwen3.6    # filter by model name
```

### Running Recipes

```bash
sparkrun run qwen3.6-35b-a3b-nvfp4-mtp-vllm    # run a recipe
sparkrun stop qwen3.6-35b-a3b-nvfp4-mtp-vllm   # stop it
sparkrun show qwen3.6-35b-a3b-nvfp4-mtp-vllm   # show details (VRAM, config, etc.)
```

---

## How `sparkrun run` Works

The `sparkrun run` command executes a **5-phase pipeline**:

### Phase 1: Preparation
- Resolves target hosts from `--hosts`, `--cluster`, or default config
- Loads and validates the recipe (from file, URL, or registry)
- Merges CLI overrides with recipe defaults and runtime defaults (see [Config Chain](#config-chain))
- Determines deployment mode (solo vs. cluster)
- Resolves cache directories and transfer mode (auto/local/push/delegated)
- Generates a deterministic cluster ID

### Phase 2: Builder
- If the recipe defines a `builder` (e.g., `eugr`), builds/customizes the container image
- Calls `runtime.prepare()` for runtime-specific pre-launch setup

### Phase 3: Distribution
- Distributes container images and model weights to all cluster nodes
- Three transfer modes:
  - **Local**: Control node streams to all hosts over SSH (uses InfiniBand if available)
  - **Push**: Control node pushes to head only, head distributes to workers
  - **Delegated**: Head node pulls/downloads directly, then distributes to workers
- Establishes communication environment variables and InfiniBand IP maps

### Phase 4: Tuning
- Syncs tuning configurations from registries
- Distributes tuning configs to all remote hosts
- Handles GGUF model path resolution

### Phase 5: Launch Runtime
- Generates the final serve command (e.g., `vllm serve ...`)
- Clears page cache on remote nodes for performance
- Constructs Docker executor config (layering CLI → recipe → defaults)
- Launches containers on all nodes via SSH

### Post-Launch
1. Wait for port to be listening (up to 120 retries × 2s)
2. Wait for HTTP 200 on `/v1/models` (up to 120 retries × 5s)
3. Run `post_exec` commands inside head container
4. Run `post_commands` on control machine
5. Tail container logs (Ctrl+C detaches but does NOT kill the job)

---

## Recipe Schema (v2)

### Top-Level Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `recipe_version` | `str` | No (default: `"2"`) | `"2"` = current format, `"1"` = legacy eugr format |
| `name` | `str` | No (auto: file stem) | Recipe display name |
| `description` | `str` | No | Display description |
| `model` | `str` | **Yes** | HuggingFace model ID or GGUF spec |
| `model_revision` | `str` | No | Pin to a specific HF revision |
| `runtime` | `str` | No | `vllm`, `sglang`, `llama-cpp`, `trt-llm`, `atlas` (auto-detected if empty) |
| `runtime_version` | `str` | No | Informational version tag |
| `container` | `str` | No | Container image reference (e.g., `ghcr.io/spark-arena/dgx-vllm-eugr-nightly:latest`) |
| `mode` | `str` | No | `"auto"`, `"solo"`, `"cluster"` (deprecated; use `min_nodes`/`max_nodes`) |
| `min_nodes` | `int` | No (default: 1) | Minimum hosts. `> 1` forces cluster mode |
| `max_nodes` | `int` | No (default: None) | Maximum hosts. `1` = solo only, `None` = no limit |
| `solo_only` | `bool` | No | Shorthand for `max_nodes: 1, mode: solo` |
| `cluster_only` | `bool` | No | Shorthand for `min_nodes: 2, mode: cluster` |
| `defaults` | `dict` | No | Default variables for serve flags |
| `env` | `dict` | No | Container environment variables (supports `$VAR` expansion) |
| `command` | `str` | No | Command template with `{key}` placeholders |
| `metadata` | `dict` | No | Informational metadata (model params, quantization, benchmark results) |
| `benchmark` | `dict` | No | Benchmark config (`framework`, `timeout`, `args`) |
| `pre_exec` | `list` | No | Pre-execution hooks (shell commands or file injections) |
| `post_exec` | `list` | No | Post-launch commands inside head container |
| `post_commands` | `list` | No | Post-launch commands on control machine |
| `stop_after_post` | `bool` | No | Auto-stop after post hooks (for batch workflows) |
| `mods` | `list` | No | Mod references (named container tweaks) |
| `builder` | `str` | No | Builder plugin name (`docker-pull`, `eugr`) |
| `builder_config` | `dict` | No | Builder-specific config |
| `executor_config` | `dict` | No | Container engine settings |
| `distribution_config` | `dict` | No | Model/container distribution config |
| `runtime_config` | `dict` | No | Runtime-specific config (unknown top-level keys auto-swept here) |

### Metadata Sub-Fields

| Field | Type | Description |
|-------|------|-------------|
| `description` | `str` | Human-readable description, often includes benchmark results |
| `maintainer` | `str` | Recipe author/maintainer |
| `category` | `str` | Model category (e.g., "text-generation", "coding") |
| `model_params` | `int/str` | Model size (e.g., 35B, "35B") |
| `model_dtype` | `str` | Quantization type (e.g., "NVFP4", "FP8", "Q8_0") |
| `kv_dtype` | `str` | KV cache dtype (default: `bfloat16`) |
| `num_layers` | `int` | Number of model layers |
| `num_kv_heads` | `int` | Number of KV heads |
| `head_dim` | `int` | Attention head dimension |
| `model_vram` | `float` | VRAM override (GB) |
| `kv_vram_per_token` | `float` | KV cache VRAM per token (GB) |
| `quantization` | `str` | Quantization type: `awq`, `gptq`, `fp8`, `nvfp4`, `mxfp4`, `auto-round`, `bitsandbytes`, `compressed-tensors`, `none`, `gguf`, `int4`, `int8` |
| `quant_bits` | `int` | Quantization bits: `4`, `8` |

### Runtime-Specific Keys

Some keys are specific to certain runtimes and are stored in `runtime_config`:

| Key | Runtime | Description |
|-----|---------|-------------|
| `scheduling_policy` | Atlas | Scheduling policy for Atlas runtime |
| `mtp_quantization` | Atlas | MTP quantization for Atlas |
| `speculative` | Atlas | Boolean toggle for speculative decoding (Atlas) |
| `coding_config` | ? | (Used in some recipes but not documented in source) |
| `ctx_size` | ? | (Used in some recipes but not documented in source) |
| `mtp_quantization` | Atlas | MTP quantization for Atlas |

---

## Execution Lifecycle

```
sparkrun run <recipe>
  │
  ├─ Phase 1: Preparation
  │   ├─ Resolve hosts (from --hosts, --cluster, or defaults)
  │   ├─ Load & validate recipe
  │   ├─ Merge config chain (CLI > user config > recipe defaults)
  │   ├─ Determine mode (solo vs. cluster)
  │   ├─ Resolve cache dirs & transfer mode
  │   └─ Generate cluster ID
  │
  ├─ Phase 2: Builder
  │   ├─ If builder="eugr": build custom vLLM container
  │   └─ runtime.prepare()
  │
  ├─ Phase 3: Distribution
  │   ├─ Pull container image
  │   ├─ Distribute weights (local/push/delegated)
  │   └─ Configure InfiniBand/RDMA networking
  │
  ├─ Phase 4: Tuning
  │   ├─ Sync tuning configs from registries
  │   └─ Distribute to remote hosts
  │
  ├─ Phase 5: Launch Runtime
  │   ├─ Generate serve command
  │   ├─ Clear page cache on remote nodes
  │   └─ Launch containers via SSH
  │
  └─ Post-Launch
      ├─ Wait for port listening (120 retries × 2s)
      ├─ Wait for HTTP 200 on /v1/models (120 retries × 5s)
      ├─ Run post_exec (inside head container)
      ├─ Run post_commands (on control machine)
      └─ Tail logs (Ctrl+C detaches)
```

---

## Config Chain

The config chain determines the final values used at runtime. Values from higher-priority layers override lower layers:

```
┌─────────────────────────────────────────────┐
│  1. CLI overrides  (-o/--option flags)      │  ← Highest priority
├─────────────────────────────────────────────┤
│  2. User config  (~/.config/sparkrun/)      │
├─────────────────────────────────────────────┤
│  3. Recipe defaults  (defaults: section)    │
├─────────────────────────────────────────────┤
│  4. Runtime defaults  (user config)         │
├─────────────────────────────────────────────┤
│  5. Hardcoded defaults                      │  ← Lowest priority
└─────────────────────────────────────────────┘
```

**Example:**
```bash
# Recipe defaults: max_model_len=131072
# User config: max_model_len=32768
# CLI override: --max-model-len 8192
# Final value: 8192
sparkrun run my-recipe --max-model-len 8192
```

**User config** (`~/.config/sparkrun/config.yaml`):
```yaml
cache_dir: ~/.cache/sparkrun
hf_cache_dir: ~/.cache/huggingface
ssh:
  user: wantez
  key: ~/.ssh/id_ed25519
defaults:
  runtimes:
    vllm:
      gpu_memory_utilization: 0.52
      max_model_len: 32768
  builders:
    eugr:
      repo_url: https://github.com/eugr/spark-vllm-docker.git
```

---

## Container Engine

Sparkrun uses Docker to run inference containers. The `executor_config` dict controls container settings:

### Default Container Settings

| Setting | Default | Docker Flag | Description |
|---------|---------|-------------|-------------|
| `auto_remove` | `True` | `--rm` | Auto-remove container on exit |
| `restart_policy` | `None` | `--restart` | Restart policy (mutually exclusive with auto_remove) |
| `privileged` | `True` | `--privileged` | Privileged mode (disabled in rootless mode) |
| `gpus` | `"all"` | `--gpus` | GPU allocation |
| `ipc` | `"host"` | `--ipc` | IPC namespace |
| `shm_size` | `"32gb"` | `--shm-size` | Shared memory size |
| `network` | `"host"` | `--network` | Network mode |
| `user` | `None` | `--user` | Container user (auto-resolved by default) |

### Rootless Mode Adjustments

When running in rootless mode (default):
- `privileged`: `False`
- `security_opt`: `["no-new-privileges"]`
- `cap_add`: `[]`
- `ulimit`: `["memlock=-1:-1", "stack=67108864"]`
- `devices`: `["/dev/infiniband"]`

### CLI Flags for Container Settings

| Flag | Effect |
|------|--------|
| `--no-rm` | Disable auto_remove |
| `--memory <size>` | Set memory limit |
| `--restart <policy>` | Set restart policy |
| `--label <key=value>` | Add container label |
| `--executor-args <args>` | Pass arbitrary docker run args |
| `--rootful` | Disable rootless mode |

---

## Multi-Node / Cluster Mode

On DGX Spark, each node has exactly **1 GPU**. Multi-node tensor parallelism is used for models that don't fit on a single node:

### Mode Resolution

| Configuration | Mode |
|---------------|------|
| `mode: solo` or `max_nodes: 1` | Single node |
| `mode: cluster` or `min_nodes: 2` | Multi-node cluster |
| `mode: auto` (default) | Resolved based on `min_nodes`/`max_nodes` |

### Multi-Node Tensor Parallelism

```bash
# 2-node tensor parallel for a large model
sparkrun run my-recipe --tp 2 --hosts node1,node2

# Cluster mode with auto-scaling
sparkrun run my-recipe --min-nodes 2 --max-nodes 4
```

**How it works:**
- `--tp N` maps to N hosts (1 GPU per node)
- sparkrun automatically detects InfiniBand/RDMA connectivity
- Configures NCCL for multi-node communication
- Distributes model weights across nodes
- Handles SSH mesh setup

---

## Hooks & Mods

### Pre-Execution Hooks (`pre_exec`)

Runs inside **every container** before the serve command. Two formats:

**Shell command:**
```yaml
pre_exec:
  - "pip install extra-package"
```
Executed via `docker exec <container> bash -c '<cmd>'`.

**File injection:**
```yaml
pre_exec:
  - copy: configs/flashinfer.patch
    dest: /workspace/flashinfer.patch
    source_host: control
```
Copies a file into the container via `docker cp`.

### Post-Execution Hooks

**`post_exec`** — runs inside the **head container** after health checks pass:
```yaml
post_exec:
  - "echo 'Health check passed' >> /workspace/health.log"
```

**`post_commands`** — runs on the **control machine** after health checks pass:
```yaml
post_commands:
  - "echo 'Recipe launched successfully' >> /workspace/logs/launch.log"
```

**`stop_after_post`** — when `True`, after post hooks complete, the workload is stopped:
```yaml
stop_after_post: true
```
Useful for batch workflows where you want to run a recipe, execute post hooks, then automatically stop.

### Hook Template Variables

All hooks support `{key}` substitution with these variables:
- `{model}` — model ID
- `{port}` — serving port
- `{head_host}` — head node hostname
- `{head_ip}` — head node IP address
- `{cluster_id}` — unique cluster identifier
- `{container_name}` — container name
- `{cache_dir}` — model cache directory
- `{base_url}` — `http://{head_ip}:{port}/v1`
- All `defaults` keys are available

### Mods

**Mods** are named container tweaks — directories containing a `run.sh` script. They are automatically converted to `pre_exec` entries:

1. **Copy**: `docker cp` the mod directory into the container at `/workspace/mods/<name>`
2. **Exec**: `chmod +x run.sh && ./run.sh` inside the mod directory

**Resolution order** for mod references:
1. Explicit scoped reference: `@registry/<rel>`
2. Adjacent to recipe file: `<rel>` or `mods/<rel>` relative to recipe source
3. Same registry as recipe: uses the registry's `mods_subpath`
4. Eugr fallback: the registry named `eugr`

---

## VRAM Estimation

Sparkrun auto-detects model architecture from HuggingFace and estimates VRAM requirements before launching:

```bash
sparkrun show qwen3.6-35b-a3b-nvfp4-mtp-vllm
```

This shows:
- Estimated VRAM for model weights
- Estimated KV cache VRAM
- Whether the configuration fits on a single DGX Spark (128 GB) or requires multiple nodes
- Suggested `tensor_parallel` value

The estimation uses metadata from the recipe (`model_params`, `model_dtype`, `kv_dtype`, `num_layers`, etc.) and can be overridden with `model_vram` and `kv_vram_per_token`.

---

## Default Registries

Sparkrun ships with these default registries:

| Name | URL | Subpath | Visible | Description |
|------|-----|---------|---------|-------------|
| `official` | spark-arena/recipe-registry | `official-recipes` | Yes | Official Spark Arena recipes |
| `eugr` | eugr/spark-vllm-docker | `recipes` | Yes | Eugr vLLM build recipes |
| `sparkrun-transitional` | dbotwinick/sparkrun-recipe-registry | `transitional/recipes` | Yes | Transitional recipes |
| `atlas` | Avarok-Cybersecurity/atlas-recipes | `recipes` | No | Atlas runtime recipes |
| `experimental` | spark-arena/recipe-registry | `experimental-recipes` | No | Experimental recipes |
| `community` | spark-arena/community-recipe-registry | `recipes` | Yes | Community-contributed recipes |
| `sparkrun-testing` | dbotwinick/sparkrun-recipe-registry | `testing/recipes` | No | Testing recipes |

**This registry** (`iromu`) is a custom registry added via `sparkrun registry add`. It follows the same format but is maintained independently.

### Registry Discovery

- **First-run**: Clones repos from default registries, reads `.sparkrun/registry.yaml` manifests, saves to `~/.config/sparkrun/registries.yaml`
- **Subsequent**: Loads from cached `registries.yaml`
- **Sync**: Uses sparse checkouts and shared clones for efficiency

### User Recipe Search Paths

1. `./recipes/` (current working directory)
2. `~/.config/sparkrun/recipes/` (user config directory)
3. Extra paths from `recipe_paths` in user config