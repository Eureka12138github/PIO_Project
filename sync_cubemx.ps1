# CubeMX 到 PlatformIO 自动同步脚本 (PowerShell 版本)
# 功能：
# 1. 从 CubeMX 生成的工程复制必要文件到 PlatformIO 项目
# 2. 智能合并 main.c 文件，保留用户自定义代码
# 3. 备份机制，防止数据丢失

param(
    [string]$CubeMXPath = "D:\Embedded-related\PlatformIO\CUBEMX FOR PIO\PROJECT_FOR_PIO",
    [string]$PIOPath = "D:\Embedded-related\PlatformIO\PIO_TEST2",
    [switch]$Force,
    [switch]$SyncBack,
    [switch]$BackupOnly,
    [switch]$CleanBackup
)

# ==================== 配置区域 ====================
$BackupRetentionDays = 7

# ==================== 辅助函数 ====================

function Write-Header {
    param([string]$Text)
    Write-Host "" -NoNewline
    Write-Host "=" * 70 -ForegroundColor Cyan
    Write-Host $Text -ForegroundColor Cyan
    Write-Host "=" * 70 -ForegroundColor Cyan
    Write-Host ""
}

function Write-Success {
    param([string]$Text)
    Write-Host "✓ $Text" -ForegroundColor Green
}

function Write-Warning-Custom {
    param([string]$Text)
    Write-Host "⚠ $Text" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Text)
    Write-Host "❌ $Text" -ForegroundColor Red
}

function Write-Info {
    param([string]$Text)
    Write-Host "ℹ $Text" -ForegroundColor Blue
}

# ==================== 核心功能函数 ====================

function Get-PIOProjectPath {
    """
    尝试获取当前 VSCode 工作区路径
    如果失败，返回默认路径
    """
    # 检查环境变量
    if ($env:VSCODE_WORKSPACE_FOLDER -and (Test-Path $env:VSCODE_WORKSPACE_FOLDER)) {
        Write-Info "检测到 VSCode 工作区：$env:VSCODE_WORKSPACE_FOLDER"
        return $env:VSCODE_WORKSPACE_FOLDER
    }
    
    Write-Info "使用默认 PlatformIO 工程路径：$PIOPath"
    return $PIOPath
}

function Test-ValidatePaths {
    param(
        [string]$CubemxPath,
        [string]$PioPath
    )
    
    $errors = @()
    
    # 检查 CubeMX 路径
    if (-not (Test-Path $CubemxPath)) {
        $errors += "CubeMX 工程路径不存在：$CubemxPath"
    }
    
    $coreIncPath = Join-Path $CubemxPath "Core\Inc"
    $coreSrcPath = Join-Path $CubemxPath "Core\Src"
    
    if (-not (Test-Path $coreIncPath)) {
        $errors += "CubeMX Core/Inc 目录不存在：$coreIncPath"
    }
    
    if (-not (Test-Path $coreSrcPath)) {
        $errors += "CubeMX Core/Src 目录不存在：$coreSrcPath"
    }
    
    # 检查 PlatformIO 路径
    if (-not (Test-Path $PioPath)) {
        $errors += "PlatformIO 工程路径不存在：$PioPath"
    }
    
    $pioSrcPath = Join-Path $PioPath "src"
    $pioIncPath = Join-Path $PioPath "include"
    
    if (-not (Test-Path $pioSrcPath)) {
        $errors += "PlatformIO src 目录不存在：$pioSrcPath"
    }
    
    if (-not (Test-Path $pioIncPath)) {
        $errors += "PlatformIO include 目录不存在：$pioIncPath"
    }
    
    if ($errors.Count -gt 0) {
        foreach ($error in $errors) {
            Write-Error-Custom $error
        }
        return $false
    }
    
    Write-Success "路径验证通过"
    return $true
}

function New-Backup {
    param([string]$FilePath)
    
    if (-not (Test-Path $FilePath)) {
        return $null
    }
    
    # 创建备份目录
    $backupDir = Join-Path (Split-Path $FilePath -Parent) "backup"
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    }
    
    # 生成带时间戳的备份文件名
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $filename = Split-Path $FilePath -Leaf
    $backupFilename = "$filename.$timestamp.bak"
    $backupFullPath = Join-Path $backupDir $backupFilename
    
    # 复制文件
    Copy-Item -Path $FilePath -Destination $backupFullPath -Force
    Write-Success "已备份：$filename -> $backupFilename"
    
    return $backupFullPath
}

