@echo off
echo Setting up Lyra environment for Windows...
echo.

:: Check if Python is installed
where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Python is not installed or not in your PATH.
    echo Please install Python 3.10 or newer and try again.
    pause
    exit /b 1
)

:: Clean up previous failed installations
echo Cleaning up previous installation attempts...
if exist lyra_env (
    echo Removing existing virtual environment...
    rmdir /s /q lyra_env
)

:: Create a fresh virtual environment
echo Creating fresh virtual environment...
python -m venv lyra_env --clear

:: Manually add key packages to avoid trying to upgrade pip directly
echo Installing basic packages...
call lyra_env\Scripts\activate
python -m pip install --upgrade pip setuptools wheel

:: Try the simple approach first - directly install key dependencies
echo Installing core dependencies directly...
python -m pip install python-dotenv requests numpy pandas
python -m pip install torch --index-url https://download.pytorch.org/whl/cpu
python -m pip install transformers sentence-transformers

:: Install OpenAI API if needed
python -m pip install openai>=1.0.0 langchain>=0.1.0 langchain-openai>=0.0.1

:: Install our package in development mode
echo Installing Lyra in development mode...
python -m pip install -e .

echo.
echo Setup completed! To run Lyra:
echo 1. Activate the environment: lyra_env\Scripts\activate
echo 2. Start Lyra: python -m lyra.main
echo.
pause
