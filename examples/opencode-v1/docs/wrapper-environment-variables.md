# `personal-opencode` wrapper 환경 변수 설명

이 문서는 `bin/personal-opencode` wrapper가 설정하거나 제거하는 환경 변수를 설명합니다.

목표는 다음 두 가지입니다.

1. 회사가 공용으로 관리하는 OpenCode/OMO release를 수정하지 않고 실행합니다.
2. 사용자 로그인 환경에 남아 있는 다른 config/permission이 개인 LLM 프로필에 섞이지 않도록 합니다.

## 요약

| 환경 변수 | 처리 | 용도 |
|---|---|---|
| `COMPANY_OPENCODE_ROOT` | Wrapper 전용 | 공용 read-only release 루트 |
| `PERSONAL_OPENCODE_CONFIG_HOME` | Wrapper 전용 | 개인 config 기준 경로 |
| `PERSONAL_OPENCODE_DATA_HOME` | Wrapper 전용 | 개인 영구 데이터 기준 경로 |
| `PERSONAL_OPENCODE_STATE_HOME` | Wrapper 전용 | 개인 service/runtime 상태 기준 경로 |
| `PERSONAL_OPENCODE_CACHE_HOME` | Wrapper 전용 | 개인 cache 기준 경로 |
| `XDG_CONFIG_HOME` | OpenCode/OMO 사용 | 개인 config 경로 |
| `XDG_DATA_HOME` | OpenCode/OMO 사용 | 인증 정보, 세션 등 영구 데이터 경로 |
| `XDG_STATE_HOME` | OpenCode/OMO 사용 | background service 상태 경로 |
| `XDG_CACHE_HOME` | OpenCode/OMO 사용 | model/plugin/tool cache 경로 |
| `OPENCODE_CONFIG` | 제거 | 추가 config 파일 주입 방지 |
| `OPENCODE_CONFIG_CONTENT` | 제거 | 인라인 config 주입 방지 |
| `OPENCODE_CONFIG_DIR` | 제거 | 추가 config/plugin 디렉터리 주입 방지 |
| `OPENCODE_PERMISSION` | 제거 | 인라인 permission override 방지 |
| `OMO_DISABLE_POSTHOG` | `1`로 설정 | OMO PostHog telemetry 비활성화 |
| `OMO_SEND_ANONYMOUS_TELEMETRY` | `0`으로 설정 | OMO 익명 telemetry 비활성화 |
| `PATH` | 공용 helper 우선 | OMO/native helper 실행 파일 탐색 |
| `HOME` | 변경하지 않음 | Git/SSH/사용자 도구와 `~/.omo` 유지 |

---

# 1. Wrapper 전용 변수

다음 변수는 이 wrapper가 경로 계산에 사용합니다. OpenCode 자체가 직접 읽는 환경 변수는 아닙니다.

## `COMPANY_OPENCODE_ROOT`

공용 release의 루트입니다.

```bash
COMPANY_OPENCODE_ROOT=/opt/company-opencode/current
```

기본값:

```text
/opt/company-opencode/current
```

예상 구조:

```text
$COMPANY_OPENCODE_ROOT/
└── runtime/
    ├── bin/opencode
    └── node_modules/
        ├── oh-my-openagent/
        └── ...
```

## `PERSONAL_OPENCODE_CONFIG_HOME`

개인 config 기준 경로입니다.

```bash
PERSONAL_OPENCODE_CONFIG_HOME=$HOME/.config/opencode-personal
```

OpenCode 설정 파일 위치:

```text
$PERSONAL_OPENCODE_CONFIG_HOME/opencode/opencode.jsonc
```

기본값:

```text
~/.config/opencode-personal
```

## `PERSONAL_OPENCODE_DATA_HOME`

인증 정보, 세션 등 사용자별 영구 데이터의 기준 경로입니다.

```bash
PERSONAL_OPENCODE_DATA_HOME=$HOME/.local/share/opencode-personal
```

이 경로는 인증 정보와 대화 데이터를 저장할 수 있으므로 삭제하거나 공용으로 공유하면 안 됩니다.

## `PERSONAL_OPENCODE_STATE_HOME`

background service와 실행 상태를 저장하는 사용자별 경로입니다.

```bash
PERSONAL_OPENCODE_STATE_HOME=$HOME/.local/state/opencode-personal
```

실행 중인 service의 등록 정보가 여기에 저장될 수 있습니다.

## `PERSONAL_OPENCODE_CACHE_HOME`

삭제 후 다시 생성할 수 있는 cache의 기준 경로입니다.

```bash
PERSONAL_OPENCODE_CACHE_HOME=$HOME/.cache/opencode-personal
```

여에는 model catalog, provider cache, plugin cache 등이 들어갈 수 있습니다. 사용자별 persistent 디스크가 부족하면 `XDG_RUNTIME_DIR` 하위로 옮길 수 있습니다.

