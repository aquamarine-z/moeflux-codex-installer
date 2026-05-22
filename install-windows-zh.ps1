$ErrorActionPreference = "Stop"

function Zh {
    param([string]$Base64)
    return [System.Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($Base64))
}

$MsgPressEnter = Zh "CWPeVmaPLpUAkPpR"
$MsgTitle = Zh "QwBvAGQAZQB4ACAALU5sj9l6iVvFiGhW"
$MsgIntro = Zh "ZGsagSxnGk+KYiAAQwBvAGQAZQB4ACAATZFufzpOf08odSAAYwBjAGgAIAAtTmyP2XoCMA=="
$MsgConfigTarget = Zh "7nYHaE2Rbn+HZfZOGv8="
$MsgAuthTarget = Zh "7nYHaKSLwYuHZfZOGv8="
$MsgBackupTiming = Zh "MFIHWf1OZWukmvZl2J6kiwmQ6WIgAHkADP/eVmaPbnikiwdZ/U4M/19O71PlTgdSYmMwUiAAbgACMA=="
$MsgStep1 = Zh "ZWukmiAAMQAvADQAGv/AaOVn0I9MiK9zg1guAC4ALgA="
$MsgStep2 = Zh "ZWukmiAAMgAvADQAGv/3i5OPZVEgAEEAUABJACAASwBlAHkAAjCTj2VR9mUNThpPPmY6eShXT1xVXgpOAjA="
$MsgEnterKey = Zh "94uTj2VRYE+EdiAAQQBQAEkAIABLAGUAeQA="
$MsgEmptyKey = Zh "QQBQAEkAIABLAGUAeQAgAA1O/YA6Tnp6DP/3i82RsGWTj2VRAjA="
$MsgStep3 = Zh "ZWukmiAAMwAvADQAGv8JkOliL2YmVAdZ/U4uAC4ALgA="
$MsgAskBackup = Zh "L2YmVAdZ/U7yXQlnh2X2Th//2J6kiyAAeQAb/wlj3lZmj254pIsM/wlj5l3zU7llEVQulQdSYmMCMA=="
$MsgBackupSelected = Zh "8l0JkOliB1n9TgIw"
$MsgBackupSkipped = Zh "8l3zjcePB1n9TgIw"
$MsgNoBackup = Zh "oWwJZ+dlh2X2TgCXgYkHWf1OGv8="
$MsgBackedUp = Zh "8l0HWf1OGv8="
$MsgStep4 = Zh "ZWukmiAANAAvADQAGv+ZUWVRIABDAG8AZABlAHgAIABNkW5/LgAuAC4A"
$MsgWriteAuth = Zh "Y2soV5lRZVEgAGEAdQB0AGgALgBqAHMAbwBuAC4ALgAuAA=="
$MsgBadJson = Zh "8l0JZyAAYQB1AHQAaAAuAGoAcwBvAG4AIAANTi9mCWdIZSAASgBTAE8ATgACMBqBLGfyXc9+SFEHWf1O52WHZfZODP92XhpPmVFlUbBlhHYgAGEAdQB0AGgALgBqAHMAbwBuAAIw"
$MsgDone = Zh "iVvFiIxbEGICMA=="
$MsgConfig = Zh "TZFuf/JdmVFlURr/"
$MsgAuth = Zh "xlullPJd9GawZRr/"
$MsgNext = Zh "C04ATmVrGv/3i82RL1QgAEMAbwBkAGUAeAAgABZizZGwZVNiAF/Ifu96DP+pi7BlTZFufx91SGUCMA=="
$MsgFailed = Zh "iVvFiDFZJY0a/w=="

function Pause-BeforeExit {
    if ($env:CODEX_INSTALLER_NO_PAUSE -eq "1") { return }
    Write-Host ""
    Read-Host $MsgPressEnter
}

function Backup-File {
    param([string]$Path)
    if (Test-Path -LiteralPath $Path) {
        $BackupPath = "$Path.bak-$Timestamp"
        $Index = 1
        while (Test-Path -LiteralPath $BackupPath) {
            $BackupPath = "$Path.bak-$Timestamp-$Index"
            $Index++
        }
        Copy-Item -LiteralPath $Path -Destination $BackupPath -Force
        Write-Host "$MsgBackedUp$BackupPath"
    }
    else {
        Write-Host "$MsgNoBackup$Path"
    }
}

