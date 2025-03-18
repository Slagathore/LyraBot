@echo off
echo Installing essential dependencies for Lyra...
echo.

:: Check if virtual environment exists
if not exist lyra_env (
    echo Virtual environment not found.
    echo Please run simple_install.bat first.
    pause
    exit /b 1
)

:: Activate environment
call lyra_env\Scripts\activate

:: Install required packages
echo Installing core packages...
python -m pip install sqlalchemy==1.4.46 sqlalchemy-utils
python -m pip install python-dotenv requests tqdm numpy pandas 
python -m pip install torch --index-url https://download.pytorch.org/whl/cpu
python -m pip install langchain langchain-community
python -m pip install sentence-transformers textblob
python -m pip install faiss-cpu

echo.
echo Dependencies installed!
echo You can now run Lyra: python -m lyra.main
echo.
pause
