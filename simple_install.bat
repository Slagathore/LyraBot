@echo off
echo Simple Lyra Installation
echo ======================
echo.

:: Check if Python is installed
where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Python is not installed or not in your PATH.
    echo Please install Python 3.10 or newer and try again.
    pause
    exit /b 1
)

:: Create a fresh virtual environment
echo Creating virtual environment...
if exist lyra_env rmdir /s /q lyra_env
python -m venv lyra_env
if %ERRORLEVEL% NEQ 0 (
    echo Failed to create virtual environment.
    pause
    exit /b 1
)

:: Activate the environment
echo Activating virtual environment...
call lyra_env\Scripts\activate
if %ERRORLEVEL% NEQ 0 (
    echo Failed to activate virtual environment.
    pause
    exit /b 1
)

:: Install base dependencies directly
echo Installing dependencies...
python -m pip install --upgrade pip wheel setuptools
python -m pip install python-dotenv requests tqdm numpy pandas matplotlib
python -m pip install torch --index-url https://download.pytorch.org/whl/cpu
python -m pip install transformers
python -m pip install langchain langchain-community openai
python -m pip install sentence-transformers
python -m pip install sqlalchemy==1.4.46 sqlalchemy-utils
python -m pip install textblob emoji
python -m pip install rasa_sdk

:: Install our package in development mode
echo Installing Lyra in development mode...
python -m pip install -e .

echo.
echo Installation completed!
echo.
echo To use Lyra:
echo 1. Activate the environment: lyra_env\Scripts\activate
echo 2. Run: python -m lyra.main
echo.
pause
