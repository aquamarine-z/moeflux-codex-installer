#!/usr/bin/env bash
set -euo pipefail

CODEX_DIR="${HOME}/.codex"
CONFIG_FILE="${CODEX_DIR}/config.toml"
AUTH_FILE="${CODEX_DIR}/auth.json"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

backup_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    local backup="${file}.bak-${TIMESTAMP}"
    local index=1
    while [[ -e "$backup" ]]; do
      backup="${file}.bak-${TIMESTAMP}-${index}"
      index=$((index + 1))
    done
    cp "$file" "$backup"
    echo "バックアップしました: $backup"
  else
    echo "バックアップ対象の既存ファイルはありません: $file"
  fi
}

read_api_key() {
  if [[ -n "${CODEX_INSTALLER_API_KEY:-}" ]]; then
    printf '%s' "$CODEX_INSTALLER_API_KEY"
    return
  fi

  local key=""
  while [[ -z "$key" ]]; do
    read -r -s -p "API Key を入力してください: " key
    echo
    if [[ -z "$key" ]]; then
      echo "API Key は空にできません。もう一度入力してください。"
    fi
  done
  printf '%s' "$key"
}

ask_backup() {
  case "${CODEX_INSTALLER_BACKUP:-}" in
    y|Y)
      echo "バックアップを選択しました。"
      return 0
      ;;
    n|N)
      echo "バックアップをスキップしました。"
      return 1
      ;;
  esac

  local selected="y"
  local key=""
  printf "既存ファイルをバックアップしますか？既定は y。Enter で確定、左右矢印キーで切り替え。"
  while true; do
    if [[ "$selected" == "y" ]]; then
      printf "\r既存ファイルをバックアップしますか？既定は y。Enter で確定、左右矢印キーで切り替え。[Y] n "
    else
      printf "\r既存ファイルをバックアップしますか？既定は y。Enter で確定、左右矢印キーで切り替え。y [N] "
    fi

    IFS= read -rsn1 key || key=""
    if [[ -z "$key" ]]; then
      echo
      break
    fi

    case "$key" in
      y|Y)
        selected="y"
        echo
        break
        ;;
      n|N)
        selected="n"
        echo
        break
        ;;
      $'\x1b')
        IFS= read -rsn2 key || key=""
        case "$key" in
          "[C"|"[D")
            [[ "$selected" == "y" ]] && selected="n" || selected="y"
            ;;
        esac
        ;;
    esac
  done

  if [[ "$selected" == "y" ]]; then
    echo "バックアップを選択しました。"
    return 0
  fi

  echo "バックアップをスキップしました。"
  return 1
}

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required to safely update auth.json."
  exit 1
fi

echo "Codex リレーインストーラー"
echo "このスクリプトは Codex を cch リレープロバイダー向けに設定します。"
echo
echo "設定ファイル: $CONFIG_FILE"
echo "認証ファイル: $AUTH_FILE"
echo "バックアップ手順では既定で y が選択されています。Enter でバックアップ、n へ切り替えることもできます。"
echo
echo "ステップ 1/4: 実行環境を確認しています..."
mkdir -p "$CODEX_DIR"

echo "ステップ 2/4: API Key を入力してください。入力内容は画面に表示されません。"
API_KEY="$(read_api_key)"

echo
echo "ステップ 3/4: バックアップするか選択..."
if ask_backup; then
  backup_file "$CONFIG_FILE"
  backup_file "$AUTH_FILE"
fi

echo
echo "ステップ 4/4: Codex 設定を書き込んでいます..."
cat > "$CONFIG_FILE" <<'EOF'
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
EOF

echo "auth.json を書き込んでいます..."
AUTH_FILE="$AUTH_FILE" API_KEY="$API_KEY" python3 <<'PY'
import json
import os
from pathlib import Path

path = Path(os.environ["AUTH_FILE"])
key = os.environ["API_KEY"]

data = {}
if path.exists():
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        data = {}

data["auth_mode"] = "api-key"
data["OPENAI_API_KEY"] = key
path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
PY

chmod 600 "$AUTH_FILE"

echo
echo "インストールが完了しました。"
echo "設定を書き込みました: $CONFIG_FILE"
echo "認証情報を更新しました: $AUTH_FILE"
echo "次の手順: Codex を再起動するか、ターミナルを開き直して新しい設定を読み込んでください。"
