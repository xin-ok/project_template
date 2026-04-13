@echo off
chcp 65001 >nul
setlocal

rem Project root = parent directory of this script (the parent of scripts/).
rem This makes the script work the same whether invoked as
rem   scripts\generate_presets.bat   (from project root)
rem   .\generate_presets.bat         (from inside scripts/)
set "ROOT_DIR=%~dp0.."

echo ======================================
echo  Generating CMakePresets.json
echo ======================================

cmake -P "%ROOT_DIR%\cmake\GeneratePresets.cmake"
if errorlevel 1 (
    echo.
    echo [ERROR] Generation failed.
    pause
    exit /b 1
)

echo.
echo [OK] Generation complete.
pause
