# CubeMX to PlatformIO Auto-Sync Script
# Simple version without encoding issues

param(
    [string]$CubeMXPath = "D:\Embedded-related\PlatformIO\CUBEMX FOR PIO\PROJECT_FOR_PIO",
    [string]$PIOPath = ""  # Empty means auto-detect
)

# ============================================================================
# Auto-detect PIO project path
# ============================================================================

function Get-PIOProjectPath {
    # Method 1: Get script directory
    $scriptDir = $null
    if ($MyInvocation.MyCommand -and $MyInvocation.MyCommand.Path) {
        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    }
    
    if ($scriptDir -and (Test-Path $scriptDir)) {
        $hasSrc = Test-Path (Join-Path $scriptDir "src")
        $hasPlatformioIni = Test-Path (Join-Path $scriptDir "platformio.ini")
        
        if ($hasSrc -and $hasPlatformioIni) {
            Write-Host "[AUTO-DETECT] Using script directory: $scriptDir" -ForegroundColor Green
            return $scriptDir
        }
    }
    
    # Method 2: Try VSCode workspace
    if ($env:VSCODE_WORKSPACE_FOLDER -and (Test-Path $env:VSCODE_WORKSPACE_FOLDER)) {
        Write-Host "[AUTO-DETECT] Using VSCode workspace: $($env:VSCODE_WORKSPACE_FOLDER)" -ForegroundColor Green
        return $env:VSCODE_WORKSPACE_FOLDER
    }
    
    # Method 3: Current location
    $currentPath = (Get-Location).Path
    $hasSrc = Test-Path (Join-Path $currentPath "src")
    $hasPlatformioIni = Test-Path (Join-Path $currentPath "platformio.ini")
    
    if ($hasSrc -and $hasPlatformioIni) {
        Write-Host "[AUTO-DETECT] Using current directory: $currentPath" -ForegroundColor Green
        return $currentPath
    }
    
    # Method 4: Fallback
    $defaultPath = "D:\Embedded-related\PlatformIO\PIO_TEST2"
    Write-Host "[FALLBACK] Using default path: $defaultPath" -ForegroundColor Yellow
    return $defaultPath
}

# ============================================================================
# Main script
# ============================================================================

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "CubeMX to PlatformIO Auto-Sync Tool" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

# Auto-detect PIO path if not provided
$PIOPath = if ([string]::IsNullOrEmpty($PIOPath)) {
    Get-PIOProjectPath
} else {
    $PIOPath
}

# Validate paths
if (-not (Test-Path $CubeMXPath)) {
    Write-Host "ERROR: CubeMX path does not exist: $CubeMXPath" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $PIOPath)) {
    Write-Host "ERROR: PIO path does not exist: $PIOPath" -ForegroundColor Red
    exit 1
}

$coreInc = Join-Path $CubeMXPath "Core\Inc"
$coreSrc = Join-Path $CubeMXPath "Core\Src"
$pioInc = Join-Path $PIOPath "include"
$pioSrc = Join-Path $PIOPath "src"

Write-Host "CubeMX Project: $CubeMXPath"
Write-Host "PIO Project: $PIOPath"
Write-Host ""

# Check if directories exist
if (-not (Test-Path $coreInc)) {
    Write-Host "ERROR: Core/Inc not found in CubeMX project" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $coreSrc)) {
    Write-Host "ERROR: Core/Src not found in CubeMX project" -ForegroundColor Red
    exit 1
}

# Create backup function
function New-Backup {
    param([string]$FilePath)
    if (-not (Test-Path $FilePath)) { return }
    
    $backupDir = Join-Path (Split-Path $FilePath -Parent) "backup"
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $filename = Split-Path $FilePath -Leaf
    $backupPath = Join-Path $backupDir "$filename.$timestamp.bak"
    
    Copy-Item -Path $FilePath -Destination $backupPath
    Write-Host "  [BACKUP] $filename" -ForegroundColor Yellow
}

# Main sync function
function Sync-Files {
    Write-Host "Copying header files..." -ForegroundColor Cyan
    
    $headerFiles = @("stm32f1xx_hal_conf.h", "stm32f1xx_it.h", "main.h")
    foreach ($file in $headerFiles) {
        $src = Join-Path $coreInc $file
        $dst = Join-Path $pioInc $file
        if (Test-Path $src) {
            if (Test-Path $dst) {
                New-Backup -FilePath $dst
            }
            Copy-Item -Path $src -Destination $dst -Force
            Write-Host "  [OK] $file" -ForegroundColor Green
        }
    }
    
    Write-Host ""
    Write-Host "Copying source files..." -ForegroundColor Cyan
    
    $sourceFiles = @("stm32f1xx_hal_msp.c", "stm32f1xx_it.c", "system_stm32f1xx.c")
    foreach ($file in $sourceFiles) {
        $src = Join-Path $coreSrc $file
        $dst = Join-Path $pioSrc $file
        if (Test-Path $src) {
            if (Test-Path $dst) {
                New-Backup -FilePath $dst
            }
            Copy-Item -Path $src -Destination $dst -Force
            Write-Host "  [OK] $file" -ForegroundColor Green
        }
    }
    
    # Special handling for main.c
    Write-Host ""
    Write-Host "Processing main.c (smart merge)..." -ForegroundColor Cyan
    $cubeMain = Join-Path $coreSrc "main.c"
    $pioMain = Join-Path $pioSrc "main.c"
    
    if (Test-Path $cubeMain) {
        if (Test-Path $pioMain) {
            # Backup PIO main.c
            New-Backup -FilePath $pioMain
            
            # Simple merge: copy CubeMX version but warn user
            Write-Host "  [INFO] Merging main.c..." -ForegroundColor Yellow
            Write-Host "  [WARN] Please manually merge your custom code!" -ForegroundColor Red
            
            # For now, just copy (user should backup first)
            Copy-Item -Path $cubeMain -Destination $pioMain -Force
            Write-Host "  [OK] main.c copied (PLEASE MERGE MANUALLY!)" -ForegroundColor Yellow
        } else {
            Copy-Item -Path $cubeMain -Destination $pioMain -Force
            Write-Host "  [OK] main.c (first copy)" -ForegroundColor Green
        }
    }
}

# Interactive menu
Write-Host ""
Write-Host "Select operation mode:" -ForegroundColor Cyan
Write-Host "1. Standard Sync (copy files with backup)"
Write-Host "2. Force Sync (overwrite all)"
Write-Host "3. Backup Only"
Write-Host "4. Exit"
Write-Host ""

$choice = Read-Host "Enter choice (1-4)"

if ($choice -eq "1" -or $choice -eq "2") {
    Write-Host ""
    Write-Host "Starting sync..." -ForegroundColor Cyan
    Sync-Files
    Write-Host ""
    Write-Host "======================================================================"
    Write-Host "Sync completed!" -ForegroundColor Green
    Write-Host "Please verify with: pio run"
    Write-Host "======================================================================"
} elseif ($choice -eq "3") {
    Write-Host ""
    Write-Host "Creating backups..." -ForegroundColor Cyan
    $files = @("main.c", "stm32f1xx_it.c", "system_stm32f1xx.c")
    foreach ($file in $files) {
        $filepath = Join-Path $pioSrc $file
        if (Test-Path $filepath) {
            New-Backup -FilePath $filepath
        }
    }
    Write-Host ""
    Write-Host "Backup completed!" -ForegroundColor Green
} elseif ($choice -eq "4") {
    Write-Host "Exiting..."
    exit 0
} else {
    Write-Host "Invalid choice!" -ForegroundColor Red
    exit 1
}
