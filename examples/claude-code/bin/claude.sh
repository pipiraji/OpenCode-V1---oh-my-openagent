#!/usr/bin/env bash
set -Eeuo pipefail

# ============================================================================
# 포터블 Claude Code 런처 (폐쇄망 · 내부 LLM 전용, A안)
#
# 모델마다 서버/토큰이 다른 환경을 전제로, Claude Code는 LiteLLM 라우터 한 곳에만
# 연결합니다. 모델별 api_base/api_key는 라우터(litellm/config.yaml)가 처리하고,
# Claude Code는 model_name(모델 ID)으로 라우팅합니다.
#
# ⚠ 라우터 주소·토큰 등 접속 정보는 난수 placeholder 입니다. 회사(폐쇄망)에서 실제 값으로 교체하세요.
#   모델명(model_name)과 별칭 매핑은 실제 오픈소스 모델명을 그대로 사용합니다.
#
# [홈 격리 — 실행 계정의 홈디렉토리를 절대 수정하지 않음]
#   HOME 을 /tmp 샌드박스로 두고, 진짜 홈의 dotfile 은 '링크'만 한다(읽기).
#   쓰기가 잦은 캐시/설정 dir(.cache/.config/.local/.claude/.npm)은 제외 → 홈 쓰기 0.
#   HOME 자체가 /tmp 이므로 XDG_* 등 별도 리다이렉트 env 는 불필요.
#
# [Wrapper 전용 변수]
#   COMPANY_CLAUDE_ROOT   설치 루트 (기본: 이 스크립트의 디렉터리)
#   CLAUDE_CONFIG_DIR     런타임 config (기본: /tmp/claude_$USER/claude_config, 휘발)
#   CLAUDE_SANDBOX_HOME   샌드박스 HOME (기본: /tmp/claude_$USER/home)
#   CLAUDE_ROUTER_URL     LiteLLM 라우터 주소 (기본: http://10.29.248.6:4000)
#   CLAUDE_ROUTER_TOKEN   라우터 키 = LiteLLM master_key (기본: sk-router-16a59d11fb4d7a21)
#   CLAUDE_MODEL          기본 모델 = 라우터 model_name (기본: gemma4)
#   CLAUDE_AGENTS_DIR     공유 스킬/룰 소스 (기본: $REAL_HOME/.agents)
#   CLAUDE_MCP_SRC        MCP 설정 소스 (기본: $HERE/mcp.json = 설치 디렉토리)
#
# 배포물과 런타임(둘 다 매 실행 시 신규 생성, /tmp 휘발):
#   $HOME(샌드박스)             진짜 홈 dotfile 링크(.cache/.config/.local/.claude/.npm 제외)
#   $CONFIG_DIR/settings.json   모델 피커(modelPicker)
#   $CONFIG_DIR/mcp.json        MCP 서버 = $CLAUDE_MCP_SRC 복사본 → --mcp-config 로 읽힘
#   $CONFIG_DIR/{skills,rules}  $AGENTS_DIR(공유) + $HERE/{skills,rules}(설치디렉토리) 링크
#
# [Claude Code가 읽는 표준 변수]
#   CLAUDE_CONFIG_DIR
#   ANTHROPIC_BASE_URL / ANTHROPIC_AUTH_TOKEN / ANTHROPIC_MODEL
#   ANTHROPIC_DEFAULT_{SONNET,OPUS,HAIKU,FABLE}_MODEL / CLAUDE_CODE_SUBAGENT_MODEL
#   DISABLE_UPDATES / DISABLE_AUTOUPDATER / CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
#   (그 외 폐쇄망 차단 변수 전체는 아래 '폐쇄망(외부 인터넷 불가) 차단' 블록 참조)
# ============================================================================

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${COMPANY_CLAUDE_ROOT:-$HERE}"
BINARY="$ROOT/claude-code/bin/claude.exe"

USER="${USER:-$(id -un)}"
RUNTIME="/tmp/claude_$USER"

# 진짜 홈은 HOME 을 덮기 전에 확보 (HOME 을 /tmp 샌드박스로 바꾸므로)
REAL_HOME="$(getent passwd "$USER" 2>/dev/null | cut -d: -f6 || true)"
[[ -n "$REAL_HOME" ]] || REAL_HOME="$HOME"

CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$RUNTIME/claude_config}"
SANDBOX_HOME="${CLAUDE_SANDBOX_HOME:-$RUNTIME/home}"
ROUTER_URL="${CLAUDE_ROUTER_URL:-http://10.29.248.6:4000}"
ROUTER_TOKEN="${CLAUDE_ROUTER_TOKEN:-sk-router-16a59d11fb4d7a21}"
MODEL="${CLAUDE_MODEL:-gemma4}"
AGENTS_DIR="${CLAUDE_AGENTS_DIR:-$REAL_HOME/.agents}"

