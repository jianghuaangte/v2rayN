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

# 检查是否管理员权限
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

# 修复版：创建桌面快捷方式（完全兼容）
function Create-Shortcut-Compat {
    param(
        [string]$TargetPath,
        [string]$ShortcutName,
        [switch]$AllUsers
    )
    
    try {
        # 获取桌面路径
        $desktop = if ($AllUsers) {
            [Environment]::GetFolderPath("CommonDesktopDirectory")
        } else {
            [Environment]::GetFolderPath("Desktop")
        }
        
        $linkPath = Join-Path $desktop "$ShortcutName.lnk"
        
        Write-Host "Creating shortcut on desktop..."
        
        # 方法1：标准 COM 对象（主要方法）
        try {
            $WshShell = New-Object -ComObject WScript.Shell
            if ($null -ne $WshShell) {
                $shortcut = $WshShell.CreateShortcut($linkPath)
                $shortcut.TargetPath = $TargetPath
                $shortcut.WorkingDirectory = Split-Path $TargetPath
                $shortcut.WindowStyle = 1
                $shortcut.Description = $ShortcutName
                $shortcut.Save()
                Write-Host "✓ Shortcut created successfully: $linkPath" -ForegroundColor Green
                return $true
            }
        }
        catch {
            Write-Host "COM method failed, trying alternative..." -ForegroundColor Yellow
        }
        
        # 方法2：使用 .url 文件（备用方法）
        try {
            $urlPath = Join-Path $desktop "$ShortcutName.url"
            $targetUrl = $TargetPath -replace '\\', '/'
            
            $urlContent = @"
[InternetShortcut]
URL=file:///$targetUrl
WorkingDirectory=$(Split-Path $TargetPath)
IconIndex=0
IconFile=$TargetPath
"@
            $urlContent | Out-File -FilePath $urlPath -Encoding ASCII
            Write-Host "✓ URL shortcut created: $urlPath" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Host "URL method also failed: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # 方法3：使用 VBScript 创建快捷方式
        try {
            $vbsFile = Join-Path $env:TEMP "CreateShortcut.vbs"
            $vbsContent = @"
Set WshShell = CreateObject("WScript.Shell")
strDesktop = WshShell.SpecialFolders("$(&{if($AllUsers){"AllUsersDesktop"}else{"Desktop"}})")
Set oShellLink = WshShell.CreateShortcut(strDesktop & "\$ShortcutName.lnk")
oShellLink.TargetPath = "$TargetPath"
oShellLink.WorkingDirectory = "$(Split-Path $TargetPath)"
oShellLink.WindowStyle = 1
oShellLink.Description = "$ShortcutName"
oShellLink.Save
"@
            $vbsContent | Out-File -FilePath $vbsFile -Encoding ASCII
            $process = Start-Process -FilePath "wscript.exe" -ArgumentList $vbsFile -Wait -PassThru -NoNewWindow
            if ($process.ExitCode -eq 0) {
                Remove-Item $vbsFile -Force
                Write-Host "✓ VBScript shortcut created" -ForegroundColor Green
                return $true
            }
        }
        catch {
            Write-Host "VBScript method failed: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # 方法4：使用 PowerShell 直接创建 .lnk 文件（最终备用）
        try {
            # 创建简单的 .lnk 文件内容（二进制格式简化版）
            $lnkHeader = @(
                0x4C, 0x00, 0x00, 0x00, 0x01, 0x14, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0xC0, 0x00, 0x00, 0x00,
                0x00, 0x00, 0x00, 0x46
            )
            
            # 将目标路径转换为字节数组
            $targetBytes = [System.Text.Encoding]::Unicode.GetBytes($TargetPath + "`0")
            $workingDirBytes = [System.Text.Encoding]::Unicode.GetBytes((Split-Path $TargetPath) + "`0")
            
            # 组合所有字节
            $allBytes = $lnkHeader + $targetBytes + $workingDirBytes
            
            # 写入文件
            [System.IO.File]::WriteAllBytes($linkPath, [byte[]]$allBytes)
            Write-Host "✓ Raw LNK file created" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Host "All shortcut methods failed." -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Shortcut creation error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# 使用修复版函数创建快捷方式
$shortcutResult = Create-Shortcut-Compat -TargetPath $v2rayExe.FullName -ShortcutName "v2rayN" -AllUsers:$AllUsers

if ($shortcutResult) {
    Write-Host @'
Done!

You can now launch v2rayN from the desktop shortcut.
'@
} else {
    Write-Host "Shortcut creation failed, but v2rayN is installed at: $($v2rayExe.FullName)" -ForegroundColor Yellow
}

# 可选：清理临时文件
try {
    if (Test-Path $zipFile) {
        Remove-Item $zipFile -Force
    }
} catch {
    # 忽略清理错误
}
