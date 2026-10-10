# 포터블 Claude Code (폐쇄망 · 내부 LLM 전용)

작성일: 2026-10-10
상태: **확정(final)** — 내부 LLM(Ollama) + **LiteLLM 라우터(A안)** / `/opt` 공유 경로 / `/tmp` 휘발 / 공유 스킬·룰은 `~/.agents` 링크
예제 파일: `bin/claude`(런처), `litellm/config.yaml`(라우터)
참고 문서: `doc/` (Claude Code 공식 문서 한글판 — `모델 구성.md`, `환경변수.md` 등)

> ⚠ **서버 주소·포트·토큰은 난수 placeholder** 입니다(폐쇄망 실제 값으로 교체). **모델명은 실제 오픈소스 모델명 그대로** 둡니다(거대 → 라이트 순): `deepseek-coder-v2`, `qwen3-coder`, `mistral-nemo`, `llama3.1`, `gemma4`.

## 목표
- 폐쇄망 공용/프로젝트 계정에서 Claude Code를 **내부 LLM에만** 연결해 배포·실행.
- 외부망·claude.ai 구독/API 키 불필요.
- 타 사용자 홈·개인 설정을 **건드리지 않고**, `/tmp`에서 격리 실행.
- 파일을 여러 개 만들지 않음 → **래퍼(wrapper) 1개**로 완결. 배포물은 래퍼뿐이고, `settings.json`은 **래퍼가 실행 시 생성**(다중 모델 피커용).

## 핵심 결정
- 설정/세션/자격증명/플러그인은 `CLAUDE_CONFIG_DIR` 하나로 이동 (OpenCode의 XDG 다중 변수보다 단순).
- model·provider·업데이트 차단·네트워크는 **전부 환경변수**로.
- permissions는 settings.json 대신 **CLI 플래그**(`--allowedTools`/`--disallowedTools`/`--permission-mode`).
- `settings.json`은 배포하지 않고 **래퍼가 매 실행 시 생성** — 다중 모델 피커(`modelPicker`) 전용.
- 설치: npm(내부 미러) 글로벌 설치 → 프로젝트 `claude_install/`로 `cp -a` vendoring.
- 바이너리는 `bin/claude.exe`가 자체 완결(네이티브) → 플랫폼 패키지 복사 불필요.
- **프로토콜: Ollama** (Anthropic `/v1/messages` 네이티브). 모델별 서버/토큰이 달라 **앞단에 LiteLLM 라우터 1개**를 둠(A안, "여러 서버 라우팅"). 단일 서버만 쓰면 라우터 없이 바로 Ollama에 연결 가능.
- **배포 위치: `/opt/company-claude/claude_install`** (홈 밖 공유 경로), 사용자 PATH로 연결.
- **데이터: `/tmp` 휘발** — 세션·기록 미보존, 로그인은 `ANTHROPIC_AUTH_TOKEN`으로 처리.
- **공유 스킬/룰**: `CLAUDE_CONFIG_DIR`는 `/tmp`로 두고, `$HOME/.agents/{skills,rules}`만 **링크로 공유** (OpenCode와 동일 소스) → 홈 오염·쿼터 0.

## 자원 값
| 항목 | 값 |
|---|---|
| `ANTHROPIC_BASE_URL` | `http://10.29.248.6:4000` (LiteLLM 라우터; A안) |
| `ANTHROPIC_AUTH_TOKEN` | `sk-router-16a59d11fb4d7a21` (= LiteLLM `general_settings.master_key`) |
| `ANTHROPIC_MODEL` | `gemma4` (라우터 `model_name`, 기본) |
| `ANTHROPIC_DEFAULT_FABLE_MODEL` | `deepseek-coder-v2` (가장 거대) |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `qwen3-coder` |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `mistral-nemo` |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `gemma4` (가장 라이트) |
| `CLAUDE_CODE_SUBAGENT_MODEL` | `gemma4` |
| `CLAUDE_CONFIG_DIR` | `/tmp/claude_$USER/claude_config` |