if [[ ! -x "$BINARY" ]]; then
  echo "Claude Code 실행파일을 찾지 못했거나 실행할 수 없습니다: $BINARY" >&2
  echo "COMPANY_CLAUDE_ROOT 또는 claude_install 구성을 확인하세요." >&2
  exit 69
fi

# --- 홈 격리: HOME 을 /tmp 샌드박스로, 진짜 홈 dotfile 은 '링크'만 (홈 쓰기 0) ---
if [[ "$SANDBOX_HOME" == "$REAL_HOME" || "$SANDBOX_HOME" == "/" ]]; then
  echo "샌드박스 HOME 설정이 위험합니다(진짜 홈과 동일/루트): $SANDBOX_HOME" >&2
  exit 70
fi
install -d -m 700 "$RUNTIME"
rm -rf "$SANDBOX_HOME"
install -d -m 700 "$SANDBOX_HOME"
shopt -s dotglob nullglob
for src in "$REAL_HOME"/.*; do
  name="${src##*/}"
  case "$name" in .|..|.cache|.config|.local|.claude|.npm) continue;; esac  # 쓰기 잦은 캐시/설정 dir 제외
  [[ -e "$src" ]] || continue
  ln -sfn "$src" "$SANDBOX_HOME/$name"
done
shopt -u dotglob nullglob
export HOME="$SANDBOX_HOME"

install -d -m 700 "$CONFIG_DIR"

# 공유 스킬/룰: $AGENTS_DIR(공유) + $HERE/{skills,rules}(설치 디렉토리, 예: graphify) 병합 링크
for d in skills rules; do
  dst="$CONFIG_DIR/$d"
  rm -rf "$dst"; install -d -m 700 "$dst"
  for root in "$AGENTS_DIR/$d" "$HERE/$d"; do
    [[ -d "$root" ]] || continue
    for src in "$root"/*; do
      [[ -e "$src" ]] || continue
      ln -sfn "$src" "$dst/${src##*/}"
    done
  done
done

# 모델 피커(settings.json 전용) — 배포물이 아니라 매 실행 시 생성, 라우터 model_name 과 일치
cat > "$CONFIG_DIR/settings.json" <<'JSON'
{
  "modelPicker": {
    "replaceBuiltInOptions": true,
    "options": [
      { "model": "deepseek-coder-v2", "label": "DeepSeek Coder V2" },
      { "model": "qwen3-coder",       "label": "Qwen3 Coder" },
      { "model": "mistral-nemo",      "label": "Mistral Nemo" },
      { "model": "llama3.1",          "label": "Llama 3.1" },
      { "model": "gemma4",            "label": "Gemma4" }
    ]
  }
}
JSON

# MCP: 설치 디렉토리 소스를 런타임 config 로 매 실행 신규 복사 → --mcp-config 로 읽음
#   (기존 MCP 설정과 병합; 래퍼 설정만 쓰려면 아래 exec 에 --strict-mcp-config 추가)
MCP_SRC="${CLAUDE_MCP_SRC:-$HERE/mcp.json}"
MCP_ARG=()
if [[ -f "$MCP_SRC" ]]; then
  install -m 600 "$MCP_SRC" "$CONFIG_DIR/mcp.json"
  MCP_ARG=(--mcp-config "$CONFIG_DIR/mcp.json")
fi

