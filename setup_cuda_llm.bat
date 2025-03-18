@echo off
cd /d %~dp0

echo ==== Lyra LLM GPU Setup Utility for 35B Model ====
echo.

REM Activate the Lyra virtual environment
call G:\AI\Lyra\lyra_env\Scripts\activate.bat

REM Check CUDA availability
echo Checking CUDA availability...
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
python -c "import torch; print(f'CUDA device count: {torch.cuda.device_count()}')"
python -c "import torch; print(f'CUDA version: {torch.version.cuda if torch.cuda.is_available() else \"N/A\"}')"
python -c "import torch; print(f'Device name: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \"N/A\"}')"
python -c "import torch; print(f'Memory allocated: {torch.cuda.memory_allocated() / 1024**3:.2f} GB')"
python -c "import torch; print(f'Memory reserved: {torch.cuda.memory_reserved() / 1024**3:.2f} GB')"

echo.
echo ==== Setting up Windows for 35B model ====
echo.

echo 1. Installing optimized CUDA packages...
pip install -U pip setuptools wheel
pip install -U torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121

echo.
echo 2. Installing llama-cpp-python with CUDA support...
set CMAKE_ARGS=-DLLAMA_CUBLAS=on
set FORCE_CMAKE=1
pip install --upgrade --force-reinstall llama-cpp-python==0.3.8+cu121 --no-cache-dir --extra-index-url https://download.pytorch.org/whl/cu121

echo.
echo 3. Testing GPU detection...
python -c "from llama_cpp import Llama; print(f'llama-cpp-python supports GPU offload: {Llama.supports_gpu_offload()}')"

echo.
echo ==== Launching LLM server with optimized settings for 35B model ====
echo.

set MODEL_PATH=G:\AI\Lyra\BigModes\Qwen2.5-QwQ-35B-Eureka-3-ablit-uncen-gguf\Qwen2.5-QwQ-35B-Eureka-Cubed-abliterated-uncensored-D_AU-Q6_k.gguf
set CTX_SIZE=2048
set GPU_LAYERS=35
set N_BATCH=128
set N_THREADS=6
set HOST=127.0.0.1
set PORT=8000

REM Environment variables to optimize CUDA
set CUDA_VISIBLE_DEVICES=0
set GGML_CUDA_NO_PINNED=1
set GGML_CUDA_FORCE_MMQ=1
set GGML_CUDA_MEM_PERCENT=90
set GGML_CUDA_DMMV_X=32

echo Starting server with optimized settings for 35B model...
echo - Model: %MODEL_PATH%
echo - GPU Layers: %GPU_LAYERS%
echo - Context: %CTX_SIZE%
echo - Batch: %N_BATCH%
echo.

python -m llama_cpp.server --model %MODEL_PATH% --n_ctx %CTX_SIZE% --n_gpu_layers %GPU_LAYERS% --host %HOST% --port %PORT% --n_batch %N_BATCH% --n_threads %N_THREADS% --rope_scaling_type 2

echo.
echo LLM server finished. Please check the logs above.
pause
