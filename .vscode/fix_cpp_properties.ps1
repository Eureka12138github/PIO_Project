# Fix PlatformIO c_cpp_properties.json Path Bug
# This script fixes the path duplication bug in auto-generated c_cpp_properties.json
# It dynamically detects and replaces project paths with ${workspaceFolder} variables

$projectRoot = Split-Path -Parent $PSScriptRoot
$cppPropertiesPath = Join-Path $PSScriptRoot "c_cpp_properties.json"

Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "Fixing c_cpp_properties.json for $projectRoot..." -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""

if (Test-Path $cppPropertiesPath) {
    $content = Get-Content $cppPropertiesPath -Raw
    
    # Get the workspace folder name dynamically (e.g., "PIO_HAL_PROJECT_TEMPLATE1")
    $workspaceFolderName = Split-Path $projectRoot -Leaf
    
    Write-Host "Detected workspace folder: $workspaceFolderName" -ForegroundColor Yellow
    Write-Host "Project root: $projectRoot" -ForegroundColor Yellow
    Write-Host ""
    
    # Build regex pattern to match any absolute path containing the workspace folder name
    # This handles both:
    # 1. Path duplication bug: D:/path/.../Workspace/Workspace/include
    # 2. Regular absolute paths: D:/path/.../Workspace/include
    
    # Escape special regex characters in the workspace folder name
    $escapedWorkspaceName = [regex]::Escape($workspaceFolderName)
    
    # Define common subfolders to look for
    $subfolders = @('include', 'src', 'src/Drivers', 'src/Drivers/Display', 'src/Drivers/Display/Fonts')
    
    $fixedContent = $content
    
    foreach ($subfolder in $subfolders) {
        $escapedSubfolder = [regex]::Escape($subfolder)
        
        # Pattern 1: Paths with duplication bug (workspace appears twice) - backslash version
        # e.g., D:\path\...\Workspace\Workspace\include
        $pattern1_bs = ('[A-Za-z]:\\[^"\n]*?' + $escapedWorkspaceName + '\\' + $escapedWorkspaceName + '\\' + $escapedSubfolder)
        $fixedContent = $fixedContent -replace $pattern1_bs, ('${workspaceFolder}/' + $subfolder)
        
        # Pattern 2: Normal absolute paths - backslash version
        # e.g., D:\path\...\Workspace\include
        $pattern2_bs = ('[A-Za-z]:\\[^"\n]*?' + $escapedWorkspaceName + '\\' + $escapedSubfolder)
        $fixedContent = $fixedContent -replace $pattern2_bs, ('${workspaceFolder}/' + $subfolder)
        
        # Pattern 1: Paths with duplication bug (workspace appears twice) - forward slash version
        # e.g., D:/path/.../Workspace/Workspace/include
        $pattern1_fs = ('[A-Za-z]:/[^"\n]*?' + $escapedWorkspaceName + '/' + $escapedWorkspaceName + '/' + $escapedSubfolder)
        $fixedContent = $fixedContent -replace $pattern1_fs, ('${workspaceFolder}/' + $subfolder)
        
        # Pattern 2: Normal absolute paths - forward slash version
        # e.g., D:/path/.../Workspace/include
        $pattern2_fs = ('[A-Za-z]:/[^"\n]*?' + $escapedWorkspaceName + '/' + $escapedSubfolder)
        $fixedContent = $fixedContent -replace $pattern2_fs, ('${workspaceFolder}/' + $subfolder)
    }
    
    # Normalize all backslashes to forward slashes for consistency
    $fixedContent = $fixedContent -replace '\\\\', '/'
    
    # Remove empty strings from arrays
    $fixedContent = $fixedContent -replace ',\s*""\s*\]', ']'
    
    Set-Content $cppPropertiesPath -Value $fixedContent -Encoding UTF8
    
    Write-Host "Fixed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Please RESTART VSCode to apply the changes." -ForegroundColor Yellow
} else {
    Write-Host "File not found: $cppPropertiesPath" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================================================" -ForegroundColor Cyan