# ============================================================================
# 폐쇄망(외부 인터넷 불가) 차단 — 비필수 트래픽·업데이트·텔레메트리·웹 접근
#   ※ 대부분 CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC 하나로 포괄되지만,
#     의도와 영향을 명시적으로 남기기 위해 개별 변수도 함께 선언한다.
# ============================================================================
# (1) 총괄 — 자동업데이트·텔레메트리·오류보고·/feedback·릴리스노트·PR/MR 배지·
#     빠른모드 가용성 확인·기능 플래그(GrowthBook) 가져오기까지 한 번에 차단.
#     값이 0/false 여도 여전히 차단되며, 해제하려면 unset.
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
# (2) 텔레메트리 / 추적 / 오류보고
export DISABLE_TELEMETRY=1              # Statsig·OTel (0 이어도 거부됨)
export DO_NOT_TRACK=1                   # 개발자 CLI 공통 규약 (DISABLE_TELEMETRY 와 동일)
export DISABLE_ERROR_REPORTING=1        # Sentry 류 오류보고 거부 (0 이어도 거부됨)
export DISABLE_GROWTHBOOK=1             # 기능 플래그 fetch 끔 → 코드 기본값 사용
# (3) 업데이트 — 폐쇄망은 새 버전을 받을 수 없음
export DISABLE_UPDATES=1                # 수동 `claude update`/`claude install` 포함 전면 차단
export DISABLE_AUTOUPDATER=1            # 백그라운드 자동 업데이트 (DISABLE_UPDATES 가 더 엄격)
export DISABLE_UPGRADE_COMMAND=1        # /upgrade 명령 숨김
# (4) 피드백 / 설문 — Anthropic 전송 경로
export DISABLE_FEEDBACK_COMMAND=1       # /feedback·/bug·/share
export CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1   # "How is Claude doing?" 세션 설문
export CLAUDE_CODE_SEND_FEEDBACK=0             # Claude 가 작성한 피드백
# (5) 플러그인 / 마켓플레이스 — 원격 git clone·등록
export CLAUDE_CODE_DISABLE_OFFICIAL_MARKETPLACE_AUTOINSTALL=1  # 공식 마켓 자동 등록 안 함
export CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE=1        # 새로고침 실패해도 기존 체크아웃 유지(에어갭)
export DISABLE_INSTALL_GITHUB_APP_COMMAND=1                    # /install-github-app 숨김
# (6) claude.ai 연결 — 커넥터·아티팩트
export ENABLE_CLAUDEAI_MCP_SERVERS=false   # claude.ai MCP 서버 가져오기 끔
export CLAUDE_CODE_DISABLE_ARTIFACT=1      # 산출물을 claude.ai 웹페이지로 게시하는 Artifact 끔
# (7) 웹 도구 — 외부 인터넷 불가
export CLAUDE_CODE_DISABLE_WEB_FETCH=1     # WebFetch 끔 (v2.1.285+). WebSearch 는 env 가 없어 exec 의 --disallowedTools 로 차단
# (8) IDE 연동 — 확장 자동 설치·자동 연결 시도 방지
export CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL=1
export CLAUDE_CODE_AUTO_CONNECT_IDE=false

# 런타임 config 위치를 Claude Code 에 알림 (기본 ~/.claude 대신 /tmp)
export CLAUDE_CONFIG_DIR="$CONFIG_DIR"

# 내부 LLM: LiteLLM 라우터 1곳 (모델별 서버/토큰은 라우터가 처리)
export ANTHROPIC_BASE_URL="$ROUTER_URL"
export ANTHROPIC_AUTH_TOKEN="$ROUTER_TOKEN"
export ANTHROPIC_MODEL="$MODEL"

# Claude Code 내부 별칭 / 서브에이전트 모델 → 라우터 model_name 매핑
#   서열(거대 → 라이트): fable > opus > sonnet > haiku  (모델 목록도 같은 순서)
export ANTHROPIC_DEFAULT_FABLE_MODEL="deepseek-coder-v2"   # fable  (가장 어려운/긴 작업)
export ANTHROPIC_DEFAULT_OPUS_MODEL="qwen3-coder"          # opus   (복잡한 추론 / opusplan 플랜)
export ANTHROPIC_DEFAULT_SONNET_MODEL="mistral-nemo"       # sonnet (일상 코딩 / opusplan 비플랜)
export ANTHROPIC_DEFAULT_HAIKU_MODEL="gemma4"              # haiku  (간단·빠른 작업 / 백그라운드)
export CLAUDE_CODE_SUBAGENT_MODEL="gemma4"                 # 서브에이전트 / 에이전트팀 기본

# 느린 로컬 모델 최적화: 타임아웃 확대 / 5분 본문 유휴 타임아웃 해제
export API_TIMEOUT_MS=1200000                         # 요청 타임아웃 20분 (기본 10분)
export API_FORCE_IDLE_TIMEOUT=0                        # 청크 사이 5분 유휴 타임아웃 끔
export CLAUDE_STREAM_IDLE_TIMEOUT_MS=600000            # 스트림 정체 타임아웃 10분
# (선택) 커스텀 모델 ID의 컨텍스트 윈도우 보정 — 라우터 모델과 다르면 지정
# export CLAUDE_CODE_MAX_CONTEXT_TOKENS=131072

# permissions (settings.json 대신 CLI 플래그)
#   WebSearch 는 전용 env 가 없어 여기서 차단(WebFetch 는 CLAUDE_CODE_DISABLE_WEB_FETCH 로 이미 차단)
exec "$BINARY" \
  --permission-mode default \
  --allowedTools "Bash(git status *)" "Bash(git diff *)" \
  --disallowedTools "Bash(git push *)" "Bash(sudo *)" "Read(./.env)" "WebFetch" "WebSearch" \
  "${MCP_ARG[@]}" \
  "$@"
