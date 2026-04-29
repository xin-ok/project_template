@echo off
chcp 65001 >nul
echo ======================================
echo  生成 CMakePresets.json
echo ======================================

cmake -P ./cmake/GeneratePresets.cmake

echo.
echo ✅ 生成完成！
pause
