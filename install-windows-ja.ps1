$ErrorActionPreference = "Stop"

function L {
    param([string]$Base64)
    return [System.Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($Base64))
}

$MsgPressEnter = L "RQBuAHQAZQByACAArTD8MJIwvGJXMGYwQn2GTg=="
$MsgTitle = L "QwBvAGQAZQB4ACAA6jDsMPwwpDDzMLkwyDD8MOkw/DA="
$MsgIntro = L "UzBuMLkwrzDqMNcwyDBvMCAAQwBvAGQAZQB4ACAAkjAgAGMAYwBoACAA6jDsMPww1zDtMNAwpDDAMPwwEVRRMGswLYqaW1cwfjBZMAIw"
$MsgConfigTarget = L "LYqaW9UwoTCkMOswOgAgAA=="
$MsgAuthTarget = L "jYo8itUwoTCkMOswOgAgAA=="
$MsgBackupTiming = L "0DDDMK8wojDDMNcwS2IGmGcwbzDiZZpbZzAgAHkAIABMMHiQnmJVMIwwZjBEMH4wWTACMEUAbgB0AGUAcgAgAGcw0DDDMK8wojDDMNcwATBuACAAeDAHUoow/2ZIMIswUzBoMIIwZzBNMH4wWTACMA=="
$MsgStep1 = L "uTDGMMMw1zAgADEALwA0ADoAIACfW0yIsHSDWJIwuniNilcwZjBEMH4wWTAuAC4ALgA="
$MsgStep2 = L "uTDGMMMw1zAgADIALwA0ADoAIABBAFAASQAgAEsAZQB5ACAAkjBlUZtSVzBmME8wYDBVMEQwAjBlUZtShVG5W28wO3Vil2swaIg6eVUwjDB+MFswkzACMA=="
$MsgEnterKey = L "QQBQAEkAIABLAGUAeQAgAJIwZVGbUlcwZjBPMGAwVTBEMA=="
$MsgEmptyKey = L "QQBQAEkAIABLAGUAeQAgAG8wenprMGcwTTB+MFswkzACMIIwRjAATqZeZVGbUlcwZjBPMGAwVTBEMAIw"
$MsgStep3 = L "uTDGMMMw1zAgADMALwA0ADoAIADQMMMwrzCiMMMw1zBZMIswSzB4kJ5iLgAuAC4A"
$MsgAskBackup = L "4mVYW9UwoTCkMOswkjDQMMMwrzCiMMMw1zBXMH4wWTBLMB//4mWaW28wIAB5AAIwRQBuAHQAZQByACAAZzC6eJpbATDmXfNT4ndwU60w/DBnMAdSijD/ZkgwAjA="
$MsgBackupSelected = L "0DDDMK8wojDDMNcwkjB4kJ5iVzB+MFcwXzACMA=="
$MsgBackupSkipped = L "0DDDMK8wojDDMNcwkjC5MK0wwzDXMFcwfjBXMF8wAjA="
$MsgNoBackup = L "0DDDMK8wojDDMNcw/lthjG4w4mVYW9UwoTCkMOswbzBCMIowfjBbMJMwOgAgAA=="
$MsgBackedUp = L "0DDDMK8wojDDMNcwVzB+MFcwXzA6ACAA"
$MsgStep4 = L "uTDGMMMw1zAgADQALwA0ADoAIABDAG8AZABlAHgAIAAtippbkjD4Zk0wvI+TMGcwRDB+MFkwLgAuAC4A"
$MsgWriteAuth = L "YQB1AHQAaAAuAGoAcwBvAG4AIACSMPhmTTC8j5MwZzBEMH4wWTAuAC4ALgA="
$MsgBadJson = L "4mVYW24wIABhAHUAdABoAC4AagBzAG8AbgAgAG8wCWe5UmowIABKAFMATwBOACAAZzBvMEIwijB+MFswkzACMORTRDDVMKEwpDDrMG8wxV+BiWsw3F9YMGYw0DDDMK8wojDDMNcwVTCMMAEwsGVXMEQwIABhAHUAdABoAC4AagBzAG8AbgAgAJIw+GZNMLyPfzB+MFkwAjA="
$MsgDone = L "pDDzMLkwyDD8MOswTDCMW4ZOVzB+MFcwXzACMA=="
$MsgConfig = L "LYqaW5Iw+GZNMLyPfzB+MFcwXzA6ACAA"
$MsgAuth = L "jYo8isVgMViSMPRmsGVXMH4wVzBfMDoAIAA="
$MsgNext = L "IWtuMEtiBpg6ACAAQwBvAGQAZQB4ACAAkjCNUXeN1VJZMIswSzABML8w/DDfMMow6zCSMIuVTTD0dlcwZjCwZVcwRDAtippbkjCtin8wvI+TMGcwTzBgMFUwRDACMA=="
$MsgFailed = L "pDDzMLkwyDD8MOswazAxWVdlVzB+MFcwXzA6AA=="

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

