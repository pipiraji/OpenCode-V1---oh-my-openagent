> ## Documentation Index
> Fetch the complete documentation index at: https://code.claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# hooks를 사용하여 작업 자동화

> Claude Code가 파일을 편집하거나 작업을 완료하거나 입력이 필요할 때 자동으로 셸 명령을 실행합니다. 코드 형식 지정, 알림 전송, 명령 검증 및 프로젝트 규칙 적용합니다.

Hooks는 사용자 정의 셸 명령입니다. Claude Code는 라이프사이클의 특정 지점에서 이들을 실행하며, 이는 결정론적 제어를 제공합니다. LLM이 실행하도록 선택하는 것에 의존하기보다는 특정 작업이 항상 발생합니다. Hooks를 사용하여 프로젝트 규칙을 적용하고, 반복적인 작업을 자동화하며, Claude Code를 기존 도구와 통합합니다.

판단이 필요한 결정의 경우 결정론적 규칙이 아닌 경우, [프롬프트 기반 hooks](#prompt-based-hooks) 또는 [에이전트 기반 hooks](#agent-based-hooks)를 사용할 수도 있습니다. 이들은 Claude 모델을 사용하여 조건을 평가합니다.

Claude Code를 확장하는 다른 방법은 [skills](/docs/ko/skills)를 참조하여 Claude에 추가 지침과 실행 가능한 명령을 제공하고, [subagents](/docs/ko/sub-agents)를 사용하여 격리된 컨텍스트에서 작업을 실행하며, [plugins](/docs/ko/plugins/overview)를 사용하여 프로젝트 전체에서 공유할 확장을 패키징합니다.

<Tip>
  이 가이드는 일반적인 사용 사례와 시작 방법을 다룹니다. 전체 이벤트 스키마, JSON 입출력 형식 및 비동기 hooks 및 MCP 도구 hooks와 같은 고급 기능은 [Hooks 참조](/docs/ko/hooks)를 참조하세요.
</Tip>

<h2 id="set-up-your-first-hook">
  첫 번째 훅 설정하기
</h2>

훅을 만들려면 [설정 파일](#configure-hook-location)에 `hooks` 블록을 추가합니다. 이 안내에서는 데스크톱 알림 훅을 만듭니다. 이 훅을 사용하면 터미널을 계속 지켜보지 않아도 Claude가 입력을 기다릴 때마다 알림을 받을 수 있습니다.

<Steps>
  <Step title="설정에 훅 추가하기">
    `~/.claude/settings.json`을 열고 `Notification` 훅을 추가합니다. 파일이 없으면 새로 만듭니다. 아래 예시는 macOS용 `osascript`를 사용합니다. Linux 및 Windows용 명령은 [Claude가 입력을 필요로 할 때 알림 받기](#get-notified-when-claude-needs-input)를 참조하세요.

    ```json theme={null}
    {
      "hooks": {
        "Notification": [
          {
            "matcher": "",
            "hooks": [
              {
                "type": "command",
                "command": "osascript -e 'display notification \"Claude Code needs your attention\" with title \"Claude Code\"'"
              }
            ]
          }
        ]
      }
    }
    ```

    설정 파일에 이미 `hooks` 키가 있다면 전체 객체를 교체하지 말고 기존 이벤트 키와 같은 수준에 `Notification`을 추가합니다. 각 이벤트 이름은 단일 `hooks` 객체 안의 키입니다.

    ```json theme={null}
    {
      "hooks": {
        "PostToolUse": [
          {
            "matcher": "Edit|Write",
            "hooks": [{ "type": "command", "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write" }]
          }
        ],
        "Notification": [
          {
            "matcher": "",
            "hooks": [{ "type": "command", "command": "osascript -e 'display notification \"Claude Code needs your attention\" with title \"Claude Code\"'" }]
          }
        ]
      }
    }
    ```

    CLI에서 원하는 내용을 설명하여 Claude에게 훅 작성을 요청할 수도 있습니다.
  </Step>

  <Step title="구성 확인하기">
    Claude Code 프롬프트에 `/hooks`를 입력하여 훅 브라우저를 엽니다. 새 훅이 목록의 `Notification` 아래에 표시됩니다.
  </Step>

  <Step title="훅 테스트하기">
    `Esc`를 눌러 CLI로 돌아갑니다. 상태 표시줄에 `⏸ manual mode on`이 표시될 때까지 `Shift+Tab`을 누른 다음, Claude에게 권한이 필요한 작업을 요청하고 터미널에서 다른 곳으로 전환합니다. 데스크톱 알림이 표시되어야 합니다.
  </Step>
</Steps>

<h2 id="what-you-can-automate">
  자동화할 수 있는 것
</h2>

Hooks를 사용하면 Claude Code의 라이프사이클의 주요 지점에서 코드를 실행할 수 있습니다: 편집 후 파일 형식 지정, 실행 전 명령 차단, Claude가 입력이 필요할 때 알림 전송, 세션 시작 시 컨텍스트 주입 등. 전체 hook 이벤트 목록은 [Hooks 참조](/docs/ko/hooks#hook-lifecycle)를 참조하세요.

각 예제에는 [설정 파일](#configure-hook-location)에 추가하는 즉시 사용 가능한 구성 블록이 포함되어 있습니다.

별도의 모델 검토를 실행하고 결과를 세션에 다시 피드백하는 hooks의 프로덕션 예제는 [`security-guidance` 플러그인이 Claude Code와 통합되는 방식](/docs/ko/security-guidance#how-the-plugin-integrates-with-claude-code)을 참조하세요.

<h3 id="get-notified-when-claude-needs-input">
  Claude가 입력이 필요할 때 알림 받기
</h3>

Claude가 작업을 완료하고 입력이 필요할 때마다 데스크톱 알림을 받으므로 터미널을 확인하지 않고 다른 작업으로 전환할 수 있습니다.

이 훅은 Claude가 입력 또는 권한을 기다릴 때 Claude Code가 발생시키는 `Notification` 이벤트를 사용합니다. 정확한 시점은 [각 알림 유형이 발생하는 시점](/docs/ko/hooks#notification)을 참조하세요.

아래의 각 탭은 플랫폼의 기본 알림 명령을 사용합니다. `~/.claude/settings.json`에 추가합니다:

<Tabs>
  <Tab title="macOS">
    ```json theme={null}
    {
      "hooks": {
        "Notification": [
          {
            "matcher": "",
            "hooks": [
              {
                "type": "command",
                "command": "osascript -e 'display notification \"Claude Code needs your attention\" with title \"Claude Code\"'"
              }
            ]
          }
        ]
      }
    }
    ```

    <Accordion title="알림이 나타나지 않으면">
      `osascript`는 기본 제공 Script Editor 앱을 통해 알림을 라우팅합니다. Script Editor에 알림 권한이 없으면 명령이 아무 표시 없이 실패하고 macOS는 권한을 부여하라고 확인을 요청하지 않습니다.

      Terminal에서 이를 한 번 실행하여 Script Editor가 알림 설정에 나타나도록 합니다:

      ```bash theme={null}
      osascript -e 'display notification "test"'
      ```

      아직 아무것도 나타나지 않습니다. **시스템 설정 > 알림**을 열고 목록에서 **Script Editor**를 찾은 다음 **알림 허용**을 켭니다. 명령을 다시 실행하여 테스트 알림이 나타나는지 확인합니다.
    </Accordion>
  </Tab>

  <Tab title="Linux">
    ```json theme={null}
    {
      "hooks": {
        "Notification": [
          {
            "matcher": "",
            "hooks": [
              {
                "type": "command",
                "command": "notify-send 'Claude Code' 'Claude Code needs your attention'"
              }
            ]
          }
        ]
      }
    }
    ```

    <Accordion title="알림이 나타나지 않으면">
      `notify-send`는 데스크톱 알림 데몬이 필요하며, 헤드리스 서버, SSH 세션 및 대부분의 컨테이너에는 이것이 없습니다. 먼저 명령을 직접 테스트합니다:

      ```bash theme={null}
      notify-send 'Claude Code' 'test'
      ```

      명령을 찾을 수 없으면 Debian 및 Ubuntu에서 `libnotify-bin` 패키지를 설치하거나 배포판의 동등한 패키지를 설치합니다.
    </Accordion>
  </Tab>

  <Tab title="Windows (PowerShell)">
    ```json theme={null}
    {
      "hooks": {
        "Notification": [
          {
            "matcher": "",
            "hooks": [
              {
                "type": "command",
                "command": "powershell.exe -Command \"[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('Claude Code needs your attention', 'Claude Code')\""
              }
            ]
          }
        ]
      }
    }
    ```

    <Accordion title="대화 상자가 나타나지 않으면">
      이 명령은 화면 모서리의 알림이 아닌 대화 상자를 열므로 대화 상자가 터미널 창 뒤에서 열릴 수 있습니다. 먼저 PowerShell에서 명령을 직접 테스트합니다.

      Claude Code를 WSL 내부에서 실행하는 경우 `powershell.exe`는 Windows interop을 통해 `PATH`에서 사용 가능해야 합니다.
    </Accordion>
  </Tab>
</Tabs>

빈 `matcher`는 모든 알림 유형에서 발생합니다. 특정 이벤트에서만 발생하도록 하려면 다음 값 중 하나로 설정합니다:

| Matcher | 발생 시점 |
| :- | :- |
| `permission_prompt` | Claude가 도구 사용을 승인하거나 샌드박스된 명령의 [네트워크 요청](/docs/ko/sandboxing#network-isolation)을 승인하도록 요청할 때, 그리고 프롬프트가 약 6초 동안 대기했을 때 |
| `idle_prompt` | Claude가 약 60초 전에 응답을 완료했고 입력하지 않았을 때 |
| `auth_success` | 인증이 완료될 때 |
| `elicitation_dialog` | MCP 서버가 유도 양식을 열고 약 6초 동안 입력하지 않았을 때 |
| `elicitation_url_dialog` | MCP 서버가 브라우저 URL을 열도록 요청하고 약 6초 동안 입력하지 않았을 때 |
| `elicitation_complete` | MCP 서버가 [URL 모드 유도](/docs/ko/hooks#elicitation-input)가 완료되었음을 보고할 때 |
| `elicitation_response` | MCP 유도 응답이 서버로 다시 전송될 때 |
| `agent_needs_input` | 백그라운드 세션이 입력을 기다리기 시작하고 [agent view](/docs/ko/agent-view)가 열려 있을 때, 또는 현재 세션이 [agent team 팀원의 터미널 설정 질문](/docs/ko/agent-teams#choose-a-display-mode)을 물어보거나 [분류기 요청 요금](/docs/ko/auto-mode-classifier-billing)에 대한 자동 모드의 공지를 표시하고 약 6초 동안 입력하지 않았을 때 |
| `agent_completed` | 백그라운드 세션이 완료되거나 실패합니다. [agent view](/docs/ko/agent-view)가 열려 있을 때만 발생합니다 |
| `quota_auto_resume_fired` | Claude Code가 claude.ai 사용 제한으로 일시 중지된 작업을 계속합니다: 재설정 시 또는 Claude Code 중에 수행하는 작업(예: 사용 크레딧 추가, 플랜 업그레이드 또는 모델 전환)으로 인해 사용 가능한 사용량이 더 빨리 제공될 때, [모델 설정 예외](/docs/ko/interactive-mode#wait-for-a-usage-limit-to-reset) 포함 |
| `quota_auto_resume_stale` | claude.ai 사용 제한이 컴퓨터가 약 30분 이상 절전 상태였을 때 재설정됩니다. Claude Code는 계속하지 않고 `Enter`를 누르기를 기다립니다. 더 짧은 절전 후에는 계속하고 대신 `quota_auto_resume_fired`를 발생시킵니다 |
| `quota_auto_resume_disabled` | Claude Code가 작업을 계속하지 않고 claude.ai 사용 제한 대기를 종료합니다: [`autoContinueAtUsageLimit`](/docs/ko/settings-reference#autocontinueatusagelimit)이 꺼졌거나 Claude Code가 자체적으로 시작한 대기 중에 재설정이 24시간 이상 멀어졌거나, 계속된 작업이 계속 제한에 도달했거나, 계속이 모델에 도달하기 전에 차단되었습니다. `Esc` 또는 `Ctrl+C`를 누르거나 **자동으로 계속하지 않음**을 선택할 때는 발생하지 않습니다 |

Claude Code는 터미널과 Agent SDK를 통해 권한 요청에 응답하는 Claude Desktop, VS Code 확장 및 기타 호스트에서 `permission_prompt`를 다르게 시간 지정합니다. 두 시간 지정 모두에 대해 [각 알림 유형이 발생하는 시점](/docs/ko/hooks#notification)을 참조하세요.

`quota_auto_resume_fired`, `quota_auto_resume_stale` 및 `quota_auto_resume_disabled` matcher는 Claude Code v2.1.234 이상이 필요합니다.

터미널 세션에서 샌드박스된 명령의 네트워크 요청에 대한 `permission_prompt`는 Claude Code v2.1.246 이상이 필요합니다.

팀원의 터미널 설정 질문에 대한 `agent_needs_input`은 Claude Code v2.1.248 이상이 필요합니다.

Claude Code 프롬프트에서 `/hooks`를 입력하고 `Notification` 아래에 훅이 표시되는지 확인합니다.

<h3 id="auto-format-code-after-edits">
  편집 후 코드 자동 형식 지정
</h3>

Claude가 편집하는 모든 파일에서 [Prettier](https://prettier.io/)를 자동으로 실행하여 수동 개입 없이 형식이 일관되게 유지되도록 합니다.

이 hook은 `PostToolUse` 이벤트를 `Edit|Write` matcher와 함께 사용하므로 파일 편집 도구 후에만 실행됩니다. 명령은 [`jq`](https://jqlang.org/)를 사용하여 편집된 파일 경로를 추출하고 Prettier에 전달합니다. 프로젝트 루트의 `.claude/settings.json`에 추가합니다:

```json theme={null}
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"
          }
        ]
      }
    ]
  }
}
```

hook을 테스트하려면 Claude에게 JavaScript 파일에 단일 따옴표 문자열이 있는 줄을 추가하도록 요청한 다음 파일을 엽니다: Prettier의 기본 설정을 사용하면 hook이 이를 이중 따옴표로 다시 작성합니다.

훅이 성공하면 Claude Code는 대화에서 아무것도 표시하지 않습니다. 훅이 실행되었는지 확인하려면 편집된 파일이 다시 형식화되었는지 확인하거나 [훅이 수행한 작업 확인](#check-what-a-hook-did)을 참조하세요.

`Bash` 명령이 파일을 다시 작성할 때를 포함하여 파일이 어떻게 변경되든 특정 파일을 다시 형식화하려면 대신 [FileChanged](/docs/ko/hooks#filechanged) hook을 사용합니다.

<Note>
  이 페이지의 Bash 예제는 JSON 구문 분석을 위해 `jq`를 사용합니다. macOS에서 `brew install jq`로, Debian 및 Ubuntu에서 `apt-get install jq`로 설치하거나 [`jq` 다운로드](https://jqlang.org/download/)를 참조하세요.
</Note>

<h3 id="block-edits-to-protected-files">
  보호된 파일에 대한 편집 차단
</h3>

Claude가 `.env`, `package-lock.json` 또는 `.git/`의 모든 항목과 같은 민감한 파일을 수정하지 못하도록 방지합니다. Claude는 편집이 차단된 이유를 설명하는 피드백을 받으므로 접근 방식을 조정할 수 있습니다.

이 예제는 hook이 호출하는 별도의 스크립트 파일을 사용합니다. 스크립트는 대상 파일 경로를 보호된 패턴 목록과 비교하고 종료 코드 2로 종료하여 편집을 차단합니다.

<Steps>
  <Step title="hook 스크립트 만들기">
    이를 `.claude/hooks/protect-files.sh`에 저장합니다:

    ```bash theme={null}
    #!/bin/bash
    # protect-files.sh

    INPUT=$(cat)
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

    # Windows 백슬래시 구분자를 정규화하여 아래 패턴이 일치하도록 합니다
    FILE_PATH="${FILE_PATH//\\//}"

    PROTECTED_PATTERNS=(".env" "package-lock.json" ".git/")

    for pattern in "${PROTECTED_PATTERNS[@]}"; do
      if [[ "$FILE_PATH" == *"$pattern"* ]]; then
        echo "Blocked: $FILE_PATH matches protected pattern '$pattern'" >&2
        exit 2
      fi
    done

    exit 0
    ```
  </Step>

  <Step title="macOS 및 Linux에서 스크립트를 실행 가능하게 만들기">
    Hook 스크립트는 Claude Code가 실행하려면 실행 가능해야 합니다:

    ```bash theme={null}
    chmod +x .claude/hooks/protect-files.sh
    ```
  </Step>

  <Step title="hook 등록">
    모든 `Edit` 또는 `Write` 도구 호출 전에 스크립트를 실행하는 `PreToolUse` hook을 `.claude/settings.json`에 추가합니다:

    ```json theme={null}
    {
      "hooks": {
        "PreToolUse": [
          {
            "matcher": "Edit|Write",
            "hooks": [
              {
                "type": "command",
                "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/protect-files.sh"
              }
            ]
          }
        ]
      }
    }
    ```
  </Step>

  <Step title="hook 테스트">
    Claude에게 `.env` 파일에 주석을 추가하도록 요청합니다. Claude Code는 실행 전에 편집을 차단하고 스크립트의 `Blocked:` 메시지를 Claude에게 피드백으로 전달합니다.
  </Step>
</Steps>

<h3 id="re-inject-context-after-compaction">
  압축 후 컨텍스트 다시 주입
</h3>

Claude의 컨텍스트 윈도우가 가득 차면 압축은 대화를 요약하여 공간을 확보합니다. 이는 중요한 세부 정보를 잃을 수 있습니다. `compact` matcher와 함께 `SessionStart` hook을 사용하여 모든 압축 후 중요한 컨텍스트를 다시 주입합니다.

Claude Code는 명령이 stdout에 쓰는 일반 텍스트를 Claude의 컨텍스트에 추가합니다. 이 예제는 Claude에게 프로젝트 규칙과 최근 작업을 상기시킵니다. 프로젝트 루트의 `.claude/settings.json`에 추가합니다:

```json theme={null}
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Reminder: use Bun, not npm. Run bun test before committing. Current sprint: auth refactor.'"
          }
        ]
      }
    ]
  }
}
```

`echo`를 `git log --oneline -5`와 같이 동적 출력을 생성하는 모든 명령으로 바꿀 수 있습니다. 모든 세션 시작 시 컨텍스트를 주입하려면 [CLAUDE.md](/docs/ko/memory) 사용을 고려하세요. 환경 변수는 [`CLAUDE_ENV_FILE`](/docs/ko/hooks#persist-environment-variables)을 참조하세요.

<h3 id="audit-configuration-changes">
  구성 변경 감사
</h3>

세션 중에 설정 또는 skills 파일이 변경될 때를 추적합니다. `ConfigChange` 이벤트는 외부 프로세스 또는 편집기가 구성 파일을 수정할 때 발생하므로 규정 준수를 위해 변경 사항을 기록하거나 무단 수정을 차단할 수 있습니다.

이 예제는 각 변경을 감사 로그에 추가합니다. `~/.claude/settings.json`에 추가합니다:

```json theme={null}
{
  "hooks": {
    "ConfigChange": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "jq -c '{timestamp: now | todate, source: .source, file: .file_path}' >> ~/claude-config-audit.log"
          }
        ]
      }
    ]
  }
}
```

Matcher는 구성 유형으로 필터링합니다: `user_settings`, `project_settings`, `local_settings`, `policy_settings` 또는 `skills`. 변경이 적용되지 않도록 차단하려면 종료 코드 2로 종료하거나 `{"decision": "block"}`을 반환합니다. 전체 입력 스키마는 [ConfigChange 참조](/docs/ko/hooks#configchange)를 참조하세요.

hook이 변경 사항을 기록하는지 확인하려면 세션이 실행 중인 동안 다른 편집기에서 설정 파일을 편집한 다음 `~/claude-config-audit.log`를 엽니다: hook은 타임스탬프, 소스 및 파일 경로가 있는 변경당 하나의 JSON 줄을 추가합니다.

<h3 id="reload-environment-when-directory-or-files-change">
  디렉토리 또는 파일이 변경될 때 환경 다시 로드
</h3>

일부 프로젝트는 어느 디렉토리에 있는지에 따라 다른 환경 변수를 설정합니다. [direnv](https://direnv.net/)와 같은 도구는 셸에서 자동으로 이를 수행하지만 Claude의 Bash 도구는 자체적으로 해당 변경 사항을 선택하지 않습니다.

`SessionStart` hook을 `CwdChanged` hook과 쌍으로 사용하면 이를 해결합니다. `SessionStart`는 시작한 디렉토리에 대한 변수를 로드하고 `CwdChanged`는 Claude가 디렉토리를 변경할 때마다 이를 다시 로드합니다. 둘 다 `CLAUDE_ENV_FILE`에 쓰며, Claude Code는 각 Bash 명령 전에 이를 스크립트 프리앰블로 실행합니다. `~/.claude/settings.json`에 추가합니다:

```json theme={null}
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "direnv export bash > \"$CLAUDE_ENV_FILE\""
          }
        ]
      }
    ],
    "CwdChanged": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "direnv export bash > \"$CLAUDE_ENV_FILE\""
          }
        ]
      }
    ]
  }
}
```

`direnv allow`를 `.envrc`가 있는 각 디렉토리에서 한 번 실행하여 direnv가 이를 로드할 수 있도록 허용합니다. direnv 대신 devbox 또는 nix를 사용하는 경우 `direnv export bash` 대신 `devbox shellenv` 또는 `devbox global shellenv`를 사용하면 동일한 패턴이 작동합니다.

모든 디렉토리 변경이 아닌 특정 파일에 반응하려면 `FileChanged`를 `matcher`와 함께 사용하여 감시할 파일 이름을 나열합니다 (파이프로 구분). 감시 목록을 구성하기 위해 이 값은 정규식으로 평가되지 않고 리터럴 파일 이름으로 분할됩니다. [FileChanged](/docs/ko/hooks#filechanged)를 참조하여 파일이 변경될 때 어떤 hook 그룹이 실행되는지 필터링하는 방법도 확인하세요. 이 예제는 작업 디렉토리에서 `.envrc` 및 `.env`를 감시합니다:

```json theme={null}
{
  "hooks": {
    "FileChanged": [
      {
        "matcher": ".envrc|.env",
        "hooks": [
          {
            "type": "command",
            "command": "direnv export bash > \"$CLAUDE_ENV_FILE\""
          }
        ]
      }
    ]
  }
}
```

입력 스키마, `watchPaths` 출력 및 `CLAUDE_ENV_FILE` 세부 정보는 [CwdChanged](/docs/ko/hooks#cwdchanged) 및 [FileChanged](/docs/ko/hooks#filechanged) 참조 항목을 참조하세요.

<h3 id="auto-approve-specific-permission-prompts">
  특정 권한 프롬프트 자동 승인
</h3>

항상 허용하는 도구 호출에 대한 승인 대화를 건너뜁니다. 이 예제는 `ExitPlanMode`를 자동 승인합니다. 이는 Claude가 계획 제시를 완료하고 진행을 요청할 때 호출하는 도구이므로 계획이 준비될 때마다 프롬프트가 표시되지 않습니다.

위의 종료 코드 예제와 달리 자동 승인을 위해서는 hook이 JSON 결정을 stdout에 작성해야 합니다. Claude Code는 권한을 요청하려고 할 때 `PermissionRequest` hook을 실행하며, hook이 `"behavior": "allow"`를 반환하면 Claude Code는 사용자 대신 요청에 응답합니다.

Matcher는 hook을 `ExitPlanMode`로만 범위를 지정하므로 다른 프롬프트는 영향을 받지 않습니다. `~/.claude/settings.json`에 추가합니다:

```json theme={null}
{
  "hooks": {
    "PermissionRequest": [
      {
        "matcher": "ExitPlanMode",
        "hooks": [
          {
            "type": "command",
            "command": "echo '{\"hookSpecificOutput\": {\"hookEventName\": \"PermissionRequest\", \"decision\": {\"behavior\": \"allow\"}}}'"
          }
        ]
      }
    ]
  }
}
```

Hook이 승인하면 Claude Code는 계획 모드를 종료하고 계획 모드에 들어가기 전에 활성화되었던 권한 모드를 복원합니다. 트랜스크립트는 대화가 나타났을 위치에 "Allowed by PermissionRequest hook"을 표시합니다. Hook 경로는 항상 현재 대화를 유지합니다: 대화가 할 수 있는 방식으로 컨텍스트를 지우고 새로운 구현 세션을 시작할 수 없습니다.

대신 특정 권한 모드를 설정하려면 hook의 출력에 `setMode` 항목이 있는 `updatedPermissions` 배열이 포함될 수 있습니다. `mode` 값은 `default`, `acceptEdits` 또는 `bypassPermissions`과 같은 모든 권한 모드이며 `destination: "session"`은 현재 세션에만 적용합니다.

<Note>
  `bypassPermissions`은 bypass 모드를 이미 사용할 수 있는 상태로 세션을 시작한 경우에만 적용됩니다: `--dangerously-skip-permissions`, `--permission-mode bypassPermissions`, `--allow-dangerously-skip-permissions` 또는 [사용자, `--settings` 또는 관리 설정](/docs/ko/settings-reference#permissions-defaultmode)의 `permissions.defaultMode: "bypassPermissions"`. bypass 모드가 [`permissions.disableBypassPermissionsMode`](/docs/ko/permissions#managed-settings)로 비활성화되었거나 [제한된 모드](/docs/ko/cli-reference#cli-flags)에서 세션을 시작한 경우에는 적용되지 않습니다.

  Claude Code는 절대 이를 `defaultMode`로 저장하지 않습니다.
</Note>

세션을 `acceptEdits`로 전환하려면 hook이 이 JSON을 stdout에 작성합니다:

```json theme={null}
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow",
      "updatedPermissions": [
        { "type": "setMode", "mode": "acceptEdits", "destination": "session" }
      ]
    }
  }
}
```

Matcher를 가능한 한 좁게 유지합니다. `.*`와 일치하거나 matcher를 비워두면 파일 쓰기 및 셸 명령을 포함한 모든 권한 프롬프트를 자동 승인합니다. 전체 결정 필드 집합은 [PermissionRequest 참조](/docs/ko/hooks#permissionrequest-decision-control)를 참조하세요.

<h2 id="how-hooks-work">
  Hooks 작동 방식
</h2>

Claude Code는 라이프사이클의 특정 지점에서 hook 이벤트를 발생시킵니다. 이벤트가 발생하면 Claude Code는 일치하는 모든 hooks를 병렬로 실행합니다. [Hook 핸들러 필드](/docs/ko/hooks#hook-handler-fields)를 참조하여 중복 핸들러가 처리되는 방식을 확인하세요. 아래 표는 각 이벤트와 발생 시기를 보여줍니다:

| 이벤트 | 발생 시점 |
| :- | :- |
| `SessionStart` | 세션이 시작되거나 재개될 때 |
| `Setup` | `--init-only`로 Claude Code를 시작하거나, `-p` 모드에서 `--init` 또는 `--maintenance`로 시작할 때. CI 또는 스크립트에서 일회성 준비를 위함 |
| `UserPromptSubmit` | 프롬프트를 제출할 때, Claude가 처리하기 전. [Claude Code가 자체적으로 시작하는 턴](/docs/ko/hooks#userpromptsubmit)에서도 발생 |
| `UserPromptExpansion` | 사용자가 입력한 명령이 프롬프트로 확장될 때, Claude에 도달하기 전. 확장을 차단할 수 있음 |
| `PreToolUse` | 도구 호출이 실행되기 전. 차단할 수 있음 |
| `PermissionRequest` | 도구 호출이 권한 결정이 필요할 때 |
| `PermissionDenied` | 자동 모드가 도구 호출을 거부할 때, 분류기 판정이 없는 거부 포함. JSON `hookSpecificOutput.retry: true`를 사용하여 모델이 거부된 도구 호출을 재시도할 수 있음을 알립니다. Claude Code는 분류기가 판정을 내리지 않았을 때 `retry`를 무시합니다 |
| `PostToolUse` | 도구 호출이 성공한 후 |
| `PostToolUseFailure` | 도구 호출이 실패한 후 |
| `PostToolBatch` | 병렬 도구 호출의 전체 배치가 해결된 후, 다음 모델 호출 전 |
| `Notification` | Claude Code가 알림을 보낼 때 |
| `MessageDisplay` | 어시스턴트 메시지 텍스트가 표시되는 동안 |
| `SubagentStart` | 서브에이전트가 생성될 때 |
| `SubagentStop` | 서브에이전트가 완료될 때 |
| `TaskCreated` | `TaskCreate`를 통해 작업이 생성될 때 |
| `TaskCompleted` | 작업이 완료로 표시될 때 |
| `Stop` | Claude가 응답을 마칠 때 |
| `StopFailure` | API 오류로 인해 턴이 종료될 때 |
| `TeammateIdle` | [에이전트 팀](/docs/ko/agent-teams) 팀원이 유휴 상태가 될 때 |
| `InstructionsLoaded` | CLAUDE.md 또는 `.claude/rules/*.md` 파일이 컨텍스트에 로드될 때. 세션 시작 시 및 세션 중에 파일이 지연 로드될 때 발생 |
| `ConfigChange` | 세션 중에 구성 파일이 변경될 때 |
| `CwdChanged` | 작업 디렉토리가 변경될 때, 예를 들어 Claude가 `cd` 명령을 실행할 때. direnv와 같은 도구를 사용한 반응형 환경 관리에 유용 |
| `DirectoryAdded` | 작업 디렉토리가 세션 중에 `/add-dir` 또는 SDK `register_repo_root` 제어 요청을 통해 추가될 때 |
| `FileChanged` | 감시 중인 파일이 디스크에서 변경될 때. `matcher` 필드는 감시할 파일명을 지정합니다 |
| `WorktreeCreate` | 워크트리가 `--worktree`, `isolation: "worktree"`를 통해 생성되거나 백그라운드 세션을 위해 생성될 때. 기본 git 동작을 대체합니다 |
| `WorktreeRemove` | `WorktreeCreate` 훅이 생성한 워크트리가 제거될 때 |
| `PreCompact` | 컨텍스트 압축 전 |
| `PostCompact` | 컨텍스트 압축이 완료된 후 |
| `PreModelSwitch` | Claude Code가 사용자 또는 클라이언트가 요청한 모델 전환을 적용하기 전. 전환을 차단할 수 있음 |
| `PostModelSwitch` | 세션의 모델이 변경된 후, Claude Code가 자체적으로 수행하는 변경(예: 세션을 재개할 때 모델 복원) 포함 |
| `Elicitation` | MCP 서버가 도구 호출 중에 사용자 입력을 요청할 때 |
| `ElicitationResult` | 사용자가 MCP 유도에 응답한 후, 응답이 서버로 다시 전송되기 전 |
| `SessionEnd` | 세션이 종료될 때 |

각 hook에는 실행 방식을 결정하는 `type`이 있습니다. 대부분의 hooks는 `"type": "command"`를 사용하여 셸 명령을 실행합니다. 네 가지 다른 유형을 사용할 수 있습니다:

* `"type": "http"`: 이벤트 데이터를 URL에 POST합니다. [HTTP hooks](#http-hooks)를 참조하세요.
* `"type": "mcp_tool"`: 구성된 MCP 서버에서 도구를 호출합니다. [MCP tool hooks](/docs/ko/hooks#mcp-tool-hook-fields)를 참조하세요.
* `"type": "prompt"`: 단일 턴 LLM 평가입니다. [프롬프트 기반 hooks](#prompt-based-hooks)를 참조하세요.
* `"type": "agent"`: 도구 액세스를 통한 다중 턴 검증입니다. Agent hooks는 실험적이며 변경될 수 있습니다. [Agent 기반 hooks](#agent-based-hooks)를 참조하세요.

<h3 id="combine-results-from-multiple-hooks">
  여러 hooks의 결과 결합
</h3>

여러 hooks가 동일한 이벤트와 일치하면 모든 hook의 명령이 완료될 때까지 실행된 후 Claude Code가 결과를 병합합니다. 하나의 hook이 `deny`를 반환하는 것이 형제 hooks의 실행을 중지하지 않습니다. 한 hook의 `deny`가 다른 hook의 부작용을 억제하는 것에 의존하지 마세요.

모든 일치하는 hooks가 완료된 후 Claude Code는 출력을 결합합니다. `PreToolUse` 권한 결정의 경우 가장 제한적인 답변이 우선합니다: `deny`, `defer`, `ask`, `allow` 순서입니다. `additionalContext`의 텍스트는 모든 hook에서 유지되고 Claude와 함께 전달됩니다.

아래 예제는 `Bash`에 두 개의 `PreToolUse` hooks를 등록합니다. 첫 번째는 모든 명령을 로그 파일에 추가하고 0으로 종료합니다. 두 번째는 명령에 `rm -rf`가 포함되어 있을 때 거부하기 위해 2로 종료하는 스크립트를 실행합니다:

```json theme={null}
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r .tool_input.command >> ~/.claude/bash.log"
          },
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-rm-rf.sh"
          }
        ]
      }
    ]
  }
}
```

Claude가 `rm -rf /tmp/build`를 실행하려고 할 때 두 hooks 모두 병렬로 실행됩니다. 로깅 hook은 명령을 `~/.claude/bash.log`에 쓰고 0으로 종료하여 결정이 없음을 보고합니다. 보안 규칙 hook은 2로 종료하여 도구 호출을 거부합니다. 거부가 우선하므로 Claude Code는 명령을 차단하고 Claude에게 보안 규칙의 stderr를 표시합니다. 로깅 hook이 이미 실행되었기 때문에 로그 항목은 여전히 기록됩니다.

<h3 id="read-input-and-return-output">
  입력 읽기 및 출력 반환
</h3>

Hooks는 stdin, stdout, stderr 및 종료 코드를 통해 Claude Code와 통신합니다. 이벤트가 발생하면 Claude Code는 이벤트별 데이터를 JSON으로 스크립트의 stdin에 전달합니다. 스크립트는 해당 데이터를 읽고 작업을 수행한 다음 종료 코드를 통해 Claude Code에 다음 작업을 알립니다.

<h4 id="hook-input">
  Hook 입력
</h4>

모든 이벤트에는 `session_id`(세션의 고유 ID) 및 `cwd`(이벤트가 발생했을 때의 작업 디렉토리)와 같은 공통 필드가 포함되지만 각 이벤트 유형은 다른 데이터를 추가합니다. Claude가 Bash 명령을 실행할 때 `PreToolUse` hook은 stdin에서 다음 필드를 받습니다:

* `hook_event_name`: hook을 트리거한 이벤트
* `tool_name`: Claude가 사용하려는 도구
* `tool_input`: Claude가 도구에 전달한 인수입니다. Bash의 경우 `command` 필드는 셸 명령을 포함합니다.

예를 들어 `npm test` 명령에 대한 hook 입력은 다음과 같습니다:

```json theme={null}
{
  "session_id": "abc123",
  "cwd": "/Users/sarah/myproject",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "npm test"
  }
}
```

스크립트는 해당 JSON을 구문 분석하고 해당 필드에 대해 작동할 수 있습니다. `UserPromptSubmit` hooks는 `prompt` 텍스트를 대신 받고, `SessionStart` hooks는 `startup`, `resume`, `clear`, `compact` 또는 `fork`의 `source`를 받으며, 등등입니다. 공유 필드는 참조의 [공통 입력 필드](/docs/ko/hooks#common-input-fields)를 참조하고 각 이벤트별 섹션에서 이벤트별 스키마를 참조하세요.

<h4 id="hook-output">
  Hook 출력
</h4>

스크립트는 stdout 또는 stderr에 쓰고 특정 코드로 종료하여 Claude Code에 다음 작업을 알립니다. 다음 `PreToolUse` hook은 명령을 차단합니다:

```bash theme={null}
#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

if echo "$COMMAND" | grep -q "drop table"; then
  echo "Blocked: dropping tables is not allowed" >&2  # stderr는 Claude의 피드백이 됩니다
  exit 2 # exit 2 = 작업 차단
fi

exit 0  # exit 0 = 결정 없음; 정상적인 권한 흐름이 적용됩니다
```

종료 코드는 다음에 일어날 일을 결정합니다:

* **Exit 0**: hook이 종료 코드를 통해 이의를 제기하지 않습니다.
  * `PreToolUse` hook의 경우 이것은 도구 호출을 승인하지 않습니다: 정상적인 [권한 흐름](/docs/ko/permissions)이 여전히 적용됩니다.
  * `UserPromptSubmit`, `UserPromptExpansion`, `SessionStart` 및 `PostModelSwitch` hooks의 경우 Claude Code는 stdout을 [일반 텍스트로 처리](/docs/ko/hooks#exit-code-0)하여 Claude의 컨텍스트에 추가합니다.
* **Exit 2**: Claude Code가 작업을 차단합니다. stderr에 이유를 작성하세요. 이것이 어디에 도달하는지는 이벤트에 따라 다릅니다: 일부 이벤트는 이를 Claude에 피드백으로 전달하여 조정할 수 있도록 하고, 다른 이벤트는 사용자에게 표시하며, `ConfigChange` 및 `Elicitation`과 같은 몇 가지는 메시지를 표시하지 않습니다. 일부 이벤트는 차단될 수 없습니다: `SessionStart` 및 기타의 경우 exit 2는 stderr를 사용자에게 표시하고 실행이 계속됩니다. 전체 목록은 [이벤트별 exit 코드 2 동작](/docs/ko/hooks#exit-code-2-behavior-per-event)을 참조하세요.
* **다른 종료 코드**: 대부분의 이벤트의 경우 결과는 hook이 stdout에 인쇄한 내용에 따라 다릅니다:
  * 스키마 검증을 통과하는 구문 분석된 객체: Claude Code는 종료 코드를 무시하고 JSON만이 결과를 결정하며 hook은 오류로 보고되지 않습니다. `WorktreeCreate`가 0이 아닌 종료에서 실패하는 것과 같은 이벤트별 예외는 참조의 [Exit code output](/docs/ko/hooks#exit-code-output) 섹션에 나열됩니다.
  * 스키마 검증에 실패하는 구문 분석된 객체 또는 Claude Code가 [JSON으로 구문 분석](/docs/ko/hooks#exit-code-0)하려고 하지만 유효한 JSON이 아닌 stdout: 차단되지 않는 오류입니다. 공지는 검증 또는 구문 분석 메시지를 포함합니다.
  * Claude Code가 [일반 텍스트로 처리](/docs/ko/hooks#exit-code-0)하는 stdout 또는 빈 stdout: 작업이 차단되지 않는 오류로 진행됩니다. 트랜스크립트는 `<hook name> hook error` 공지를 표시한 후 `Failed with non-blocking status code:`로 접두사가 붙은 stderr의 첫 번째 줄을 표시합니다. 전체 stderr를 캡처하려면 `claude --debug`를 사용하거나 세션 중에 `/debug`를 실행하여 [디버그 로깅](/docs/ko/hooks#debug-hooks)을 활성화하세요.

<h4 id="structured-json-output">
  구조화된 JSON 출력
</h4>

종료 코드는 차단하거나 침묵하는 것만 허용합니다. 더 많은 제어를 위해 exit 0을 하고 stdout에 JSON 객체를 인쇄합니다.

<Note>
  Exit 2를 사용하여 stderr 메시지로 차단하거나 exit 0을 사용하여 구조화된 제어를 위해 JSON을 사용합니다. hook당 하나의 접근 방식을 선택하세요. 혼합할 때 일어나는 일은 [Exit code output](/docs/ko/hooks#exit-code-output)을 참조하세요.
</Note>

예를 들어 `PreToolUse` hook은 도구 호출을 거부하고 이유를 알리거나 사용자 승인을 위해 에스컬레이션할 수 있습니다:

```json theme={null}
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Use rg instead of grep for better performance"
  }
}
```

`"deny"`를 사용하면 Claude Code는 도구 호출을 취소하고 `permissionDecisionReason`을 Claude에게 피드백으로 전달합니다.

`PreToolUse`에서 Claude Code는 각 `permissionDecision` 값을 다음과 같이 처리합니다:

* `"allow"`: 대화형 권한 프롬프트를 건너뜁니다. 엔터프라이즈 관리형 거부 목록을 포함한 거부 및 요청 규칙은 여전히 적용되며, [`requiresUserInteraction`](/docs/ko/mcp#require-approval-for-a-specific-tool)으로 표시된 MCP 도구 및 조직이 `ask`로 설정한 [커넥터 도구](/docs/ko/mcp#organization-controls-on-connector-tools)에 대한 프롬프트도 마찬가지입니다(해당 설정이 Claude Code에 도달하는 세션에서).
* `"deny"`: 도구 호출을 취소하고 이유를 Claude에 전송합니다
* `"ask"`: 일반적으로 사용자에게 권한 프롬프트를 표시합니다

네 번째 값인 `"defer"`는 `-p` 플래그가 있는 [비대화형 모드](/docs/ko/headless)에서 사용 가능합니다. 도구 호출을 보존하여 프로세스를 종료하므로 Agent SDK 래퍼가 입력을 수집하고 재개할 수 있습니다. 참조의 [나중에 도구 호출 연기](/docs/ko/hooks#defer-a-tool-call-for-later)를 참조하세요.

`PreModelSwitch` hook은 동일한 `permissionDecision` 필드를 반환합니다: `"allow"`는 모델 전환을 진행하게 하고 `"deny"`는 이를 취소합니다. `"ask"`는 대화형 세션에서 `/model`을 실행할 때 전환을 확인하도록 합니다. 다른 곳에서는 Claude Code가 `"ask"`를 거부로 처리합니다. [PreModelSwitch 결정 제어](/docs/ko/hooks#premodelswitch-decision-control)를 참조하세요.

다른 이벤트는 다른 결정 패턴을 사용합니다. 예를 들어 `PostToolUse` 및 `Stop` hooks는 최상위 `decision: "block"` 필드를 사용하고 `PermissionRequest`는 `hookSpecificOutput.decision.behavior`를 사용합니다. 이벤트별 전체 분석은 참조의 [요약 표](/docs/ko/hooks#decision-control)를 참조하세요.

`UserPromptSubmit` hooks의 경우 `hookSpecificOutput.additionalContext`를 대신 사용하여 Claude의 컨텍스트에 텍스트를 주입합니다. `additionalContext`를 `hookSpecificOutput` 내에 중첩하세요. JSON의 최상위 수준에 배치하면 Claude Code는 이를 자동으로 무시합니다. 예를 들어 이 출력은 모든 프롬프트에 현재 브랜치 상태를 추가합니다:

```json theme={null}
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "Current branch: release-42. Deploy freeze until Friday."
  }
}
```

프롬프트 차단 및 세션 제목 설정을 포함한 전체 출력 형태는 [UserPromptSubmit 결정 제어](/docs/ko/hooks#userpromptsubmit-decision-control)를 참조하세요.

`type: "prompt"`를 사용하는 Hooks는 출력을 다르게 처리합니다: [프롬프트 기반 hooks](#prompt-based-hooks)를 참조하세요.

<h3 id="filter-hooks-with-matchers">
  Matchers로 hooks 필터링
</h3>

Matcher가 없으면 hook은 이벤트의 모든 발생에서 발생합니다. Matchers를 사용하면 범위를 좁힐 수 있습니다. 예를 들어 모든 도구 호출 후가 아닌 파일 편집 후에만 포매터를 실행하려면 `PostToolUse` hook에 matcher를 추가합니다:

```json theme={null}
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "prettier --write ..." }
        ]
      }
    ]
  }
}
```

`"Edit|Write"` matcher는 Claude가 `Edit` 또는 `Write` 도구를 사용할 때만 발생하고 `Bash`, `Read` 또는 다른 도구를 사용할 때는 발생하지 않습니다. 쉼표도 같은 방식으로 대안을 구분하므로 `"Edit, Write"`는 동등합니다. [Matcher 패턴](/docs/ko/hooks#matcher-patterns)을 참조하여 일반 이름과 정규식이 평가되는 방식을 확인하세요.

<Note>
  Claude는 또한 셸 명령을 실행하여 파일을 생성하거나 수정할 수 있습니다. Hook이 규정 준수 스캔 또는 감사 로깅과 같이 모든 파일 변경을 확인해야 하는 경우 턴당 한 번 작업 트리를 스캔하는 [`Stop`](/docs/ko/hooks#stop) hook을 추가합니다. 호출당 범위를 대신 원하면 `Bash|PowerShell`도 일치시키고 스크립트가 `git status --porcelain`으로 수정되고 추적되지 않은 파일을 나열하도록 합니다. [PowerShell hook 입력 섹션](/docs/ko/hooks#powershell)은 `Bash`만 일치시키는 것이 충분하지 않은 이유를 설명합니다. 특정 파일이 디스크에서 변경될 때 hook을 실행하려면 무엇이 작성했든 [FileChanged](/docs/ko/hooks#filechanged) hook을 사용합니다.
</Note>

각 이벤트 유형은 특정 필드에서 일치합니다:

| 이벤트 | Matcher가 필터링하는 것 | 예제 matcher 값 |
| :- | :- | :- |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | 도구 이름 | `Bash`, `Edit\|Write`, `mcp__.*` |
| `SessionStart` | 세션이 시작된 방식 | `startup`, `resume`, `clear`, `compact`, `fork` |
| `Setup` | 어떤 CLI 플래그가 설정을 트리거했는지 | `init`, `maintenance` |
| `SessionEnd` | 세션이 종료된 이유 | `clear`, `resume`, `logout`, `prompt_input_exit`, `other` |
| `Notification` | 알림 유형 | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_url_dialog`, `elicitation_complete`, `elicitation_response`, `agent_needs_input`, `agent_completed`, `quota_auto_resume_fired`, `quota_auto_resume_stale`, `quota_auto_resume_disabled` |
| `SubagentStart` | 에이전트 유형 | `general-purpose`, `Explore`, `Plan` 또는 사용자 정의 에이전트 이름 |
| `PreCompact`, `PostCompact` | 압축을 트리거한 것 | `manual`, `auto` |
| `PreModelSwitch`, `PostModelSwitch` | 세션이 전환되는 모델의 정규 이름([PreModelSwitch](/docs/ko/hooks#premodelswitch) 아래에 설명됨) | `claude-opus-5`, `claude-opus-4-6\|claude-opus-5`, `.*opus.*` |
| `SubagentStop` | 에이전트 유형 | `SubagentStart`와 동일한 값 |
| `ConfigChange` | 구성 소스 | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `DirectoryAdded` | 디렉토리가 추가된 방식 | `slash_command`, `register_repo_root` |
| `StopFailure` | 오류 유형 | `rate_limit`, `overloaded`, `authentication_failed`, `oauth_org_not_allowed`, `account_on_hold`, `billing_error`, `invalid_request`, `model_not_found`, `server_error`, `max_output_tokens`, `cloud_credential_error`, `unknown` |
| `InstructionsLoaded` | 로드 이유 | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `Elicitation` | MCP 서버 이름 | 구성된 MCP 서버 이름 |
| `ElicitationResult` | MCP 서버 이름 | `Elicitation`과 동일한 값 |
| `FileChanged` | 감시할 리터럴 파일 이름 ([FileChanged](/docs/ko/hooks#filechanged) 참조) | `.envrc\|.env` |
| `UserPromptExpansion` | 명령 이름 | skill 또는 명령 이름 |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged`, `MessageDisplay` | matcher 지원 없음 | 모든 발생에서 항상 발생 |

아래 탭은 다양한 이벤트 유형에서 몇 가지 추가 matchers를 보여줍니다.

<Tabs>
  <Tab title="모든 Bash 명령 기록">
    `Bash` 도구 호출만 일치시키고 각 명령을 파일에 기록합니다. `PostToolUse` 이벤트는 명령이 완료된 후 발생하므로 `tool_input.command`는 실행된 내용을 포함합니다. Hook은 stdin에서 이벤트 데이터를 JSON으로 받고 `jq -r '.tool_input.command'`는 명령 문자열만 추출하며 `>>`는 로그 파일에 추가합니다:

    ```json theme={null}
    {
      "hooks": {
        "PostToolUse": [
          {
            "matcher": "Bash",
            "hooks": [
              {
                "type": "command",
                "command": "jq -r '.tool_input.command' >> ~/.claude/command-log.txt"
              }
            ]
          }
        ]
      }
    }
    ```
  </Tab>

  <Tab title="MCP 도구 일치">
    MCP 도구는 기본 제공 도구와 다른 명명 규칙을 사용합니다: `mcp__<server>__<tool>`. 여기서 `<server>`는 MCP 서버 이름이고 `<tool>`은 제공하는 도구입니다. 예를 들어 `mcp__github__search_repositories` 또는 `mcp__filesystem__read_file`. [플러그인 번들 서버](/docs/ko/mcp#plugin-provided-mcp-servers)의 도구는 대신 `mcp__plugin_my-plugin_db__query`와 같은 범위가 지정된 서버 세그먼트를 사용합니다. 정규식 matcher를 사용하여 특정 서버의 모든 도구를 대상으로 하거나 `mcp__.*__write.*`와 같은 패턴으로 서버 전체에서 일치합니다. 참조의 [MCP 도구 일치](/docs/ko/hooks#match-mcp-tools)를 참조하여 전체 예제 목록을 확인하세요.

    아래 명령은 hook의 JSON 입력에서 `jq`를 사용하여 도구 이름을 추출하고 stderr에 씁니다. stderr에 쓰면 stdout을 깨끗하게 유지하고 메시지를 [디버그 로그](/docs/ko/hooks#debug-hooks)로 보냅니다:

    ```json theme={null}
    {
      "hooks": {
        "PreToolUse": [
          {
            "matcher": "mcp__github__.*",
            "hooks": [
              {
                "type": "command",
                "command": "echo \"GitHub tool called: $(jq -r '.tool_name')\" >&2"
              }
            ]
          }
        ]
      }
    }
    ```
  </Tab>

  <Tab title="세션 종료 시 정리">
    `SessionEnd` 이벤트는 세션이 종료된 이유에 대한 matchers를 지원합니다. 이 hook은 일반 종료가 아닌 `/clear`를 실행할 때만 발생합니다:

    ```json theme={null}
    {
      "hooks": {
        "SessionEnd": [
          {
            "matcher": "clear",
            "hooks": [
              {
                "type": "command",
                "command": "rm -f /tmp/claude-scratch-*.txt"
              }
            ]
          }
        ]
      }
    }
    ```
  </Tab>
</Tabs>

<h4 id="filter-by-tool-name-and-arguments-with-the-if-field">
  `if` 필드를 사용하여 도구 이름 및 인수로 필터링
</h4>

`if` 필드는 [권한 규칙 구문](/docs/ko/permissions)을 사용하여 도구 이름과 인수를 함께 사용하여 hooks를 필터링하므로 hook 프로세스는 도구 호출이 일치할 때만 생성됩니다. 이는 도구 이름만으로 그룹 수준에서 필터링하는 `matcher`를 초과합니다.

예를 들어 모든 Bash 명령이 아닌 `git` 명령을 사용할 때만 hook을 실행하려면:

```json theme={null}
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(git *)",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/check-git-policy.sh"
          }
        ]
      }
    ]
  }
}
```

Hook 명령이 실행되는지 여부는 `if` 패턴의 형태와 Claude가 호출하는 Bash 명령에 따라 달라집니다:

| `if` 패턴 | Bash 명령 | Hook이 실행되나요? | 이유 |
| :- | :- | :- | :- |
| `Bash(git *)` | `git push` | 예 | 명령 이름이 일치합니다 |
| `Bash(git *)` | `npm test && git push` | 예 | 각 서브명령이 확인됩니다; `git push`가 일치합니다 |
| `Bash(git *)` | `echo $(git log)` | 예 | `$()` 및 백틱 내의 명령이 확인됩니다; `git log`가 일치합니다 |
| `Bash(git *)` | `echo $(date)` | 아니오 | 서브명령이 `git *`과 일치하지 않습니다 |
| `Bash(git push *)` | `echo $(date)` | 예 | 명령 이름보다 더 많이 지정하는 패턴은 `$()`, 백틱 또는 `$VAR`에서 어쨌든 hook을 실행합니다 |

Claude Code가 Bash 입력이 실행할 명령을 결정할 수 없을 때 필터는 최선의 노력이므로 패턴에 관계없이 hook을 실행합니다. [Bash 일치 표](/docs/ko/hooks#bash-if-matching)는 Claude Code가 서브명령으로 좁힐 수 있고 없는 명령 형태를 다룹니다. 필터는 최선의 노력이므로 하드 허용 또는 거부를 적용하려면 hook 대신 [권한 시스템](/docs/ko/permissions)을 사용합니다.

`if` 필드는 권한 규칙과 동일한 패턴을 허용합니다: `"Bash(git *)"`, `"Edit(*.ts)"` 등. 여러 도구 이름을 일치시키려면 각각 자신의 `if` 값을 가진 별도의 핸들러를 사용하거나 파이프 교대가 지원되는 `matcher` 수준에서 일치합니다.

`if`는 도구 이벤트에서만 작동합니다: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest` 및 `PermissionDenied`. 다른 이벤트에 추가하면 hook이 실행되지 않습니다.

<h3 id="configure-hook-location">
  Hook 위치 구성
</h3>

Hook을 추가하는 위치는 범위를 결정합니다:

| 위치 | 범위 | 공유 가능 |
| :- | :- | :- |
| `~/.claude/settings.json` | 모든 프로젝트 | 아니오, 컴퓨터에 로컬 |
| `.claude/settings.json` | 단일 프로젝트 | 예, 리포지토리에 커밋 가능 |
| `.claude/settings.local.json` | 단일 프로젝트 | 아니오, Claude Code가 설정을 저장할 때 gitignored |
| 관리형 정책 설정 | 조직 전체 | 예, 관리자 제어 |
| [Plugin](/docs/ko/plugins) `hooks/hooks.json` | 플러그인이 활성화되었을 때 | 예, 플러그인과 함께 번들됨 |
| [Skill](/docs/ko/skills) frontmatter | Skill이 호출되면 나머지 세션입니다. [Skills 및 agents의 Hooks](/docs/ko/hooks#hooks-in-skills-and-agents)를 참조하세요 | 예, skill 파일에 정의됨 |
| [Subagent](/docs/ko/sub-agents) frontmatter | 해당 subagent가 실행되는 동안 | 예, subagent 파일에 정의됨 |

Claude Code에서 [`/hooks`](/docs/ko/hooks#the-%2Fhooks-menu)를 실행하여 이벤트별로 그룹화된 모든 구성된 hooks를 찾아봅니다.

Hooks를 비활성화하려면 설정 파일에서 `"disableAllHooks": true`를 설정합니다. Claude Code는 [설정 우선순위](/docs/ko/hooks#disable-or-remove-hooks)가 적용된 후 남은 값을 읽으므로 프로젝트의 설정 파일이 사용자의 설정을 재정의할 수 있습니다. 관리형 설정에서 구성된 Hooks는 `disableAllHooks`도 설정되지 않는 한 실행됩니다. 각 수준의 전체 범위는 [`disableAllHooks`](/docs/ko/settings-reference#disableallhooks)를 참조하세요.

Claude Code가 실행 중인 동안 설정 파일을 직접 편집하면 파일 감시자가 일반적으로 hook 변경을 자동으로 선택합니다.

<h2 id="prompt-based-hooks">
  프롬프트 기반 훅
</h2>

결정론적 규칙이 아닌 판단이 필요한 경우, `type: "prompt"` 훅을 사용합니다. 셸 명령을 실행하는 대신, Claude Code는 프롬프트와 훅의 입력 데이터를 Claude 모델로 전송하여 결정을 내립니다. 더 많은 기능이 필요한 경우 `model` 필드로 다른 모델을 지정할 수 있습니다.

모델의 유일한 역할은 결정을 JSON으로 반환하는 것입니다:

* `"ok": true`: 작업이 진행됩니다
* `"ok": false`: 어떤 일이 발생하는지는 이벤트에 따라 다릅니다:
  * `Stop` 및 `SubagentStop`: `reason`이 Claude로 피드백되어 계속 작업하도록 합니다. 단, 응답이 `"impossible": true`를 설정하여 조건을 절대 만족할 수 없는 것으로 표시하는 경우, Claude Code는 중지를 허용하고 턴이 종료됩니다
  * `PreToolUse`: 도구 호출이 거부됩니다. 기본적으로 턴이 종료되고 거부 `reason`이 경고 줄로 채팅에 나타납니다. 훅에서 `continueOnBlock: true`를 설정하여 대신 `reason`을 Claude에 도구 오류로 반환하면, Claude가 조정하고 계속할 수 있습니다. v2.1.210 이전에는 거부 `reason`이 Claude에 도구 오류로 반환되었고 턴이 계속되었습니다
  * `PostToolUse`: 기본적으로 턴이 종료되고 `reason`이 경고 줄로 채팅에 나타납니다. `continueOnBlock: true`를 설정하여 `reason`을 Claude로 피드백하고 대신 턴을 계속합니다
  * `PostToolBatch`, `UserPromptSubmit`, 및 `UserPromptExpansion`: 턴이 종료되고 `reason`이 경고 줄로 채팅에 나타납니다

이 예제는 `Stop` 훅을 사용하여 모델에 모든 요청된 작업이 완료되었는지 묻습니다. 모델이 조건이 아직 충족되지 않았기 때문에 `"ok": false`를 반환하면, Claude는 계속 작업하고 `reason`을 다음 지시로 사용합니다:

```json theme={null}
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Check if all tasks are complete. If not, respond with {\"ok\": false, \"reason\": \"what remains to be done\"}."
          }
        ]
      }
    ]
  }
}
```

전체 구성 옵션은 참조에서 [프롬프트 기반 훅](/docs/ko/hooks#prompt-based-hooks)을 참조합니다.

<h2 id="agent-based-hooks">
  에이전트 기반 hooks
</h2>

<Warning>
  에이전트 hooks는 실험적입니다. 동작 및 구성은 향후 릴리스에서 변경될 수 있습니다. 프로덕션 워크플로우의 경우 [명령 hooks](/docs/ko/hooks#command-hook-fields)를 선호합니다.
</Warning>

검증에 파일 검사 또는 명령 실행이 필요한 경우 `type: "agent"` hooks를 사용합니다. 단일 LLM 호출을 수행하는 프롬프트 hooks와 달리 에이전트 hooks는 파일을 읽고 코드를 검색하며 결정을 반환하기 전에 다른 도구를 사용할 수 있는 subagent를 생성합니다.

에이전트 hooks는 `"ok"` / `"reason"` 응답 형식을 사용하며 기본 타임아웃이 60초이고 최대 50개의 도구 사용 턴입니다. 프롬프트 hook의 `impossible` 필드를 지원하지 않습니다. `ok: false`일 때 Claude Code는 에이전트 hook을 동일한 이벤트에서 `continueOnBlock: true`를 사용하는 프롬프트 hook과 동일한 방식으로 처리하므로 `PreToolUse` 및 `PostToolUse`에서 턴이 계속됩니다. 에이전트 hooks에는 `continueOnBlock` 필드가 없습니다. Claude Code가 hook의 JSON 입력으로 대체하는 `$ARGUMENTS` 플레이스홀더를 포함한 필드는 [에이전트 hook 구성](/docs/ko/hooks#agent-hook-configuration)을 참조하세요.

이 예제는 Claude가 중지되기 전에 테스트가 통과하는지 확인합니다:

```json theme={null}
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "agent",
            "prompt": "Verify that all unit tests pass. Run the test suite and check the results. $ARGUMENTS",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

Hook 입력 데이터만으로 결정을 내릴 수 있을 때 프롬프트 hooks를 사용합니다. 코드베이스의 실제 상태에 대해 무언가를 확인해야 할 때 에이전트 hooks를 사용합니다.

전체 구성 옵션은 참조의 [에이전트 기반 hooks](/docs/ko/hooks#agent-based-hooks)를 참조하세요.

<h2 id="http-hooks">
  HTTP hooks
</h2>

`type: "http"` hooks를 사용하여 셸 명령을 실행하는 대신 이벤트 데이터를 HTTP 엔드포인트에 POST합니다. 엔드포인트는 명령 hook이 stdin에서 받을 것과 동일한 JSON을 받고 동일한 JSON 형식을 사용하여 HTTP 응답 본문을 통해 결과를 반환합니다.

HTTP hooks는 웹 서버, 클라우드 함수 또는 외부 서비스가 hook 로직을 처리하기를 원할 때 유용합니다: 예를 들어 팀 전체에서 도구 사용 이벤트를 기록하는 공유 감사 서비스입니다.

이 예제는 모든 도구 사용을 로컬 로깅 서비스에 게시합니다:

```json theme={null}
{
  "hooks": {
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "http",
            "url": "http://localhost:8080/hooks/tool-use",
            "headers": {
              "Authorization": "Bearer $MY_TOKEN"
            },
            "allowedEnvVars": ["MY_TOKEN"]
          }
        ]
      }
    ]
  }
}
```

엔드포인트는 명령 hooks와 동일한 [출력 형식](/docs/ko/hooks#json-output)의 JSON 본문으로 응답하며, Claude Code는 응답 상태도 확인합니다:

* **2xx 상태**: 도구 호출을 차단하려면 본문에 적절한 `hookSpecificOutput` 필드를 반환합니다.
* **그 외 모든 상태 또는 요청 실패**: Claude Code는 [비차단 오류](/docs/ko/hooks#exit-code-output)를 보고하고 작업을 계속 진행합니다. 엔드포인트가 실패했을 때 작업을 차단하려면 hook에 [`onFailure: "block"`](/docs/ko/hooks#block-the-action-when-a-hook-fails)을 설정합니다.

헤더 값은 `$VAR_NAME` 또는 `${VAR_NAME}` 구문을 사용한 환경 변수 보간을 지원합니다. `allowedEnvVars` 배열에 나열된 변수만 해결됩니다. 다른 모든 `$VAR` 참조는 비어 있습니다.

전체 구성 옵션 및 응답 처리는 참조의 [HTTP hooks](/docs/ko/hooks#http-hook-fields)를 참조하세요.

<h2 id="limitations-and-troubleshooting">
  제한 사항 및 문제 해결
</h2>

<h3 id="limitations">
  제한 사항
</h3>

Hooks를 설계할 때 다음 제약 사항을 염두에 두십시오:

* 명령 hooks는 stdout, stderr 및 종료 코드를 통해서만 통신합니다. `/` 명령이나 도구 호출을 직접 트리거할 수 없습니다. `additionalContext`를 통해 반환된 텍스트는 Claude가 일반 텍스트로 읽는 [시스템 알림](/docs/ko/glossary#system-reminder)으로 주입됩니다. HTTP hooks는 응답 본문을 통해 통신합니다.
* Hook 타임아웃은 유형에 따라 다릅니다. `timeout` 필드(초 단위)로 hook당 재정의할 수 있습니다.
  * `command`, `http`, `mcp_tool`: 10분. Claude Code는 `UserPromptSubmit`, `PreModelSwitch` 및 `PostModelSwitch` hooks의 기본값을 30초로 낮추고, `MessageDisplay`의 경우 10초로 낮춥니다.
  * `prompt`: 30초.
  * `agent`: 60초.
  * 모든 유형의 [`SessionEnd`](/docs/ko/hooks#sessionend) hooks는 1.5초 예산을 공유합니다. 설정에서 더 긴 hook당 `timeout`을 설정하면 Claude Code는 예산을 일치하도록 올리며, 최대 60초까지입니다.
* `PostToolUse` hooks는 도구가 이미 실행되었으므로 작업을 취소할 수 없습니다.
* [`PermissionRequest`](/docs/ko/hooks#permissionrequest) 훅은 Claude Code가 사용자에게 권한을 요청하려고 할 때, 또는 프롬프트를 표시할 수 없는 호출을 자동으로 거부하려고 할 때 발생합니다. `-p` 플래그를 사용하는 [비대화형 모드](/docs/ko/headless)에서도 [`dontAsk` 모드](/docs/ko/permission-modes#allow-only-pre-approved-tools-with-dontask-mode)가 아닌 경우 여전히 실행되며, 어떤 훅도 결정하지 않고 다른 어떤 것도 응답할 수 없는 호출은 거부됩니다.
* `Stop` hooks는 작업 완료 시에만이 아니라 Claude가 응답을 완료할 때마다 발생합니다. 사용자 중단 시에는 발생하지 않습니다. API 오류는 대신 [StopFailure](/docs/ko/hooks#stopfailure)를 발생시킵니다.
* 여러 `PreToolUse` hooks가 [`updatedInput`](/docs/ko/hooks#pretooluse)을 반환하여 도구의 인수를 다시 쓸 때 마지막으로 완료된 것이 우선합니다. Hooks는 병렬로 실행되므로 순서는 비결정적입니다. 동일한 도구의 입력을 수정하는 hook이 두 개 이상 있는 것을 피합니다.

<h3 id="hooks-and-permission-modes">
  Hooks 및 권한 모드
</h3>

`PreToolUse` hooks는 모든 [권한 모드](/docs/ko/permission-modes)에서 권한 모드 확인 전에 발생하며, `dontAsk`를 포함합니다. `permissionDecision: "deny"`를 반환하는 hook은 `bypassPermissions` 모드 또는 `--dangerously-skip-permissions`에서도 도구를 차단합니다. 이를 통해 사용자가 권한 모드를 변경하여 우회할 수 없는 정책을 적용할 수 있습니다.

반대는 사실이 아닙니다: `"allow"`를 반환하는 hook은 설정의 거부 규칙을 우회하지 않으며, [`requiresUserInteraction`](/docs/ko/mcp#require-approval-for-a-specific-tool)으로 표시된 MCP 도구의 프롬프트를 억제할 수 없거나 조직이 [커넥터 도구](/docs/ko/mcp#organization-controls-on-connector-tools)를 `ask`로 설정한 세션에서 해당 설정이 Claude Code에 도달하는 경우입니다. Hooks는 제한을 강화할 수 있지만 권한 규칙이 허용하는 것을 초과하여 완화할 수 없습니다.

설치한 [mod](/docs/ko/plugins/mods/overview)가 `tool.check`를 처리하는 경우, 훅이 관리형 설정에 있지 않는 한 `PreToolUse` 훅이 차단한 호출을 승인할 수 있습니다. [훅으로 권한 확장](/docs/ko/permissions#extend-permissions-with-hooks)에서 어떤 규칙이 mod보다 우선하는지 나열합니다.

<h3 id="hook-not-firing">
  Hook이 발생하지 않음
</h3>

Hook이 구성되었지만 실행되지 않습니다.

* `/hooks`를 실행하고 hook이 올바른 이벤트 아래에 나타나는지 확인합니다
* Matcher 패턴이 도구 이름과 정확히 일치하는지 확인합니다. Matchers는 대소문자 구분입니다
* 올바른 이벤트 유형을 트리거하는지 확인합니다: `PreToolUse`는 도구 실행 전에 발생하고 `PostToolUse`는 후에 발생합니다. `PermissionRequest` hook은 Claude Code가 사용자에게 권한을 요청하려고 할 때 발생합니다. 비대화형 경우는 [제한 사항](#limitations)을 참조하십시오

<h3 id="hook-error-in-output">
  출력에 Hook 오류
</h3>

트랜스크립트에 "PreToolUse hook error: ..." 같은 메시지가 표시됩니다.

* 스크립트가 예기치 않게 0이 아닌 코드로 종료되었습니다. 샘플 JSON을 파이프하여 수동으로 테스트합니다:
  ```bash theme={null}
  echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | ./my-hook.sh
  echo $?  # 종료 코드 확인
  ```
* "command not found"가 표시되면 절대 경로를 사용하거나 `${CLAUDE_PROJECT_DIR}`을 사용하여 스크립트를 참조합니다. 셸 인용을 완전히 피하려면 `"args": []`를 추가하여 [exec form](/docs/ko/hooks#exec-form-and-shell-form)으로 전환하면 셸 없이 스크립트를 직접 생성합니다
* "jq: command not found"가 표시되면 `jq`를 설치하거나 JSON 구문 분석을 위해 Python/Node.js를 사용합니다
* 공지에 JSON 검증 메시지가 표시되면 hook의 stdout이 JSON으로 구문 분석되었지만 스키마 검증에 실패했습니다. JSON 구문 분석 메시지가 표시되면 stdout이 JSON 객체처럼 보였지만 유효한 JSON이 아니었습니다. 둘 다 종료 0에서도 발생합니다.

  구문 분석 실패를 수정하려면 문자열 연결 대신 `jq`와 같은 JSON 인코더로 페이로드를 빌드하여 값 내의 따옴표와 백슬래시가 이스케이프됩니다. 참조의 [Exit code output](/docs/ko/hooks#exit-code-output) 섹션에서 종료 코드 및 JSON 조합을 다룹니다
* 스크립트가 실행되지 않으면 실행 가능하게 만듭니다: `chmod +x ./my-hook.sh`

<h3 id="/hooks-shows-no-hooks-configured">
  `/hooks`에 구성된 hooks가 없음
</h3>

설정 파일을 편집했지만 hooks가 메뉴에 나타나지 않습니다.

* 파일 편집은 일반적으로 자동으로 선택됩니다. 몇 초 후에 나타나지 않으면 파일 감시자가 변경을 놓쳤을 수 있습니다: 세션을 다시 시작하여 강제로 다시 로드합니다.
* JSON이 유효한지 확인합니다: 후행 쉼표 및 주석은 허용되지 않습니다
* 설정 파일이 올바른 위치에 있는지 확인합니다: 프로젝트 hooks의 경우 `.claude/settings.json`, 전역 hooks의 경우 `~/.claude/settings.json`
* 메뉴에 `Only hooks from managed settings run here`가 표시되면 조직에서 [`allowManagedHooksOnly`](/docs/ko/settings-reference#allowmanagedhooksonly)를 설정한 것입니다. 사용자, 프로젝트 및 로컬 설정 파일의 훅은 실행되지 않으며 목록에 표시되지 않습니다

<h3 id="stop-hook-hits-the-block-cap">
  Stop hook이 블록 상한에 도달함
</h3>

Claude가 중지하는 대신 계속 작업하다가 Stop hook이 너무 많은 횟수를 연속으로 차단했다는 경고로 턴을 종료합니다.

Claude Code는 Stop hook이 그 사이에 Claude의 도구 호출 없이 8번 연속으로 차단하면 해당 Stop hook을 재정의합니다. Hook 스크립트는 이미 계속 진행을 트리거했는지 확인해야 합니다. JSON 입력에서 `stop_hook_active` 필드를 구문 분석하고 `true`인 경우 조기에 종료합니다:

```bash theme={null}
#!/bin/bash
INPUT=$(cat)
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0  # Claude가 중지되도록 허용
fi
# ... hook 로직의 나머지
```

Hook이 수렴하기 위해 8번 이상의 반복이 필요한 경우 [`CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`](/docs/ko/env-vars)으로 상한을 올립니다.

<h3 id="hook-json-has-no-effect">
  Hook JSON이 효과가 없음
</h3>

Hook이 유효한 JSON을 출력하지만 결정이 적용되지 않고 트랜스크립트에 오류가 나타나지 않습니다. 어느 원인이 적용되는지 확인합니다:

* **JSON 앞의 추가 출력**: 일반적으로 셸 프로필의 무조건적인 `echo`로 인해 다른 것이 먼저 stdout에 쓰므로 출력이 더 이상 `{`로 시작하지 않으며 Claude Code가 JSON으로 구문 분석하지 않습니다. 원인과 수정은 이 목록을 따릅니다.
* **잘못된 수준의 필드**: 각 필드의 배치를 [JSON output](/docs/ko/hooks#json-output) 형식과 비교합니다. 예를 들어 `permissionDecision`은 최상위 수준이 아니라 `hookSpecificOutput` 내부에 속합니다.

Claude Code가 셸 형식 명령 hook(`args` 없는 hook)을 실행할 때 macOS 및 Linux에서는 `sh -c`를 생성하고, Windows에서는 Git Bash를 생성하거나 Git Bash가 기본적으로 설치되지 않은 경우 PowerShell을 생성합니다. 이 셸은 비대화형이지만 Git Bash 및 일부 구성(예: `BASH_ENV`가 `~/.bashrc`를 가리킴)은 여전히 프로필을 소싱합니다. 해당 프로필에 무조건적인 `echo` 문이 포함되어 있으면 출력이 hook의 JSON에 앞에 붙습니다:

```text theme={null}
Shell ready on arm64
{"decision": "block", "reason": "Not allowed"}
```

결합된 출력은 더 이상 `{`로 시작하지 않으므로 Claude Code는 stdout의 모든 것을 일반 텍스트로 취급하고 JSON을 무시합니다. 종료 0에서 트랜스크립트에 아무것도 보고되지 않습니다. 구문 분석 시도는 [디버그 로그](/docs/ko/hooks#debug-hooks)에만 기록됩니다. 이를 수정하려면 셸 프로필의 echo 문을 래핑하여 대화형 셸에서만 실행되도록 합니다:

```bash theme={null}
# ~/.zshrc 또는 ~/.bashrc에서
if [[ $- == *i* ]]; then
  echo "Shell ready"
fi
```

`$-` 변수는 셸 플래그를 포함하고 `i`는 대화형을 의미합니다. Hooks는 비대화형 셸에서 실행되므로 echo는 건너뜁니다.

Hook이 `permissionDecision` 또는 `additionalContext`를 `hookSpecificOutput` 내부가 아닌 최상위 수준에서 반환할 때 JSON은 여전히 구문 분석되고 Claude Code는 잘못된 위치의 필드를 무시하고 오류를 보고하지 않습니다. 무시된 필드를 확인하려면 `claude --debug`로 Claude Code를 시작하고 [디버그 로그](/docs/ko/hooks#debug-hooks)에서 `Hook JSON output had unrecognized keys`를 검색합니다.

<h3 id="check-what-a-hook-did">
  훅이 수행한 작업 확인
</h3>

`Ctrl+O`를 눌러 트랜스크립트 보기를 열고 훅의 결과를 확인합니다:

* **성공**: 훅의 JSON이 `systemMessage` 또는 Stop 훅 피드백과 같은 것을 표시하지 않는 한 아무것도 표시되지 않습니다.
  * 훅이 실행되었는지 확인하려면 재포맷된 파일과 같은 효과를 확인합니다
* **차단 오류**: 대부분의 이벤트에서는 차단과 함께 전달된 메시지(예: `Blocked: rm commands are not allowed`)가 표시됩니다. `ConfigChange` 및 `Elicitation`과 같은 몇 가지 이벤트에서는 메시지가 표시되지 않습니다. 메시지의 출처는 [종료 코드 2](/docs/ko/hooks#exit-code-2)에서 다룹니다.
* **차단하지 않는 오류**: `Failed with non-blocking status code:` 뒤에 오는 stderr의 첫 번째 줄이나 JSON 검증 또는 구문 분석 메시지와 같은 간단한 설명과 함께 `<hook name> hook error` 공지가 표시됩니다. 작업은 계속 진행되었습니다.

이벤트별 예외를 포함하여 특정 종료 코드와 stdout에 대한 결과를 확인하려면 참조의 [Exit code output](/docs/ko/hooks#exit-code-output)을 참조하십시오.

훅 종료 코드, stdout 및 stderr를 포함한 전체 실행 세부 정보는 디버그 로그에서 확인합니다. `claude --debug-file /tmp/claude.log`로 Claude Code를 시작하여 알려진 경로에 로그를 쓴 다음, 다른 터미널에서 `tail -f /tmp/claude.log`를 실행합니다. 해당 플래그 없이 시작한 경우 세션 중에 `/debug`를 실행하여 로깅을 활성화하고 로그 경로를 찾습니다.

<h2 id="learn-more">
  자세히 알아보기
</h2>

* [Hooks 참조](/docs/ko/hooks): 전체 이벤트 스키마, JSON 출력 형식, 비동기 hooks 및 MCP 도구 hooks
* [보안 고려 사항](/docs/ko/hooks#security-considerations): 공유 또는 프로덕션 환경에서 hooks를 배포하기 전에 검토합니다
* [Bash 명령 검증기 예제](https://github.com/anthropics/claude-code/blob/main/examples/hooks/bash_command_validator_example.py): 완전한 참조 구현
