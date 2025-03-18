@echo off
echo Fixing Lyra database...
echo.

:: Activate the environment
call lyra_env\Scripts\activate

:: Install SQLAlchemy first
echo Installing SQLAlchemy...
python -m pip install sqlalchemy==1.4.46 sqlalchemy-utils

:: Run the database fix script
echo Running database fix...
python db_fix.py

echo.
echo Database fix complete!
echo You can now run Lyra: python -m lyra.main
echo.
pause
