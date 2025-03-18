@echo off
cd /d %~dp0
echo ==== Advanced GitHub Fix Utility ====
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

echo.
echo Step 1: Setting up Git LFS properly...
echo.
git lfs install --skip-repo

echo.
echo Step 2: Ensuring all large files are tracked by LFS...
echo.
git lfs track "*.gguf"
git lfs track "*.safetensors"
git lfs track "*.pth"
git lfs track "*.bin"
git lfs track "*.pt"
git lfs track "*.h5"
git lfs track "*.pb"
git lfs track "*.psd"
git lfs track "*.ckpt"
git lfs track "*.onnx"
git lfs track "*.mlmodel"
git lfs track "*.model"
git lfs track "*.msgpack"

echo Ensuring .gitattributes is updated...
git add .gitattributes

echo.
echo Step 3: Setting up advanced git options...
echo.
git config lfs.batch true
git config lfs.concurrenttransfers 8
git config http.postBuffer 524288000
git config http.maxRequestBuffer 100M
git config core.compression 9
git config core.bigFileThreshold 10m

echo.
echo Step 4: Analysis of large files in repository...
echo.
echo Finding all files over 50MB...
echo.
for /f "tokens=*" %%a in ('git ls-files -s ^| find "100" ^| find /v "100644"') do (
    echo Potential large file found: %%a
)

echo.
echo Step 5: Fixing issues with large commits...
echo.

echo Do you want to try fixing your stuck commits? (y/n)
set /p fix_choice=

if /i "%fix_choice%"=="y" (
    echo.
    echo Choose the method to fix commits:
    echo.
    echo 1. Soft reset and recreate commit (preserves changes, good for LFS issues)
    echo 2. Split large commit into multiple smaller ones (best for >10k changes)
    echo 3. Remove tracked large files from history (use with caution)
    echo.
    set /p method_choice=Enter choice (1-3): 

    if "%method_choice%"=="1" (
        echo.
        echo Creating backup branch of current state...
        git branch backup-fix-lfs-%date:~-4,4%%date:~-7,2%%date:~-10,2%

        echo.
        echo How many commits back do you want to reset? (usually 1 or 2)
        set /p num_commits=

        echo.
        echo Resetting to %num_commits% commits back but keeping changes...
        git reset --soft HEAD~%num_commits%

        echo.
        echo Now recommitting with proper LFS tracking...
        git add .
        git commit -m "Fixed: Properly track large files with Git LFS"

        echo.
        echo Do you want to force push this fix? (y/n)
        echo WARNING: This will overwrite remote history!
        set /p force_push=
        if /i "%force_push%"=="y" (
            git push --force
        ) else (
            echo Push canceled. You can push manually when ready.
        )
    ) else if "%method_choice%"=="2" (
        echo.
        echo Creating temporary branch for splitting...
        git branch temp-split-branch
        git checkout temp-split-branch
        
        echo.
        echo Reset to before the problematic commit...
        git reset --mixed HEAD~1
        
        echo.
        echo Now we'll add and commit files in smaller batches...
        echo Taking a maximum of 5000 files per batch...
        
        set batch_num=1
        set max_per_batch=5000
        set total_files=0
        set batch_files=0
        
        for /f "tokens=*" %%f in ('git status --porcelain ^| find /c /v ""') do set total_files=%%f
        
        echo Found %total_files% changed files to commit
        
        for /f "tokens=*" %%f in ('git status --porcelain') do (
            git add "%%f"
            set /a batch_files+=1
            set /a total_processed+=1
            
            if !batch_files! GEQ %max_per_batch% (
                echo Committing batch !batch_num! with !batch_files! files...
                git commit -m "Split commit part !batch_num! [automated]"
                set /a batch_num+=1
                set batch_files=0
            )
            
            if !total_processed! GEQ %total_files% (
                if !batch_files! GTR 0 (
                    echo Committing final batch !batch_num! with !batch_files! files...
                    git commit -m "Split commit part !batch_num! [automated]"
                )
            )
        )
        
        echo.
        echo Completed splitting commits. Now perform:
        echo git checkout main
        echo git merge temp-split-branch
        echo git push
    ) else if "%method_choice%"=="3" (
        echo.
        echo WARNING: This will permanently remove large files from git history
        echo Make sure you have backups of important data before proceeding!
        echo.
        echo Do you want to continue? (y/n)
        set /p continue_choice=
        
        if /i "%continue_choice%"=="y" (
            echo.
            echo Enter path pattern for files to remove (e.g., "*.gguf" or "path/to/large/file.bin")
            set /p file_pattern=
            
            echo.
            echo Creating backup branch...
            git branch backup-before-filter-%date:~-4,4%%date:~-7,2%%date:~-10,2%
            
            echo.
            echo Removing %file_pattern% from git history...
            echo This may take a while for large repositories...
            git filter-branch --force --index-filter "git rm -r --cached --ignore-unmatch %file_pattern%" --prune-empty --tag-name-filter cat -- --all
            
            echo.
            echo Cleaning up...
            git for-each-ref --format="delete %(refname)" refs/original/ | git update-ref --stdin
            git reflog expire --expire=now --all
            git gc --aggressive --prune=now
            
            echo.
            echo Do you want to force push this change? (y/n)
            echo WARNING: This will permanently alter repository history!
            set /p force_push=
            if /i "%force_push%"=="y" (
                git push --force --all
            ) else (
                echo Push canceled. You can push manually when ready.
            )
        )
    )
) else (
    echo Fix operation canceled.
)

echo.
echo Script completed! 
echo.
echo If you're still having issues, consider:
echo 1. Using GitHub Desktop which handles LFS better than command line
echo 2. Creating a new repository and gradually adding files in smaller commits
echo 3. Contacting GitHub support if you need increased LFS storage
echo.
pause
