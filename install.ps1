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

Write-Host "Downloading v2rayN..."
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZip -UseBasicParsing
} catch {
    Write-Host "❌ Failed to download v2rayN. Please check your network or proxy settings."
    exit 1
}

Write-Host "Extracting v2rayN to $installPath..."
if (!(Test-Path $installPath)) {
    New-Item -Path $installPath -ItemType Directory -Force | Out-Null
}
Expand-Archive -Path $tempZip -DestinationPath $installPath -Force

# 查找解压后 v2rayN.exe 的完整路径（考虑 zip 里包了一层文件夹）
$v2rayExe = Get-ChildItem -Path $installPath -Recurse -Filter "v2rayN.exe" -File | Select-Object -First 1

if (-not $v2rayExe) {
    Write-Host "❌ Cannot find v2rayN.exe in the extracted folder."
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

Write-Host @'
✅ 安装完成！

桌面已创建 v2rayN 快捷方式。
'@
