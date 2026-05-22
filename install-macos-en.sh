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
    echo "Backed up: $backup"
  else
    echo "No existing file to back up: $file"
  fi
}

read_api_key() {
  if [[ -n "${CODEX_INSTALLER_API_KEY:-}" ]]; then
    printf '%s' "$CODEX_INSTALLER_API_KEY"
    return
  fi

  local key=""
  while [[ -z "$key" ]]; do
    read -r -s -p "Enter your API key: " key
    echo
    if [[ -z "$key" ]]; then
      echo "API key cannot be empty."
    fi
  done
  printf '%s' "$key"
}

ask_backup() {
  case "${CODEX_INSTALLER_BACKUP:-}" in
    y|Y)
      echo "Backup selected."
      return 0
      ;;
    n|N)
      echo "Backup skipped."
      return 1
      ;;
  esac

  local selected="y"
  local key=""
  printf "Back up existing files? Default: y. Press Enter to confirm, Left/Right to switch. "
  while true; do
    if [[ "$selected" == "y" ]]; then
      printf "\rBack up existing files? Default: y. Press Enter to confirm, Left/Right to switch. [Y] n "
    else
      printf "\rBack up existing files? Default: y. Press Enter to confirm, Left/Right to switch. y [N] "
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
    echo "Backup selected."
    return 0
  fi

  echo "Backup skipped."
  return 1
}

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required to safely update auth.json."
  exit 1
fi

echo "Codex relay installer"
echo "This script will configure Codex to use the cch relay provider."
echo
echo "Target config file: $CONFIG_FILE"
echo "Target auth file:   $AUTH_FILE"
echo "At the backup step, default is y. Press Enter to back up, or switch to n."
echo
echo "Step 1/4: Checking runtime..."
mkdir -p "$CODEX_DIR"

echo "Step 2/4: Enter your API key. Your input will not be shown on screen."
API_KEY="$(read_api_key)"

echo
echo "Step 3/4: Backup choice..."
if ask_backup; then
  backup_file "$CONFIG_FILE"
  backup_file "$AUTH_FILE"
fi

echo
echo "Step 4/4: Writing Codex configuration..."
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

echo "Writing auth.json..."
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
echo "Installation complete."
echo "Config written to: $CONFIG_FILE"
echo "Auth updated at:   $AUTH_FILE"
echo "Next step: restart Codex or reopen your terminal so the new config is loaded."
