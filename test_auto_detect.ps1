# 测试脚本：验证路径自动检测功能

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "测试 PIO 路径自动检测功能" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

# 测试 Get-PIOProjectPath 函数
function Get-PIOProjectPath {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    Write-Host "脚本目录：$scriptDir" -ForegroundColor Gray
    
    $hasSrc = Test-Path (Join-Path $scriptDir "src")
    $hasPlatformioIni = Test-Path (Join-Path $scriptDir "platformio.ini")
    
    Write-Host "  - 有 src 目录：$hasSrc" -ForegroundColor Gray
    Write-Host "  - 有 platformio.ini: $hasPlatformioIni" -ForegroundColor Gray
    
    if ($hasSrc -and $hasPlatformioIni) {
        Write-Host "[检测成功] 使用脚本目录：$scriptDir" -ForegroundColor Green
        return $scriptDir
    }
    
    if ($env:VSCODE_WORKSPACE_FOLDER -and (Test-Path $env:VSCODE_WORKSPACE_FOLDER)) {
        Write-Host "[检测成功] 使用 VSCode workspace: $env:VSCODE_WORKSPACE_FOLDER" -ForegroundColor Green
        return $env:VSCODE_WORKSPACE_FOLDER
    }
    
    $currentLocation = Get-Location
    Write-Host "[检测失败] 使用当前目录：$currentLocation" -ForegroundColor Yellow
    return $currentLocation
}

$detectedPath = Get-PIOProjectPath

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "检测结果：$detectedPath" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

# 验证是否正确的 PIO 项目
$hasSrc = Test-Path (Join-Path $detectedPath "src")
$hasInclude = Test-Path (Join-Path $detectedPath "include")
$hasPlatformioIni = Test-Path (Join-Path $detectedPath "platformio.ini")

Write-Host "验证项目结构:" -ForegroundColor Cyan
Write-Host "  - src/: $hasSrc" -ForegroundColor $(if($hasSrc){"Green"}else{"Red"})
Write-Host "  - include/: $hasInclude" -ForegroundColor $(if($hasInclude){"Green"}else{"Red"})
Write-Host "  - platformio.ini: $hasPlatformioIni" -ForegroundColor $(if($hasPlatformioIni){"Green"}else{"Red"})
Write-Host ""

if ($hasSrc -and $hasInclude -and $hasPlatformioIni) {
    Write-Host "✓ 检测成功！这是一个有效的 PlatformIO 项目" -ForegroundColor Green
} else {
    Write-Host "✗ 检测失败！请检查项目结构" -ForegroundColor Red
}

Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
