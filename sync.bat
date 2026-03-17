@echo off
chcp 65001 >nul
echo ========================================================================
echo CubeMX to PlatformIO 快速同步工具
echo ========================================================================
echo.
echo 正在启动同步脚本...
echo.
echo [INFO] 当前目录：%CD%
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0sync_cubemx_simple.ps1"

pause
