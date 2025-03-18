@echo off
cd /d %~dp0
echo ==== GitHub Push Fix Utility ====
echo.

echo Checking Git LFS installation...
git lfs version 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Git LFS is not installed. Installing now...
    echo Please download and install Git LFS from https://git-lfs.github.com/
    start https://git-lfs.github.com/
    echo After installation, return to this script and press any key to continue...
    pause
)

echo Initializing Git LFS...
git lfs install

echo Ensuring LFS tracking for large files...
git lfs track "*.psd"
git lfs track "*.h5"
git lfs track "*.pb"
git lfs track "*.gguf"
git lfs track "*.safetensors"
git lfs track "*.pth"
git lfs track "*.bin"
git lfs track "*.pt"

echo Checking for uncommitted changes...
git status

echo.
echo If you have uncommitted changes, you should commit them first with:
echo git add .
echo git commit -m "Your commit message"
echo.

echo Do you want to fix potential LFS issues by resetting problematic commits? (y/n)
set /p reset_choice=

if /i "%reset_choice%"=="y" (
    echo Creating a backup branch of your current state...
    git branch backup-before-lfs-fix
    
    echo Attempting to fix LFS issues...
    
    REM Option 1: Soft reset to preserve changes but remove commits
    git reset --soft HEAD~2
    
    echo Recommitting changes with proper LFS tracking...
    git add .
    git commit -m "Fixed: Properly track large files with Git LFS"
    
    echo Attempting force push (use carefully)...
    echo This will overwrite the remote branch with your local fixes.
    
    echo Do you want to force push to fix the remote branch? (y/n)
    set /p push_choice=
    if /i "%push_choice%"=="y" (
        git push --force
    ) else (
        echo Push canceled. You can push manually when ready.
    )
) else (
    echo LFS reset canceled.
    echo For manual fixing, you can use:
    echo - git reset --soft HEAD~2
    echo - git add .
    echo - git commit -m "Fixed LFS tracking"
    echo - git push --force
)

echo.
echo Script completed. Check the output for any errors.
pause
