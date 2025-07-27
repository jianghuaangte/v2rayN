<#
.SYNOPSIS
    Download and install v2rayN with desktop shortcut
#>

# 1. 设置下载参数
$url = "https://ghfast.top/https://github.com/2dust/v2rayN/releases/download/7.13.2/v2rayN-windows-64-SelfContained.zip"
$zipFile = "$env:TEMP\v2rayN.zip"
$destDir = "$PSScriptRoot\v2rayN"
$shortcutPath = "$env:USERPROFILE\Desktop\v2rayN.lnk"

# 2. 创建目标目录
if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force }

# 3. 下载ZIP文件
try {
    Write-Host "Downloading v2rayN..."
    Invoke-WebRequest -Uri $url -OutFile $zipFile -UseBasicParsing
}
catch {
    Write-Host "Download failed: $_" -ForegroundColor Red
    exit 1
}

# 4. 解压文件
try {
    Write-Host "Extracting files..."
    Expand-Archive -Path $zipFile -DestinationPath $destDir -Force
}
catch {
    Write-Host "Extraction failed: $_" -ForegroundColor Red
    exit 1
}

# 5. 创建桌面快捷方式
try {
    $exePath = Join-Path $destDir "v2rayN.exe"
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $exePath
    $shortcut.WorkingDirectory = $destDir
    $shortcut.Save()
    Write-Host "Shortcut created: $shortcutPath" -ForegroundColor Green
}
catch {
    Write-Host "Shortcut creation failed: $_" -ForegroundColor Yellow
}

# 6. 清理临时文件
Remove-Item $zipFile -ErrorAction SilentlyContinue
Write-Host "Installation completed!" -ForegroundColor Green
