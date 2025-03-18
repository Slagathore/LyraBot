@echo off
cd /d %~dp0
echo ==== Master Repository Fix ====
echo.

echo This script will:
echo 1. Fix the Android SDK error
echo 2. Fix Git LFS issues
echo 3. Create a clean master branch
echo 4. Push to GitHub

echo.
echo Step 1: Fixing Android SDK error...
call fix_android_sdk_error.bat

echo.
echo Step 2: Setting up Git LFS properly...
git lfs install
git config lfs.batch true
git config lfs.concurrenttransfers 8
git config http.postBuffer 524288000
git config http.maxRequestBuffer 100M

echo Tracking large files with Git LFS...
git lfs track "*.gguf"
git lfs track "*.safetensors"
git lfs track "*.pth"
git lfs track "*.bin"
git lfs track "*.pt"
git lfs track "*.ckpt"
git lfs track "*.onnx"
git lfs track "*.h5"
git lfs track "*.pb"
git lfs track "*.model"
git lfs track "*.msgpack"
git lfs track "*.mlmodel"
git add .gitattributes

echo.
echo Step 3: Fixing BigModes submodule issue...
git submodule deinit -f BigModes 2>nul
if exist ".git/modules/BigModes" (
    rmdir /s /q ".git\modules\BigModes"
)
git rm --cached -f BigModes 2>nul

echo.
echo Step 4: Updating .gitignore file...
echo Adding BigModes/ and lyra_env/ to .gitignore...
findstr /C:"BigModes/" .gitignore >nul || echo BigModes/ >> .gitignore
findstr /C:"lyra_env/" .gitignore >nul || echo lyra_env/ >> .gitignore
git add .gitignore

echo.
echo Step 5: Creating a clean master branch...
echo Checking out a new branch without history...
git checkout --orphan new-master

echo Resetting staging area...
git reset

echo.
echo Adding essential files only...
git add .gitignore
git add .gitattributes
git add .lfsconfig
git add *.md 2>nul
git add src/ 2>nul
git add lyra_config.json 2>nul
git add requirements.txt 2>nul
git add *.bat
git add *.ps1
git add *.py 2>nul

echo.
echo Files staged for commit:
git status

echo.
echo Do you want to commit these files to the new master branch? (y/n)
set /p commit_confirm=

if /i "%commit_confirm%"=="y" (
    git commit -m "Clean repository setup with proper Git LFS configuration"
    
    echo.
    echo Renaming branch to 'master'...
    git branch -m master
    
    echo.
    echo WARNING: The next step will REPLACE your remote master branch!
    echo Do you want to push this clean master branch to GitHub? (y/n)
    set /p push_confirm=
    
    if /i "%push_confirm%"=="y" (
        echo Pushing to master...
        git push -f origin master
        
        echo.
        echo Do you want to delete all other local branches? (y/n)
        set /p clean_branches=
        
        if /i "%clean_branches%"=="y" (
            for /f "tokens=* delims= " %%b in ('git branch ^| findstr /v /c:"master" /c:"*"') do (
                git branch -D %%b
            )
        )
    ) else (
        echo Push canceled. You can push manually with:
        echo git push -f origin master
    )
) else (
    echo Commit canceled. You can add more files and then commit.
)

echo.
echo Repository fix process complete!
echo Please check above for any errors.
pause