---

# 2. OpenCode와 OMO가 사용하는 표준 XDG 변수

Wrapper 전용 경로를 실제 OpenCode/OMO 표준 변수로 변환합니다.

```bash
export XDG_CONFIG_HOME="$CONFIG_ROOT"
export XDG_DATA_HOME="$DATA_ROOT"
export XDG_STATE_HOME="$STATE_ROOT"
export XDG_CACHE_HOME="$CACHE_ROOT"
```

## `XDG_CONFIG_HOME`

사용자별 config 기준 경로입니다.

```text
$XDG_CONFIG_HOME/opencode/opencode.jsonc
```

개인 provider 정의, 기본 model, permission, 공용 OMO plugin 경로 등을 읽습니다.

## `XDG_DATA_HOME`

영구 데이터 경로입니다.

```text
$XDG_DATA_HOME/opencode/
```

V1에서는 다음과 같은 데이터가 들어갈 수 있습니다.

- provider credential/API key
- 대화 세션
- 작업 상태
- 로그
- snapshot 관련 데이터

따라서 사용자 쓰기 권한이 필요합니다.

## `XDG_STATE_HOME`

사용자별 service/runtime 상태 경로입니다.

```text
$XDG_STATE_HOME/opencode/
```

background service 등록 파일 등이 위치할 수 있습니다.

## `XDG_CACHE_HOME`

재생성 가능한 cache 경로입니다.

```text
$XDG_CACHE_HOME/opencode/
$XDG_CACHE_HOME/oh-my-opencode/
```

이 디렉터리는 삭제해도 OpenCode/OMO가 다시 생성할 수 있습니다. 단, 네트워크가 차단된 환경에서는 model catalog 재생성이 실패할 수 있습니다.

---

# 3. 제거하는 OpenCode 변수

Wrapper는 다음 변수를 실행 환경에서 제거합니다.

```bash
unset OPENCODE_CONFIG OPENCODE_CONFIG_CONTENT OPENCODE_CONFIG_DIR OPENCODE_PERMISSION
```

이 구문은 현재 login shell을 변경하지 않습니다. `personal-opencode`가 실행한 OpenCode 자식 프로세스에서만 해당 변수가 제거됩니다.

## `OPENCODE_CONFIG`

### 의미

추가 config 파일을 지정합니다.

```bash
OPENCODE_CONFIG=/etc/company/opencode.jsonc opencode
```

설정 파일은 통째로 교체되지 않고 병합됩니다. 같은 키가 여러 설정에 있으면 나중에 읽은 값이 우선합니다.

### personal wrapper에서 제거하는 이유

사용자 환경에 회사 config가 남아 있으면 회사 model/provider가 개인 설정을 덮어쓸 수 있습니다.

```text
개인 설정: model = personal/coder
회사 설정: model = company/model
최종 결과: 회사 설정이 우선할 수 있음
```

제거 후에는 `XDG_CONFIG_HOME` 아래의 개인 config만 사용합니다.

## `OPENCODE_CONFIG_CONTENT`

### 의미

파일 대신 인라인 JSON 설정을 전달합니다.

```bash
OPENCODE_CONFIG_CONTENT='{
  "model": "anthropic/claude"
}' opencode
```

이 값은 다른 사용자/프로젝트 설정 뒤에 병합될 수 있습니다.

### personal wrapper에서 제거하는 이유

다음 값이 로그인 환경에 남아 있을 수 있습니다.

```bash
export OPENCODE_CONFIG_CONTENT='{"model":"company/model"}'
```

이 경우 개인 config의 model/provider가 다시 변경되고, 다른 provider의 token 입력이 나타날 수 있습니다.

## `OPENCODE_CONFIG_DIR`

### 의미

추가 config 디렉터리를 지정합니다.

```bash
OPENCODE_CONFIG_DIR=/etc/company/opencode.d opencode
```

해당 디렉터리는 `.opencode`과 비슷한 구조로 사용됩니다.

```text
/etc/company/opencode.d/
├── opencode.json
├── agents/
├── commands/
├── plugins/
├── skills/
└── themes/
```

### personal wrapper에서 제거하는 이유

회사 agent, command, plugin, skill이 개인 프로필에 함께 로드될 수 있습니다.

```text
/etc/company/opencode.d/plugins/company-plugin.js
```

이 plugin이 내부적으로 다른 provider를 사용하거나 회사 설정을 다시 병합할 수도 있습니다.

### 주의

이 변수를 제거해도 프로젝트 내부의 다음 파일은 계속 로드됩니다.

```text
<project>/.opencode/opencode.json
<project>/.opencode/plugins/
```

이 wrapper는 외부 환경 주입만 차단하며 프로젝트 내부 설정까지 차단하지는 않습니다.

