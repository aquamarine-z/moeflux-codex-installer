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
    echo "백업했습니다: $backup"
  else
    echo "백업할 기존 파일이 없습니다: $file"
  fi
}

read_api_key() {
  if [[ -n "${CODEX_INSTALLER_API_KEY:-}" ]]; then
    printf '%s' "$CODEX_INSTALLER_API_KEY"
    return
  fi

  local key=""
  while [[ -z "$key" ]]; do
    read -r -s -p "API Key를 입력하세요: " key
    echo
    if [[ -z "$key" ]]; then
      echo "API Key는 비워 둘 수 없습니다. 다시 입력하세요."
    fi
  done
  printf '%s' "$key"
}

ask_backup() {
  case "${CODEX_INSTALLER_BACKUP:-}" in
    y|Y)
      echo "백업을 선택했습니다."
      return 0
      ;;
    n|N)
      echo "백업을 건너뛰었습니다."
      return 1
      ;;
  esac

  local selected="y"
  local key=""
  printf "기존 파일을 백업할까요? 기본값은 y입니다. Enter로 확인, 좌우 방향키로 전환합니다."
  while true; do
    if [[ "$selected" == "y" ]]; then
      printf "\r기존 파일을 백업할까요? 기본값은 y입니다. Enter로 확인, 좌우 방향키로 전환합니다.[Y] n "
    else
      printf "\r기존 파일을 백업할까요? 기본값은 y입니다. Enter로 확인, 좌우 방향키로 전환합니다.y [N] "
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
    echo "백업을 선택했습니다."
    return 0
  fi

  echo "백업을 건너뛰었습니다."
  return 1
}

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required to safely update auth.json."
  exit 1
fi

echo "Codex 릴레이 설치 관리자"
echo "이 스크립트는 Codex를 cch 릴레이 공급자로 설정합니다."
echo
echo "설정 파일: $CONFIG_FILE"
echo "인증 파일: $AUTH_FILE"
echo "백업 단계에서는 기본값 y가 선택됩니다. Enter로 백업하거나 n으로 전환할 수 있습니다."
echo
echo "1/4 단계: 실행 환경을 확인하는 중..."
mkdir -p "$CODEX_DIR"

echo "2/4 단계: API Key를 입력하세요. 입력 내용은 화면에 표시되지 않습니다."
API_KEY="$(read_api_key)"

echo
echo "3/4 단계: 백업 여부 선택..."
if ask_backup; then
  backup_file "$CONFIG_FILE"
  backup_file "$AUTH_FILE"
fi

echo
echo "4/4 단계: Codex 설정을 쓰는 중..."
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

echo "auth.json을 쓰는 중..."
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
echo "설치가 완료되었습니다."
echo "설정을 썼습니다: $CONFIG_FILE"
echo "인증 정보를 업데이트했습니다: $AUTH_FILE"
echo "다음 단계: Codex를 다시 시작하거나 터미널을 다시 열어 새 설정을 불러오세요."
