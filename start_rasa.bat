@echo off
title Starting Rasa AI Assistant

:: Step 1: Start Rasa Action Server in a new terminal
start cmd /k "cd /d %~dp0 && poetry run rasa run actions"

:: Step 2: Give it a few seconds to start before launching the bot
timeout /t 15

:: Step 3: Start Rasa Bot API on port 5005 in a new terminal
start cmd /k "cd /d %~dp0 && poetry run rasa run --enable-api --debug"

:: Step 4: Wait a bit longer for the bot to start before launching chat
timeout /t 20

:: Step 5: Open interactive chat shell (connected to port 5006)
start cmd /k "cd /d %~dp0 && poetry run rasa shell --connector rest --port 5006"

echo All Rasa services started! You can now interact with your bot.
exit
