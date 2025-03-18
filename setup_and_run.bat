@echo off
echo Setting up Lyra...

if not exist "lyra_env" (
    echo Creating virtual environment...
    python resolve_dependencies.py --env-name lyra_env --langchain
) else (
    echo Virtual environment already exists.
)

echo Running Lyra...
call lyra_env\Scripts\activate
python -m lyra.main
pause