> ★ 배포 시 확인: **`ANTHROPIC_BASE_URL`**(라우터 주소)·**`ANTHROPIC_AUTH_TOKEN`**(라우터 키, `litellm/config.yaml`의 `master_key`와 동일)와 **모델 태그**. 모델별 실제 Ollama 서버/토큰은 **`litellm/config.yaml`**에서 관리한다(VRAM 2GB면 `gemma4:e2b`/`e4b` 권장).
> 단일 서버만 쓴다면 라우터 없이 `ANTHROPIC_BASE_URL`을 Ollama 주소(`http://localhost:11434`)로 두고 토큰은 더미로 두면 된다.

## 디렉토리 구조
```
claude_install/                       # 통째로 이동 가능, 공유 read-only 가능
├── claude                            # 런처(wrapper) — PATH에 이 디렉토리를 추가
└── claude-code/
    └── bin/claude.exe                # 네이티브 바이너리(자체 완결, 이 내부 경로는 패키지 고정)

/tmp/claude_<계정>/claude_config/      # = CLAUDE_CONFIG_DIR (런타임, 휘발)
├── skills -> $HOME/.agents/skills     # 공유(링크, 읽기용) — OpenCode와 동일 소스
├── rules  -> $HOME/.agents/rules      # 공유(링크, 읽기용)
├── plugins/                          # (선택) 또는 CLAUDE_CODE_PLUGIN_DIRS 사용
└── sessions/ projects/ backups/ …    # Claude Code가 자동 생성 (쓰기 필요)
```

## 공유 스킬/룰 (OpenCode 호환) — 왜 config=temp + 링크인가
- Claude Code는 스킬/룰을 `$CLAUDE_CONFIG_DIR/skills`, `$CLAUDE_CONFIG_DIR/rules`에서 읽음.
- OpenCode도 `$HOME/.agents/skills/*/SKILL.md`를 읽음 → **같은 소스를 공유** 가능.
- config 자체를 `~/.agents`로 두면 런타임 파일(`settings.json`·`plugins/`·`sessions/`·`history.jsonl` 등)이 공유 디렉토리를 오염시키고, `agents/`·`commands/` 포맷 충돌·홈 쿼터 위험이 있음.
- 따라서 **config는 `/tmp`, `$HOME/.agents/{skills,rules}`만 링크**로 끌어와 공유(방향: temp → home).
- 링크는 읽기용. Claude Code가 스킬을 쓰는 기능(플러그인/스킬 관리)을 쓰지 않으면 소스는 그대로 유지됨.

## MCP 서버 설정 (외부 도구 연결)
Claude Code에 MCP 도구(브라우저·DB·내부 API 등)를 붙이는 설정입니다. 상세는 `doc/MCP 서버에 연결하기.md`, `doc/MCP를 통해 Claude Code를 도구에 연결하기.md`.

### 어디에 두나 — 프로젝트 루트의 `.mcp.json` (project 범위)
| 범위 | 파일 | 설명 |
|---|---|---|
| `project` | **프로젝트(저장소) 루트의 `.mcp.json`** | 저장소에 커밋하면 팀원 전원이 동일 서버 사용 — **이 예제는 이걸 사용** |
| `local` | `claude mcp add` 기본값 | 사용자+현재 프로젝트 전용(`.mcp.json`은 안 만듦) |
| `user` | `~/.claude.json`의 `mcpServers` | 모든 프로젝트 — 단, **래퍼가 config를 `/tmp`로 옮기므로 개인 홈을 안 건드린다는 원칙에 어긋남 → 사용 비권장** |

- Claude Code는 **세션 시작 시** `.mcp.json`을 읽습니다 → 추가 후 **세션 재시작** 필요.
- 첫 연결 시 **승인 프롬프트**가 뜹니다(놓치면 `/mcp` 명령으로 승인/확인).

