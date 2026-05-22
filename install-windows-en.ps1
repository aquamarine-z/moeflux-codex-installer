$ErrorActionPreference = "Stop"

$MsgPressEnter = "Press Enter to exit"
$MsgTitle = "Codex relay installer"
$MsgIntro = "This script will configure Codex to use the cch relay provider."
$MsgConfigTarget = "Target config file: "
$MsgAuthTarget = "Target auth file: "
$MsgBackupTiming = "At the backup step, default is y. Press Enter to back up, or switch to n."
$MsgStep1 = "Step 1/4: Checking runtime..."
$MsgStep2 = "Step 2/4: Enter your API key. Your input will not be shown on screen."
$MsgEnterKey = "Enter your API key"
$MsgEmptyKey = "API key cannot be empty. Please enter it again."
$MsgStep3 = "Step 3/4: Backup choice..."
$MsgAskBackup = "Back up existing files? Default: y. Press Enter to confirm, Left/Right to switch."
$MsgBackupSelected = "Backup selected."
$MsgBackupSkipped = "Backup skipped."
$MsgNoBackup = "No existing file to back up: "
$MsgBackedUp = "Backed up: "
$MsgStep4 = "Step 4/4: Writing Codex configuration..."
$MsgWriteAuth = "Writing auth.json..."
$MsgBadJson = "Existing auth.json is not valid JSON. A backup may be created and a new auth.json will be written."
$MsgDone = "Installation complete."
$MsgConfig = "Config written to: "
$MsgAuth = "Auth updated at: "
$MsgNext = "Next step: restart Codex or reopen your terminal so the new config is loaded."
$MsgFailed = "Installation failed:"

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
