param(
    [switch]$AllUsers
)

$installPath = "C:\Program Files"
$exeName = "v2rayN.exe"
$zipUrl = "https://gitcode.com/freedom3z/kexue/releases/download/v1.0/kexue.zip"
$zipFile = "$env:TEMP\v2rayN.zip"

Write-Host "Downloading v2rayN..."

try {
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile -UseBasicParsing
} catch {
    Write-Host "Failed to download v2rayN. Please check your internet connection."
    exit 1
}

Write-Host "Extracting to $installPath..."

if (!(Test-Path -Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath -Force | Out-Null
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

try {
    # 如果支持 UTF8 解压
    $encoding = [System.Text.Encoding]::UTF8
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $installPath, $encoding)
} catch {
    # 回退到兼容方式
    Write-Warning "UTF8 解压失败，尝试默认方式"
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $installPath)
}

Remove-Item $zipFile

# Create desktop shortcut
$shortcutPath = "$([Environment]::GetFolderPath("Desktop"))\v2rayN.lnk"
$exePath = Join-Path $installPath $exeName

if (Test-Path $exePath) {
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = $exePath
    $Shortcut.WorkingDirectory = $installPath
    $Shortcut.Description = "v2rayN"
    $Shortcut.Save()

    Write-Host @'
Done!

You can launch v2rayN from the desktop shortcut.
'@
} else {
    Write-Warning "v2rayN.exe 未找到，可能解压失败或路径不正确。"
}