### 샘플 1개 — 폐쇄망용 로컬 stdio 서버
```json
{
  "mcpServers": {
    "company-docs": {
      "type": "stdio",
      "command": "/opt/company-claude/mcp/company-docs-server",
      "args": ["--config", "/opt/company-claude/mcp/server-config.json"]
    }
  }
}
```
- `type: "stdio"` → 로컬에서 **서브프로세스로 실행**(외부망 불필요). `command`+`args`가 실행 프로그램입니다. 내부 네트워크의 HTTP 서버라면 `{ "type": "http", "url": "http://<내부 호스트>:<포트>/mcp" }` 형식입니다.
- 폐쇄망에서는 `npx`/`uvx`가 패키지를 못 받으므로 **내부 미러로 설치한 실행 경로**를 `command`에 지정하세요.
- CLI로 등록하는 대안: `claude mcp add company-docs --scope project -- /opt/.../company-docs-server` (`/mcp`·`claude mcp list`로 관리).
- 서버 시작이 느리면 `MCP_TIMEOUT`(밀리초, 기본 30000)을 늘립니다: `export MCP_TIMEOUT=120000`.

## 여러 모델 지정 (`modelPicker`)
- `/model` 피커에 원하는 모델을 **개수 제한 없이** 이름 붙여 상주시킬 수 있음. settings.json 전용(env/CLI 등가 없음).
- 배포물을 늘리지 않기 위해 **래퍼가 매 실행 시 `$CLAUDE_CONFIG_DIR/settings.json`을 생성**한다(3단계 래퍼 참조).
- `options[].model`은 `--model`이 받는 값 그대로(Ollama 태그/이름) — 검증 없이 전달됨.
- `replaceBuiltInOptions: true` → 내장 Claude 행을 숨기고 이 목록만 표시.
- 최신 모델을 CC가 모르면 `"behavesAs": "<아는 모델 id>"`로 능력치만 차용.
- 모델 추가/변경은 래퍼 here-doc의 `options` 배열만 수정.
- **목록 순서 = 무게순(거대 → 라이트)** 로 정렬해 피커에 표시(현재 `deepseek-coder-v2` → `gemma4`).

**개수 상한:** `modelPicker.options`는 문서상 제한 없음. (env만 쓸 경우 별칭 `sonnet`/`opus`/`haiku`/`fable` 4개 + `ANTHROPIC_CUSTOM_MODEL_OPTION` 1개 = 약 5개가 한계. 게이트웨이 자동 발견 `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY`는 **id에 `claude`/`anthropic`이 든 것만** 채택하므로 Ollama `gemma4`는 걸러져 사용 불가.)

**환경변수만으로도 별칭 매핑 가능:** `ANTHROPIC_DEFAULT_{SONNET,OPUS,HAIKU,FABLE}_MODEL`로 각 별칭이 가리킬 모델을 지정하고, `CLAUDE_CODE_SUBAGENT_MODEL`로 서브에이전트 기본 모델을 지정할 수 있다(래퍼에 반영됨). 값은 라우터 `model_name`(또는 전체 모델명). 단 이 방식은 **고정된 별칭 4개**를 바꾸는 것이라 이름을 임의로 붙일 수 없고, `ANTHROPIC_DEFAULT_*_MODEL`을 설정하면 `/model` 피커에 그 패밀리 행이(내장 행 대신) 표시된다 → 임의 이름을 여러 개 상주시키려면 `modelPicker`.

## 여러 서버 라우팅 (모델별 URL/토큰이 다를 때)
Claude Code의 엔드포인트/토큰은 **전역 1개**(`ANTHROPIC_BASE_URL`/`ANTHROPIC_AUTH_TOKEN`)이고 `modelPicker`는 **모델 ID만** 지정합니다. 따라서 **모델마다 서버·토큰이 다르면** Claude Code만으로는 불가 → **A안(LiteLLM 라우터) 채택.** B안은 프록시를 넣을 수 없을 때의 대안.

예시 서버(난수 placeholder):

