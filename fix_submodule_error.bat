@echo off
cd /d %~dp0
echo ==== Fixing BigModes Submodule Error ====
echo.

echo This script will fix the "does not have a commit checked out" error.

echo.
echo Step 1: Checking if BigModes is a submodule...
if exist ".gitmodules" (
    findstr "BigModes" .gitmodules >nul
    if %ERRORLEVEL% EQU 0 (
        echo BigModes is configured as a submodule.
    ) else (
        echo BigModes is not listed as a submodule.
    )
) else (
    echo No .gitmodules file found.
)

echo.
echo Step 2: Removing BigModes from Git tracking...
echo.

echo Attempting to deinitialize submodule if it exists...
git submodule deinit -f BigModes 2>nul

echo Removing any submodule entries...
if exist ".git/modules/BigModes" (
    echo Removing .git/modules/BigModes...
    rmdir /s /q ".git\modules\BigModes"
)

echo.
echo Step 3: Remove BigModes directory from Git index...
git rm --cached -f BigModes 2>nul

echo.
echo Step 4: Add BigModes to .gitignore if it's not already there...
findstr /C:"BigModes/" .gitignore >nul
if %ERRORLEVEL% NEQ 0 (
    echo Adding BigModes/ to .gitignore...
    echo BigModes/ >> .gitignore
)

echo.
echo Step 5: Re-adding important files...
echo.
echo Checking current branch...
for /f "tokens=* usebackq" %%b in (`git branch --show-current`) do set current_branch=%%b
echo Current branch: %current_branch%

echo.
echo Would you like to add and commit changes? (y/n)
set /p add_changes=

if /i "%add_changes%"=="y" (
    git add .gitignore
    git add .gitattributes
    git add .lfsconfig
    git add *.bat
    git add *.ps1
    git add src/ 2>nul
    git add *.py 2>nul
    git add requirements.txt 2>nul
    git add README.md 2>nul
    git add lyra_config.json 2>nul
    
    echo.
    echo Enter a commit message:
    set /p commit_message=
    git commit -m "%commit_message%"
    
    echo.
    echo Changes committed. You can now push with:
    echo git push origin %current_branch%
)

echo.
echo Script completed!
pause
