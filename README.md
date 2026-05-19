# Moeflux Codex Installer

Multilingual installer scripts for configuring Codex to use the `cch` relay provider.

`cch` relay endpoint:

```text
https://api.moeflux.com/v1
```

## Installer Files

| Language | Windows PowerShell | macOS/Linux |
| --- | --- | --- |
| English | `install-windows-en.ps1` | `install-macos-en.sh` |
| 中文 | `install-windows-zh.ps1` | `install-macos-zh.sh` |
| 日本語 | `install-windows-ja.ps1` | `install-macos-ja.sh` |
| 한국어 | `install-windows-ko.ps1` | `install-macos-ko.sh` |

## English

### What This Installer Does

The installer writes user-level Codex files:

- Windows: `%USERPROFILE%\.codex\config.toml`
- Windows: `%USERPROFILE%\.codex\auth.json`
- macOS/Linux: `~/.codex/config.toml`
- macOS/Linux: `~/.codex/auth.json`

It configures Codex to use:

```toml
model_provider = "cch"
model = "gpt-5.4"
base_url = "https://api.moeflux.com/v1"
```

It also asks for your API key and writes it to `auth.json`.

### Windows

Run PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\install-windows-en.ps1
```

Windows 10 and Windows 11 include Windows PowerShell by default.

### macOS/Linux

```bash
chmod +x ./install-macos-en.sh
./install-macos-en.sh
```

The shell script requires `python3`.

### Backup

Before writing files, the installer asks whether to back up existing files.

- Default is `y`.
- Press `Enter` to back up.
- Use left/right arrow keys to switch between `y` and `n`.
- You can also press `y` or `n` directly.

### Automation

```powershell
$env:CODEX_INSTALLER_API_KEY = "sk-..."
$env:CODEX_INSTALLER_BACKUP = "y"
$env:CODEX_INSTALLER_NO_PAUSE = "1"
.\install-windows-en.ps1
```

```bash
CODEX_INSTALLER_API_KEY="sk-..." CODEX_INSTALLER_BACKUP="y" ./install-macos-en.sh
```

## 中文

### 这个安装器会做什么

安装器会写入用户级 Codex 配置文件：

- Windows：`%USERPROFILE%\.codex\config.toml`
- Windows：`%USERPROFILE%\.codex\auth.json`
- macOS/Linux：`~/.codex/config.toml`
- macOS/Linux：`~/.codex/auth.json`

它会把 Codex 配置为使用：

```toml
model_provider = "cch"
model = "gpt-5.4"
base_url = "https://api.moeflux.com/v1"
```

安装时会询问 API Key，并写入 `auth.json`。

### Windows

在 PowerShell 里运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\install-windows-zh.ps1
```

Windows 10 和 Windows 11 默认自带 Windows PowerShell。

### macOS/Linux

```bash
chmod +x ./install-macos-zh.sh
./install-macos-zh.sh
```

Shell 脚本需要 `python3`。

### 备份

写入文件前，安装器会询问是否备份已有文件。

- 默认是 `y`。
- 直接按回车会备份。
- 可以用左右方向键在 `y` 和 `n` 之间切换。
- 也可以直接按 `y` 或 `n`。

### 自动化安装

```powershell
$env:CODEX_INSTALLER_API_KEY = "sk-..."
$env:CODEX_INSTALLER_BACKUP = "y"
$env:CODEX_INSTALLER_NO_PAUSE = "1"
.\install-windows-zh.ps1
```

```bash
CODEX_INSTALLER_API_KEY="sk-..." CODEX_INSTALLER_BACKUP="y" ./install-macos-zh.sh
```

## 日本語

### このインストーラーが行うこと

このインストーラーはユーザー単位の Codex 設定ファイルを書き込みます。

- Windows: `%USERPROFILE%\.codex\config.toml`
- Windows: `%USERPROFILE%\.codex\auth.json`
- macOS/Linux: `~/.codex/config.toml`
- macOS/Linux: `~/.codex/auth.json`

Codex は次の設定で `cch` リレープロバイダーを使うようになります。

```toml
model_provider = "cch"
model = "gpt-5.4"
base_url = "https://api.moeflux.com/v1"
```

実行時に API Key を入力し、`auth.json` に保存します。

### Windows

PowerShell で実行します。

```powershell
powershell -ExecutionPolicy Bypass -File .\install-windows-ja.ps1
```

Windows 10 と Windows 11 には Windows PowerShell が標準で含まれています。

### macOS/Linux

```bash
chmod +x ./install-macos-ja.sh
./install-macos-ja.sh
```

Shell スクリプトには `python3` が必要です。

### バックアップ

ファイルを書き込む前に、既存ファイルをバックアップするか確認します。

- 既定値は `y` です。
- `Enter` を押すとバックアップします。
- 左右矢印キーで `y` と `n` を切り替えられます。
- `y` または `n` を直接押すこともできます。

### 自動インストール

```powershell
$env:CODEX_INSTALLER_API_KEY = "sk-..."
$env:CODEX_INSTALLER_BACKUP = "y"
$env:CODEX_INSTALLER_NO_PAUSE = "1"
.\install-windows-ja.ps1
```

```bash
CODEX_INSTALLER_API_KEY="sk-..." CODEX_INSTALLER_BACKUP="y" ./install-macos-ja.sh
```

## 한국어

### 이 설치 관리자가 하는 일

이 설치 관리자는 사용자 단위 Codex 설정 파일을 작성합니다.

- Windows: `%USERPROFILE%\.codex\config.toml`
- Windows: `%USERPROFILE%\.codex\auth.json`
- macOS/Linux: `~/.codex/config.toml`
- macOS/Linux: `~/.codex/auth.json`

Codex가 다음 `cch` 릴레이 공급자를 사용하도록 설정합니다.

```toml
model_provider = "cch"
model = "gpt-5.4"
base_url = "https://api.moeflux.com/v1"
```

실행 중 API Key를 입력받아 `auth.json`에 저장합니다.

### Windows

PowerShell에서 실행합니다.

```powershell
powershell -ExecutionPolicy Bypass -File .\install-windows-ko.ps1
```

Windows 10과 Windows 11에는 Windows PowerShell이 기본 포함되어 있습니다.

### macOS/Linux

```bash
chmod +x ./install-macos-ko.sh
./install-macos-ko.sh
```

Shell 스크립트에는 `python3`가 필요합니다.

### 백업

파일을 쓰기 전에 기존 파일을 백업할지 확인합니다.

- 기본값은 `y`입니다.
- `Enter`를 누르면 백업합니다.
- 좌우 방향키로 `y`와 `n`을 전환할 수 있습니다.
- `y` 또는 `n`을 직접 눌러도 됩니다.

### 자동 설치

```powershell
$env:CODEX_INSTALLER_API_KEY = "sk-..."
$env:CODEX_INSTALLER_BACKUP = "y"
$env:CODEX_INSTALLER_NO_PAUSE = "1"
.\install-windows-ko.ps1
```

```bash
CODEX_INSTALLER_API_KEY="sk-..." CODEX_INSTALLER_BACKUP="y" ./install-macos-ko.sh
```

## Releases

GitHub Releases include a zip archive containing all installer scripts and this README.

Create a new release by pushing a version tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

The workflow creates:

```text
moeflux-codex-installer-v1.0.0.zip
```