## `OPENCODE_PERMISSION`

### 의미

권한을 인라인 JSON으로 덮어씁니다.

```bash
OPENCODE_PERMISSION='{"bash":"allow"}' opencode
```

### personal wrapper에서 제거하는 이유

개인 config에 다음 제한이 있어도 환경 변수가 더 나중에 적용될 수 있습니다.

```jsonc
{
  "permission": {
    "bash": {
      "*": "ask",
      "git push *": "deny",
      "sudo *": "deny"
    }
  }
}
```

예를 들어 다음 값이 남아 있으면 위험합니다.

```bash
OPENCODE_PERMISSION='{"bash":"allow"}'
```

이 경우 아래 제한이 약화될 수 있습니다.

- `git push` 승인 생략
- `sudo` 승인 생략
- 위험한 `rm` 명령 승인 생략
- 외부 네트워크 요청 제한 약화

---

# 4. V1 설정 우선순위

V1에서는 설정이 대체되지 않고 병합됩니다. 일반적인 순서는 다음과 같습니다.

```text
1. 원격 조직 config
2. 사용자 전역 config
3. OPENCODE_CONFIG
4. 프로젝트 opencode.json
5. .opencode 디렉터리
6. OPENCODE_CONFIG_CONTENT
7. /etc/opencode managed config
8. 관리형 preference
```

마지막으로 `OPENCODE_PERMISSION`이 별도로 적용될 수 있습니다.

그래서 host 환경에 위 변수들이 남아 있으면 personal wrapper의 구성이 의도보다 넓어질 수 있습니다.

---

# 5. Linux managed config 주의

V1은 다음 경로를 관리자 설정으로 인식할 수 있습니다.

```text
/etc/opencode/opencode.jsonc
/etc/opencode/opencode.json
```

확인:

```bash
ls -la /etc/opencode 2>/dev/null
```

이 파일에 다음 키가 있으면 사용자 개인 설정보다 우선할 수 있습니다.

```jsonc
{
  "model": "company/model",
  "provider": {},
  "enabled_providers": ["company"],
  "plugin": ["oh-my-openagent"]
}
```

Wrapper의 `unset`은 managed config를 비활성화하지 않습니다. 회사 managed config와 개인 config를 함께 사용하려면 충돌하는 키를 managed config에서 제거하거나 별도 release/profile로 분리해야 합니다.

---

# 6. OMO telemetry 변수

## 쉽게 말하면

다음 두 줄은 OMO를 끄는 설정이 아니라 **OMO의 사용 통계 전송만 끄는 설정**입니다.

```bash
export OMO_DISABLE_POSTHOG=1
export OMO_SEND_ANONYMOUS_TELEMETRY=0
```

```text
OMO 기능은 계속 사용
OMO 사용 통계만 전송하지 않음
```

## Telemetry란?

Telemetry는 프로그램이 사용자의 코드나 프롬프트를 직접 열거하는 기능이라기보다, 다음 형태의 사용 이벤트를 외부 분석 서비스로 보내는 기능입니다.

```text
OMO plugin이 시작됨
OMO CLI가 실행됨
설치된 OMO 버전 정보
비식별화된 설치 식별자
```

현재 OMO 문서에 따르면 기본 telemetry는 다음 특징을 가집니다.

- 머신당 UTC 날짜 기준 최대 1회 전송
- 설치 식별자는 SHA256으로 해시
- 원본 hostname을 전송하지 않음
- PostHog person profile을 만들지 않음

특정 회사는 외부 서비스로 설치/사용 이벤트를 보내는 것 자체를 금지할 수 있으므로, 이 배포 예시는 기본적으로 전송을 끕니다.

## 두 변수의 역할

| 환경 변수 | 값 | 의미 |
|---|---:|---|
| `OMO_DISABLE_POSTHOG` | `1` | PostHog 전송을 끄는 legacy 호환 설정 |
| `OMO_SEND_ANONYMOUS_TELEMETRY` | `0` | 익명 telemetry 전송을 끄는 명시적 설정 |

### `OMO_DISABLE_POSTHOG=1`

```bash
export OMO_DISABLE_POSTHOG=1
```

문자 그대로 `PostHog를 비활성화`라는 뜻입니다.

`1`은 활성 상태의 legacy 스위치 역할을 하므로, OMO는 이 플래그가 켜져 있으면 telemetry를 보내지 않습니다.

이 변수는 OMO의 다음 기능을 끄지 않습니다.

- LLM 요청
- agent 실행
- plugin 실행
- subagent 실행
- MCP
- LSP
- 파일 편집
- tool 실행

즉, `OMO_DISABLE_POSTHOG=1`은 **OMO 전체를 비활성화하는 값이 아닙니다.**

### `OMO_SEND_ANONYMOUS_TELEMETRY=0`

