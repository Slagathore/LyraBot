@echo off
echo Installing Lyra dependencies with Poetry...
poetry install
echo Updating key dependencies...
poetry update openai langchain langchain-openai
echo.
echo Done! Run Lyra using run_with_poetry.bat