| 모델 | URL | 토큰 |
|---|---|---|
| `deepseek-coder-v2` | `http://10.160.110.124:11434` | `sk-c36baf52d4f479647948e526f963b021` |
| `qwen3-coder` | `http://10.101.160.238:8080` | (없음) |
| `mistral-nemo` | `http://10.102.102.245:8080` | `sk-6df396f8e01935fda71ceb4b80bf5ee3` |
| `llama3.1` | `http://10.228.83.6:8080` | `sk-6e53e0363a9cb445e1b035ab4db01473` |
| `gemma4` | `http://10.203.201.25:8000` | `sk-a1296e4ca349babe929e9ff99e9514bb` |

### A) 라우터(프록시) 1개 앞단에 — 래퍼 1개 유지 **(채택)**
- Claude Code는 라우터 **한 곳**만 봄. 모델별 `api_base`/`api_key`는 라우터 설정에 두고 **모델 ID 문자열로 라우팅**.
- 래퍼 변경: `ANTHROPIC_BASE_URL`→라우터, `ANTHROPIC_AUTH_TOKEN`→라우터 키. `modelPicker.options`는 라우터의 모델명 목록.
- 설정 파일: **`litellm/config.yaml`** (이 예제에 포함). 래퍼: **`bin/claude`**.
```yaml
# LiteLLM 예시 (폐쇄망 반입 필요: pip 휠 vendoring) — model_list 순서 = 무게순(거대 → 라이트)
model_list:
  - model_name: deepseek-coder-v2
    litellm_params: { model: ollama/deepseek-coder-v2, api_base: http://10.160.110.124:11434, api_key: sk-c36baf52d4f479647948e526f963b021 }
  - model_name: qwen3-coder
    litellm_params: { model: ollama/qwen3-coder, api_base: http://10.101.160.238:8080 }
  - model_name: mistral-nemo
    litellm_params: { model: ollama/mistral-nemo, api_base: http://10.102.102.245:8080, api_key: sk-6df396f8e01935fda71ceb4b80bf5ee3 }
  - model_name: llama3.1
    litellm_params: { model: ollama/llama3.1, api_base: http://10.228.83.6:8080, api_key: sk-6e53e0363a9cb445e1b035ab4db01473 }
  - model_name: gemma4
    litellm_params: { model: ollama/gemma4, api_base: http://10.203.201.25:8000, api_key: sk-a1296e4ca349babe929e9ff99e9514bb }
```
```jsonc
// 래퍼가 생성하는 settings.json 의 modelPicker (라우터 model_name 과 일치)
{ "modelPicker": { "replaceBuiltInOptions": true, "options": [
  { "model": "deepseek-coder-v2", "label": "DeepSeek Coder V2" },
  { "model": "qwen3-coder",       "label": "Qwen3 Coder" },
  { "model": "mistral-nemo",      "label": "Mistral Nemo" },
  { "model": "llama3.1",          "label": "Llama 3.1" },
  { "model": "gemma4",            "label": "Gemma4" }
] } }
```
```bash
export ANTHROPIC_BASE_URL="http://10.29.248.6:4000"
export ANTHROPIC_AUTH_TOKEN="sk-router-16a59d11fb4d7a21"
```
- 장점: 래퍼 1개, 세션 중 모델 전환 자유. 단점: 프록시 1개 추가 운영(폐쇄망 반입).

### B) 엔드포인트별 래퍼 분리 — 프록시 없이 (대안)
- 서버마다 래퍼/프로필 1개: `ANTHROPIC_BASE_URL`·토큰·`CLAUDE_CONFIG_DIR`을 각각 분리.
- 공통 골격은 3단계 래퍼와 동일하고, 아래 3줄 + `modelPicker` 목록만 서버별로 교체:
```bash
# 모델(서버)마다 래퍼 1개
export ANTHROPIC_BASE_URL="http://10.203.201.25:8000"     # gemma4 서버
export ANTHROPIC_AUTH_TOKEN="sk-a1296e4ca349babe929e9ff99e9514bb"
export CLAUDE_CONFIG_DIR="/tmp/claude_$USER/gemma4"
# modelPicker options 예: { "model": "gemma4", "label": "Gemma4" }
```
- 장점: 추가 서비스·의존성 0. 단점: 래퍼·프로필이 서버 수만큼 증가, 세션 중 서버 전환 불가.

