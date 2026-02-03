@echo off
REM Quick launcher for auto image upload script
echo.
echo ========================================
echo   Photography Portfolio Auto-Updater
echo ========================================
echo.
echo This will automatically process new images
echo and add them to your portfolio.
echo.
echo Press Ctrl+C to cancel, or
pause

powershell -ExecutionPolicy Bypass -File "%~dp0auto_add_images.ps1"

echo.
echo.
echo Script completed!
echo.
pause
