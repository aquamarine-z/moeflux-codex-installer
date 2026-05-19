$ErrorActionPreference = "Stop"

function L {
    param([string]$Base64)
    return [System.Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($Base64))
}

$MsgPressEnter = L "RQBuAHQAZQByACAApNB8uSAADLLstyAAhcjMuA=="
$MsgTitle = L "QwBvAGQAZQB4ACAAtLkIuHTHIAAkwVjOIAAAray5kMc="
$MsgIntro = L "dMcgAKTCbNC9ubjSlLIgAEMAbwBkAGUAeAB8uSAAYwBjAGgAIAC0uQi4dMcgAPWsCa6Qx1y4IAAkwRXIadXIsuSyLgA="
$MsgConfigTarget = L "JMEVyCAADNN8xzoAIAA="
$MsgAuthTarget = L "eMedySAADNN8xzoAIAA="
$MsgBackupTiming = L "MbzFxSAA6LLErNDFHMGUsiAAMK74vBKsIAB5AACsIAAgwd3QKbTIsuSyLgAgAEUAbgB0AGUAcgBcuCAAMbzFxVjVcKyYsCAAbgA8x1y4IAAEyFjWYNUgABjCIACIx7XCyLLksi4A"
$MsgStep1 = L "MQAvADQAIADossSsOgAgAOTCidUgAFjWvaxExyAAVdZ4x1jVlLIgABHJLgAuAC4A"
$MsgStep2 = L "MgAvADQAIADossSsOgAgAEEAUABJACAASwBlAHkAfLkgAIXHJbhY1TjBlMYuACAAhccluCAAtLCpxkDHIABU1nS60MUgAFzU3MIYtMDJIABKxbXCyLLksi4A"
$MsgEnterKey = L "QQBQAEkAIABLAGUAeQB8uSAAhccluFjVOMGUxg=="
$MsgEmptyKey = L "QQBQAEkAIABLAGUAeQCUsiAARL7MxiAAWLQgABjCIADGxbXCyLLksi4AIADkstzCIACFxyW4WNU4wZTGLgA="
$MsgStep3 = L "MwAvADQAIADossSsOgAgADG8xcUgAOzFgL0gACDB3dAuAC4ALgA="
$MsgAskBackup = L "MK50yCAADNN8x0THIAAxvMXFYNVMrpTGPwAgADCu+LwSrEDHIAB5AIXHyLLksi4AIABFAG4AdABlAHIAXLggAFXWeMcsACAAjMiwxiAAKbyl1aTQXLggAATIWNZp1ciy5LIuAA=="
$MsgBackupSelected = L "MbzFxUTHIAAgwd3QiNW1wsiy5LIuAA=="
$MsgBackupSkipped = L "MbzFxUTHIAB0rAix8LbIxbXCyLLksi4A"
$MsgNoBackup = L "MbzFxWDVIAAwrnTIIAAM03zHdMcgAMbFtcLIsuSyOgAgAA=="
$MsgBackedUp = L "MbzFxYjVtcLIsuSyOgAgAA=="
$MsgStep4 = L "NAAvADQAIADossSsOgAgAEMAbwBkAGUAeAAgACTBFchExyAA8MSUsiAAEckuAC4ALgA="
$MsgWriteAuth = L "YQB1AHQAaAAuAGoAcwBvAG4ARMcgAPDElLIgABHJLgAuAC4A"
$MsgBadJson = L "MK50yCAAYQB1AHQAaAAuAGoAcwBvAG4AdMcgACDHqNZc1SAASgBTAE8ATgB0xyAARMXZssiy5LIuACAAdMcEyCAADNN8x0DHIABE1ZTGWNV0uiAAMbzFxRi04KwgAMjAIABhAHUAdABoAC4AagBzAG8AbgBExyAAAcXIsuSyLgA="
$MsgDone = L "JMFYzgCsIABExsy4GLTIxbXCyLLksi4A"
$MsgConfig = L "JMEVyETHIAB8w7XCyLLksjoAIAA="
$MsgAuth = L "eMedySAAFcj0vHy5IADFxXCzdMe40ojVtcLIsuSyOgAgAA=="
$MsgNext = L "5LJMxyAA6LLErDoAIABDAG8AZABlAHgAfLkgAOSy3MIgANzCkcdY1XCsmLAgADDR+LsQsUTHIADkstzCIAD0xbTFIADIwCAAJMEVyETHIACIvey3JMY4wZTGLgA="
$MsgFailed = L "JMFYztDFIADkwijTiNW1wsiy5LI6AA=="

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
    $Auth["auth_mode"] = "api-key"
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

