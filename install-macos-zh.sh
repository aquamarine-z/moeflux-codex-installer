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
    echo "已备份：$backup"
  else
    echo "没有旧文件需要备份：$file"
  fi
}

read_api_key() {
  if [[ -n "${CODEX_INSTALLER_API_KEY:-}" ]]; then
    printf '%s' "$CODEX_INSTALLER_API_KEY"
    return
  fi

  local key=""
  while [[ -z "$key" ]]; do
    read -r -s -p "请输入你的 API Key：" key
    echo
    if [[ -z "$key" ]]; then
      echo "API Key 不能为空。"
    fi
  done
  printf '%s' "$key"
}

ask_backup() {
  case "${CODEX_INSTALLER_BACKUP:-}" in
    y|Y)
      echo "已选择备份。"
      return 0
      ;;
    n|N)
      echo "已跳过备份。"
      return 1
      ;;
  esac

  local selected="y"
  local key=""
  printf "是否备份已有文件？默认 y；按回车确认，按左右方向键切换。"
  while true; do
    if [[ "$selected" == "y" ]]; then
      printf "\r是否备份已有文件？默认 y；按回车确认，按左右方向键切换。[Y] n "
    else
      printf "\r是否备份已有文件？默认 y；按回车确认，按左右方向键切换。y [N] "
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
    echo "已选择备份。"
    return 0
  fi

  echo "已跳过备份。"
  return 1
}

if ! command -v python3 >/dev/null 2>&1; then
  echo "需要安装 python3 才能安全更新 auth.json。"
  exit 1
fi

echo "Codex 中转站安装器"
echo "此脚本会把 Codex 配置为使用 cch 中转站。"
echo
echo "目标配置文件：$CONFIG_FILE"
echo "目标认证文件：$AUTH_FILE"
echo "到备份步骤时默认选择 y，回车确认备份，也可以切换到 n。"
echo
echo "步骤 1/4：检查运行环境..."
mkdir -p "$CODEX_DIR"

echo "步骤 2/4：请输入 API Key。输入时不会显示在屏幕上。"
API_KEY="$(read_api_key)"

echo
echo "步骤 3/4：选择是否备份..."
if ask_backup; then
  backup_file "$CONFIG_FILE"
  backup_file "$AUTH_FILE"
fi

echo
echo "步骤 4/4：写入 Codex 配置..."
cat > "$CONFIG_FILE" <<'EOF'
# 核心模型配置
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

echo "正在写入 auth.json..."
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

data["auth_mode"] = "apikey"
data["OPENAI_API_KEY"] = key
path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
PY

chmod 600 "$AUTH_FILE"

echo
echo "安装完成。"
echo "配置已写入：$CONFIG_FILE"
echo "密钥已更新：$AUTH_FILE"
echo "下一步：请重启 Codex 或重新打开终端，让新配置生效。"