function Read-ApiKey {
    if (-not [string]::IsNullOrWhiteSpace($env:CODEX_INSTALLER_API_KEY)) { return $env:CODEX_INSTALLER_API_KEY }
    while ($true) {
        $SecureKey = Read-Host $MsgEnterKey -AsSecureString
        $Ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureKey)
        try { $Key = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($Ptr) }
        finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($Ptr) }
        if ([string]::IsNullOrWhiteSpace($Key)) {
            Write-Host $MsgEmptyKey
            continue
        }
        return $Key
    }
}

function Ask-Backup {
    if ($env:CODEX_INSTALLER_BACKUP) {
        if ($env:CODEX_INSTALLER_BACKUP.ToLowerInvariant().StartsWith("n")) {
            Write-Host $MsgBackupSkipped
            return $false
        }
        Write-Host $MsgBackupSelected
        return $true
    }
    if ([Console]::IsInputRedirected) {
        $Answer = Read-Host $MsgAskBackup
        if ($Answer -and $Answer.ToLowerInvariant().StartsWith("n")) {
            Write-Host $MsgBackupSkipped
            return $false
        }
        Write-Host $MsgBackupSelected
        return $true
    }
    $Selected = $true
    Write-Host $MsgAskBackup
    while ($true) {
        if ($Selected) { Write-Host -NoNewline "`r[Y] n " } else { Write-Host -NoNewline "`ry [N] " }
        $Key = [Console]::ReadKey($true)
        switch ($Key.Key) {
            "Enter" {
                Write-Host ""
                if ($Selected) { Write-Host $MsgBackupSelected; return $true }
                Write-Host $MsgBackupSkipped
                return $false
            }
            "LeftArrow" { $Selected = -not $Selected }
            "RightArrow" { $Selected = -not $Selected }
            "Y" { Write-Host ""; Write-Host $MsgBackupSelected; return $true }
            "N" { Write-Host ""; Write-Host $MsgBackupSkipped; return $false }
        }
    }
}

try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $CodexDir = Join-Path $env:USERPROFILE ".codex"
    $ConfigFile = Join-Path $CodexDir "config.toml"
    $AuthFile = Join-Path $CodexDir "auth.json"
    $Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

    Write-Host $MsgTitle
    Write-Host $MsgIntro
    Write-Host ""
    Write-Host "$MsgConfigTarget$ConfigFile"
    Write-Host "$MsgAuthTarget$AuthFile"
    Write-Host $MsgBackupTiming
    Write-Host ""
    Write-Host $MsgStep1
    Write-Host $MsgStep2
    $ApiKey = Read-ApiKey

    New-Item -ItemType Directory -Path $CodexDir -Force | Out-Null
    Write-Host ""
    Write-Host $MsgStep3
    if (Ask-Backup) {
        Backup-File -Path $ConfigFile
        Backup-File -Path $AuthFile
    }

    Write-Host ""
    Write-Host $MsgStep4
@'
# Core model configuration
model_provider = "cch"
model = "gpt-5.4"
model_reasoning_effort = "medium"
disable_response_storage = true
approval_policy = "never"
sandbox_mode = "workspace-write"
personality = "pragmatic"
web_search = "live"
suppress_unstable_features_warning = true

plan_tool = true
apply_patch_freeform = true
view_image_tool = true
unified_exec = false
streamable_shell = false
rmcp_client = true

[model_providers.cch]
name = "cch"
base_url = "https://api.moeflux.com/v1"
wire_api = "responses"
requires_openai_auth = true

[sandbox_workspace_write]
network_access = true
'@ | Set-Content -LiteralPath $ConfigFile -Encoding UTF8

    Write-Host $MsgWriteAuth
    $Auth = [ordered]@{}
    if (Test-Path -LiteralPath $AuthFile) {
        try {
            $ExistingAuthText = [System.IO.File]::ReadAllText($AuthFile, [System.Text.Encoding]::UTF8)
            $ExistingAuth = $ExistingAuthText | ConvertFrom-Json
            foreach ($Property in $ExistingAuth.PSObject.Properties) { $Auth[$Property.Name] = $Property.Value }
        }
        catch {
            Write-Host $MsgBadJson
            $Auth = [ordered]@{}
        }
    }
    $Auth["auth_mode"] = "apikey"
    $Auth["OPENAI_API_KEY"] = $ApiKey
    $Auth | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $AuthFile -Encoding UTF8

    Write-Host ""
    Write-Host $MsgDone
    Write-Host "$MsgConfig$ConfigFile"
    Write-Host "$MsgAuth$AuthFile"
    Write-Host $MsgNext
}
catch {
    Write-Host ""
    Write-Host $MsgFailed
    Write-Host $_.Exception.Message
    exit 1
}
finally {
    Pause-BeforeExit
}