→ **채택: A.** 래퍼 1개·세션 중 모델 전환이 유지되고, 모델별 서버/토큰은 `litellm/config.yaml` 한 곳에 모인다. (B는 프록시를 넣을 수 없는 환경의 대안.)

## 최적화 요약 (모델별 URL/토큰이 다를 때)
- **URL/토큰은 라우터에만** 존재(`litellm/config.yaml`). Claude Code 쪽엔 전역 1개(라우터 주소·키)만 → 모델 추가/변경은 **config 한 곳만** 수정.
- Claude Code가 보내는 **모델 ID = 라우터 `model_name`**. `modelPicker.options`와 **반드시 일치**시킨다.
- **별칭 매핑**(`ANTHROPIC_DEFAULT_*_MODEL`)으로 내부 호출(백그라운드=haiku, 자동 폴백=fable, 서브에이전트=`CLAUDE_CODE_SUBAGENT_MODEL`)까지 **라우터 모델로 고정** → 실제 Anthropic 모델로 새지 않음.
- **느린 로컬 모델 타임아웃**을 래퍼에서 확대(`API_TIMEOUT_MS`·`API_FORCE_IDLE_TIMEOUT=0`·`CLAUDE_STREAM_IDLE_TIMEOUT_MS`) + 라우터 `timeout` → 생성 중 끊김 방지.
- 게이트웨이 자동 발견(`CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY`)은 **끔** — 모델명 필터로 `gemma4` 등이 제외되므로 `modelPicker`로 대체.

## 설치 절차 + 검증

### 1) 글로벌 설치 (관리자 계정, 내부 npm 미러)
```bash
node -v                                                          # 22+ (설치 시점만)
npm view @anthropic-ai/claude-code-linux-x64@2.1.296 version     # 플랫폼 패키지 미러 확인 (필수)
npm install -g @anthropic-ai/claude-code
claude --version
```
- 검증: `claude --version` 출력.
- 주의: `sudo` 금지. 글로벌 prefix가 홈이면 약 245MB(바이너리) 소비.

### 2) 프로젝트로 vendoring
```bash
GLOBAL="$(npm config get prefix)"
mkdir -p claude_install
cp -a "$GLOBAL/lib/node_modules/@anthropic-ai/claude-code" claude_install/
claude_install/claude-code/bin/claude.exe --version
```
- `cp -a` 사용(symlink 보존). 플랫폼 패키지는 복사 대상에서 제외 가능.
- 검증: 복사된 바이너리 단독 실행.

