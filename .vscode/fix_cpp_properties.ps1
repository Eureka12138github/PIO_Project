# Fix PlatformIO c_cpp_properties.json Path Bug
# This script fixes the path duplication bug in auto-generated c_cpp_properties.json

$projectRoot = Split-Path -Parent $PSScriptRoot
$cppPropertiesPath = Join-Path $PSScriptRoot "c_cpp_properties.json"

Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "Fixing c_cpp_properties.json for $projectRoot..." -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""

if (Test-Path $cppPropertiesPath) {
    $content = Get-Content $cppPropertiesPath -Raw
    
    # Replace duplicated project paths with workspaceFolder variables (handle both / and \)
    # Pattern 1: Embedded-relatedPIOPIO_HAL_PROJECT_TEMPLATE (duplicated path bug)
    $fixedContent = $content -replace [regex]::Escape('D:\\Embedded-related\\PIO\\PIO_HAL_PROJECT_TEMPLATE\\Embedded-relatedPIOPIO_HAL_PROJECT_TEMPLATE\\include'), '${workspaceFolder}/include'
    $fixedContent = $fixedContent -replace [regex]::Escape('D:/Embedded-related/PIO/PIO_HAL_PROJECT_TEMPLATE/Embedded-relatedPIOPIO_HAL_PROJECT_TEMPLATE/include'), '${workspaceFolder}/include'
    
    $fixedContent = $fixedContent -replace [regex]::Escape('D:\\Embedded-related\\PIO\\PIO_HAL_PROJECT_TEMPLATE\\Embedded-relatedPIOPIO_HAL_PROJECT_TEMPLATE\\src\\Drivers'), '${workspaceFolder}/src/Drivers'
    $fixedContent = $fixedContent -replace [regex]::Escape('D:/Embedded-related/PIO/PIO_HAL_PROJECT_TEMPLATE/Embedded-relatedPIOPIO_HAL_PROJECT_TEMPLATE/src/Drivers'), '${workspaceFolder}/src/Drivers'
    
    $fixedContent = $fixedContent -replace [regex]::Escape('D:\\Embedded-related\\PIO\\PIO_HAL_PROJECT_TEMPLATE\\Embedded-relatedPIOPIO_HAL_PROJECT_TEMPLATE\\src\\Drivers\\Display'), '${workspaceFolder}/src/Drivers/Display'
    $fixedContent = $fixedContent -replace [regex]::Escape('D:/Embedded-related/PIO/PIO_HAL_PROJECT_TEMPLATE/Embedded-relatedPIOPIO_HAL_PROJECT_TEMPLATE/src/Drivers/Display'), '${workspaceFolder}/src/Drivers/Display'
    
    $fixedContent = $fixedContent -replace [regex]::Escape('D:\\Embedded-related\\PIO\\PIO_HAL_PROJECT_TEMPLATE\\Embedded-relatedPIOPIO_HAL_PROJECT_TEMPLATE\\src\\Drivers\\Display\\Fonts'), '${workspaceFolder}/src/Drivers/Display/Fonts'
    $fixedContent = $fixedContent -replace [regex]::Escape('D:/Embedded-related/PIO/PIO_HAL_PROJECT_TEMPLATE/Embedded-relatedPIOPIO_HAL_PROJECT_TEMPLATE/src/Drivers/Display/Fonts'), '${workspaceFolder}/src/Drivers/Display/Fonts'
    
    # Pattern 2: Regular absolute paths to convert
    $fixedContent = $fixedContent -replace [regex]::Escape('D:\\Embedded-related\\PIO\\PIO_HAL_PROJECT_TEMPLATE\\include'), '${workspaceFolder}/include'
    $fixedContent = $fixedContent -replace [regex]::Escape('D:/Embedded-related/PIO/PIO_HAL_PROJECT_TEMPLATE/include'), '${workspaceFolder}/include'
    
    $fixedContent = $fixedContent -replace [regex]::Escape('D:\\Embedded-related\\PIO\\PIO_HAL_PROJECT_TEMPLATE\\src'), '${workspaceFolder}/src'
    $fixedContent = $fixedContent -replace [regex]::Escape('D:/Embedded-related/PIO/PIO_HAL_PROJECT_TEMPLATE/src'), '${workspaceFolder}/src'
    
    # Remove empty strings from arrays
    $fixedContent = $fixedContent -replace ',\s*""\s*\]', ']'
        
    Set-Content $cppPropertiesPath -Value $fixedContent -Encoding UTF8
    
    Write-Host "✓ Fixed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Please RESTART VSCode to apply the changes." -ForegroundColor Yellow
} else {
    Write-Host "✗ File not found: $cppPropertiesPath" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================================================" -ForegroundColor Cyan
