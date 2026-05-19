# Moeflux Codex Installer

Multilingual installer scripts for configuring Codex to use the `cch` relay provider at:

```text
https://api.moeflux.com/v1
```

The scripts write user-level Codex configuration and authentication files:

- Windows: `%USERPROFILE%\.codex\config.toml` and `%USERPROFILE%\.codex\auth.json`
- macOS/Linux: `~/.codex/config.toml` and `~/.codex/auth.json`

## Languages

| Language | Windows | macOS/Linux |
| --- | --- | --- |
| English | `install-windows-en.ps1` | `install-macos-en.sh` |
| Chinese | `install-windows-zh.ps1` | `install-macos-zh.sh` |
| Japanese | `install-windows-ja.ps1` | `install-macos-ja.sh` |
| Korean | `install-windows-ko.ps1` | `install-macos-ko.sh` |

## What It Configures

The installer writes this Codex provider configuration:

```toml
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
```

It also updates `auth.json` with:

```json
{
  "auth_mode": "api-key",
  "OPENAI_API_KEY": "your-api-key"
}
```

## Windows Usage

Run the script for your language in PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\install-windows-en.ps1
```

For Chinese:

```powershell
powershell -ExecutionPolicy Bypass -File .\install-windows-zh.ps1
```

Windows 10 and Windows 11 include Windows PowerShell by default. The localized Windows scripts avoid non-ASCII source text internally so they remain compatible with Windows PowerShell 5.1.

## macOS/Linux Usage

Run the script for your language:

```bash
chmod +x ./install-macos-en.sh
./install-macos-en.sh
```

For Chinese:

```bash
chmod +x ./install-macos-zh.sh
./install-macos-zh.sh
```

The shell scripts require `python3` to safely write `auth.json`.

## Backup Behavior

The installer asks whether to back up existing files before writing new ones.

- Default is `y`.
- Press `Enter` to back up.
- Use left/right arrow keys to switch between `y` and `n`.
- You can also press `y` or `n` directly.

Backup files are written next to the original files, for example:

```text
config.toml.bak-20260519-120000
auth.json.bak-20260519-120000
```

If a backup name already exists, the installer appends a number such as `-1` or `-2`.

## Automation

For scripted installs, set these environment variables:

| Variable | Purpose |
| --- | --- |
| `CODEX_INSTALLER_API_KEY` | Provides the API key without prompting. |
| `CODEX_INSTALLER_BACKUP` | Use `y` or `n` to choose backup behavior. |
| `CODEX_INSTALLER_NO_PAUSE` | Set to `1` to skip the final pause in Windows scripts. |

Windows example:

```powershell
$env:CODEX_INSTALLER_API_KEY = "sk-..."
$env:CODEX_INSTALLER_BACKUP = "y"
$env:CODEX_INSTALLER_NO_PAUSE = "1"
.\install-windows-en.ps1
```

macOS/Linux example:

```bash
CODEX_INSTALLER_API_KEY="sk-..." CODEX_INSTALLER_BACKUP="y" ./install-macos-en.sh
```

## Releases

GitHub Releases include a zip archive containing all installer scripts.

To create a release, push a version tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

The workflow will create `moeflux-codex-installer-v1.0.0.zip` and attach it to the release.
