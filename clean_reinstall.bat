@echo off
echo This will delete the existing Lyra environment and create a fresh one.
echo.
echo Press Ctrl+C to cancel or...
pause

:: Remove the existing environment if it exists
if exist lyra_env (
    echo Removing existing virtual environment...
    rmdir /s /q lyra_env
)

:: Remove other temporary files
if exist .env.local (
    del .env.local
)

:: Clear pip cache to avoid using cached packages
echo Clearing pip cache...
python -m pip cache purge

:: Create a fresh environment
echo Creating a fresh virtual environment...
python -m venv lyra_env

:: Make sure pip is installed
echo Installing pip...
call lyra_env\Scripts\activate
python -m ensurepip --upgrade
python -m pip install --upgrade pip setuptools wheel

:: Run the dependency resolver
echo Running dependency resolver with all options...
python resolve_dependencies.py --use-existing-venv --all

echo.
echo Clean reinstall complete!
echo To activate the environment, run: lyra_env\Scripts\activate
echo.
pause
