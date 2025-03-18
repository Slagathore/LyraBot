@echo off
echo Installing Rasa SDK for Lyra...
echo.

:: Activate the environment
call lyra_env\Scripts\activate

:: Install Rasa SDK
echo Installing Rasa SDK...
python -m pip install rasa_sdk

echo.
echo Installation complete!
echo You can now run Lyra with Rasa support: python -m lyra.main
echo.
pause
