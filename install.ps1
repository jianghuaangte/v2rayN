<#
.SYNOPSIS
    Download v2rayN from GitHub, extract it, and create a desktop shortcut.
.DESCRIPTION
    This script downloads v2rayN, extracts the ZIP file to the current directory,
    and creates a desktop shortcut for v2rayN.exe.
.NOTES
    File Name      : Install-v2rayN.ps1
    Prerequisite   : PowerShell 5.1 or later
#>

# 1. 定义下载参数
$downloadUrl = "https://ghproxy.net/https://github.com/2dust/v2rayN/releases/download/7.13.2/v2rayN-windows-64-SelfContained.zip"
$zipFileName = "v2rayN-windows-64-SelfContained.zip"
$desktopShortcutName = "v2rayN.lnk"

# 2. 检查当前目录是否可写
if (-not (Test-Path -Path . -PathType Container -IsValid)) {
    Write-Host "错误：当前目录不可写！" -ForegroundColor Red
    exit 1
}

# 3. 下载 ZIP 文件
try {
    Write-Host "正在下载 v2rayN..."
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFileName -UseBasicParsing
    Write-Host "下载完成！" -ForegroundColor Green
} catch {
    Write-Host "下载失败: $_" -ForegroundColor Red
    exit 1
}

# 4. 解压 ZIP 文件
try {
    Write-Host "正在解压..."
    Expand-Archive -Path $zipFileName -DestinationPath . -Force
    Write-Host "解压完成！" -ForegroundColor Green
} catch {
    Write-Host "解压失败: $_" -ForegroundColor Red
    exit 1
}

# 5. 创建桌面快捷方式
try {
    $v2rayNPath = Resolve-Path -Path ".\v2rayN\v2rayN.exe"
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path -Path $desktopPath -ChildPath $desktopShortcutName

    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $v2rayNPath
    $shortcut.WorkingDirectory = Split-Path -Path $v2rayNPath -Parent
    $shortcut.Save()

    Write-Host "已在桌面创建快捷方式: $shortcutPath" -ForegroundColor Green
} catch {
    Write-Host "创建快捷方式失败: $_" -ForegroundColor Red
}

# 6. 清理 ZIP 文件（可选）
Remove-Item -Path $zipFileName -Force
Write-Host "安装完成！" -ForegroundColor Green
