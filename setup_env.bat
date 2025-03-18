@echo off
SETX PATH "%PATH%;C:\Users\Cole\AppData\Roaming\Python\Python313\Scripts"
echo Added Python scripts directory to PATH

REM Add dummy Android SDK environment variable to remove errors
SETX ANDROID_HOME "C:\Android\sdk"
echo Added Android environment variable to suppress build errors

echo Please restart your command prompt for changes to take effect
pause
