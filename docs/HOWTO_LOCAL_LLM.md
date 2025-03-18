# How to Use Lyra with Local LLMs

This guide provides detailed instructions for setting up and using Lyra with local large language models (LLMs) instead of relying on external APIs.

## Table of Contents

1. [Setting Up Dependencies](#setting-up-dependencies)
2. [Managing Models](#managing-models)
3. [Configuration](#configuration)
4. [Running Lyra](#running-lyra)
5. [Advanced Usage](#advanced-usage)
6. [Troubleshooting](#troubleshooting)

## Setting Up Dependencies

Local LLM inference requires specific dependencies that may conflict with other packages. Here's how to properly set them up:

### Method 1: Using Poetry (Recommended)

Poetry helps manage dependencies in isolated environments:

```bash
# Install Poetry if you don't have it
pip install poetry

# Install Lyra dependencies
poetry install -E local-llm

# Activate the environment
poetry shell
```

### Method 2: Using the Dependency Resolver Script

We provide a script that resolves dependency conflicts:

```bash
# Install core dependencies with local LLM support
python resolve_dependencies.py --local-llm
```

### Method 3: Manual Installation

For more control or if you're experiencing issues:

```bash
# Create a virtual environment (recommended)
python -m venv lyra_env
source lyra_env/bin/activate  # On Windows: lyra_env\Scripts\activate

# Install core dependencies
pip install -r requirements.txt

# Install LLM dependencies
pip install llama-cpp-python transformers accelerate torch
pip install bitsandbytes --no-build-isolation  # For 8-bit quantization
```

### GPU Support

For CUDA support (NVIDIA GPUs):

1. Install the CUDA Toolkit (11.8 or newer recommended)
2. Install PyTorch with CUDA support:
   ```bash
   pip install torch --index-url https://download.pytorch.org/whl/cu118
   ```
3. Install optimized llama-cpp-python:
   ```bash
   CMAKE_ARGS="-DLLAMA_CUBLAS=on" pip install llama-cpp-python --force-reinstall --no-cache-dir
   ```

## Managing Models

Lyra includes a model manager to help download, organize, and use LLM models.

### Listing Available Models

```bash
# List all locally available models
python -m lyra.model_manager list
```

### Searching for Models

```bash
# Search for models on Hugging Face
python -m lyra.model_manager search "mistral instruct"

# Search for video models specifically
python -m lyra.model_manager search "stable diffusion" --type video
```

### Downloading Models

```bash
# Download a specific file from a repository
python -m lyra.model_manager download TheBloke/Qwen2.5-7B-GGUF --filename qwen2.5-7b.Q5_K_M.gguf

# Download an entire model repository
python -m lyra.model_manager download TheBloke/Mistral-7B-Instruct-v0.2-GGUF
```

### Testing Models

```bash
# Test a model with a sample prompt
python -m lyra.model_manager test path/to/your/model.gguf --prompt "Write a short poem about AI"
```

### Model Selection Guidelines

| Use Case | Recommended Model | Size | Notes |
|----------|------------------|------|-------|
| Low-end hardware | Phi-2-GGUF (Q4_K_M) | 2-3GB | Good for basic conversations |
| Mid-range systems | Mistral-7B-Instruct (Q5_K_M) | 5-6GB | Good balance |
| High-end systems | Qwen2.5-QwQ-37B-Eureka | 20-30GB | Best quality responses |
| With powerful GPU | Any Hugging Face model | Varies | Use 8-bit quantization |

## Configuration

### Environment Variables

Create or modify a `.env` file in the project root:

