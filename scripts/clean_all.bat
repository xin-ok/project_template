@echo off
chcp 65001 >nul
setlocal

rem Project root = parent directory of this script (the parent of scripts/).
rem This makes the script work the same whether invoked as
rem   scripts\clean_all.bat   (from project root)
rem   .\clean_all.bat         (from inside scripts/)
set "ROOT_DIR=%~dp0.."

echo ======================================
echo  Cleaning: build bin lib install packages
echo ======================================

if exist "%ROOT_DIR%\build"    rmdir /s /q "%ROOT_DIR%\build"
if exist "%ROOT_DIR%\bin"      rmdir /s /q "%ROOT_DIR%\bin"
if exist "%ROOT_DIR%\lib"      rmdir /s /q "%ROOT_DIR%\lib"
if exist "%ROOT_DIR%\install"  rmdir /s /q "%ROOT_DIR%\install"
if exist "%ROOT_DIR%\packages" rmdir /s /q "%ROOT_DIR%\packages"

echo.
echo [OK] Cleanup complete.

rem Pause only in an interactive terminal; skip when running in CI or from a script.
if not defined CI pause