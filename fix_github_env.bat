@echo off
cd /d %~dp0
echo ==== Fix GitHub Environment Files ====
echo.

echo Checking current branch status...
git branch
echo.

REM Make sure we're on a valid branch first
for /f "tokens=* usebackq" %%b in (`git branch --show-current`) do set current_branch=%%b
echo Current branch: %current_branch%

echo.
echo Step 1: Adding virtual environment to .gitignore...
echo.

REM Check if gitignore exists
if not exist .gitignore (
    echo Creating new .gitignore file...
    echo # Virtual Environment > .gitignore
) else (
    echo Updating existing .gitignore...
)

REM Add virtual environment entries to gitignore
findstr /C:"lyra_env/" .gitignore >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo lyra_env/ >> .gitignore
    echo lyra_env/Lib/site-packages/torch/lib/torch_cpu.dll >> .gitignore
    echo lyra_env/Lib/site-packages/torch/lib/dnnl.lib >> .gitignore
    echo **/torch_cpu.dll >> .gitignore
    echo **/dnnl.lib >> .gitignore
    echo **/torch_*.dll >> .gitignore
    echo **/dnnl*.lib >> .gitignore
)

REM Fix BigModes submodule issue
echo.
echo Step 2: Fixing BigModes directory issue...
echo.

echo Removing any submodule configuration for BigModes...
git submodule deinit -f BigModes 2>nul
if exist ".git/modules/BigModes" (
    echo Removing .git/modules/BigModes...
    rmdir /s /q ".git\modules\BigModes"
)
git rm --cached -f BigModes 2>nul

REM Add BigModes to gitignore
findstr /C:"BigModes/" .gitignore >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo BigModes/ >> .gitignore
)

echo.
echo Step 3: Checking for uncommitted changes...
git status --porcelain
if not %ERRORLEVEL% == 0 (
    echo.
    echo There are uncommitted changes. Would you like to commit them? (y/n)
    set /p commit_changes=
    
    if /i "%commit_changes%"=="y" (
        echo.
        echo Enter a commit message:
        set /p commit_message=
        git add .gitignore
        git add .gitattributes
        git commit -m "%commit_message%"
    )
)

echo.
echo Step 4: Choose how to proceed:
echo.
echo 1. Create a new clean branch (recommended if you have large files in history)
echo 2. Fix the current branch (try this first if you don't have many commits yet)
echo 3. Abort - make no changes
echo.
set /p option=Enter your choice (1-3): 

if "%option%"=="1" (
    echo.
    echo Creating a new clean branch...
    
    REM Ensure we have the latest LFS tracking in place first
    echo Ensuring all large files are tracked by LFS...
    git lfs track "*.gguf"
    git lfs track "*.safetensors"
    git lfs track "*.pth"
    git lfs track "*.bin"
    git lfs track "*.pt"
    git lfs track "*.h5"
    git lfs track "*.pb"
    git lfs track "*.psd"
    git lfs track "*.ckpt"
    git add .gitattributes
    
    REM Create a new orphan branch with no history
    echo Checking out new orphan branch...
    git checkout --orphan clean-branch-new
    
    REM Reset to remove all files from staging
    git reset
    
    REM Add only essential files
    echo Adding only essential files...
    git add .gitignore
    git add .gitattributes
    git add .lfsconfig 
    git add README.md 2>nul
    git add src/ 2>nul
    git add lyra_config.json 2>nul
    git add requirements.txt 2>nul
    git add *.bat 2>nul
    git add *.ps1 2>nul
    git add *.py 2>nul
    
    echo.
    echo Please verify these are the files you want to commit:
    git status
    
    echo.
    echo Do you want to commit these files to the new clean branch? (y/n)
    set /p commit_clean=
    
    if /i "%commit_clean%"=="y" (
        git commit -m "Fresh start with proper configuration for large files"
        
        echo.
        echo Do you want to rename this branch to be your main branch? (y/n)
        set /p rename_main=
        
        if /i "%rename_main%"=="y" (
            echo.
            echo Choose the name for your main branch:
            echo 1. main
            echo 2. master
            set /p branch_name=
            
            if "%branch_name%"=="1" (
                git branch -m main
                echo Branch renamed to 'main'
                echo.
                echo Ready to force push. This will OVERWRITE your remote history!
                echo Continue? (y/n)
                set /p push_confirm=
                
                if /i "%push_confirm%"=="y" (
                    git push -f origin main
                ) else (
                    echo Push cancelled. You can push manually with:
                    echo git push -f origin main
                )
            ) else (
                git branch -m master
                echo Branch renamed to 'master'
                echo.
                echo Ready to force push. This will OVERWRITE your remote history!
                echo Continue? (y/n)
                set /p push_confirm=
                
                if /i "%push_confirm%"=="y" (
                    git push -f origin master
                ) else (
                    echo Push cancelled. You can push manually with:
                    echo git push -f origin master
                )
            )
        ) else (
            echo Branch remains as 'clean-branch-new'. You can push it with:
            echo git push -f origin clean-branch-new
        )
    ) else (
        echo Operation cancelled. You can return to your previous branch with:
        echo git checkout %current_branch%
    )
) else if "%option%"=="2" (
    echo.
    echo Fixing the current branch...
    
    REM Ensure we have the latest LFS tracking in place
    echo Ensuring all large files are tracked by LFS...
    git lfs track "*.gguf"
    git lfs track "*.safetensors"
    git lfs track "*.pth"
    git lfs track "*.bin"
    git lfs track "*.pt"
    git lfs track "*.h5"
    git lfs track "*.pb"
    git lfs track "*.ckpt"
    git add .gitattributes
    
    REM Commit updated gitignore and gitattributes
    git add .gitignore
    git add .lfsconfig
    git commit -m "Updated gitignore and LFS configuration"
    
    echo.
    echo Running git garbage collection to clean up repository...
    git gc --aggressive --prune=now
    
    echo.
    echo Do you want to try pushing to remote? (y/n)
    set /p try_push=
    
    if /i "%try_push%"=="y" (
        git push origin %current_branch%
    )
) else (
    echo Operation aborted. No changes made.
)

echo.
echo Script completed!
pause
