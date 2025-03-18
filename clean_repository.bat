@echo off
cd /d %~dp0
echo ==== Lyra Repository Cleanup Utility ====
echo.

echo This script will fix all repository issues and create a clean master branch

echo.
echo Step 1: Fixing BigModes submodule error...
echo.

echo Removing any submodule configuration for BigModes...
git submodule deinit -f BigModes 2>nul
if exist ".git/modules/BigModes" (
    echo Removing .git/modules/BigModes...
    rmdir /s /q ".git\modules\BigModes"
)
git rm --cached -f BigModes 2>nul

echo.
echo Step 2: Configuring Git LFS properly...
echo.

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
echo Step 3: Updating .gitignore file...
echo.

echo Making sure problematic files are ignored...

REM Add BigModes to gitignore
findstr /C:"BigModes/" .gitignore >nul
if %ERRORLEVEL% NEQ 0 (
    echo Adding BigModes/ to .gitignore...
    echo BigModes/ >> .gitignore
)

REM Add virtual environment to gitignore
findstr /C:"lyra_env/" .gitignore >nul
if %ERRORLEVEL% NEQ 0 (
    echo Adding lyra_env/ to .gitignore...
    echo lyra_env/ >> .gitignore
)

echo.
echo Step 4: Creating a clean master branch...
echo.

echo Listing current branches...
git branch

echo.
echo Creating new clean branch without history...
git checkout --orphan clean-master

echo.
echo Resetting staging area...
git reset

echo.
echo Adding essential files only...
git add .gitignore
git add .gitattributes
git add .lfsconfig
git add README.md 2>nul
git add src/ 2>nul
git add lyra_config.json
git add requirements.txt
git add *.bat
git add *.ps1
git add *.py 2>nul

echo.
echo Verifying files to be committed (check this list carefully)...
git status

echo.
echo Do you want to commit these files to the new master branch? (y/n)
set /p commit_confirm=

if /i "%commit_confirm%"=="y" (
    git commit -m "Fresh start with clean repository setup"
    
    echo.
    echo Renaming branch to 'master'...
    git branch -m master
    
    echo.
    echo WARNING: The next step will OVERWRITE your remote master branch!
    echo All other branches will be preserved on the remote.
    echo Do you want to force push this clean master branch? (y/n)
    set /p push_confirm=
    
    if /i "%push_confirm%"=="y" (
        echo Force pushing to master...
        git push -f origin master
        
        echo.
        echo Setting master as your default branch...
        echo You must do this manually on GitHub:
        echo 1. Go to your repository on GitHub
        echo 2. Click on Settings -> Branches
        echo 3. Change the default branch to 'master'
        
        echo.
        echo Cleaning up local branches...
        echo Do you want to delete all other local branches? (y/n)
        set /p clean_branches=
        
        if /i "%clean_branches%"=="y" (
            FOR /F "tokens=*" %%G IN ('git branch ^| findstr /v "master"') DO (
                git branch -D %%G 2>nul
            )
            echo Local branches cleaned up.
        )
    ) else (
        echo Push cancelled. You can push manually with:
        echo git push -f origin master
    )
) else (
    echo Commit cancelled. You can continue modifying files and commit when ready.
)

echo.
echo Step 5: Fixing Android SDK errors...
echo.

set ANDROID_HOME=C:\Android\sdk
echo Setting ANDROID_HOME=%ANDROID_HOME%
setx ANDROID_HOME "%ANDROID_HOME%"

if not exist "BigModes\llama.cpp\examples\llama.android" (
    mkdir "BigModes\llama.cpp\examples\llama.android" 2>nul
)

echo Creating local.properties file...
echo sdk.dir=%ANDROID_HOME% > "BigModes\llama.cpp\examples\llama.android\local.properties" 2>nul

echo.
echo Repository cleanup completed!
echo.
pause
