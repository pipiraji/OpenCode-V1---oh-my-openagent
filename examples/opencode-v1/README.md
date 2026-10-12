# OpenCode V1 + oh-my-openagent 개인 LLM 배포 예시

이 예시는 다음 구성을 가정합니다.

- OpenCode **V1** (`1.15.x`)
- OMO 패키지: `oh-my-openagent`
- 공용 release: `/opt/company-opencode/current`
- 개인 LLM: 사용자별 provider 한 개만 사용
- 개인 API key: 사용자별 `opencode.jsonc`에 저장
- OMO/agent/category도 개인 provider만 사용

> 개인 LLM의 API protocol은 아직 확인되지 않았습니다. 현재 예시는 가장 일반적인 **OpenAI-compatible 형식**입니다.

## 파일

```text
examples/v1-personal-opencode/
├── bin/
│   └── personal-opencode       # 사용자 실행 wrapper
├── config/
│   ├── opencode.jsonc          # V1 OpenCode + personal provider
│   └── omo.jsonc               # oh-my-openagent 설정
└── docs/
    ├── omo-config-guide.md               # omo.jsonc와 provider/model key 작성법
    └── wrapper-environment-variables.md  # wrapper 환경 변수 설명
```

## 1. 공용 release 구조

```text
/opt/company-opencode/current/
└── runtime/
    ├── bin/
    │   └── opencode
    └── node_modules/
        ├── oh-my-openagent/
        └── ...
```

`node_modules`는 root 소유 읽기 전용이어야 합니다. 사용자가 실행할 때 갱신하지 않습니다.

## 2. 사용자별 파일 설치

```bash
install -d -m 700 "$HOME/.config/opencode-personal/opencode"
install -d -m 700 "$HOME/.omo"

install -m 600 \
  examples/v1-personal-opencode/config/opencode.jsonc \
  "$HOME/.config/opencode-personal/opencode/opencode.jsonc"

install -m 600 \
  examples/v1-personal-opencode/config/omo.jsonc \
  "$HOME/.omo/omo.jsonc"

install -m 755 \
  examples/v1-personal-opencode/bin/personal-opencode \
  /usr/local/bin/personal-opencode
```

실제 token을 넣은 `opencode.jsonc`는 Git에 커밋하지 마십시오.

## 3. provider placeholder 수정

`~/.config/opencode-personal/opencode/opencode.jsonc`에서 다음을 바꿉니다.

```jsonc
"baseURL": "http://REPLACE_WITH_PERSONAL_LLM_BASE_URL/v1",
"apiKey": "REPLACE_WITH_PERSONAL_API_KEY"
```

그리고 `provider.personal.models`의 키를 LLM 서버가 실제로 사용하는 model ID로 바꿉니다.

예시에서는 catalog key와 실제 model ID가 같게 두었습니다.

```jsonc
"models": {
  "coder": {
    "name": "Personal Coder"
  }
}
```

서버의 실제 model ID가 `my-model-v2`라면:

```jsonc
"model": "personal/my-model-v2",

"models": {
  "my-model-v2": {
    "id": "actual-server-model-id"
  }
}
```

V1 custom provider schema는 사용 중인 OpenCode 버전의 `https://opencode.ai/config.json`으로 확인하십시오.

## 4. API protocol별 변경

### OpenAI-compatible

현재 예시값입니다.

```jsonc
"npm": "@ai-sdk/openai-compatible",
"options": {
  "baseURL": "http://host:port/v1",
  "apiKey": "token"
}
```

대부분의 server가 `Authorization: Bearer <token>`을 사용합니다.

### Anthropic-compatible

```jsonc
"npm": "@ai-sdk/anthropic",
"options": {
  "baseURL": "https://host",
  "apiKey": "token"
}
```

baseURL 경로와 인증 header가 실제 server 구현과 일치하는지 확인해야 합니다.

### 그 외 protocol

다음 중 하나가 필요할 수 있습니다.

