# Lyra
A conversational AI with long-term + emotional + contextually sensitive memory, multi-modal capabilities, many different skills to interact + help the user, curious thought, ability to learn modules on the go, and finally with full self driven self-improvement through recursive feedback looping + AI buddy system.

## Features
- **Memory**: FAISS for long-term memory, emotional + contextual understanding
- **LLM**: Support for both OpenAI API and local LLM models
- **Personality**: Dynamic mood and OCEAN traits with self-improvement loop
- **Multi-Modal**: Text and video generation capabilities

## New in this version
- **Local LLM Support**: Run with Qwen2.5-QwQ-37B-Eureka or other local models
- **Video Generation**: Create videos from text descriptions using Wan2.1-I2V
- **Model Manager**: Download, manage and test models with a simple CLI
- **Improved Dependencies**: Fixed dependency conflicts between components

## Quick Start

### Method 1: Simple Installation (Recommended for Windows)
```bash
# Run the simple installation script
.\simple_install.bat

# Activate the environment
.\lyra_env\Scripts\activate

# Run Lyra
python -m lyra.main
```

### Method 2: Using Virtual Environment (Recommended)
```bash
# Start Lyra (setup + run)
python start_lyra.py

# Or set up environment separately
python resolve_dependencies.py --langchain

# Then activate environment and run
# On Windows:
.\lyra_env\Scripts\activate
# On macOS/Linux:
source lyra_env/bin/activate

# Run Lyra
python -m lyra.main
```

### Method 3: Using the Model Manager
```bash
# List available models
python model_manager.py list

# Download models (may take time)
python model_manager.py download --type text
python model_manager.py download --type video

# Set active models
python model_manager.py set --type text --model-path "path/to/model.gguf"

# Test models
python model_manager.py test --type text --prompt "Hello Lyra!"
```

### Method 4: Using Poetry (Advanced)
```bash
# Install using Poetry with local LLM dependencies
poetry install --extras "local-llm"

# For video generation
poetry install --extras "video"

# Run using Poetry
poetry run python -m lyra.main
```

## Troubleshooting

### Installation Issues
If you encounter issues during installation:

1. Try the simple installation method (`simple_install.bat`) which installs core dependencies directly
2. If that fails, try a clean reinstall: `clean_reinstall.bat`
3. On Windows, make sure you're using Command Prompt (not PowerShell) for running batch files
4. Check that Python 3.10+ is installed and in your PATH

For more detailed help, see the [installation guide](docs/HOWTO_LOCAL_LLM.md).

## Environment Variables
Create a file named `.env` in the project root directory with settings:
```
OPENAI_API_KEY=your_api_key_here
```

## Development
To install development tools:
```bash
python resolve_dependencies.py --dev
```

