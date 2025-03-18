@echo off
cd /d %~dp0

REM Activate the Lyra virtual environment
call G:\AI\Lyra\lyra_env\Scripts\activate.bat

echo Setting up GPU-accelerated LLM server for Qwen2.5-35B model...

REM Default parameters - optimized for 35B model
SET MODEL_PATH=G:\AI\Lyra\BigModes\Qwen2.5-QwQ-35B-Eureka-3-ablit-uncen-gguf\Qwen2.5-QwQ-35B-Eureka-Cubed-abliterated-uncensored-D_AU-Q6_k.gguf
SET CTX_SIZE=2048
SET GPU_LAYERS=35
SET HOST=127.0.0.1
SET PORT=8000
SET N_BATCH=128
SET N_THREADS=6

REM Environment variables to optimize CUDA performance
SET CUDA_VISIBLE_DEVICES=0
SET GGML_CUDA_NO_PINNED=1
SET GGML_CUDA_FORCE_MMQ=1
SET GGML_CUDA_MEM_PERCENT=90
SET GGML_CUDA_DMMV_X=32
SET GGML_CUDA_MMV_Y=1

echo Installing CUDA-optimized llama-cpp-python...
pip install --upgrade --force-reinstall llama-cpp-python==0.3.8+cu121 --extra-index-url https://pip.pytorch.org/whl/cu121

echo Starting server with optimized settings for 35B model...
python -m llama_cpp.server --model %MODEL_PATH% --n_ctx %CTX_SIZE% --n_gpu_layers %GPU_LAYERS% --host %HOST% --port %PORT% --n_batch %N_BATCH% --n_threads %N_THREADS% --rope_scaling_type 2

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Initial settings failed, trying with reduced parameters...
    echo.
    
    SET CTX_SIZE=1024
    SET GPU_LAYERS=25
    SET N_BATCH=64
    SET N_THREADS=4
    
    echo Retrying with: GPU_LAYERS=%GPU_LAYERS%, CTX_SIZE=%CTX_SIZE%, BATCH=%N_BATCH%
    python -m llama_cpp.server --model %MODEL_PATH% --n_ctx %CTX_SIZE% --n_gpu_layers %GPU_LAYERS% --host %HOST% --port %PORT% --n_batch %N_BATCH% --n_threads %N_THREADS%
)

echo.
echo This window hosts the language model server. Keep it open while using Lyra.
echo Lyra will connect to this server at http://%HOST%:%PORT%
echo.
pause