function Get-UserCodeSections {
    param([string]$FilePath)
    
    if (-not (Test-Path $FilePath)) {
        return @{}
    }
    
    $content = Get-Content -Path $FilePath -Raw -Encoding UTF8
    $userSections = @{}
    
    # 匹配 USER CODE BEGIN 和 END 之间的内容
    $pattern = '/\* USER CODE BEGIN (.*?) \*/\s*(.*?)\s*/\* USER CODE END (.*?) \*/'
    $matches = [regex]::Matches($content, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    
    foreach ($match in $matches) {
        $beginTag = $match.Groups[1].Value
        $code = $match.Groups[2].Value.Trim()
        $endTag = $match.Groups[3].Value
        
        if ($beginTag -eq $endTag) {
            $userSections[$beginTag] = $code
            Write-Host "  ✓ 提取用户代码段：USER CODE $beginTag" -ForegroundColor Gray
        }
    }
    
    return $userSections
}

function Merge-MainFiles {
    param(
        [string]$CubeMainPath,
        [string]$PioMainPath
    )
    
    Write-Host "`n📋 开始合并 main.c..." -ForegroundColor Cyan
    
    # 备份现有文件
    New-Backup -FilePath $PioMainPath | Out-Null
    
    # 提取用户代码
    Write-Host "  提取 PlatformIO 中的用户代码..." -ForegroundColor Gray
    $userCode = Get-UserCodeSections -FilePath $PioMainPath
    
    # 读取 CubeMX 的 main.c
    Write-Host "  读取 CubeMX main.c..." -ForegroundColor Gray
    $cubeContent = Get-Content -Path $CubeMainPath -Raw -Encoding UTF8
    
    # 如果 PlatformIO 没有用户代码，直接使用 CubeMX 版本
    if ($userCode.Count -eq 0) {
        Write-Info "PlatformIO 中没有用户代码，直接复制 CubeMX 版本"
        Copy-Item -Path $CubeMainPath -Destination $PioMainPath -Force
        return
    }
    
    # 合并策略：用 CubeMX 的内容替换，但保留用户代码段
    Write-Host "  合并用户代码到 CubeMX 框架..." -ForegroundColor Gray
    $mergedContent = $cubeContent
    
    # 对每个用户代码段，插入到对应位置
    foreach ($section in $userCode.GetEnumerator()) {
        $sectionName = $section.Key
        $code = $section.Value
        
        $beginMarker = "/* USER CODE BEGIN $sectionName */"
        $endMarker = "/* USER CODE END $sectionName */"
        
        # 查找并替换
        $pattern = [regex]::Escape($beginMarker) + '.*?' + [regex]::Escape($endMarker)
        $replacement = "$beginMarker`n$code`n$endMarker"
        
        $mergedContent = [regex]::Replace($mergedContent, $pattern, $replacement, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    }
    
    # 写入合并后的文件
    Set-Content -Path $PioMainPath -Value $mergedContent -Encoding UTF8 -NoNewline
    Write-Host "  ✓ main.c 合并完成" -ForegroundColor Green
}

function Copy-FilesSafely {
    param(
        [string]$CubemxPath,
        [string]$PioPath,
        [switch]$Force
    )
    
    $coreInc = Join-Path $CubemxPath "Core\Inc"
    $coreSrc = Join-Path $CubemxPath "Core\Src"
    $pioInc = Join-Path $PioPath "include"
    $pioSrc = Join-Path $PioPath "src"
    
    # 需要复制的文件列表
    $filesToCopy = @{
        'inc' = @(
            'stm32f1xx_hal_conf.h',
            'stm32f1xx_it.h',
            'main.h'
        )
        'src' = @(
            'stm32f1xx_hal_msp.c',
            'stm32f1xx_it.c',
            'system_stm32f1xx.c'
        )
    }
    
    Write-Host "`n 开始复制头文件..." -ForegroundColor Cyan
    foreach ($filename in $filesToCopy['inc']) {
        $srcFile = Join-Path $coreInc $filename
        $dstFile = Join-Path $pioInc $filename
        
        if (Test-Path $srcFile) {
            if ((Test-Path $dstFile) -and (-not $Force)) {
                New-Backup -FilePath $dstFile | Out-Null
            }
            Copy-Item -Path $srcFile -Destination $dstFile -Force
            Write-Success $filename
        } else {
            Write-Warning-Custom "$filename 不存在，跳过"
        }
    }
    
    Write-Host "`n 开始复制源文件..." -ForegroundColor Cyan
    foreach ($filename in $filesToCopy['src']) {
        $srcFile = Join-Path $coreSrc $filename
        $dstFile = Join-Path $pioSrc $filename
        
        if (Test-Path $srcFile) {
            if ((Test-Path $dstFile) -and (-not $Force)) {
                New-Backup -FilePath $dstFile | Out-Null
            }
            Copy-Item -Path $srcFile -Destination $dstFile -Force
            Write-Success $filename
        } else {
            Write-Warning-Custom "$filename 不存在，跳过"
        }
    }
    
    # 特殊处理 main.c
    Write-Host "`n📂 处理 main.c（智能合并）..." -ForegroundColor Cyan
    $cubeMain = Join-Path $coreSrc 'main.c'
    $pioMain = Join-Path $pioSrc 'main.c'
    
    if (Test-Path $cubeMain) {
        if (Test-Path $pioMain) {
            Merge-MainFiles -CubeMainPath $cubeMain -PioMainPath $pioMain
        } else {
            Copy-Item -Path $cubeMain -Destination $pioMain -Force
            Write-Success "main.c (首次复制)"
        }
    } else {
        Write-Warning-Custom "main.c 不存在，跳过"
    }
    
    # main.h 处理
    $cubeMainH = Join-Path $coreInc 'main.h'
    $pioMainH = Join-Path $pioInc 'main.h'
    
    if (Test-Path $cubeMainH) {
        if ((Test-Path $pioMainH) -and (-not $Force)) {
            $userCode = Get-UserCodeSections -FilePath $pioMainH
            if ($userCode.Count -gt 0) {
                Write-Info "main.h 包含用户代码，已备份"
                New-Backup -FilePath $pioMainH | Out-Null
            }
        }
        Copy-Item -Path $cubeMainH -Destination $pioMainH -Force
        Write-Success "main.h"
    }
}

function Sync-BackToCubeMX {
    param(
        [string]$PioPath,
        [string]$CubemxPath
    )
    
    Write-Host "`n⚠️  警告：此操作将修改 CubeMX 工程文件！" -ForegroundColor Yellow
    Write-Host "   建议仅在确认需要时执行此操作。" -ForegroundColor Yellow
    
    $response = Read-Host "   是否继续？(y/N)"
    if ($response.ToLower() -ne 'y') {
        Write-Host "   已取消同步操作" -ForegroundColor Gray
        return
    }
    
    $pioMain = Join-Path $PioPath 'src\main.c'
    $cubeMain = Join-Path $CubemxPath 'Core\Src\main.c'
    
    if (-not (Test-Path $pioMain)) {
        Write-Error-Custom "PlatformIO main.c 不存在"
        return
    }
    
    # 备份 CubeMX 文件
    New-Backup -FilePath $cubeMain | Out-Null
    
    # 提取用户代码
    $userCode = Get-UserCodeSections -FilePath $pioMain
    
    if ($userCode.Count -eq 0) {
        Write-Info "PlatformIO main.c 中没有用户代码"
        return
    }
    
    # 读取 CubeMX main.c
    $cubeContent = Get-Content -Path $cubeMain -Raw -Encoding UTF8
    
    # 插入用户代码
    $mergedContent = $cubeContent
    foreach ($section in $userCode.GetEnumerator()) {
        $sectionName = $section.Key
        $code = $section.Value
        
        $beginMarker = "/* USER CODE BEGIN $sectionName */"
        $endMarker = "/* USER CODE END $sectionName */"
        
        $pattern = [regex]::Escape($beginMarker) + '.*?' + [regex]::Escape($endMarker)
        $replacement = "$beginMarker`n$code`n$endMarker"
        
        $mergedContent = [regex]::Replace($mergedContent, $pattern, $replacement, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    }
    
    # 写回 CubeMX
    Set-Content -Path $cubeMain -Value $mergedContent -Encoding UTF8 -NoNewline
    Write-Success "已将用户代码同步回 CubeMX"
}

function Clean-Backup {
    param([string]$PioPath)
    
    $backupDir = Join-Path $PioPath 'src\backup'
    if (-not (Test-Path $backupDir)) {
        return
    }
    
    $cutoffTime = (Get-Date).AddDays(-$BackupRetentionDays)
    $cleaned = 0
    
    Get-ChildItem -Path $backupDir | ForEach-Object {
        if ($_.LastWriteTime -lt $cutoffTime) {
            Remove-Item $_.FullName -Force
            $cleaned++
        }
    }
    
    if ($cleaned -gt 0) {
        Write-Success "清理了 $cleaned 个旧备份文件"
    }
}

# ==================== 主程序 ====================

function Main {
    Write-Header "CubeMX → PlatformIO 自动同步工具"
    
    # 获取路径
    $pioPath = Get-PIOProjectPath
    $cubemxPath = $CubeMXPath
    
    Write-Host "CubeMX 工程：$cubemxPath" -ForegroundColor Gray
    Write-Host "PlatformIO 工程：$pioPath" -ForegroundColor Gray
    
    # 验证路径
    if (-not (Test-ValidatePaths -CubemxPath $cubemxPath -PioPath $pioPath)) {
        Write-Error-Custom "路径验证失败，请检查配置"
        return 1
    }
    
    # 检查是否使用了命令行参数
    if ($SyncBack) {
        Sync-BackToCubeMX -PioPath $pioPath -CubemxPath $cubemxPath
        return 0
    }
    
    if ($BackupOnly) {
        Write-Host "`n📦 创建备份..." -ForegroundColor Cyan
        $filesToBackup = @(
            (Join-Path $pioPath 'src\main.c'),
            (Join-Path $pioPath 'src\stm32f1xx_it.c'),
            (Join-Path $pioPath 'src\system_stm32f1xx.c')
        )
        foreach ($filepath in $filesToBackup) {
            if (Test-Path $filepath) {
                New-Backup -FilePath $filepath | Out-Null
            }
        }
        Write-Success "备份完成！"
        return 0
    }
    
    if ($CleanBackup) {
        Clean-Backup -PioPath $pioPath
        Write-Success "清理完成！"
        return 0
    }
    
    # 交互模式
    Write-Host "`n请选择操作模式:" -ForegroundColor Cyan
    Write-Host "1. 标准模式 - 复制并合并文件（推荐）"
    Write-Host "2. 强制模式 - 完全覆盖（会备份现有文件）"
    Write-Host "3. 仅备份 - 仅创建备份，不复制文件"
    Write-Host "4. 同步回 CubeMX - 将 PIO 修改同步回 CubeMX"
    Write-Host "5. 清理备份 - 删除 7 天前的备份"
    
    $choice = Read-Host "`n请输入选项 (1-5)"
    
    try {
        switch ($choice) {
            '1' {
                Write-Host "`n 执行标准同步..." -ForegroundColor Cyan
                Copy-FilesSafely -CubemxPath $cubemxPath -PioPath $pioPath
                Write-Host "`n✅ 同步完成！" -ForegroundColor Green
                Write-Host "   请检查编译是否成功：pio run" -ForegroundColor Blue
            }
            '2' {
                Write-Warning-Custom "警告：强制模式将覆盖所有文件（main.c 除外）！"
                $confirm = Read-Host "   确认继续？(y/N)"
                if ($confirm.ToLower() -eq 'y') {
                    Copy-FilesSafely -CubemxPath $cubemxPath -PioPath $pioPath -Force
                    Write-Host "`n✅ 强制同步完成！" -ForegroundColor Green
                } else {
                    Write-Host "   已取消操作" -ForegroundColor Gray
                }
            }
            '3' {
                Write-Host "`n📦 创建备份..." -ForegroundColor Cyan
                $filesToBackup = @(
                    (Join-Path $pioPath 'src\main.c'),
                    (Join-Path $pioPath 'src\stm32f1xx_it.c'),
                    (Join-Path $pioPath 'src\system_stm32f1xx.c')
                )
                foreach ($filepath in $filesToBackup) {
                    if (Test-Path $filepath) {
                        New-Backup -FilePath $filepath | Out-Null
                    }
                }
                Write-Host "`n✅ 备份完成！" -ForegroundColor Green
            }
            '4' {
                Sync-BackToCubeMX -PioPath $pioPath -CubemxPath $cubemxPath
            }
            '5' {
                Clean-Backup -PioPath $pioPath
                Write-Host "`n✅ 清理完成！" -ForegroundColor Green
            }
            default {
                Write-Error-Custom "无效选项"
                return 1
            }
        }
    } catch {
        Write-Error-Custom "发生错误：$_"
        return 1
    }
    
    Write-Host ""
    Write-Host "=" * 70 -ForegroundColor Cyan
    return 0
}

# 执行主函数
exit Main
