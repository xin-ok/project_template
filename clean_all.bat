@echo off
chcp 65001 >nul
echo ======================================
echo  一键清理: build bin lib install
echo ======================================

if exist build rmdir /s /q build
if exist bin   rmdir /s /q bin
if exist lib   rmdir /s /q lib
if exist install rmdir /s /q install
if exist packages rmdir /s /q packages

echo.
echo ✅ 清理完成！
pause