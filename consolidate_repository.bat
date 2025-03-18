@echo off
cd /d %~dp0
echo ==== Repository Consolidation Utility ====
echo.

echo This utility will help merge all branches into a single clean master branch.

echo.
echo Step 1: Ensuring all files are properly tracked for Git LFS...
git lfs install

REM Make sure we're tracking all the right file types with LFS
echo Updating LFS tracking for large files...
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
echo Step 2: Cleaning up .gitignore to exclude problematic files...
echo Ensuring virtual environment is ignored...
findstr /C:"lyra_env/" .gitignore >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo lyra_env/ >> .gitignore
    echo **/torch_cpu.dll >> .gitignore
    echo **/dnnl.lib >> .gitignore
    echo **/torch_*.dll >> .gitignore
    echo **/dnnl*.lib >> .gitignore
)

echo.
echo Step 3: Get current branch information...
git branch
echo.
for /f "tokens=* usebackq" %%b in (`git branch --show-current`) do set current_branch=%%b
echo Current branch: %current_branch%
echo.

echo Step 4: Check if there are uncommitted changes...
git status --porcelain
if not %ERRORLEVEL% == 0 (
    echo.
    echo There are uncommitted changes. Would you like to commit them? (y/n)
    set /p commit_changes=
    
    if /i "%commit_changes%"=="y" (
        echo.
        echo Enter a commit message:
        set /p commit_message=
        git add .
        git commit -m "%commit_message%"
    ) else (
        echo.
        echo Please commit or stash your changes before continuing.
        goto end
    )
)

echo.
echo Step 5: Consolidation Options:
echo.
echo 1. Create a new master branch from current state (cleanest option)
echo 2. Merge all branches into current branch
echo 3. Fix Android errors and clean up repository without changing branches
echo.
set /p option=Enter your choice (1-3): 

if "%option%"=="1" (
    echo.
    echo Creating a new master branch from current state...
    git checkout --orphan new-master
    git add .
    git commit -m "Consolidated repository with proper LFS tracking"
    
    echo.
    echo Do you want to force push this new branch as 'master' or 'main'? (y/n)
    set /p push_new_master=
    
    if /i "%push_new_master%"=="y" (
        echo.
        echo Which name should be used for the main branch?
        echo 1. master
        echo 2. main
        set /p branch_name_choice=
        
        if "%branch_name_choice%"=="1" (
            set main_branch=master
        ) else (
            set main_branch=main
        )
        
        REM Delete old main branch locally
        git branch -D %main_branch% 2>nul
        
        REM Rename new branch to main branch name
        git branch -m %main_branch%
        
        echo.
        echo Ready to force push to %main_branch%. This will overwrite remote history!
        echo Continue? (y/n)
        set /p continue_push=
        
        if /i "%continue_push%"=="y" (
            git push -f origin %main_branch%
        ) else (
            echo Push canceled. You can push manually when ready.
        )
    ) else (
        echo Branch remains as 'new-master'. You can push it with:
        echo git push -f origin new-master:main
    )
    
) else if "%option%"=="2" (
    echo.
    echo Which branch should be the target branch? (Usually 'main' or 'master')
    set /p target_branch=
    
    echo.
    echo Checking out target branch...
    git checkout %target_branch%
    
    echo.
    echo Listing all branches...
    git branch
    
    echo.
    echo Enter branches to merge into %target_branch%, separated by space:
    set /p branches_to_merge=
    
    for %%b in (%branches_to_merge%) do (
        echo.
        echo Merging %%b into %target_branch%...
        git merge %%b -m "Merging %%b into %target_branch%"
        
        if not %ERRORLEVEL% == 0 (
            echo.
            echo Merge conflict detected with branch %%b.
            echo Resolve conflicts, then run 'git add .' and 'git commit'.
            echo Once resolved, continue this script.
            echo.
            pause
        )
    )
    
    echo.
    echo Do you want to push the consolidated branch? (y/n)
    set /p push_consolidated=
    
    if /i "%push_consolidated%"=="y" (
        git push origin %target_branch%
    ) else (
        echo Push canceled. You can push manually when ready.
    )
    
) else if "%option%"=="3" (
    echo.
    echo Running Android error fix script...
    call fix_android_errors.bat
    
    echo.
    echo Cleaning up repository...
    git gc --aggressive --prune=now
)

:end
echo.
echo Script completed!
pause
