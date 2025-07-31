param(
    [switch]$AllUsers
)

$installInstructions = @'
Hey friend

This installer is only available for Windows.
Please manually install on other systems.
'@

if ($IsMacOS -or $IsLinux) {
    Write-Host $installInstructions
    exit
}

# 检查是否管理员权限（安装到 C:\Program Files 通常需要）
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator."
    exit
}

$zipUrl = "https://gitcode.com/freedom3z/kexue/releases/download/v1.0/kexue.zip"
$installDir = "C:\Program Files\kexue"
$zipFile = Join-Path $env:TEMP "kexue.zip"

Write-Host "Downloading package from $zipUrl..."

try {
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile -UseBasicParsing
} catch {
    Write-Host "Failed to download the package. Please check your internet connection."
    exit
}

# 解压
Write-Host "Extracting to $installDir..."
if (Test-Path $installDir) {
    Remove-Item -Recurse -Force $installDir
}
Expand-Archive -LiteralPath $zipFile -DestinationPath $installDir

# 查找 v2rayN.exe
Write-Host "Searching for v2rayN.exe..."
$v2rayExe = Get-ChildItem -Path $installDir -Filter "v2rayN.exe" -Recurse -File | Select-Object -First 1

if (-not $v2rayExe) {
    Write-Host "v2rayN.exe not found after extraction."
    exit
}

# 创建快捷方式到桌面
$WshShell = New-Object -ComObject WScript.Shell
$desktop = if ($AllUsers) {
    [Environment]::GetFolderPath("CommonDesktopDirectory")
} else {
    [Environment]::GetFolderPath("Desktop")
}
$linkPath = Join-Path $desktop "v2rayN.lnk"

Write-Host "Creating shortcut on desktop..."
$shortcut = $WshShell.CreateShortcut($linkPath)
$shortcut.TargetPath = $v2rayExe.FullName
$shortcut.WorkingDirectory = Split-Path $v2rayExe.FullName
$shortcut.WindowStyle = 1
$shortcut.Description = "v2rayN"
$shortcut.Save()

Write-Host @'
Done!

You can now launch v2rayN from the desktop shortcut.
'@