### 3) 런처 `claude_install/claude`
> 아래는 요약이며, 전체 파일(헤더 주석 포함)은 **`bin/claude`**. 배포 시 `claude_install/claude`로 복사.
```bash
#!/usr/bin/env bash
set -Eeuo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # = claude_install

# 포터블 격리 (홈 대신 temp)
export CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-/tmp/claude_$USER/claude_config}"
install -d -m 700 "$CLAUDE_CONFIG_DIR"

# 공유 스킬/룰 링크 (OpenCode와 동일 소스: $HOME/.agents) — 소스 있을 때만, 읽기용
for d in skills rules; do
  src="$HOME/.agents/$d"
  [ -d "$src" ] || continue
  dst="$CLAUDE_CONFIG_DIR/$d"
  [ -L "$dst" ] || [ ! -e "$dst" ] || rm -rf "$dst"   # 기존 실제 디렉토리면 교체(안 하면 그 안에 링크 생성)
  ln -sfn "$src" "$dst"
done

# 모델 피커(settings.json 전용) — 배포물이 아니라 매 실행 시 생성. 라우터 model_name 과 일치
cat > "$CLAUDE_CONFIG_DIR/settings.json" <<'JSON'
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

# 외부 트래픽·업데이트 차단
export DISABLE_UPDATES=1
export DISABLE_AUTOUPDATER=1
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

# 내부 LLM: LiteLLM 라우터 1곳 (모델별 서버/토큰은 litellm/config.yaml 이 처리)
export ANTHROPIC_BASE_URL="http://10.29.248.6:4000"
export ANTHROPIC_AUTH_TOKEN="sk-router-16a59d11fb4d7a21"   # = litellm general_settings.master_key
export ANTHROPIC_MODEL="gemma4"

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
exec "$HERE/claude-code/bin/claude.exe" \
  --permission-mode default \
  --allowedTools "Bash(git status *)" "Bash(git diff *)" \
  --disallowedTools "Bash(git push *)" "Bash(sudo *)" "Read(./.env)" \
  "$@"
```
- 검증: `claude_install/claude --version`, 세션에서 `/status`(config 경로·모델), `/context`(스킬/룰 로드) 확인.

### 4) 사용자 PATH 연결 (관리자)
```bash
# /etc/profile.d/claude.sh
export PATH="/opt/company-claude/claude_install:$PATH"
```

### 5) 연결 검증
```bash
# 라우터(Anthropic /v1/messages)로 모델 라우팅까지 확인
curl -sS http://10.29.248.6:4000/v1/messages \
  -H "authorization: Bearer sk-router-16a59d11fb4d7a21" \
  -H 'content-type: application/json' -H 'anthropic-version: 2023-06-01' \
  -d '{"model":"gemma4","max_tokens":16,"messages":[{"role":"user","content":"hi"}]}'
```

## 사용한 환경변수 레퍼런스
| 목적 | 변수 |
|---|---|
| 설정 트리 위치 | `CLAUDE_CONFIG_DIR` |
| 엔드포인트/토큰 | `ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN` |
| 모델(기본) | `ANTHROPIC_MODEL`, `ANTHROPIC_DEFAULT_MODEL` |
| 모델 별칭 매핑 | `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_HAIKU_MODEL`, `ANTHROPIC_DEFAULT_FABLE_MODEL` (구 `ANTHROPIC_SMALL_FAST_MODEL` deprecated) |
| 서브에이전트 모델 | `CLAUDE_CODE_SUBAGENT_MODEL` (강제: `CLAUDE_CODE_SUBAGENT_MODEL_FORCE`) |
| 모델 ID 재매핑 | `settings.json`의 `modelOverrides` (Anthropic 모델 ID → 제공자 문자열) |
| 커스텀 모델(피커) | `ANTHROPIC_CUSTOM_MODEL_OPTION` (+`_NAME`/`_DESCRIPTION`/`_SUPPORTED_CAPABILITIES`) |
| 다중 모델(피커) | `settings.json`의 `modelPicker.options` — 환경변수 아님(래퍼가 생성) |
| 창/출력 한계 | `CLAUDE_CODE_MAX_CONTEXT_TOKENS`, `CLAUDE_CODE_MAX_OUTPUT_TOKENS` |
| 업데이트 차단 | `DISABLE_UPDATES`, `DISABLE_AUTOUPDATER` |
| 외부 트래픽 차단 | `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`, `DISABLE_TELEMETRY`, `DISABLE_ERROR_REPORTING`, `DO_NOT_TRACK`, `CLAUDE_CODE_DISABLE_OFFICIAL_MARKETPLACE_AUTOINSTALL` |
| 플러그인 | `CLAUDE_CODE_PLUGIN_CACHE_DIR`, `CLAUDE_CODE_PLUGIN_SEED_DIR`, `CLAUDE_CODE_PLUGIN_DIRS` |
| 서브프로세스 자격증명 제거 | `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1` |
| 프록시/TLS | `HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY`, `CLAUDE_CODE_CERT_STORE`, `CLAUDE_CODE_PROXY_RESOLVES_HOSTS` |
| 느린 모델 타임아웃 | `API_TIMEOUT_MS`, `API_FORCE_IDLE_TIMEOUT`, `CLAUDE_STREAM_IDLE_TIMEOUT_MS` |
| 홈 CLAUDE.md 누출 회피 | `CLAUDE_CODE_DISABLE_CLAUDE_MDS` |
| 게이트웨이 모델 자동 노출 | `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY` |
| 게이트웨이 호환 | `CLAUDE_CODE_ATTRIBUTION_HEADER=0`, `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS`, `CLAUDE_CODE_EXTRA_BODY` |

