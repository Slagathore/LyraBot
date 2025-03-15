@echo off
title GitHub Auto-Push

echo Committing and pushing to GitHub...

:: Navigate to the project directory (ensures it's running from the right location)
cd /d %~dp0

:: Open a new Command Prompt window to execute Git commands
start cmd /k 
"git add .
git commit -m "Automated commit"
git push origin master
exit"

echo Done! Your repo has been pushed to GitHub.
exit
