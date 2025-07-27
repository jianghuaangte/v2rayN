param(
    [switch]$AllUsers
)

$downloadUrl = "https://ghfast.top/https://github.com/2dust/v2rayN/releases/download/7.13.2/v2rayN-windows-64-SelfContained.zip"
$zipName = "v2rayN.zip"

function Get-DesktopPath {
    if ($AllUsers) {
        return "$Env:PUBLIC\Desktop"
    } else {
        return [Environment]::GetFolderPath('Desktop')
    }
}

function Get-InstallPath {
    if ($AllUsers) {
        return "C:\Program Files\v2rayN"
    } else {
        return "$env:LOCALAPPDATA\v2rayN"
    }
}

$desktop = Get-DesktopPath
$installPath = Get-InstallPath
$tempZip = Join-Path $env:TEMP $zipName

Write-Host "📥 正在下载 v2rayN..."
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZip -UseBasicParsing
} catch {
    Write-Host "❌ 下载失败，请检查网络连接或代理设置。"
    exit 1
}

Write-Host "📦 正在解压到 $installPath..."
if (!(Test-Path $installPath)) {
    New-Item -Path $installPath -ItemType Directory -Force | Out-Null
}
Expand-Archive -Path $tempZip -DestinationPath $installPath -Force

# 查找解压后 v2rayN.exe 的完整路径（考虑 zip 里包了一层文件夹）
$v2rayExe = Get-ChildItem -Path $installPath -Recurse -Filter "v2rayN.exe" -File | Select-Object -First 1

if (-not $v2rayExe) {
    Write-Host "❌ 无法在解压目录中找到 v2rayN.exe。"
    exit 1
}

$shortcutPath = Join-Path $desktop "v2rayN.lnk"
$wshShell = New-Object -ComObject WScript.Shell
$shortcut = $wshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $v2rayExe.FullName
$shortcut.WorkingDirectory = Split-Path $v2rayExe.FullName
$shortcut.WindowStyle = 1
$shortcut.Description = "v2rayN 快捷方式"
$shortcut.Save()

Write-Host ""
Write-Host "✅ 安装完成！"
Write-Host ""
Write-Host "📍 桌面已创建 v2rayN 快捷方式。"
Write-Host ""
