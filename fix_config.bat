@echo off
chcp 65001 >nul
echo ========================================================================
echo 快速修复 c_cpp_properties.json 路径问题
echo ========================================================================
echo.
echo 正在修复 VSCode 配置...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0.vscode\fix_cpp_properties.ps1"

echo.
echo ========================================================================
echo 修复完成！请重启 VSCode 以应用更改
echo ========================================================================
pause