- `@ai-sdk/openai`
- 별도 AI SDK provider package
- 사내 OpenCode provider plugin

provider package를 정확히 모르면 이 예시를 그대로 사용하지 말고, `/v1/models`, 요청 URL, 인증 header를 먼저 확인하십시오.

OpenCode와 OMO가 실제로 동작하려면 개인 LLM이 streaming과 tool/function calling을 지원해야 합니다.

## 5. 다른 provider/model 숨기기

V1 예시는 다음을 사용합니다.

```jsonc
"enabled_providers": ["personal"]
```

이 설정이 있으면 `personal` 외 provider는 로드되지 않으므로 다른 provider의 인증 화면이 뜨지 않습니다.

V1 `experimental.policies`를 사용하는 대체 방식:

```jsonc
"experimental": {
  "policies": [
    {
      "action": "provider.use",
      "resource": "*",
      "effect": "deny"
    },
    {
      "action": "provider.use",
      "resource": "personal",
      "effect": "allow"
    }
  ]
}
```

두 방식 중 하나만 사용하십시오.

## 6. OMO 설정

현재 unified OMO config의 사용자 경로는 다음과 같습니다.

```text
~/.omo/omo.jsonc
```

예시 파일은 다음을 고정합니다.

- telemetry 비활성화
- OMO auto-update hook 비활성화
- 모든 OMO agent/category를 `personal/coder`로 지정
- background task 동시성 3

OMO는 버전별로 agent 이름과 schema가 바뀌므로, 실제 배포 버전의 schema로 검증하십시오.

현재 unified config의 사용자 파일은 `~/.omo/omo.jsonc` 하나입니다. 이 예시는 해당 파일을 개인 provider용으로 바꾸는 방식입니다. 회사와 개인 OMO 설정을 같은 사용자 계정에서 동시에 유지해야 한다면 OMO profile과 별도 OpenCode config 계층을 추가로 설계해야 합니다.

## 7. 실행

```bash
personal-opencode
```

또는:

```bash
cd /path/to/project
personal-opencode
```

첫 실행 확인:

```bash
personal-opencode --version
personal-opencode models
personal-opencode run --model personal/coder "OK라고만 답해줘"
```

`models` 출력에는 `personal/*`만 나타나야 합니다.

## 8. V1 managed config 주의

V1 Linux managed config가 다음 경로에 있으면 사용자 설정보다 우선합니다.

```text
/etc/opencode/opencode.jsonc
```

또는:

```text
/etc/opencode/opencode.json
```

확인:

```bash
ls -la /etc/opencode 2>/dev/null
```

이 파일에 `model`, `provider`, `enabled_providers`, `plugin` 등이 있으면 사용자 개인 config를 덮어쓸 수 있습니다. 회사 managed config와 개인 config를 모두 사용하려면 충돌하는 키를 회사 managed config에서 제거하거나 별도 profile/release로 분리해야 합니다.

## 9. 보안 주의

- token이 들어 있는 실제 `opencode.jsonc`는 `0600`
- Git 저장소에 token 포함 파일 커밋 금지
- 공용 `/opt/company-opencode`에는 token 금지
- 공유 NFS에 token 파일 금지
- wrapper에 token을 command-line argument로 전달하지 않기
- provider 로그는 token을 포함할 수 있으므로 공유 전에 제거

V1은 파일 기반 대체를 지원합니다. token을 별도 파일에 두려면:

```jsonc
"apiKey": "{file:~/.secrets/personal-llm-api-key}"
```

파일을 직접 수정하는 대신 이 방식을 사용하면 config 백업에서 token을 제외하기 쉽습니다.

## 10. release 무결성 확인

공용 release가 실행 중 변경되지 않았는지 확인:

```bash
find /opt/company-opencode/current -type f -mmin -10 -print
```

release에 `SHA256SUMS`이 있다면:

```bash
cd /opt/company-opencode/current
sha256sum -c SHA256SUMS
```
