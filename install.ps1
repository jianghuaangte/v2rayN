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
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $installPath, $true)

Remove-Item $zipFile

# Create desktop shortcut
$shortcutPath = "$([Environment]::GetFolderPath("Desktop"))\v2rayN.lnk"
$exePath = Join-Path $installPath $exeName

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
