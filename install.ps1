# 设置控制台输出编码为 UTF-8，防止中文乱码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# 设置变量
$downloadUrl = "https://hk.gh-proxy.com/github.com/2dust/v2rayN/releases/download/7.13.2/v2rayN-windows-64-SelfContained.zip"
$zipFile = "$env:TEMP\v2rayN.zip"
$installDir = "C:\Program Files\usr\local\bin"
$exeName = "v2rayN.exe"
$desktopShortcut = "$([Environment]::GetFolderPath("Desktop"))\v2rayN.lnk"

Write-Host "🚀 开始安装 v2rayN ..." -ForegroundColor Cyan

# 创建安装目录（如果不存在）
if (!(Test-Path -Path $installDir)) {
    Write-Host "📁 创建安装目录: $installDir"
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}

# 下载压缩包
Write-Host "🌐 正在下载 v2rayN..." -NoNewline
Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile
Write-Host " ✅"

# 解压 ZIP 到目标目录
Write-Host "📦 正在解压到: $installDir"
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $installDir)

# 删除 ZIP 文件
Remove-Item $zipFile

# 创建快捷方式
Write-Host "🔗 正在创建桌面快捷方式..."
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($desktopShortcut)
$Shortcut.TargetPath = Join-Path $installDir $exeName
$Shortcut.WorkingDirectory = $installDir
$Shortcut.WindowStyle = 1
$Shortcut.Description = "v2rayN 快捷方式"
$Shortcut.Save()

Write-Host "`n✅ v2rayN 安装完成，快捷方式已创建在桌面。" -ForegroundColor Green