## 배포 전 확인 / 리스크
1. **프로토콜/엔드포인트** — **Ollama** (Anthropic `/v1/messages` 네이티브).
   - **단일 서버면 프록시 불필요.**
   - **모델별 URL/토큰이 다르면 라우터(LiteLLM) 1개 필요** (위 "여러 서버 라우팅" A안), 프록시 회피 시 래퍼 분리(B안).
   - OpenAI-compatible 백엔드면 LiteLLM 등 Anthropic 변환 프록시 필요.
2. **아키텍처/libc** — 설치 머신 = 대상 머신(linux-x64/glibc) 일치 필요. Alpine(musl)이면 musl 머신에서 설치.
3. **데이터 영속성** — 확정: **`/tmp` 휘발**. reboot 시 세션·기록 소실(의도됨). 영속이 필요해지면 사용자별 영구 경로로 전환.
4. **공유 권한** — `chmod -R a+rX claude_install` (다른 사용자 실행 가능하게).
5. **홈 `~/.claude/CLAUDE.md` 누출** — `CLAUDE_CONFIG_DIR` 설정에도 홈 지침이 로드될 수 있음. 문제 시 래퍼에 `CLAUDE_CODE_DISABLE_CLAUDE_MDS=1` 추가.
6. **`~/.claude.json` 위치** — 포터블 핵심. `CLAUDE_CONFIG_DIR` 하위로 따라오는지 실측 확인 필요.
7. **npm 미러에 플랫폼 패키지 존재** — `@anthropic-ai/claude-code-linux-x64@<버전>` 없으면 반입 요청.

## 확정 사항
- 프로토콜: **Ollama** (Anthropic `/v1/messages` 네이티브).
- 다중 서버(모델별 URL/토큰): **라우터(LiteLLM) 1개를 앞단에 두는 A안 채택** (B안=래퍼 분리는 대안).
- 배포 위치: **`/opt/company-claude/claude_install`** (홈 밖 공유 경로).
- 데이터 영속성: **`/tmp` 휘발** (세션·기록 미보존).
- 공유 스킬/룰: **`/tmp` config + `$HOME/.agents/{skills,rules}` 링크** (OpenCode 호환, 홈 오염 없음).
- 다중 모델: **`modelPicker`를 래퍼가 매 실행 시 `settings.json`으로 생성** (env 상한 ~5개 회피, 개수 무제한).
- 배포 시: `ANTHROPIC_BASE_URL`·모델 태그를 환경에 맞게 확인, 리스크 2·4·5·6·7 검증.
- 값 구분: **모델명은 실제 오픈소스 모델명 유지**, **서버 주소·포트·토큰·라우터 정보는 난수 placeholder**.
- 모델 정렬: **무게순(거대 → 라이트)** `deepseek-coder-v2` > `qwen3-coder` > `mistral-nemo` > `llama3.1` > `gemma4` (피커·라우터 공통). 별칭 서열 fable > opus > sonnet > haiku.
- MCP: **프로젝트 루트 `.mcp.json`(project 범위)** 사용 — `user` 범위는 `~/.claude.json`에 써서 /tmp 격리에 부적합. 폐쇄망은 로컬 `stdio` 서버 우선.
