#!/usr/bin/env bash
set -Eeuo pipefail

# ============================================================================
# 환경 변수 설명
#
# [Wrapper 전용 변수] OpenCode 자체는 이 변수들을 직접 읽지 않습니다.
#   COMPANY_OPENCODE_ROOT
#       회사가 공용으로 관리하는 읽기 전용 release의 루트 경로입니다.
#       기본값: /opt/company-opencode/current
#   PERSONAL_OPENCODE_CONFIG_HOME
#       개인 XDG config 기준 경로입니다.
#       실제 설정 파일: <값>/opencode/opencode.jsonc
#       기본값: ~/.config/opencode-personal
#   PERSONAL_OPENCODE_DATA_HOME
#       인증 정보, 세션 등 사용자별 영구 데이터의 기준 경로입니다.
#       기본값: ~/.local/share/opencode-personal
#   PERSONAL_OPENCODE_STATE_HOME
#       background service 등 사용자별 실행 상태의 기준 경로입니다.
#       기본값: ~/.local/state/opencode-personal
#   PERSONAL_OPENCODE_CACHE_HOME
#       model/plugin/tool cache처럼 삭제 후 재생성 가능한 데이터의 경로입니다.
#       기본값: ~/.cache/opencode-personal
#
# [OpenCode와 OMO가 읽는 표준 XDG 변수]
#   XDG_CONFIG_HOME
#       사용자별 config 기준 경로를 대체합니다.
#       OpenCode 설정: $XDG_CONFIG_HOME/opencode/opencode.jsonc
#   XDG_DATA_HOME
#       사용자별 영구 데이터 경로를 대체합니다.
#       인증 정보와 세션이 저장되므로 쓰기 가능해야 합니다.
#   XDG_STATE_HOME
#       service/runtime 상태를 저장하는 사용자별 경로를 대체합니다.
#   XDG_CACHE_HOME
#       사용자별 cache 경로를 대체합니다.
#       삭제 후 다시 생성해도 되므로 임시 저장소를 사용할 수 있습니다.
#
# [아래에서 제거하는 OpenCode 변수]
#   OPENCODE_CONFIG
#       추가 config 파일 경로입니다. 그대로 두면 개인 설정을 덮어쓸 수 있습니다.
#   OPENCODE_CONFIG_CONTENT
#       로드된 config에 병합되는 인라인 JSON 설정입니다.
#   OPENCODE_CONFIG_DIR
#       agent, command, plugin을 찾는 추가 config 디렉터리입니다.
#   OPENCODE_PERMISSION
#       permission을 덮어쓰는 인라인 JSON 설정입니다.
#
# [OMO 변수]
#   OMO_DISABLE_POSTHOG
#       OMO의 PostHog telemetry를 끄는 legacy 호환 변수입니다.
#   OMO_SEND_ANONYMOUS_TELEMETRY
#       0/false/no로 설정하면 OMO의 익명 telemetry를 끕니다.
# ============================================================================

# 사용자별 개인 LLM 프로필로 실행합니다.
# 공용 OpenCode/OMO 설치본은 수정하지 않습니다.

# Wrapper-only: 공용 read-only release의 루트
ROOT="${COMPANY_OPENCODE_ROOT:-/opt/company-opencode/current}"
BINARY="$ROOT/runtime/bin/opencode"
OMO_PACKAGE="$ROOT/runtime/node_modules/oh-my-openagent"

# Wrapper-only: 개인 config/data/state/cache의 기준 경로
CONFIG_ROOT="${PERSONAL_OPENCODE_CONFIG_HOME:-$HOME/.config/opencode-personal}"
CONFIG_FILE="$CONFIG_ROOT/opencode/opencode.jsonc"

DATA_ROOT="${PERSONAL_OPENCODE_DATA_HOME:-$HOME/.local/share/opencode-personal}"
STATE_ROOT="${PERSONAL_OPENCODE_STATE_HOME:-$HOME/.local/state/opencode-personal}"
CACHE_ROOT="${PERSONAL_OPENCODE_CACHE_HOME:-$HOME/.cache/opencode-personal}"

if [[ ! -x "$BINARY" ]]; then
  echo "OpenCode 실행파일을 찾지 못했거나 실행할 수 없습니다: $BINARY" >&2
  exit 69
fi

if [[ ! -d "$OMO_PACKAGE" ]]; then
  echo "공용 OMO 패키지를 찾지 못했습니다: $OMO_PACKAGE" >&2
  echo "COMPANY_OPENCODE_ROOT 또는 공용 release 디렉터리 구성을 확인하세요." >&2
  exit 69
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "개인 OpenCode 설정 파일을 찾지 못했습니다: $CONFIG_FILE" >&2
  echo "examples/v1-personal-opencode/config/opencode.jsonc를 해당 경로에 복사한 뒤 placeholder를 수정하세요." >&2
  exit 78
fi

install -d -m 700 \
  "$CONFIG_ROOT/opencode" \
  "$DATA_ROOT" \
  "$STATE_ROOT" \
  "$CACHE_ROOT"

# OpenCode/OMO가 실제로 읽는 표준 XDG 경로로 변환합니다.
export COMPANY_OPENCODE_ROOT="$ROOT"
export XDG_CONFIG_HOME="$CONFIG_ROOT"
export XDG_DATA_HOME="$DATA_ROOT"
export XDG_STATE_HOME="$STATE_ROOT"
export XDG_CACHE_HOME="$CACHE_ROOT"

# 다른 profile의 config/permission override가 섞이지 않도록 제거합니다.
unset OPENCODE_CONFIG OPENCODE_CONFIG_CONTENT OPENCODE_CONFIG_DIR OPENCODE_PERMISSION

# 공용 helper 실행 파일을 먼저 찾도록 PATH 앞에 추가합니다.
export PATH="$ROOT/runtime/bin:$ROOT/runtime/node_modules/.bin:$PATH"

# OMO 사용자 config(~/.omo/omo.jsonc)는 HOME 기반이라 HOME은 변경하지 않습니다.
# 두 변수를 함께 설정해 OMO telemetry 비활성화를 명시합니다.
export OMO_DISABLE_POSTHOG=1
export OMO_SEND_ANONYMOUS_TELEMETRY=0

exec "$BINARY" "$@"