```bash
export OMO_SEND_ANONYMOUS_TELEMETRY=0
```

`익명 사용 통계를 보낼지`를 직접 지정하는 변수입니다.

비활성화 값:

```text
0
false
no
```

활성화 값:

```text
1
true
yes
```

회사 배포에서는 telemetry를 허용하지 않는 경우가 많으므로 `0`으로 설정합니다.

## 왜 두 개 다 설정하나요?

두 변수는 거의 같은 목적을 가지지만, OMO 버전에 따라 확인하는 이름이 다를 수 있습니다.

```text
구버전 → OMO_DISABLE_POSTHOG
새버전 → OMO_SEND_ANONYMOUS_TELEMETRY
```

따라서 두 개를 함께 설정하면 OMO 업데이트 직후에도 telemetry가 켜지는 상황을 줄일 수 있습니다.

해당 버전이 한 변수를 인식하지 못하더라도 예전 wrapper의 `unset`과 마찬가지로 실행을 막지 않는 것이 일반적인 환경 변수 동작입니다.

## 회사가 telemetry를 허용하려면

회사 정책에서 익명 사용 통계를 허용한다면 wrapper의 두 줄을 제거하거나 다음처럼 바꿉니다.

```bash
export OMO_SEND_ANONYMOUS_TELEMETRY=1
```

그리고 legacy 비활성화 값은 설정하지 않습니다.

```bash
# 이 줄이 있으면 telemetry가 꺼질 수 있으므로 설정하지 않음
# export OMO_DISABLE_POSTHOG=1
```

 telemetry 허용 여부는 OMO 버전과 회사 개인정보 보호 정책에 맞춰 관리자가 결정해야 합니다.

## 설정 확인

현재 wrapper가 두 변수를 설정하는지 소스에서 확인합니다.

```bash
grep -nE 'OMO_(DISABLE_POSTHOG|SEND_ANONYMOUS_TELEMETRY)' \
  examples/v1-personal-opencode/bin/personal-opencode
```

기대 결과:

```text
export OMO_DISABLE_POSTHOG=1
export OMO_SEND_ANONYMOUS_TELEMETRY=0
```

실제 telemetry 정책은 사용 중인 OMO 버전의 schema와 문서에서 다시 확인해야 합니다.

---

# 7. `PATH`와 `HOME`

## `PATH`

공용 helper를 사용자 PATH보다 먼저 찾도록 설정합니다.

```bash
export PATH="$ROOT/runtime/bin:$ROOT/runtime/node_modules/.bin:$PATH"
```

다음 helper가 이 경로에서 실행될 수 있습니다.

- OMO CLI
- ast-grep
- comment checker
- provider helper
- MCP helper

공용 release는 읽기 전용이어야 하며 helper가 실행 중 release를 수정하지 않아야 합니다.

## `HOME`

이 wrapper는 `HOME`을 변경하지 않습니다.

```text
HOME=/home/USER
```

이유:

- Git/SSH 설정 유지
- 사용자 credential 유지
- `~/.omo/omo.jsonc` 유지
- shell 및 child process의 정상적인 home 해석 유지

현재 unified OMO config의 사용자 파일은 다음과 같습니다.

```text
~/.omo/omo.jsonc
```

따라서 회사 프로필과 개인 프로필의 OMO 설정을 동시에 분리하려면 별도 OMO profile 설계가 필요합니다.

---

# 8. 확인 명령

## 최종 환경 확인

```bash
personal-opencode --version
personal-opencode models
```

`models`에는 개인 provider의 model만 나타나야 합니다.

## Config 확인

```bash
personal-opencode debug config
```

출력에 token이 포함될 수 있으므로 공유 전에 민감한 값을 제거하십시오.

## 환경 변수 확인

```bash
env | grep -E '^(COMPANY_OPENCODE_ROOT|PERSONAL_OPENCODE_|XDG_|OPENCODE_|OMO_)' \
  | sed 's/=.*/=<set>/' \
  | sort
```

Token이나 API key는 이 명령의 출력에 나타나지 않도록 값은 가립니다.

## Background service 확인

```bash
personal-opencode service status
personal-opencode service restart
```

Personal profile과 공용 release를 함께 사용할 때는 background service가 어느 config 경로에서 시작되었는지 확인해야 합니다.

---

# 9. 보안 체크리스트

- `personal-opencode`는 사용자 UID로 실행
- 공용 release는 root 소유 읽기 전용
- 공용 디렉터리에 token 저장 금지
- 실제 token이 들어간 사용자 config는 `0600`
- token이 들어간 config를 Git에 커밋 금지
- `OPENCODE_PERMISSION` 환경 주입 차단
- `/etc/opencode` managed config 충돌 확인
- OMO telemetry 비활성화
- wrapper에 token을 command-line argument로 전달하지 않기
- provider log 공유 전에 token/header 제거
