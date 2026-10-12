> ## Documentation Index
> Fetch the complete documentation index at: https://code.claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Hooks 참조

> Claude Code hook 이벤트, 구성 스키마, JSON 입출력 형식, 종료 코드, 비동기 hook, HTTP hook, 프롬프트 hook, MCP 도구 hook에 대한 참조입니다.

<Tip>
  예제가 포함된 빠른 시작 가이드는 [hook으로 작업 자동화](/docs/ko/hooks-guide)를 참조하세요.
</Tip>

Hook은 Claude Code의 수명 주기에서 특정 지점에 자동으로 실행되는 사용자 정의 셸 명령, HTTP 엔드포인트, MCP 도구 호출, LLM 프롬프트 또는 서브에이전트입니다. Claude Code는 터미널의 세션, IDE 확장 프로그램, [데스크톱 앱](/docs/ko/desktop-quickstart), [클라우드 세션](/docs/ko/claude-code-on-the-web)을 포함하여 실행되는 모든 곳에서 동일한 hook 이벤트를 발생시킵니다. 이 참조를 사용하여 이벤트 스키마, 구성 옵션, JSON 입출력 형식, 비동기 hook, HTTP hook, MCP 도구 hook과 같은 고급 기능을 조회할 수 있습니다.

플러그인은 Claude Code가 자체 프로세스에서 호출하는 JavaScript 함수로 훅을 등록할 수도 있으며, 이러한 함수는 이벤트에 대응할 뿐 아니라 인터페이스에 그리기도 할 수 있습니다. 이렇게 하는 플러그인을 [mod](/docs/ko/plugins/mods/overview)라고 하며, 이러한 함수 훅은 이 페이지가 아닌 [이벤트에 반응하기](/docs/ko/plugins/mods/events)에서 다룹니다. 이 페이지의 훅은 mod와 함께 계속 작동합니다.

<h2 id="hook-lifecycle">
  Hook 수명 주기
</h2>

Claude Code는 세션 중 특정 지점에서 hook을 실행합니다. 이벤트가 발생하고 matcher가 일치하면 Claude Code는 이벤트에 대한 JSON 컨텍스트를 hook 핸들러에 전달합니다. 명령 hook의 경우 입력은 stdin에 도착합니다. HTTP hook의 경우 POST 요청 본문으로 도착합니다. 그러면 핸들러는 입력을 검사하고 조치를 취한 후 선택적으로 결정을 반환할 수 있습니다.

이벤트는 세 가지 주기로 발생합니다:

* 세션당 한 번: `SessionStart` 및 `SessionEnd`
* 턴당 한 번: `UserPromptSubmit`, `Stop` 및 `StopFailure`
* 에이전트 루프 내의 모든 도구 호출에서: `PreToolUse` 및 `PostToolUse`(단, [`EndConversation`](/docs/ko/tools-reference#endconversation-tool-behavior) 호출은 제외되며, 이는 둘 다 건너뜁니다)

<div style={{maxWidth: "500px", margin: "0 auto"}}>
  <Frame>
    <img src="https://mintcdn.com/claude-code/x7pO8l4XcvAXCoVc/images/hooks-lifecycle.svg?fit=max&auto=format&n=x7pO8l4XcvAXCoVc&q=85&s=81b9256c1bbe8832553485f5d9e9c746" className="dark:hidden" alt="선택적 Setup에서 SessionStart로 시작하여 턴당 루프(UserPromptSubmit, 슬래시 명령에 대한 UserPromptExpansion, 중첩된 에이전트 루프(PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, PostToolBatch, SubagentStart/Stop, TaskCreated, TaskCompleted), Stop 또는 StopFailure), TeammateIdle, PreCompact, PostCompact, SessionEnd를 거쳐 진행되는 hook 수명 주기 다이어그램. Elicitation 및 ElicitationResult는 MCP 도구 실행 내에 중첩되고, PermissionDenied는 PermissionRequest의 부분 분기(자동 모드 거부용), WorktreeCreate, WorktreeRemove, Notification, ConfigChange, InstructionsLoaded, CwdChanged, FileChanged, DirectoryAdded는 독립적인 비동기 이벤트이며, PreModelSwitch는 요청된 모델 전환 전에 실행되는 독립적인 순차 이벤트이고, PostModelSwitch는 세션의 모델이 변경된 후에 실행되는 독립적인 비동기 이벤트이며, MessageDisplay는 어시스턴트 메시지 텍스트가 스트리밍되는 동안 실행되는 표시 전용 이벤트입니다" width="520" height="1336" data-path="images/hooks-lifecycle.svg" />

    <img src="https://mintcdn.com/claude-code/x7pO8l4XcvAXCoVc/images/hooks-lifecycle-dark.svg?fit=max&auto=format&n=x7pO8l4XcvAXCoVc&q=85&s=c9b3d88487335f58cce0b52e2f9e7531" className="hidden dark:block" alt="선택적 Setup에서 SessionStart로 시작하여 턴당 루프(UserPromptSubmit, 슬래시 명령에 대한 UserPromptExpansion, 중첩된 에이전트 루프(PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, PostToolBatch, SubagentStart/Stop, TaskCreated, TaskCompleted), Stop 또는 StopFailure), TeammateIdle, PreCompact, PostCompact, SessionEnd를 거쳐 진행되는 hook 수명 주기 다이어그램. Elicitation 및 ElicitationResult는 MCP 도구 실행 내에 중첩되고, PermissionDenied는 PermissionRequest의 부분 분기(자동 모드 거부용), WorktreeCreate, WorktreeRemove, Notification, ConfigChange, InstructionsLoaded, CwdChanged, FileChanged, DirectoryAdded는 독립적인 비동기 이벤트이며, PreModelSwitch는 요청된 모델 전환 전에 실행되는 독립적인 순차 이벤트이고, PostModelSwitch는 세션의 모델이 변경된 후에 실행되는 독립적인 비동기 이벤트이며, MessageDisplay는 어시스턴트 메시지 텍스트가 스트리밍되는 동안 실행되는 표시 전용 이벤트입니다" width="520" height="1336" data-path="images/hooks-lifecycle-dark.svg" />
  </Frame>
</div>

아래 표는 각 이벤트가 언제 발생하는지 요약합니다. [Hook 이벤트](#hook-events) 섹션에서는 각 이벤트의 전체 입력 스키마와 결정 제어 옵션을 문서화합니다.

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

<h3 id="how-a-hook-resolves">
  Hook이 어떻게 해결되는지
</h3>

파괴적인 셸 명령을 차단하는 이 `PreToolUse` hook을 고려하세요.

<Tabs>
  <Tab title="macOS/Linux">
    `matcher`는 Bash 도구 호출로 좁혀지고 `if` 조건은 `rm *`과 일치하는 Bash 부명령으로 더 좁혀지므로 `block-rm.sh`는 두 필터가 모두 일치할 때만 생성됩니다:

    ```json theme={null}
    {
      "hooks": {
        "PreToolUse": [
          {
            "matcher": "Bash",
            "hooks": [
              {
                "type": "command",
                "if": "Bash(rm *)",
                "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/block-rm.sh",
                "args": []
              }
            ]
          }
        ]
      }
    }
    ```

    스크립트는 stdin에서 JSON 입력을 읽고 명령을 추출한 후 `rm -rf`를 포함하면 `permissionDecision`을 `"deny"`로 반환합니다. 프로젝트의 `.claude/hooks/block-rm.sh`에 저장하고 Claude Code가 실행할 수 있도록 `chmod +x .claude/hooks/block-rm.sh`로 실행 가능하게 만듭니다:

    ```bash theme={null}
    #!/bin/bash
    # .claude/hooks/block-rm.sh
    COMMAND=$(jq -r '.tool_input.command')

    if echo "$COMMAND" | grep -q 'rm -rf'; then
      jq -n '{
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "deny",
          permissionDecisionReason: "Destructive command blocked by hook"
        }
      }'
    else
      exit 0  # no decision; normal permission flow applies
    fi
    ```

    이 스크립트는 이 페이지의 다른 Bash 예제처럼 JSON 입력을 파싱하므로 `jq`를 사용합니다. 따라서 이들을 시도하기 전에 `jq`를 설치하고 `PATH`에 있는지 확인하세요.
  </Tab>

  <Tab title="Windows (PowerShell)">
    matcher `Bash|PowerShell`은 [PowerShell 도구](#powershell)와 Bash를 모두 포함합니다. 단일 `if` 규칙은 한 도구의 호출만 일치하므로 각 도구는 자체 핸들러를 가집니다: 첫 번째는 `rm *`과 일치하는 Bash 부명령으로 좁혀지고, 두 번째는 `Remove-Item *`과 일치하는 PowerShell 명령으로 좁혀집니다. 둘 다 `powershell.exe`를 통해 동일한 스크립트를 실행합니다:

    ```json theme={null}
    {
      "hooks": {
        "PreToolUse": [
          {
            "matcher": "Bash|PowerShell",
            "hooks": [
              {
                "type": "command",
                "if": "Bash(rm *)",
                "command": "powershell.exe",
                "args": [
                  "-NoProfile",
                  "-ExecutionPolicy",
                  "Bypass",
                  "-File",
                  "${CLAUDE_PROJECT_DIR}/.claude/hooks/block-rm.ps1"
                ]
              },
              {
                "type": "command",
                "if": "PowerShell(Remove-Item *)",
                "command": "powershell.exe",
                "args": [
                  "-NoProfile",
                  "-ExecutionPolicy",
                  "Bypass",
                  "-File",
                  "${CLAUDE_PROJECT_DIR}/.claude/hooks/block-rm.ps1"
                ]
              }
            ]
          }
        ]
      }
    }
    ```

    `-NoProfile` 플래그는 PowerShell 프로필 로드를 건너뛰므로 hook이 빠르게 시작되고, `-ExecutionPolicy Bypass`는 PowerShell이 로컬 스크립트 파일을 실행하도록 합니다.

    스크립트는 stdin에서 JSON 입력을 읽고 명령을 추출한 후 `rm -rf` 또는 `-Recurse`가 뒤따르는 `Remove-Item`을 포함하면 `permissionDecision`을 `"deny"`로 반환합니다. 프로젝트의 `.claude/hooks/block-rm.ps1`에 저장합니다:

    ```powershell theme={null}
    # .claude/hooks/block-rm.ps1
    $callInput = [Console]::In.ReadToEnd() | ConvertFrom-Json
    $command = $callInput.tool_input.command

    if ($command -match 'rm -rf|Remove-Item.*-Recurse') {
      @{
        hookSpecificOutput = @{
          hookEventName = "PreToolUse"
          permissionDecision = "deny"
          permissionDecisionReason = "Destructive command blocked by hook"
        }
      } | ConvertTo-Json
    } else {
      exit 0  # no decision; normal permission flow applies
    }
    ```
  </Tab>
</Tabs>

이제 Claude Code가 macOS/Linux 구성에 대해 `Bash "rm -rf /tmp/build"`를 실행하기로 결정했다고 가정합니다. 다음은 발생하는 일입니다:

<Frame>
  <img src="https://mintcdn.com/claude-code/ikqp3_70mqIahteV/images/hook-resolution.svg?fit=max&auto=format&n=ikqp3_70mqIahteV&q=85&s=be0bf3053550c26de5f54cd64674c197" className="dark:hidden" alt="Hook 해결 다이어그램: PreToolUse가 발생하고, matcher가 Bash 일치를 확인한 후 if 조건이 Bash(rm *) 일치를 확인합니다. 둘 다 일치하면 hook 명령이 실행되고 permissionDecision deny를 반환하므로 도구 호출이 차단되고 Claude Code가 계속됩니다. 어느 검사도 일치하지 않으면 hook이 건너뛰어지고 도구 호출이 진행되도록 허용됩니다." width="930" height="270" data-path="images/hook-resolution.svg" />

  <img src="https://mintcdn.com/claude-code/_xqph1dUOslCOwsj/images/hook-resolution-dark.svg?fit=max&auto=format&n=_xqph1dUOslCOwsj&q=85&s=e80af91f8507cee6bd51ac3c2dd92f63" className="hidden dark:block" alt="Hook 해결 다이어그램: PreToolUse가 발생하고, matcher가 Bash 일치를 확인한 후 if 조건이 Bash(rm *) 일치를 확인합니다. 둘 다 일치하면 hook 명령이 실행되고 permissionDecision deny를 반환하므로 도구 호출이 차단되고 Claude Code가 계속됩니다. 어느 검사도 일치하지 않으면 hook이 건너뛰어지고 도구 호출이 진행되도록 허용됩니다." width="930" height="270" data-path="images/hook-resolution-dark.svg" />
</Frame>

<Steps>
  <Step title="이벤트 발생">
    `PreToolUse` 이벤트가 발생합니다. Claude Code는 도구 입력을 stdin의 hook에 JSON으로 전송합니다:

    ```json theme={null}
    { "tool_name": "Bash", "tool_input": { "command": "rm -rf /tmp/build" }, ... }
    ```
  </Step>

  <Step title="Matcher 확인">
    matcher `"Bash"`가 도구 이름과 일치하므로 이 hook 그룹이 활성화됩니다. matcher를 생략하거나 `"*"`를 사용하면 이벤트의 모든 발생에서 그룹이 활성화됩니다.
  </Step>

  <Step title="If 조건 확인">
    `if` 조건 `"Bash(rm *)"`은 `rm -rf /tmp/build`가 `rm *`과 일치하는 부명령이므로 일치하여 이 핸들러가 생성됩니다. 명령이 `npm test`였다면 `if` 검사가 실패하고 `block-rm.sh`는 절대 실행되지 않아 프로세스 생성 오버헤드를 피합니다. `if` 필드는 선택 사항입니다. 없으면 일치한 그룹의 모든 핸들러가 실행됩니다.
  </Step>

  <Step title="Hook 핸들러 실행">
    스크립트는 전체 명령을 검사하고 `rm -rf`를 찾으므로 stdout에 결정을 인쇄합니다:

    ```json theme={null}
    {
      "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": "Destructive command blocked by hook"
      }
    }
    ```

    명령이 `rm file.txt`와 같은 더 안전한 `rm` 변형이었다면 스크립트는 대신 `exit 0`을 실행합니다. 출력이 없는 종료 코드 0은 hook이 보고할 결정이 없다는 의미이므로 도구 호출은 일반적인 [권한 흐름](/docs/ko/permissions)을 통해 계속됩니다. hook은 호출을 거부할 수 있지만 침묵을 유지하는 것은 이를 승인하지 않습니다.
  </Step>

  <Step title="Claude Code가 결과에 따라 행동">
    Claude Code는 JSON 결정을 읽고 도구 호출을 차단하며 Claude에 이유를 표시합니다.
  </Step>
</Steps>

아래 [구성](#configuration) 섹션에서는 전체 스키마를 문서화하고, 각 [hook 이벤트](#hook-events) 섹션에서는 명령이 받는 입력과 반환할 수 있는 출력을 문서화합니다.

<h2 id="configuration">
  구성
</h2>

Hook은 JSON 설정 파일에서 정의됩니다. 구성은 세 가지 중첩 수준을 가집니다:

1. 응답할 [hook 이벤트](#hook-events)를 선택합니다(예: `PreToolUse` 또는 `Stop`).
2. 실행 시기를 필터링할 [matcher 그룹](#matcher-patterns)을 추가합니다(예: "Bash 도구에만 해당").
3. 일치할 때 실행할 하나 이상의 [hook 핸들러](#hook-handler-fields)를 정의합니다.

주석이 달린 예제를 포함한 완전한 설명은 위의 [hook이 어떻게 해결되는지](#how-a-hook-resolves)를 참조하십시오.

<Note>
  이 페이지는 각 수준에 대해 특정 용어를 사용합니다: 라이프사이클 포인트에 대해 **hook 이벤트**, 필터에 대해 **matcher 그룹**, 실행되는 셸 명령, HTTP 엔드포인트, MCP 도구, 프롬프트 또는 에이전트에 대해 **hook 핸들러**. "Hook"은 일반적인 기능을 나타냅니다.
</Note>

<h3 id="hook-locations">
  Hook 위치
</h3>

hook을 정의하는 위치에 따라 범위가 결정됩니다:

| 위치 | 범위 | 공유 가능 |
| :- | :- | :- |
| `~/.claude/settings.json` | 모든 프로젝트 | 아니요, 로컬 머신에만 해당 |
| `.claude/settings.json` | 단일 프로젝트 | 예, 리포지토리에 커밋 가능 |
| `.claude/settings.local.json` | 단일 프로젝트 | 아니요, Claude Code가 설정을 저장할 때 gitignored |
| 관리형 정책 설정 | 조직 전체 | 예, 관리자 제어 |
| [플러그인](/docs/ko/plugins/overview) `hooks/hooks.json` | 플러그인이 활성화되었을 때 | 예, 플러그인과 함께 번들됨 |
| [스킬](/docs/ko/skills) frontmatter | 스킬이 호출된 후 세션의 나머지 부분. [스킬 및 에이전트의 Hook](#hooks-in-skills-and-agents) 참조 | 예, 스킬 파일에서 정의됨 |
| [서브에이전트](/docs/ko/sub-agents) frontmatter | 해당 서브에이전트가 실행되는 동안 | 예, 서브에이전트 파일에서 정의됨 |

[클라우드 세션](/docs/ko/claude-code-on-the-web)은 로컬 `~/.claude/settings.json`을 읽지 않습니다. [자체 호스팅 환경](/docs/ko/self-hosted-environments-configuration#permissions-and-tool-approval)에서 Claude Code는 또한 운영자가 실행기 호스트의 `~/.claude/`에서 시드한 훅을 실행하고, 실행기 이미지의 관리형 설정 파일이 [Claude Code가 적용하는 관리형 소스](/docs/ko/managed-settings#how-claude-code-combines-managed-sources) 중 하나일 때 해당 파일의 훅을 실행합니다. 이는 기본적으로 서버 관리 설정이나 MDM 전달 Claude Code 정책이 관리형 계층을 제공하지 않을 때만 해당됩니다. 어떤 설정 파일과 플러그인, 따라서 어떤 훅이 클라우드 세션에 도달하는지는 [설정에서 이월되는 항목](/docs/ko/cloud-environments#what-carries-over-from-your-setup)을 참조하십시오.

설정 파일 해결에 대한 자세한 내용은 [설정](/docs/ko/settings)을 참조하십시오.

설정 파일, 관리형 정책 설정 및 플러그인의 Hook도 [서브에이전트](/docs/ko/sub-agents) 내에서 실행됩니다. 서브에이전트가 도구를 호출할 때, `PreToolUse` 및 `PostToolUse`와 같은 도구 이벤트는 주 대화에서 구성된 것과 동일한 hook을 실행하며, 입력은 서브에이전트를 식별하는 `agent_id` 및 `agent_type` [공통 입력 필드](#common-input-fields)를 전달합니다.

관리자는 [관리형 설정](/docs/ko/managed-settings)에서 [`allowManagedHooksOnly`](/docs/ko/settings-reference#allowmanagedhooksonly)를 사용하여 실행되는 훅을 제한할 수 있습니다:

* 사용자, 프로젝트, 로컬 및 플러그인 hook이 차단됩니다. 관리형 설정 `enabledPlugins`에서 강제 활성화된 플러그인의 Hook은 제외됩니다.
* Claude Code는 또한 [`statusLine`](/docs/ko/statusline), [`fileSuggestion`](/docs/ko/settings-reference#filesuggestion) 및 [`subagentStatusLine`](/docs/ko/statusline#subagent-status-lines) 설정을 관리형 설정으로 좁힙니다.
* Claude Code는 또한 [`disableCommandPluginSources`](/docs/ko/settings-reference#disablecommandpluginsources)가 명시적으로 `false`로 설정되지 않은 한 [`command` 소스](/docs/ko/plugins/marketplace-reference#command-plugin-source)가 있는 플러그인을 비활성화합니다. 여기에는 관리형 설정 `enabledPlugins`에서 강제 활성화된 플러그인이 포함됩니다. `command` 소스는 Claude Code v2.1.229 이상이 필요합니다.
* Claude Code는 또한 [`disableCommandPluginSources`](/docs/ko/settings-reference#disablecommandpluginsources)가 명시적으로 `false`로 설정되지 않은 한 마켓플레이스 [`headersHelper` 명령](/docs/ko/plugins/host-marketplace#authenticate-archive-downloads)을 차단합니다. 단, 관리형 설정 자체가 선언하는 마켓플레이스는 제외됩니다.

[`allowManagedHooksOnly`에서 실행되는 항목](/docs/ko/settings-reference#what-runs-under-allowmanagedhooksonly)을 참조하십시오.

Hook 항목은 각 설정 수준에서 서로를 대체하지 않고 병합됩니다: 사용자, 프로젝트 및 로컬 설정은 관리형 항목을 제거하지 않고 자신의 hook을 추가하며, 관리형 설정 외부에서 설정된 [`disableAllHooks`](#disable-or-remove-hooks) 설정은 관리형 hook을 비활성화할 수 없습니다.

[HTTP hook 허용 목록](/docs/ko/settings-reference#hook-and-skill-settings)은 관리형 정책 설정을 포함한 모든 소스의 hook에 적용됩니다:

* `allowedHttpHookUrls`: 모든 설정 수준에서 정의되면 Claude Code는 URL이 병합된 허용 목록과 일치하는 경우에만 HTTP hook 핸들러를 실행합니다.
* `httpHookAllowedEnvVars`: 정의되면 Claude Code는 해당 목록의 환경 변수만 hook 헤더에 보간합니다.

<h3 id="matcher-patterns">
  Matcher 패턴
</h3>

`matcher` 필드는 hook이 실행되는 시기를 필터링합니다. matcher가 평가되는 방식은 포함된 문자에 따라 다릅니다:

| Matcher 값 | 평가 대상 | 예제 |
| :- | :- | :- |
| `"*"`, `""` 또는 생략됨 | 모두 일치 | 이벤트의 모든 발생에서 실행됨 |
| 문자, 숫자, `_`, `-`, 공백, `,` 및 `\|`만 포함 | 정확한 문자열 또는 `\|` 또는 `,`로 구분된 정확한 문자열 목록(선택적 주변 공백 포함) | `Bash`는 Bash 도구만 일치합니다. `Edit\|Write` 및 `Edit, Write`는 각각 두 도구 중 하나와 정확히 일치합니다. `code-reviewer`는 해당 에이전트 유형만 일치합니다. |
| 다른 문자 포함 | JavaScript 정규 표현식, 앵커 없음 | `^Notebook`은 이름이 `Notebook`으로 시작하는 모든 도구와 일치합니다. `mcp__memory__.*`는 `memory` 서버의 모든 도구와 일치합니다. |

정규 표현식 경로의 matcher는 JavaScript의 `RegExp.prototype.test`로 테스트되며, 값의 어디든지 일치하면 성공합니다. `Edit.*`는 `Edit`과 `NotebookEdit` 모두와 일치합니다. 전체 문자열 일치가 필요한 경우 `^Edit$`와 같이 패턴을 `^` 및 `$`로 래핑하십시오.

`FileChanged` 및 `StopFailure`는 문자, 숫자, `_` 및 `|`만 포함하는 더 좁은 정확한 일치 집합을 사용합니다. matcher에 하이픈, 공백 또는 쉼표가 있으면 이 두 이벤트에 대해 정규 표현식 경로에 유지되며, `|`만 대안을 구분합니다. matcher 지원이 있는 다른 모든 이벤트는 `|` 또는 `,`를 허용합니다.

`FileChanged` 이벤트는 감시 목록을 작성할 때 이러한 규칙을 따르지 않습니다. [FileChanged](#filechanged)를 참조하십시오.

각 이벤트 유형은 다른 필드에서 일치합니다:

| 이벤트 | Matcher가 필터링하는 항목 | 예제 matcher 값 |
| :- | :- | :- |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | 도구 이름 | `Bash`, `Edit\|Write`, `mcp__.*` |
| `SessionStart` | 세션이 시작된 방식 | `startup`, `resume`, `clear`, `compact`, `fork` |
| `Setup` | 설정을 트리거한 CLI 플래그 | `init`, `maintenance` |
| `SessionEnd` | 세션이 종료된 이유 | `clear`, `resume`, `logout`, `prompt_input_exit`, `other` |
| `Notification` | 알림 유형 | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_url_dialog`, `elicitation_complete`, `elicitation_response`, `agent_needs_input`, `agent_completed`, `quota_auto_resume_fired`, `quota_auto_resume_stale`, `quota_auto_resume_disabled` |
| `SubagentStart` | 에이전트 유형 | `general-purpose`, `Explore`, `Plan`, 사용자 정의 에이전트 이름 또는 `^my-plugin:reviewer$`와 같은 플러그인 범위 이름 |
| `PreCompact`, `PostCompact` | 압축을 트리거한 항목 | `manual`, `auto` |
| `PreModelSwitch`, `PostModelSwitch` | 세션이 전환되는 모델의 정규 이름([PreModelSwitch](#premodelswitch) 아래에 설명됨) | `claude-opus-5`, `claude-opus-4-6\|claude-opus-5`, `.*opus.*` |
| `SubagentStop` | 에이전트 유형 | `SubagentStart`와 동일한 값 |
| `ConfigChange` | 구성 소스 | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `CwdChanged` | matcher 지원 없음 | 모든 발생에서 항상 실행됨 |
| `DirectoryAdded` | 디렉터리가 추가된 방식 | `slash_command`, `register_repo_root` |
| `FileChanged` | 감시할 리터럴 파일 이름([FileChanged](#filechanged) 참조) | `.envrc\|.env` |
| `StopFailure` | 오류 유형 | `rate_limit`, `overloaded`, `authentication_failed`, `oauth_org_not_allowed`, `account_on_hold`, `billing_error`, `invalid_request`, `model_not_found`, `server_error`, `max_output_tokens`, `cloud_credential_error`, `unknown` |
| `InstructionsLoaded` | 로드 이유 | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `UserPromptExpansion` | 명령 이름 | 스킬 또는 명령 이름 |
| `Elicitation` | MCP 서버 이름 | 구성된 MCP 서버 이름 |
| `ElicitationResult` | MCP 서버 이름 | `Elicitation`과 동일한 값 |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `MessageDisplay` | matcher 지원 없음 | 모든 발생에서 항상 실행됨 |

`StopFailure`에서 `cloud_credential_error`와 일치하려면 Claude Code v2.1.267 이상이 필요합니다. 이는 자격 증명 로드 실패를 `server_error` 또는 `unknown` 대신 해당 값으로 보고하는 첫 번째 버전입니다.

대부분의 이벤트에서 Claude Code는 stdin의 hook으로 보내는 [JSON 입력](#hook-input-and-output)의 필드에 대해 matcher를 평가합니다. 도구 이벤트의 경우 해당 필드는 `tool_name`입니다. `PreModelSwitch` 및 `PostModelSwitch`의 경우 Claude Code는 [PreModelSwitch](#premodelswitch) 아래에 설명된 대로 `to_model`에서 파생된 정규 이름에 대해 matcher를 평가합니다. 각 [hook 이벤트](#hook-events) 섹션은 matcher 값의 전체 집합과 해당 이벤트의 입력 스키마를 나열합니다.

이 예제는 Claude가 파일을 쓰거나 편집할 때만 린팅 스크립트를 실행합니다:

```json theme={null}
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/lint-check.sh"
          }
        ]
      }
    ]
  }
}
```

matcher 지원이 없는 이벤트에 `matcher` 필드를 추가하면 자동으로 무시됩니다.

도구 이벤트의 경우 개별 hook 핸들러에서 [`if` 필드](#common-fields)를 설정하여 더 좁게 필터링할 수 있습니다. `if`는 [권한 규칙 구문](/docs/ko/permissions)을 사용하여 도구 이름과 인수를 함께 일치시키므로 `"Bash(git *)"`는 Bash 입력의 모든 하위 명령이 `git *`과 일치할 때 실행되고 `"Edit(*.ts)"`는 TypeScript 파일에만 실행됩니다.

<h4 id="match-mcp-tools">
  MCP 도구 일치
</h4>

[MCP](/docs/ko/mcp) 서버 도구는 도구 이벤트(`PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`)에서 일반 도구로 나타나므로 다른 도구 이름과 동일한 방식으로 일치시킬 수 있습니다.

MCP 도구는 `mcp__<server>__<tool>` 패턴을 따릅니다. 예를 들어:

* `mcp__memory__create_entities`: Memory 서버의 엔티티 생성 도구
* `mcp__filesystem__read_file`: Filesystem 서버의 파일 읽기 도구
* `mcp__github__search_repositories`: GitHub 서버의 검색 도구

서버의 모든 도구와 일치하려면 서버 접두사에 `.*`를 추가합니다. `.*`는 필수입니다: `mcp__memory` 또는 `mcp__brave-search`와 같은 matcher는 정확한 일치 문자만 포함하므로 정확한 문자열로 비교되며 도구와 일치하지 않습니다.

* `mcp__memory__.*`는 `memory` 서버의 모든 도구와 일치합니다.
* `mcp__brave-search__.*`는 이름에 하이픈이 포함된 서버의 모든 도구와 일치합니다.
* `mcp__.*__write.*`는 모든 서버의 이름이 `write`로 시작하는 모든 도구와 일치합니다.

[플러그인 번들 MCP 서버](/docs/ko/mcp#plugin-provided-mcp-servers)의 도구는 플러그인 이름을 포함하는 범위 지정 서버 세그먼트를 사용합니다: `mcp__plugin_<plugin-name>_<server-name>__<tool>`. 베어 서버 키에 대해 작성된 matcher는 이러한 도구에 대해 실행되지 않습니다. `db` 키 아래에 서버를 번들하는 `my-plugin`이라는 플러그인의 경우 `query` 도구는 `mcp__plugin_my-plugin_db__query`로 나타나므로 해당 서버의 모든 도구에 대한 matcher는 `mcp__plugin_my-plugin_db__.*`입니다. 핸들러의 [`if` 필드](#common-fields)에서 동일한 범위 지정 도구 이름을 사용합니다. 범위 지정 이름이 작성되는 방식에 대해서는 [플러그인 제공 MCP 서버](/docs/ko/mcp#plugin-provided-mcp-servers)를 참조하십시오.

이 예제는 모든 메모리 서버 작업을 기록하고 모든 MCP 서버의 쓰기 작업을 검증합니다:

```json theme={null}
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "mcp__memory__.*",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Memory operation initiated' >> ~/mcp-operations.log"
          }
        ]
      },
      {
        "matcher": "mcp__.*__write.*",
        "hooks": [
          {
            "type": "command",
            "command": "/home/user/scripts/validate-mcp-write.py"
          }
        ]
      }
    ]
  }
}
```

<h3 id="hook-handler-fields">
  Hook 핸들러 필드
</h3>

내부 `hooks` 배열의 각 객체는 hook 핸들러입니다: matcher가 일치할 때 실행되는 셸 명령, HTTP 엔드포인트, MCP 도구, LLM 프롬프트 또는 에이전트입니다. 다섯 가지 유형이 있습니다:

* **[명령 hook](#command-hook-fields)** (`type: "command"`): 셸 명령을 실행합니다. 스크립트는 stdin의 이벤트 [JSON 입력](#hook-input-and-output)을 수신하고 종료 코드 및 stdout을 통해 결과를 다시 전달합니다.
* **[HTTP hook](#http-hook-fields)** (`type: "http"`): 이벤트의 JSON 입력을 HTTP POST 요청으로 URL에 보냅니다. 엔드포인트는 명령 hook과 동일한 [JSON 출력 형식](#json-output)을 사용하여 응답 본문을 통해 결과를 다시 전달합니다.
* **[MCP 도구 훅](#mcp-tool-hook-fields)** (`type: "mcp_tool"`): 구성된 [MCP 서버](/docs/ko/mcp)의 도구를 호출합니다. 도구의 텍스트 출력은 명령 훅 stdout처럼 처리됩니다.
* **[프롬프트 hook](#prompt-and-agent-hook-fields)** (`type: "prompt"`): Claude 모델에 단일 턴 평가를 위한 프롬프트를 보냅니다. 모델은 결정을 JSON으로 반환합니다. [프롬프트 기반 hook](#prompt-based-hooks)을 참조하십시오.
* **[에이전트 hook](#prompt-and-agent-hook-fields)** (`type: "agent"`): Read, Grep 및 Glob과 같은 도구를 사용하여 조건을 확인한 후 결정을 반환할 수 있는 서브에이전트를 생성합니다. 에이전트 hook은 실험적이며 변경될 수 있습니다. [에이전트 기반 hook](#agent-based-hooks)을 참조하십시오.

일치하는 모든 hook은 병렬로 실행됩니다. 동일한 핸들러를 둘 이상의 설정 파일에서 정의하면 한 번 실행됩니다. 플러그인 또는 스킬의 동일한 핸들러 복사본은 별도로 유지됩니다.

핸들러는 Claude Code의 환경이 있는 현재 디렉터리에서 실행됩니다. 예를 들어 다른 셸이 세션 중간에 삭제한 worktree 또는 임시 디렉터리와 같이 현재 디렉터리가 더 이상 존재하지 않으면 Claude Code는 다음 중 여전히 존재하는 첫 번째 디렉터리에서 명령 hook을 실행합니다: 세션이 시작된 디렉터리, 프로젝트 루트, 홈 디렉터리 또는 시스템 임시 디렉터리. Claude Code는 [디버그 로그](#debug-hooks)에서 폴백 디렉터리의 이름을 지정하는 경고를 기록합니다.

`$CLAUDE_CODE_REMOTE` 환경 변수는 원격 웹 환경에서 `"true"`이고 로컬 CLI에서 설정되지 않습니다. Claude Code v2.1.199 이상은 로컬 세션이 활성 Remote Control 연결을 가지는 동안 [`$CLAUDE_CODE_BRIDGE_SESSION_ID`](/docs/ko/env-vars)를 [Remote Control](/docs/ko/remote-control) 세션 ID로 설정합니다.

<h4 id="common-fields">
  공통 필드
</h4>

이 필드는 모든 hook 유형에 적용됩니다:

| 필드 | 필수 | 설명 |
| :- | :- | :- |
| `type` | 예 | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"` 또는 `"agent"` |
| `if` | 아니요 | `"Bash(git *)"` 또는 `"Edit(*.ts)"`와 같이 이 훅이 실행되는 시기를 필터링하는 [권한 규칙 구문](/docs/ko/permissions#permission-rule-syntax). 훅 명령은 도구 호출이 패턴과 일치하는 경우에만 실행됩니다. Bash 패턴이 하위 명령, `$()` 및 백틱에 대해 평가되는 방식에 대해서는 [Bash 일치 테이블](#bash-if-matching)을 참조하십시오. 도구 이벤트에서만 평가됩니다: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest` 및 `PermissionDenied`. 다른 이벤트에서는 `if`가 설정된 훅이 실행되지 않습니다. |
| `timeout` | 아니요 | 취소하기 전 초 단위. Claude Code는 [`async: true`](#run-hooks-in-the-background)로 실행하는 명령 hook에 적용하지 않습니다. 기본값: `command`, `http` 및 `mcp_tool`의 경우 600, `prompt`의 경우 30, `agent`의 경우 60. Claude Code는 [`UserPromptSubmit`](#userpromptsubmit), [`PreModelSwitch`](#premodelswitch) 및 [`PostModelSwitch`](#postmodelswitch)에서 `command`, `http` 및 `mcp_tool` 기본값을 30으로 낮추고, [`MessageDisplay`](#messagedisplay)에서 10으로 낮춥니다. [`SessionEnd`](#sessionend) hook은 1.5초 예산을 공유합니다. 설정이 더 긴 hook별 `timeout`을 설정하면 Claude Code는 예산을 일치하도록 올립니다(최대 60초). |
| `statusMessage` | 아니요 | hook이 실행되는 동안 표시되는 사용자 정의 스피너 메시지 |
| `once` | 아니요 | `true`이면 Claude Code는 첫 번째 성공적인 실행 후 hook을 제거합니다. 실패하거나 종료 코드 2로 차단되거나 시간 초과되는 실행은 hook을 제자리에 두므로 다음 일치 이벤트에서 다시 실행됩니다. [스킬 frontmatter](#hooks-in-skills-and-agents)에서 선언된 hook에만 적용됩니다. 설정 파일 및 에이전트 frontmatter에서는 무시됩니다. |

`if` 필드는 정확히 하나의 권한 규칙을 보유합니다. 규칙을 결합하기 위한 `&&`, `||` 또는 목록 구문이 없습니다. 여러 조건을 적용하려면 각각에 대해 별도의 hook 핸들러를 정의하십시오.

파일 도구의 `if` 조건에서 `"Edit(src/**)"` 같은 단일 세그먼트 디렉터리 패턴은 작업 디렉터리의 `src` 디렉터리와 그 아래의 파일만 일치합니다. 모든 깊이에서 `src`라는 디렉터리와 일치하려면 `"Edit(**/src/**)"` 형식으로 작성하십시오. v2.1.214 이전에는 `"Edit(src/**)"`가 작업 디렉터리 아래의 모든 깊이에서 `src`라는 디렉터리와 일치했습니다.

<h4 id="bash-if-matching">
  `if` 패턴이 Bash 명령과 일치하는 방식
</h4>

[`if` 필드](#common-fields)의 Bash 패턴의 경우, 훅 명령이 실행되는지 여부는 패턴의 형태와 Claude가 호출하는 Bash 명령에 따라 다릅니다. 선행 `VAR=value` 할당은 일치하기 전에 제거됩니다.

| `if` 패턴 | Bash 명령 | Hook 실행? | 이유 |
| :- | :- | :- | :- |
| `Bash(git *)` | `FOO=bar git push` | 예 | 선행 할당이 제거됨; `git push`가 일치함 |
| `Bash(git *)` | `npm test && git push` | 예 | 각 하위 명령이 확인됨; `git push`가 일치함 |
| `Bash(rm *)` | `echo $(rm -rf /)` | 예 | `$()` 및 백틱 내의 명령이 확인됨; `rm -rf /`가 일치함 |
| `Bash(rm *)` | `echo $(date)` | 아니요 | 하위 명령이 `rm *`과 일치하지 않음 |
| `Bash(git push *)` | `echo $(date)` | 예 | 명령 이름보다 더 많이 지정하는 패턴은 `$()`, 백틱 또는 `$VAR`에서 어쨌든 hook을 실행함 |

Claude Code가 Bash 입력이 실행하는 명령을 결정할 수 없으면 패턴에 관계없이 hook을 실행합니다. `if` 필터는 최선의 노력이므로 하드 허용 또는 거부를 적용하려면 hook 대신 [권한 시스템](/docs/ko/permissions)을 사용하십시오.

<h4 id="command-hook-fields">
  명령 hook 필드
</h4>

[공통 필드](#common-fields) 외에도 명령 hook은 다음 필드를 허용합니다:

| 필드 | 필수 | 설명 |
| :- | :- | :- |
| `command` | 예 | 실행할 셸 명령. `args`를 사용하면 직접 생성할 실행 파일입니다. [Exec 형식 및 셸 형식](#exec-form-and-shell-form) 참조 |
| `args` | 아니요 | 인수 목록. 존재하면 `command`는 실행 파일로 해결되고 `args`를 인수 벡터로 하여 직접 생성되며, 셸이 관여하지 않습니다. [Exec 형식 및 셸 형식](#exec-form-and-shell-form) 참조 |
| `async` | 아니요 | `true`이면 차단하지 않고 백그라운드에서 실행됩니다. [백그라운드에서 hook 실행](#run-hooks-in-the-background) 참조 |
| `asyncRewake` | 아니요 | `true`이면 백그라운드에서 실행되고 종료 코드 2에서 Claude를 깨웁니다. 훅의 stderr 또는 stderr가 비어 있으면 stdout이 Claude에게 [시스템 리마인더](/docs/ko/glossary#system-reminder)로 표시되므로 장시간 실행되는 백그라운드 실패에 반응할 수 있습니다. |
| `shell` | 아니요 | 이 hook에 사용할 셸. `"bash"` 또는 `"powershell"`을 허용합니다. 기본값은 `"bash"` 또는 Git Bash가 설치되지 않은 경우 Windows에서 `"powershell"`입니다. `"powershell"`을 설정하면 Windows에서 PowerShell을 통해 명령을 실행합니다. `CLAUDE_CODE_USE_POWERSHELL_TOOL`이 필요하지 않습니다. hook이 PowerShell을 직접 생성하기 때문입니다. `args`가 설정되면 무시됩니다. |
| `onFailure` | 아니요 | 훅이 실패할 때 해당 작업에 일어나는 동작: 기본값인 `"continue"` 또는 `"block"`. [훅이 실패할 때 작업 차단](#block-the-action-when-a-hook-fails)을 참조하십시오. Claude Code v2.1.295 이상이 필요합니다. |

<a id="exec-form-and-shell-form" />

<h5 id="exec-form-and-shell-form">
  Exec 형식 및 셸 형식
</h5>

명령 hook은 `args`가 설정되면 exec 형식으로 실행되고 `args`가 생략되면 셸 형식으로 실행됩니다. hook이 [경로 자리 표시자](#reference-scripts-by-path)를 참조할 때마다 `args`를 설정하십시오. 각 요소는 따옴표 없이 하나의 인수로 전달되기 때문입니다. 파이프 또는 `&&`와 같은 셸 기능이 필요하거나 어느 쪽도 적용되지 않을 때 `args`를 생략하십시오.

**Exec 형식**은 `args`가 있을 때 실행됩니다. Claude Code는 `command`를 `PATH`의 실행 파일로 해결하고 `args`를 인수 벡터로 하여 직접 생성합니다. 셸이 없으므로 각 `args` 요소는 작성된 그대로 정확히 하나의 인수이며 `${CLAUDE_PLUGIN_ROOT}`와 같은 경로 자리 표시자는 일반 문자열로 `command` 및 각 `args` 요소로 대체됩니다. 아포스트로피, `$` 및 백틱과 같은 특수 문자는 해석할 셸이 없기 때문에 그대로 전달됩니다. 모든 플랫폼에서 셸 토큰화가 발생하지 않습니다.

**셸 형식**은 `args`가 없을 때 실행됩니다. `command` 문자열은 셸로 전달됩니다: macOS 및 Linux에서 `sh -c`, Windows에서 Git Bash 또는 Git Bash가 설치되지 않은 경우 PowerShell. `shell` 필드를 설정하여 명시적으로 선택합니다. 셸은 문자열을 토큰화하고 변수를 확장하며 파이프, `&&`, 리디렉션 및 글로브를 해석합니다.

<Note>
  Windows에서 exec 형식은 `.exe`와 같은 실제 실행 파일로 해결되는 `command`를 필요로 합니다. npm, npx, eslint 및 기타 도구가 `node_modules/.bin`에 설치하는 `.cmd` 및 `.bat` shim은 실행 파일이 아니며 셸 없이 생성될 수 없습니다. exec 형식으로 실행하려면 기본 스크립트를 `node`로 직접 호출합니다. 예를 들어 `"command": "node", "args": ["${CLAUDE_PLUGIN_ROOT}/node_modules/eslint/bin/eslint.js"]`. `node` 더하기 스크립트 경로 패턴은 `node.exe`가 실제 바이너리이기 때문에 모든 플랫폼에서 작동합니다. `.cmd` 또는 `.bat` shim을 이름으로 실행하려면 셸 형식을 사용합니다.
</Note>

이 예제는 플러그인과 함께 번들된 Node 스크립트를 실행합니다. Exec 형식은 해결된 스크립트 경로를 따옴표 없이 하나의 인수로 전달합니다:

```json theme={null}
{
  "type": "command",
  "command": "node",
  "args": ["${CLAUDE_PLUGIN_ROOT}/scripts/format.js", "--fix"]
}
```

동등한 셸 형식은 공백이나 특수 문자가 있는 경로를 처리하기 위해 따옴표가 필요합니다:

```json theme={null}
{
  "type": "command",
  "command": "node \"${CLAUDE_PLUGIN_ROOT}\"/scripts/format.js --fix"
}
```

두 형식 모두 동일한 [경로 자리 표시자](#reference-scripts-by-path)를 지원하며, 둘 다 생성된 프로세스에서 `CLAUDE_PROJECT_DIR`, `CLAUDE_PLUGIN_ROOT` 및 `CLAUDE_PLUGIN_DATA`를 환경 변수로 내보내므로 스크립트는 시작 방식에 관계없이 `process.env.CLAUDE_PLUGIN_ROOT`를 읽을 수 있습니다.

플러그인 훅은 추가로 [`${user_config.*}`](/docs/ko/plugins/manifest-reference#user-configuration) 값을 exec 형식에서만 대체합니다: 값은 일반 문자열로 `command` 및 각 `args` 요소로 대체되므로 셸이 다시 파싱하지 않습니다.

`command`가 `${user_config.*}`를 참조하는 셸 형식 플러그인 hook은 실행되는 대신 [오류](/docs/ko/errors#plugin-command-references-user-config)로 실패합니다. 셸 형식 hook에서 옵션 값을 사용하려면 `$CLAUDE_PLUGIN_OPTION_<KEY>` 환경 변수(예: `webhook_url` 옵션의 경우 `$CLAUDE_PLUGIN_OPTION_WEBHOOK_URL`)를 읽거나 `args`를 설정하여 hook을 exec 형식으로 전환합니다. v2.1.207 이전에는 셸 형식 플러그인 hook 명령도 `${user_config.*}`를 대체했습니다.

<Note>
  Exec 형식에서 `command`는 실행 파일 이름 또는 경로만입니다. `command`가 경로 구분 기호가 없는 베어 이름이고 `args`와 함께 공백을 포함하면 Claude Code는 경고를 기록합니다. 생성이 실패하기 때문입니다: `node script.js`라는 실행 파일이 없습니다. 추가 토큰을 `args`로 이동합니다. `C:\Program Files\nodejs\node.exe`와 같은 공백이 있는 절대 경로는 단일 유효한 실행 파일이며 경고를 트리거하지 않습니다.
</Note>

<h4 id="http-hook-fields">
  HTTP hook 필드
</h4>

[공통 필드](#common-fields) 외에도 HTTP hook은 다음 필드를 허용합니다:

| 필드 | 필수 | 설명 |
| :- | :- | :- |
| `url` | 예 | POST 요청을 보낼 URL |
| `headers` | 아니요 | 키-값 쌍으로 추가 HTTP 헤더. 값은 `$VAR_NAME` 또는 `${VAR_NAME}` 구문을 사용한 환경 변수 보간을 지원합니다. `allowedEnvVars`에 나열된 변수만 해결됩니다. |
| `allowedEnvVars` | 아니요 | 헤더 값에 보간될 수 있는 환경 변수 이름 목록. 나열되지 않은 변수에 대한 참조는 빈 문자열로 바뀝니다. 환경 변수 보간이 작동하려면 필수입니다. |
| `onFailure` | 아니요 | 훅이 실패할 때 해당 작업에 일어나는 동작: 기본값인 `"continue"` 또는 `"block"`. [훅이 실패할 때 작업 차단](#block-the-action-when-a-hook-fails)을 참조하십시오. Claude Code v2.1.295 이상이 필요합니다. |

Claude Code는 hook의 [JSON 입력](#hook-input-and-output)을 `Content-Type: application/json`을 사용하여 POST 요청 본문으로 보냅니다. 응답 본문은 명령 hook과 동일한 [JSON 출력 형식](#json-output)을 사용합니다.

오류 처리는 명령 hook과 다릅니다. [HTTP 응답 처리](#http-response-handling)를 참조하십시오.

이 예제는 `PreToolUse` 이벤트를 로컬 검증 서비스로 보내고 `MY_TOKEN` 환경 변수의 토큰으로 인증합니다:

```json theme={null}
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "http",
            "url": "http://localhost:8080/hooks/pre-tool-use",
            "timeout": 30,
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

<h4 id="mcp-tool-hook-fields">
  MCP 도구 hook 필드
</h4>

[공통 필드](#common-fields) 외에도 MCP 도구 hook은 다음 필드를 허용합니다:

| 필드 | 필수 | 설명 |
| :- | :- | :- |
| `server` | 예 | 구성된 MCP 서버의 이름. [플러그인 번들 서버](/docs/ko/mcp#plugin-provided-mcp-servers)의 경우 `plugin:my-plugin:db`와 같은 범위 지정 이름 `plugin:<plugin-name>:<server-name>`입니다. 베어 서버 키가 아닙니다. |
| `tool` | 예 | 해당 서버에서 호출할 도구의 이름 |
| `input` | 아니요 | 도구에 전달된 인수. 문자열 값은 hook의 [JSON 입력](#hook-input-and-output)에서 `${path}` 대체를 지원합니다. 예를 들어 `"${tool_input.file_path}"` |

이 예제는 각 `Write` 또는 `Edit` 후에 `my_server` MCP 서버의 `security_scan` 도구를 호출하고 편집된 파일의 경로를 전달합니다:

```json theme={null}
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "mcp_tool",
            "server": "my_server",
            "tool": "security_scan",
            "input": { "file_path": "${tool_input.file_path}" }
          }
        ]
      }
    ]
  }
}
```

<h5 id="how-the-tool’s-result-is-read">
  도구 결과를 읽는 방식
</h5>

Claude Code는 도구의 텍스트 콘텐츠를 명령 훅 stdout과 동일한 방식으로 읽으며, [종료 코드 0 아래의 파싱 규칙](#exit-code-0)을 따릅니다. 도구가 `isError: true`를 반환하면 훅은 차단하지 않는 오류를 생성하고 실행이 계속됩니다.

<h5 id="when-the-server-is-still-connecting">
  서버가 아직 연결 중일 때
</h5>

`PreToolUse` 또는 `Stop`과 같이 훅이 결과를 차단하거나 변경할 수 있는 이벤트에서 Claude Code는 도구를 호출하기 전에 연결 중인 서버를 최대 [`MCP_TIMEOUT`](/docs/ko/env-vars)까지, 그리고 훅 자체의 [`timeout`](#common-fields) 내에서 기다립니다. `Notification` 또는 `SessionEnd`와 같은 관찰용 이벤트에서는 기다리지 않습니다.

[`cached` 상태](/docs/ko/mcp#server-status-detail)를 표시하는 서버는 훅이 해당 도구를 호출할 때 연결됩니다. 그 시점에 서버가 연결되어 있지 않으면 훅은 차단하지 않는 오류를 생성하고 실행이 계속됩니다. 훅은 OAuth 흐름을 시작하지 않으므로 먼저 [`/mcp`에서 서버를 인증](/docs/ko/mcp#authenticate-with-remote-mcp-servers)하십시오.

<h5 id="events-that-fire-before-mcp-servers-are-available">
  MCP 서버를 사용할 수 있기 전에 실행되는 이벤트
</h5>

`--continue` 또는 `--resume`을 사용하는 경우를 포함한 시작 시의 `SessionStart`와 모든 `Setup` 이벤트는 세션의 MCP 서버를 훅에서 사용할 수 있게 되기 전에 실행됩니다. Claude Code는 도구를 호출하지 않고 해당 이벤트의 `mcp_tool` 훅을 건너뛰며, [디버그 로그](#debug-hooks)는 `mcp_tool hooks are not available for the 'SessionStart' hook event (no MCP client context)` 또는 `Setup`을 명명하는 동일한 메시지를 기록합니다. `/clear` 또는 압축 후 세션 중에 `SessionStart`가 다시 실행되면 해당 `mcp_tool` 훅이 실행됩니다. 세션이 시작 시 필요한 모든 항목에는 대신 `SessionStart`에서 `type: "command"` 훅을 사용하십시오.

<h4 id="prompt-and-agent-hook-fields">
  프롬프트 및 에이전트 hook 필드
</h4>

[공통 필드](#common-fields) 외에도 프롬프트 및 에이전트 hook은 다음 필드를 허용합니다:

| 필드 | 필수 | 설명 |
| :- | :- | :- |
| `prompt` | 예 | 모델로 보낼 프롬프트 텍스트. hook 입력 JSON에 대한 자리 표시자로 `$ARGUMENTS`를 사용합니다. 리터럴 텍스트를 포함하려면 백슬래시로 이스케이프합니다: `\$1.00`은 `$1.00`으로 렌더링됩니다. |
| `model` | 아니요 | 평가에 사용할 모델. 기본값은 Claude Code가 [백그라운드 기능](/docs/ko/costs#background-token-usage)에 사용하는 모델입니다. |

<h3 id="reference-scripts-by-path">
  경로별 스크립트 참조
</h3>

프로젝트 또는 플러그인 루트를 기준으로 hook 스크립트를 참조하려면 이 자리 표시자를 사용합니다. hook이 실행될 때의 작업 디렉터리와 관계없이:

* `${CLAUDE_PROJECT_DIR}`: 세션이 시작된 프로젝트 루트. Claude Code는 또한 [stdio MCP 서버](/docs/ko/mcp#option-3-add-a-local-stdio-server) 및 플러그인 LSP 서버의 환경에서 이 변수를 설정합니다.
* `${CLAUDE_PLUGIN_ROOT}`: [플러그인](/docs/ko/plugins/overview)과 함께 번들된 스크립트의 플러그인 설치 디렉터리. 업데이트 전반에 걸쳐 경로가 어떻게 작동하는지에 대해서는 [플러그인 환경 변수](/docs/ko/plugins/manifest-reference#environment-variables)를 참조하십시오.
* `${CLAUDE_PLUGIN_DATA}`: 플러그인 업데이트 후에도 유지되어야 하는 의존성 및 상태를 위한 플러그인의 [영구 데이터 디렉터리](/docs/ko/plugins/components#path-variables-and-persistent-data).

<Note>
  **Worktree는 다릅니다.** Claude가 세션 중에 [worktree](/docs/ko/worktrees)에 들어가면 Claude Code는 `${CLAUDE_PROJECT_DIR}`을 원래 위치에 유지하고 worktree 경로를 다른 방식으로 hook에 전달합니다:

  * **`${CLAUDE_PROJECT_DIR}`은 제자리에 유지됩니다**: 여전히 세션이 시작된 프로젝트 루트를 가리키므로 `${CLAUDE_PROJECT_DIR}/.claude/hooks/check-style.sh`와 같은 명령은 여전히 주 체크아웃에서 스크립트를 실행합니다.
  * **`cwd`는 Claude를 따릅니다**: Claude가 worktree에 들어간 후 hook의 [입력 JSON](#common-input-fields)의 `cwd` 필드는 worktree 루트이고, Claude가 `cd`를 실행한 후 새 디렉터리입니다. hook이 Claude가 작업 중인 디렉터리를 알아야 할 때 읽습니다.
</Note>

경로 자리 표시자를 참조하는 모든 hook에 대해 [exec 형식](#exec-form-and-shell-form)을 선호합니다. 셸 형식에서 각 자리 표시자를 큰따옴표로 래핑합니다.

<Tabs>
  <Tab title="프로젝트 스크립트">
    이 예제는 `${CLAUDE_PROJECT_DIR}`을 사용하여 모든 `Write` 또는 `Edit` 도구 호출 후 프로젝트의 `.claude/hooks/` 디렉터리에서 스타일 검사기를 실행합니다:

    ```json theme={null}
    {
      "hooks": {
        "PostToolUse": [
          {
            "matcher": "Write|Edit",
            "hooks": [
              {
                "type": "command",
                "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/check-style.sh",
                "args": []
              }
            ]
          }
        ]
      }
    }
    ```
  </Tab>

  <Tab title="플러그인 스크립트">
    선택적 최상위 `description` 필드를 사용하여 `hooks/hooks.json`에서 플러그인 hook을 정의합니다. 플러그인이 활성화되면 해당 hook이 사용자 및 프로젝트 hook과 병합됩니다.

    이 예제는 플러그인과 함께 번들된 포맷팅 스크립트를 실행합니다:

    ```json theme={null}
    {
      "description": "Automatic code formatting",
      "hooks": {
        "PostToolUse": [
          {
            "matcher": "Write|Edit",
            "hooks": [
              {
                "type": "command",
                "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh",
                "args": [],
                "timeout": 30
              }
            ]
          }
        ]
      }
    }
    ```

    플러그인 훅 생성에 대한 자세한 내용은 [플러그인 구성 요소 참조](/docs/ko/plugins/components#hooks)를 참조하십시오.
  </Tab>
</Tabs>

<h3 id="hooks-in-skills-and-agents">
  스킬 및 에이전트의 Hook
</h3>

설정 파일 및 플러그인 외에도 hook은 frontmatter를 사용하여 [스킬](/docs/ko/skills) 및 [서브에이전트](/docs/ko/sub-agents)에서 직접 정의될 수 있으며, 설정 기반 hook과 동일한 구성 형식입니다. Claude Code가 등록된 상태를 유지하는 기간은 구성 요소에 따라 다릅니다:

* **서브에이전트 hook**: Claude Code는 해당 서브에이전트가 실행되는 동안만 실행하고 완료되면 제거합니다. Claude Code는 여기서 `Stop` hook을 `SubagentStop`으로 변환합니다. 서브에이전트가 완료될 때 실행되는 이벤트입니다.
* **스킬 hook**: Claude Code는 사용자 또는 Claude가 스킬을 호출할 때 등록하고 스킬의 자신의 턴 이후 턴뿐만 아니라 세션의 나머지 부분에서 실행을 계속합니다. 첫 번째 성공적인 실행 후 hook을 제거하려면 대신 [`once: true`](#common-fields)를 설정하십시오.

이 스킬은 각 `Bash` 명령 전에 보안 검증 스크립트를 실행하는 `PreToolUse` hook을 정의합니다:

```yaml theme={null}
---
name: secure-operations
description: Perform operations with security checks
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/security-check.sh"
---
```

서브에이전트는 YAML frontmatter에서 동일한 형식을 사용합니다.

프로젝트 스킬의 Frontmatter hook은 [설정 파일의 hook과 동일한 워크스페이스 신뢰 규칙](#workspace-trust)을 따릅니다. Claude Code는 사용자 또는 Claude가 스킬을 호출할 때 등록합니다. 폴더를 신뢰하지 않은 `-p` 실행 포함.

프로젝트 서브에이전트의 Frontmatter hook은 에이전트 파일이 나온 폴더에 대해 [워크스페이스 신뢰 대화](/docs/ko/permissions#project-allow-rules-and-workspace-trust)를 수락한 후에만 실행됩니다. `-p` 세션은 수락으로 계산되지 않습니다. [폴더를 신뢰하기 전에 실행되는 항목](/docs/ko/permissions#what-runs-before-you-trust-a-folder)은 설정 파일 규칙과 비교하고 서브에이전트 페이지는 [어떤 범위가 제외되는지](/docs/ko/sub-agents#hooks-in-subagent-frontmatter) 나열합니다. v2.1.218 이전에는 이러한 hook이 신뢰하지 않은 폴더에서 실행될 수 있었습니다.

<h3 id="the-/hooks-menu">
  `/hooks` 메뉴
</h3>

Claude Code에서 `/hooks`를 입력하면 구성된 hook을 확인할 수 있는 읽기 전용 브라우저가 열립니다. 목록은 각 hook에 사용자 설정, 프로젝트 설정, 로컬 설정, 플러그인 또는 현재 세션과 같은 출처를 레이블로 표시합니다.

hook을 선택하면 실행하는 내용의 전체 텍스트와 설정 파일 경로나 플러그인 이름과 같이 정의된 위치를 확인할 수 있습니다.

hook이 구성되지 않은 이벤트를 포함하여 모든 hook 이벤트를 탐색하려면 목록 끝에서 `All events`를 선택하십시오.

<h3 id="disable-or-remove-hooks">
  Hook 비활성화 또는 제거
</h3>

설정 파일에 정의된 hook을 제거하려면 해당 파일에서 항목을 삭제합니다.

hook을 제거하지 않고 일시적으로 모든 hook을 비활성화하려면 설정 파일에서 `"disableAllHooks": true`를 설정합니다. Claude Code는 [설정 우선순위](/docs/ko/settings#settings-precedence)가 적용된 후 남은 값을 읽으므로 프로젝트의 `.claude/settings.json`의 `"disableAllHooks": false`는 사용자 설정의 `true`를 재정의합니다. 프로젝트의 설정이 무엇이든 한 번 실행에 대해 hook을 끄려면 `--settings '{"disableAllHooks": true}'`를 전달합니다. 이는 프로젝트 및 로컬 설정보다 우선합니다. 구성에 유지하면서 개별 hook을 비활성화할 방법이 없습니다.

`disableAllHooks` 설정은 관리형 설정 계층을 존중합니다. 관리자가 관리형 정책 설정을 통해 hook을 구성한 경우 사용자, 프로젝트 또는 로컬 설정에서 설정된 `disableAllHooks`는 해당 관리형 hook을 비활성화할 수 없습니다. 관리형 설정 수준에서 설정된 `disableAllHooks`만 관리형 hook을 비활성화할 수 있습니다. 각 수준의 전체 범위에 대해서는 [`disableAllHooks`](/docs/ko/settings-reference#disableallhooks)를 참조하십시오.

설정 파일의 hook에 대한 직접 편집은 일반적으로 파일 감시자에 의해 자동으로 선택됩니다.

<h2 id="hook-input-and-output">
  Hook 입출력
</h2>

명령 hook은 stdin을 통해 JSON 데이터를 받고 종료 코드, stdout, stderr를 통해 결과를 전달합니다. HTTP hook은 POST 요청 본문으로 동일한 JSON을 받고 HTTP 응답 본문을 통해 결과를 전달합니다. 이 섹션에서는 모든 이벤트에 공통적인 필드와 동작을 다룹니다. [Hook 이벤트](#hook-events) 아래의 각 이벤트 섹션에는 특정 입력 스키마와 결정 제어 옵션이 포함됩니다.

macOS 및 Linux에서 명령 hook은 제어 터미널 없이 자신의 세션에서 실행됩니다. hook 프로세스 및 모든 자식 프로세스는 `/dev/tty`를 열거나 Claude Code 인터페이스에 직접 이스케이프 시퀀스를 보낼 수 없습니다. Windows에는 `/dev/tty`가 없습니다.

모든 플랫폼에서 사용자에게 메시지를 표시하려면 JSON 출력에서 [`systemMessage`](#json-output)를 반환합니다. 일부 이벤트는 이를 버리거나 다른 곳에 전달하며, 각 [이벤트의 섹션](#hook-events)에서 이를 설명합니다. 데스크톱 알림을 트리거하거나 창 제목을 설정하거나 벨을 울리려면 대신 [`terminalSequence`](#emit-terminal-notifications)를 반환합니다.

<h3 id="common-input-fields">
  공통 입력 필드
</h3>

Hook 이벤트는 각 [hook 이벤트](#hook-events) 섹션에서 문서화된 이벤트 특정 필드 외에 이러한 필드를 JSON으로 받습니다. 명령 hook의 경우 이 JSON은 stdin을 통해 도착합니다. HTTP hook의 경우 POST 요청 본문으로 도착합니다.

| 필드 | 설명 |
| :- | :- |
| `session_id` | 현재 세션 식별자 |
| `prompt_id` | 현재 처리 중인 사용자 프롬프트를 식별하는 UUID입니다. [OpenTelemetry 이벤트의 `prompt.id` 속성](/docs/ko/monitoring-usage#event-correlation-attributes)과 일치하므로 hook 출력을 단일 프롬프트의 텔레메트리와 연관시킬 수 있습니다. 첫 번째 사용자 입력 전까지는 없습니다 |
| `transcript_path` | 대화 JSON 경로입니다. 트랜스크립트 파일은 비동기적으로 기록되며 메모리 내 대화보다 뒤처질 수 있으므로 hook이 발생할 때 현재 턴의 가장 최근 메시지를 아직 포함하지 않을 수 있습니다. 현재 턴의 최종 어시스턴트 텍스트가 필요한 hook은 트랜스크립트를 읽는 대신 [Stop](#stop) 및 [SubagentStop](#subagentstop)에서 `last_assistant_message`를 사용해야 합니다 |
| `cwd` | hook이 호출될 때의 현재 작업 디렉터리 |
| `scratchpad_dir` | 세션의 [scratchpad 디렉터리](/docs/ko/claude-directory#session-scratchpad-directory) 경로이며, Claude가 임시 작업 파일을 보관하는 곳입니다. 세션에 scratchpad가 없거나 임시 디렉터리를 사용할 수 없을 때는 없습니다. Claude Code v2.1.257 이상 필요 |
| `permission_mode` | 현재 [권한 모드](/docs/ko/permissions#permission-modes): `"default"`, `"plan"`, `"acceptEdits"`, `"auto"`, `"dontAsk"` 또는 `"bypassPermissions"`. **수동**으로 표시된 모드는 `"default"`로 도착하며 `"manual"`로 도착하지 않으므로 `"default"`와 일치하는 스크립트는 계속 작동합니다. 모든 이벤트가 이 필드를 받는 것은 아닙니다. 각 [hook 이벤트](#hook-events) 섹션의 JSON 예제를 확인하세요 |
| `effort` | hook이 실행될 때 적용 중인 [effort 수준](/docs/ko/model-config#adjust-effort-level)을 담은 `level` 필드가 있는 객체: `"low"`, `"medium"`, `"high"`, `"xhigh"` 또는 `"max"`. 활성 모델이 지원하지 않는 수준을 설정하면 `level`은 Claude Code가 대신 실행한 수준을 보고합니다. [effort 수준 조정](/docs/ko/model-config#adjust-effort-level)에서 해당 수준을 선택하는 방법을 설명합니다. 이 객체는 [상태줄](/docs/ko/statusline#available-data) `effort` 필드와 일치합니다. `PreToolUse`, `PostToolUse`, `Stop`, `SubagentStop`과 같이 도구 사용 컨텍스트 내에서 발생하는 이벤트에 대해 현재 모델이 effort 매개변수를 지원할 때 존재합니다. 이 수준은 `$CLAUDE_EFFORT` 환경 변수로 hook 명령 및 Bash 도구에서도 사용할 수 있습니다. |
| `hook_event_name` | 발생한 이벤트의 이름 |

`--agent`로 실행하거나 서브에이전트 내부에서 실행할 때 두 개의 추가 필드가 포함됩니다:

| 필드 | 설명 |
| :- | :- |
| `agent_id` | 서브에이전트의 고유 식별자. hook이 서브에이전트 호출 내부에서 발생할 때만 존재합니다. 이를 사용하여 서브에이전트 hook 호출을 메인 스레드 호출과 구별합니다. |
| `agent_type` | 에이전트 이름 (예: `"Explore"` 또는 `"security-reviewer"`). 세션이 `--agent`를 사용하거나 hook이 서브에이전트 내부에서 발생할 때 존재합니다. 서브에이전트의 경우 서브에이전트의 유형이 세션의 `--agent` 값보다 우선합니다. 사용자 정의 및 플러그인 서브에이전트가 보고하는 값과 플러그인 범위 이름에 대해 matcher를 작성하는 방법은 [SubagentStart](#subagentstart)를 참조하세요. |

[`SessionStart`](#sessionstart) hook만 `model` 필드를 받을 수 있으며, Claude Code가 항상 포함하지는 않습니다. [`PreModelSwitch`](#premodelswitch) 및 [`PostModelSwitch`](#postmodelswitch) hook은 대신 `from_model` 및 `to_model`을 받으므로, 세션 중에 모델이 변경되는 것을 추적하려면 PostModelSwitch hook을 사용합니다.

`$CLAUDE_MODEL` 환경 변수는 없습니다. hook은 셸에서 설정한 경우 `$ANTHROPIC_MODEL`을 읽을 수 있지만, 세션 중에 `/model`로 모델을 전환해도 해당 값은 변경되지 않습니다.

hook 프로세스는 부모 환경을 상속합니다. 단, Claude Code가 [생성하는 모든 서브프로세스에서 제거하는](/docs/ko/monitoring-usage#administrator-configuration) `OTEL_*` 내보내기 변수와, [`CLAUDE_CODE_SUBPROCESS_ENV_SCRUB`](/docs/ko/env-vars#variables)가 `1`로 설정된 경우 제거되는 변수는 제외됩니다. [HIPAA 구성을 받는](/docs/ko/hipaa-setup#check-how-developers-sign-in-and-connect) 세션에서는 Claude Code가 hook의 환경에서 [Anthropic 자격 증명도 제거합니다](/docs/ko/hipaa-setup#anthropic-credentials-in-commands-hooks-and-mcp-servers).

예를 들어 Bash 명령에 대한 `PreToolUse` hook은 stdin에서 다음을 받습니다:

```json theme={null}
{
  "session_id": "abc123",
  "prompt_id": "550e8400-e29b-41d4-a716-446655440000",
  "transcript_path": "/home/user/.claude/projects/.../transcript.jsonl",
  "cwd": "/home/user/my-project",
  "scratchpad_dir": "/tmp/claude-1000/-home-user-my-project/abc123/scratchpad",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "npm test",
    "description": "Run test suite",
    "timeout": 120000,
    "run_in_background": false
  },
  "tool_use_id": "toolu_01ABC123..."
}
```

`tool_name`, `tool_input`, `tool_use_id` 필드는 이벤트 특정 필드입니다. 각 [hook 이벤트](#hook-events) 섹션에서는 해당 이벤트의 추가 필드를 문서화합니다.

<h3 id="exit-code-output">
  종료 코드 출력
</h3>

hook의 종료 코드는 도구 호출이나 프롬프트처럼 hook을 트리거한 작업을 계속 진행할지를 Claude Code에 알려줍니다. 완료된 실행의 결과는 다음 세 가지 중 하나입니다:

* **성공**: hook이 0으로 종료합니다. Claude Code는 hook이 출력한 [JSON 출력](#json-output) 필드를 적용하며, 해당 필드가 작업을 차단하거나 거부하지 않는 한 작업이 진행됩니다.
* **차단 오류**: hook이 2로 종료합니다. [차단할 수 있는 이벤트](#exit-code-2-behavior-per-event)에서 Claude Code는 작업을 중지합니다.
* **차단하지 않는 오류**: hook이 그 밖의 코드로 종료하거나, 시작되지 않거나 잘못된 JSON을 출력하는 등 다른 방식으로 실패합니다. 작업은 진행되며, `PreToolUse`와 같은 이벤트에서는 트랜스크립트에 `<hook name> hook error` 알림이 표시됩니다. 실패한 hook이 작업을 차단하게 하려면 [`onFailure: "block"`](#block-the-action-when-a-hook-fails)을 설정합니다.

hook이 stdout에 출력하는 내용에 따라 결과가 달라질 수 있습니다. 예를 들어 `PreToolUse` hook이 1로 종료하지만 검증을 통과하는 JSON을 출력하면 실행은 성공이며 JSON 필드가 결과를 결정합니다. `PreToolUse`와 같은 이벤트에서 hook의 결과를 확인하려면 첫 번째 열에서 stdout에 출력한 내용을, 맨 위 행에서 종료 코드를 찾아 맞춰 봅니다:

| Stdout | 종료 0 | 종료 2 | 그 밖의 종료 코드 |
| :- | :- | :- | :- |
| [스키마 검증](#json-output)을 통과하는 JSON 객체 | 성공. 필드가 적용됩니다 | 차단 오류. Claude Code는 여전히 필드를 읽지만 필드가 차단을 재정의할 수는 없습니다 | 성공. Claude Code는 종료 코드를 무시하고 필드만으로 결과를 결정합니다. [`onFailure: "block"`](#block-the-action-when-a-hook-fails)을 설정하면 실패로 간주됩니다 |
| [구문 분석할 수 없거나](#exit-code-0) 스키마 검증에 실패하는 JSON | 차단하지 않는 오류. 알림에 구문 분석 또는 검증 메시지가 표시됩니다 | 차단 오류. stderr이 이유가 됩니다 | 차단하지 않는 오류. 알림에 구문 분석 또는 검증 메시지가 표시됩니다 |
| [일반 텍스트](#exit-code-0) 또는 출력 없음 | 성공 | 차단 오류. stderr이 이유가 됩니다 | 차단하지 않는 오류. 알림에 stderr의 첫 번째 줄이 표시됩니다 |

일부 이벤트에는 자체 규칙이 있습니다:

* **`WorktreeCreate`**: JSON 내용과 관계없이 0이 아닌 종료 코드는 worktree 생성을 실패하게 합니다.
* **`WorktreeRemove`**: 0이 아닌 종료 코드는 이후에도 디렉터리가 여전히 존재하면 worktree 제거를 실패하게 합니다.
* **`Stop`, `SubagentStop`, `TaskCompleted`, 플러그인의 `UserPromptSubmit` hook**: hook이 stdout에 아무것도 출력하지 않고 2로 종료하며 stderr에 `No such file or directory`처럼 파일이 없다는 내용이 있으면 Claude Code는 실행을 차단하지 않는 오류로 취급합니다.
* **`Elicitation` 및 `ElicitationResult`**: Claude Code는 hook이 0으로 종료할 때 `hookSpecificOutput`을 적용하고, 그 밖의 종료 코드에서는 무시합니다.
* **`StopFailure`와 같이 hook 출력을 버리는 이벤트**: Claude Code는 모든 종료 코드에서 JSON을 무시합니다. 단, `terminalSequence`와 같은 부수 효과 필드는 여전히 동작합니다.

이벤트에서 종료 코드 2가 수행하는 작업은 [이벤트별 종료 코드 2 동작](#exit-code-2-behavior-per-event)을 참조하세요. 이벤트가 적용하는 결정 필드는 [결정 제어](#decision-control)를 참조하세요.

<h4 id="exit-code-0">
  종료 코드 0
</h4>

종료 0은 성공을 의미하며, 구조화된 제어를 위해 JSON을 출력할 때 의도된 종료 코드입니다.

대부분의 이벤트에서 Claude Code는 stdout을 디버그 로그에 기록하고 트랜스크립트에는 표시하지 않습니다. 예외는 `UserPromptSubmit`, `UserPromptExpansion`, `SessionStart`, `PostModelSwitch`이며, 여기서 Claude Code는 일반 텍스트 stdout을 Claude가 보고 활용할 수 있는 컨텍스트로 추가합니다.

Claude Code가 stdout을 [JSON 출력](#json-output)으로 읽는지 일반 텍스트로 읽는지는 주변 공백을 무시하고 시작 및 끝 문자에 따라 달라집니다:

* **`{`로 시작하고 `}`로 끝남**: Claude Code는 이를 JSON으로 구문 분석합니다. 출력이 각각 자체적으로 JSON으로 구문 분석되는 두 줄 이상이고 필드를 설정하는 [JSON 출력](#json-output) 객체인 줄이 없는 경우 Claude Code는 전체 출력을 일반 텍스트로 취급합니다. 이러한 줄 중 하나가 필드를 설정하면 전체 출력은 구문 분석 실패가 됩니다.
* **`{`로 시작하지만 `}`로 끝나지 않음**: Claude Code는 이를 일반 텍스트로 취급합니다.
* **다른 것으로 시작**: Claude Code는 JSON 배열이나 따옴표로 묶인 JSON 문자열을 포함하여 이를 일반 텍스트로 취급합니다.

Claude Code가 stdout을 JSON으로 구문 분석하려고 시도했지만 실패하거나, 구문 분석된 객체가 [스키마 검증](#json-output)에 실패하면 실행은 [차단하지 않는 오류](#exit-code-output)가 됩니다. `<hook name> hook error` 알림에 구문 분석 또는 검증 메시지가 표시됩니다. 일반 텍스트 stdout을 컨텍스트로 추가하는 이벤트에서 Claude Code는 구문 분석에 실패한 stdout을 추가하지 않습니다.

Claude는 0으로 종료하는 hook의 stderr을 보지 못합니다. `PreToolUse`와 같은 이벤트에서 직접 읽으려면 [디버그 로깅](#debug-hooks)을 활성화합니다. `PostToolUse` 또는 `PostToolUseFailure` hook에서 Claude에 경고를 표시하려면 대신 종료 2로 나가면 도구가 이미 실행되었더라도 [Claude가 stderr을 봅니다](#exit-code-2-behavior-per-event).

<h4 id="exit-code-2">
  종료 코드 2
</h4>

작업을 차단하려면 코드 2로 종료합니다. [차단할 수 있는 이벤트](#exit-code-2-behavior-per-event)에서 Claude Code는 작업을 중지합니다. 예를 들어 `PreToolUse` hook은 도구 호출을 차단하고 `UserPromptSubmit` hook은 프롬프트를 거부합니다.

차단과 함께 전달되는 메시지는 hook의 stderr입니다. hook이 차단 결정을 하는 JSON도 출력했다면 Claude Code는 대신 해당 결정의 이유를 사용합니다.

hook이 JSON을 출력하더라도 종료 2는 차단합니다:

* **스키마 검증을 통과하는 JSON**: Claude Code는 여전히 [JSON 출력](#json-output) 필드를 읽지만 필드가 차단을 재정의할 수는 없습니다. `permissionDecision`의 `"allow"`도 작업을 통과시키지 않습니다. `Elicitation` 및 `ElicitationResult`에서는 종료 2 hook의 `hookSpecificOutput`이 무시됩니다.
* **스키마 검증에 실패하는 JSON**: hook은 여전히 차단합니다. Claude Code는 stderr을 차단 이유로 사용하고 검증 실패를 디버그 로그에 기록합니다.

이 스크립트는 종료 2로 `rm` 명령을 차단하고 다른 모든 명령은 일반 권한 흐름에 맡깁니다:

```bash theme={null}
#!/bin/bash
# Reads JSON input from stdin, checks the command
input=$(cat)
command=$(jq -r '.tool_input.command' <<<"$input")

if [[ "$command" == rm* ]]; then
  echo "Blocked: rm commands are not allowed" >&2
  exit 2  # Blocking error: tool call is prevented
fi

exit 0  # No decision: the normal permission flow applies
```

이 스크립트를 `Bash`에 대한 `PreToolUse` hook으로 등록하면 `rm`으로 시작하는 명령이 차단되고, Claude는 이벤트 이름, 도구 이름, hook의 명령이 접두사로 붙은 hook의 stderr을 도구의 오류로 받습니다:

```text theme={null}
PreToolUse:Bash hook error: [${CLAUDE_PROJECT_DIR}/.claude/hooks/no-rm.sh]: Blocked: rm commands are not allowed
```

<h4 id="other-exit-codes">
  다른 종료 코드
</h4>

hook이 0 또는 2 이외의 코드로 종료하고 stdout에 일반 텍스트를 출력하거나 아무것도 출력하지 않으면 실행은 [차단하지 않는 오류](#exit-code-output)가 됩니다. 트랜스크립트에는 `Failed with non-blocking status code:`와 hook의 stderr 첫 번째 줄이 포함된 `<hook name> hook error` 알림이 표시됩니다. 예를 들어 `Bash`에 대한 `PreToolUse` hook이 stderr에 `something broke`를 출력하고 1로 종료하면 `PreToolUse:Bash hook error` 알림에 다음 줄이 표시됩니다:

```text theme={null}
Failed with non-blocking status code: something broke
```

첫 번째 줄이 아닌 전체 stderr을 캡처하려면 [디버그 로깅](#debug-hooks)을 활성화합니다.

시작할 수 없는 hook도 차단하지 않는 오류입니다. 셸 형식에서 스크립트 경로가 존재하지 않거나 실행 가능하지 않으면 셸은 127과 같은 코드로 종료되고 알림에 인터프리터의 메시지가 표시됩니다. 예: `Failed with non-blocking status code: /bin/sh: /path/to/hook.sh: No such file or directory`. 정책 hook을 설정할 때는 첫 번째 실행에서 이 알림을 확인하세요. `settings.json`의 경로에 오타가 있으면 hook이 전혀 실행되지 않습니다. 대신 작업을 차단하려면 [`onFailure: "block"`](#block-the-action-when-a-hook-fails)을 설정합니다.

<Warning>
  stdout에 유효한 JSON이 없으면 Claude Code는 1이 관례적인 Unix 실패 코드임에도 불구하고 종료 코드 1을 차단하지 않는 오류로 취급합니다. hook이 정책을 적용하기 위한 것이라면 `exit 2`를 사용합니다.
</Warning>

<h4 id="timeouts">
  타임아웃
</h4>

[`async: true`](#run-hooks-in-the-background)로 실행하는 명령 hook을 제외하고, Claude Code는 [`timeout`](#common-fields)에 도달한 `command`, `http`, `mcp_tool` hook을 취소하고 hook의 출력을 버리므로 대부분의 이벤트에서 시간 초과된 hook은 결정을 내리지 않습니다.

[`PreModelSwitch`](#premodelswitch)에서는 타임아웃으로 취소된 hook이 모델 전환을 차단합니다. `PreToolUse`에서는 두 hook 유형이 다르게 동작합니다:

* 시간 초과된 `command`, `http`, `mcp_tool` hook은 도구 호출을 차단하지 않습니다. 호출은 일반 [권한 흐름](/docs/ko/permissions)을 통해 계속되므로 멈춘 hook이 게이트 역할을 할 것이라고 기대하지 마세요. `command` 또는 `http` hook이 시간 초과될 때 호출을 차단하려면 [`onFailure: "block"`](#block-the-action-when-a-hook-fails)을 설정합니다.
* 타임아웃을 초과한 [Agent SDK 콜백 hook](/docs/ko/agent-sdk/hooks)은 [도구 호출을 차단합니다](#pretooluse).

<h4 id="block-the-action-when-a-hook-fails">
  hook이 실패할 때 작업 차단
</h4>

대부분의 이벤트에서 hook이 실패하거나 시간 초과되어도 Claude Code는 작업을 계속 수행하므로, 경로가 잘못되었거나 스크립트가 충돌하는 정책 hook은 모든 것을 통과시킵니다. 대신 작업을 차단하려면 `command` 또는 `http` hook에 `"onFailure": "block"`을 설정합니다. 기본값은 `"continue"`입니다. Claude Code v2.1.295 이상이 필요합니다.

`.claude/settings.json`의 이 `PreToolUse` hook은 각 Bash 명령 전에 프로젝트 스크립트를 실행하고, 스크립트가 실패하면 명령을 차단합니다:

```json theme={null}
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "node",
            "args": ["${CLAUDE_PROJECT_DIR}/.claude/hooks/check-command.js"],
            "onFailure": "block"
          }
        ]
      }
    ]
  }
}
```

테스트하려면 `check-command.js`를 없는 상태로 두고 Claude에 `ls`와 같은 Bash 명령을 실행하도록 요청합니다. Claude Code는 호출을 차단하며, 오류에는 `failed; blocking because onFailure is "block"`과 그 뒤에 node 자체의 오류 출력이 포함됩니다. 여기서는 한 줄로 줄였습니다:

```text theme={null}
PreToolUse:Bash hook error: [node ${CLAUDE_PROJECT_DIR}/.claude/hooks/check-command.js]: failed; blocking because onFailure is "block"
Error: Cannot find module '/path/to/project/.claude/hooks/check-command.js'
```

타임아웃 후에는 메시지에 `failed` 대신 `timed out`이 표시됩니다. `onFailure`를 설정하지 않으면 동일하게 스크립트가 없는 경우에도 차단하지 않는 오류가 되며 `ls`가 실행됩니다.

다음 각 항목은 실패로 간주됩니다:

* **시작할 수 없음**: 예를 들어 스크립트나 실행 파일이 존재하지 않아 명령 hook이 시작되지 않는 경우
* **0 또는 2 이외의 종료 코드**: 명령 hook이 `permissionDecision: "allow"`처럼 작업을 허용하는 JSON을 출력했더라도 실패로 간주됩니다. JSON 결정을 반환하려면 0으로 종료합니다
* **HTTP 오류**: HTTP hook의 연결이 실패하거나 응답 상태가 2xx가 아닌 경우
* **타임아웃**: hook이 [`timeout`](#common-fields)에 도달한 경우
* **잘못된 출력**: JSON 출력을 [구문 분석할 수 없거나](#exit-code-0) [스키마 검증](#json-output)에 실패하는 경우. HTTP hook의 경우 비어 있지도 않고 JSON 객체도 아닌 2xx 본문도 포함됩니다. 명령 hook의 일반 텍스트 stdout은 실패가 아닙니다

`"block"`이 설정되면 실패는 [해당 이벤트에서 종료 코드 2가 하는 일](#exit-code-2-behavior-per-event)을 수행합니다. 단, `PermissionRequest`에서는 요청을 거부합니다. 예를 들어 `PreToolUse` 실패는 도구 호출을 차단하고 `UserPromptSubmit` 실패는 프롬프트를 차단합니다.

이 필드는 다음 hook에는 효과가 없습니다:

* **`Stop`, `SubagentStop`, `TaskCompleted`, `TeammateIdle` hook**: 이러한 이벤트에서 종료 코드 2는 Claude가 계속 작업하도록 되돌려 보내며, Claude는 실행되지 않는 hook을 고칠 수 없습니다
* **백그라운드 명령 hook**: [`async` 또는 `asyncRewake`](#run-hooks-in-the-background)를 설정한 명령 hook

<h4 id="exit-code-2-behavior-per-event">
  이벤트별 종료 코드 2 동작
</h4>

종료 코드 2는 hook이 "멈추고, 이것을 하지 마세요"라고 신호하는 방식입니다. 효과는 이벤트에 따라 다릅니다. 일부 이벤트는 차단할 수 있는 작업(아직 발생하지 않은 도구 호출 등)을 나타내고, 다른 이벤트는 이미 발생했거나 방지할 수 없는 것을 나타내기 때문입니다.

| Hook 이벤트 | 차단 가능? | 종료 코드 2에서 발생하는 것 |
| :- | :- | :- |
| `PreToolUse` | 예 | 도구 호출을 차단합니다 |
| `PermissionRequest` | 아니오 | 이 이벤트에서는 종료 코드 2가 적용되지 않으며 권한 흐름은 변경 없이 진행됩니다. 대신 [`decision` 객체](#permissionrequest-decision-control)를 통해 거부합니다 |
| `UserPromptSubmit` | 예 | 프롬프트를 차단하여 Claude에 도달하지 않게 합니다. [차단된 프롬프트가 남기는 것](#what-a-blocked-prompt-leaves-behind)을 참조하세요 |
| `UserPromptExpansion` | 예 | 확장을 차단합니다 |
| `Stop` | 예 | Claude가 중지되는 것을 방지하고 대화를 계속합니다 |
| `SubagentStop` | 예 | 서브에이전트가 중지되는 것을 방지합니다 |
| `TeammateIdle` | 예 | 팀원이 유휴 상태가 되는 것을 방지하므로 계속 작업합니다 |
| `TaskCreated` | 예 | 작업 생성을 롤백합니다 |
| `TaskCompleted` | 예 | 작업이 완료로 표시되는 것을 방지합니다 |
| `ConfigChange` | 예 | 구성 변경이 적용되는 것을 차단합니다 (`policy_settings` 제외) |
| `StopFailure` | 아니오 | `terminalSequence`를 제외하고 출력과 종료 코드는 무시됩니다 |
| `PostToolUse` | 아니오 | Claude에 stderr을 표시합니다. 도구는 이미 실행되었습니다 |
| `PostToolUseFailure` | 아니오 | Claude에 stderr을 표시합니다. 도구는 이미 실패했습니다 |
| `PostToolBatch` | 예 | 다음 모델 호출 전에 에이전틱 루프를 중지합니다 |
| `PermissionDenied` | 아니오 | 거부가 이미 발생했기 때문에 종료 코드와 stderr은 무시됩니다. JSON `hookSpecificOutput.retry: true`를 사용하여 모델에 재시도할 수 있음을 알립니다. Claude Code는 [no-verdict 거부](#permissiondenied-decision-control)에 대해 `retry: true`를 무시합니다 |
| `Notification` | 아니오 | 종료 코드와 stderr은 무시됩니다 |
| `SubagentStart` | 아니오 | 사용자에게만 stderr을 표시합니다 |
| `SessionStart` | 아니오 | 사용자에게만 stderr을 표시합니다 |
| `Setup` | 아니오 | 종료 코드와 stderr은 무시됩니다 |
| `SessionEnd` | 아니오 | 사용자에게만 stderr을 표시합니다 |
| `CwdChanged` | 아니오 | 사용자에게만 stderr을 표시합니다 |
| `DirectoryAdded` | 아니오 | stderr은 디버그 로그로 갑니다. 디렉터리는 이미 추가되었습니다 |
| `FileChanged` | 아니오 | 사용자에게만 stderr을 표시합니다 |
| `PreCompact` | 예 | 압축을 차단합니다 |
| `PostCompact` | 아니오 | 사용자에게만 stderr을 표시합니다 |
| `PreModelSwitch` | 예 | 모델 전환을 차단하고 사용자에게 stderr을 표시합니다 |
| `PostModelSwitch` | 아니오 | 사용자에게만 stderr을 표시합니다. 모델은 이미 전환되었습니다 |
| `Elicitation` | 예 | 요청을 거부하며 대화 상자가 나타나지 않습니다 |
| `ElicitationResult` | 예 | 응답을 차단합니다 (action이 decline이 됨) |
| `WorktreeCreate` | 예 | 0이 아닌 종료 코드는 worktree 생성을 실패하게 합니다 |
| `WorktreeRemove` | 예 | 0이 아닌 종료 코드는 이후에도 디렉터리가 여전히 존재하면 worktree 제거를 실패하게 합니다. 디렉터리에 발생하는 일은 [WorktreeRemove](#worktreeremove)를 참조하세요 |
| `InstructionsLoaded` | 아니오 | 종료 코드는 무시됩니다 |
| `MessageDisplay` | 아니오 | 원본 텍스트가 표시됩니다 |

`SessionStart`, `SubagentStart`, `PostModelSwitch`의 경우 Claude Code는 종료 코드 2 stderr을 [차단하지 않는 오류](#exit-code-output)와 동일한 방식으로 트랜스크립트에 `<hook name> hook error` 알림으로 표시합니다. Claude는 이를 보지 못하며 세션 또는 서브에이전트는 계속 진행됩니다. `SubagentStart`의 경우 알림은 부모 대화가 아닌 서브에이전트 자체의 트랜스크립트에 나타납니다.

<h3 id="http-response-handling">
  HTTP 응답 처리
</h3>

HTTP hook은 종료 코드와 stdout 대신 HTTP 상태 코드와 응답 본문을 사용합니다. 아래의 결과는 대부분의 이벤트에 적용됩니다. `WorktreeCreate`와 같이 [이벤트별 표](#exit-code-2-behavior-per-event)에 자체 실패 규칙이 있는 이벤트는 실패한 HTTP hook에도 해당 규칙을 적용합니다:

* **빈 본문의 2xx**: 성공, 출력 없는 종료 코드 0과 동일
* **JSON 객체 본문의 2xx**: 명령 hook과 동일한 [JSON 출력](#json-output) 스키마를 사용하여 구문 분석됩니다. 스키마 검증에 실패하는 본문은 차단하지 않는 오류입니다
* **일반 텍스트 등 그 밖의 본문의 2xx**: 차단하지 않는 오류이며, 2xx가 아닌 상태와 동일하게 처리됩니다. Claude Code는 텍스트를 Claude의 컨텍스트에 추가하지 않습니다
* **2xx가 아닌 상태**: 차단하지 않는 오류, 실행이 계속됨
* **연결 실패**: 차단하지 않는 오류, 실행이 계속됨
* **타임아웃**: [타임아웃](#timeouts)에 설명된 대로 hook이 취소됩니다

HTTP hook은 상태 코드만으로 차단 오류를 신호할 수 없습니다. 2xx가 아닌 상태나 실패한 연결은 [차단하지 않는 오류](#exit-code-output)입니다. 도구 호출을 차단하거나 권한을 거부하려면 적절한 결정 필드를 포함하는 JSON 본문과 함께 2xx 응답을 반환합니다. 요청이 실패하거나 2xx가 아닌 상태를 반환할 때 작업을 차단하려면 [`onFailure: "block"`](#block-the-action-when-a-hook-fails)을 설정합니다.

<h3 id="json-output">
  JSON 출력
</h3>

종료 코드로는 차단하거나 아무것도 하지 않는 것만 가능하지만, JSON 출력은 더 세밀한 제어를 제공합니다. 종료 코드 2로 차단하는 대신 종료 0으로 나가면서 JSON 객체를 stdout에 출력합니다. Claude Code는 해당 JSON에서 특정 필드를 읽어 동작을 제어하며, 여기에는 차단, 허용 또는 사용자에게 에스컬레이션하기 위한 [결정 제어](#decision-control)가 포함됩니다.

<Note>
  hook당 하나의 접근 방식을 선택합니다: 종료 코드만 사용하여 신호하거나, 종료 0으로 나가면서 JSON을 출력하여 구조화된 제어를 합니다. 둘을 섞으면 종료 2는 [차단 효과](#exit-code-2-behavior-per-event)를 유지하고 Claude Code는 여전히 JSON 필드를 읽습니다. 단, [종료 코드 2](#exit-code-2)에 설명된 elicitation 예외가 하나 있습니다.
</Note>

hook의 stdout은 JSON 객체만 포함해야 합니다. 셸 프로필이 시작 시 텍스트를 출력하면 JSON 구문 분석을 방해할 수 있습니다. 문제 해결 가이드의 [Hook JSON이 효과가 없음](/docs/ko/hooks-guide#hook-json-has-no-effect)을 참조하세요.

hook의 `additionalContext`, `systemMessage`, `initialUserMessage` 문자열 및 일반 stdout은 10,000자로 제한됩니다:

* **범위**: Claude Code는 동일한 이벤트에 대해 여러 hook이 실행되는 경우에도 각 문자열을 개별적으로 측정합니다. JSON 출력의 경우 각 필드는 별도로 측정되며, 일반 stdout은 전체를 측정합니다.
* **제한 초과**: Claude Code는 출력을 세션 디렉터리의 파일에 저장하고 파일 경로와 최대 처음 2,000자의 미리보기로 대체합니다. 큰 유효한 Bash 결과도 [출력 제한](/docs/ko/tools-reference#output-limits)에 설명된 대로 동일한 방식으로 처리됩니다. 해당 Bash 상한과 달리 이 제한에는 이를 높이기 위한 설정이나 환경 변수가 없습니다.
* **파일 읽기**: Claude Code는 Claude에 파일을 읽도록 요청하지 않으므로 Claude가 항상 봐야 하는 내용은 제한 내에 유지하세요.

JSON 객체는 세 가지 종류의 필드를 지원합니다:

* **`continue`와 같은 범용 필드**는 아래 표에 나열됩니다. 모든 이벤트가 이를 허용하지만 일부 이벤트는 이를 버리거나 `systemMessage`를 트랜스크립트 이외의 다른 곳에 전달합니다. 각 이벤트의 섹션에서 이를 설명합니다. `terminalSequence`는 [터미널 알림 내보내기](#emit-terminal-notifications)에 나열된 예외를 제외하고 이러한 이벤트에서도 작동합니다.
* \*\*최상위 `decision` 및 `reason`\*\*은 일부 이벤트에서 차단하거나 피드백을 제공하는 데 사용됩니다.
* \*\*`hookSpecificOutput`\*\*은 더 풍부한 제어가 필요한 이벤트를 위한 중첩 객체입니다. 이벤트 이름으로 설정된 `hookEventName` 필드가 필요합니다.

| 필드 | 기본값 | 설명 |
| :- | :- | :- |
| `continue` | `true` | `false`인 경우 hook이 실행된 후 Claude가 처리를 완전히 중지합니다. 모든 이벤트 특정 결정 필드보다 우선합니다 |
| `stopReason` | 없음 | `continue`가 `false`일 때 사용자에게 표시되는 메시지. 대화에 남아 있으므로 대화가 계속되면 Claude가 이를 봅니다 |
| `suppressOutput` | `false` | 효과 없음: Claude Code는 필드를 허용하지만 이에 따라 동작하지 않습니다. 성공한 hook의 stdout은 트랜스크립트에 표시되지 않으며 디버그 로그에 기록됩니다 |
| `systemMessage` | 없음 | 사용자에게 표시되는 경고 메시지. [Agent SDK](/docs/ko/agent-sdk/overview) 및 [`--output-format stream-json`](/docs/ko/headless) 출력에서는 [`SDKInformationalMessage`](/docs/ko/agent-sdk/typescript#sdkinformationalmessage)로 도착할 수 있습니다 |
| `terminalSequence` | 없음 | 데스크톱 알림, 창 제목 또는 벨과 같이 Claude Code가 사용자를 대신하여 내보낼 터미널 이스케이프 시퀀스. OSC `0`/`1`/`2`/`9`/`99`/`777` 및 BEL로 제한됩니다. 값에 허용 목록 외의 항목이 포함되면 필드는 무시됩니다. hook에서 사용할 수 없는 `/dev/tty`에 쓰는 대신 이를 사용합니다 |

Claude를 완전히 중지하려면:

```json theme={null}
{ "continue": false, "stopReason": "Build failed, fix errors before continuing" }
```

`PreToolUse` 및 `PostToolUse` hook의 경우 Claude가 아직 응답을 스트리밍하는 동안 도구 호출이 실패하거나 완료되어도 중지가 적용됩니다.

<h4 id="emit-terminal-notifications">
  터미널 알림 내보내기
</h4>

Hook은 제어 터미널 없이 실행되므로 이스케이프 시퀀스를 `/dev/tty`에 직접 쓰면 실패합니다. 대신 `terminalSequence` 필드에 이스케이프 시퀀스를 반환하면 Claude Code가 자체 터미널 쓰기 경로를 통해 이를 내보냅니다. 이 방식은 race-free이며 tmux 및 GNU screen 내에서 작동하고 `/dev/tty`가 없는 Windows에서도 작동합니다.

이 필드는 허용 목록에 있는 하나 이상의 이스케이프 시퀀스로 구성된 문자열을 허용합니다:

* OSC `0`, `1`, `2`: 창 및 아이콘 제목
* OSC `9`: iTerm2, ConEmu, Windows Terminal, WezTerm 알림 (`9;4` 작업 표시줄 진행률 포함)
* OSC `99`: Kitty 알림
* OSC `777`: urxvt, Ghostty, Warp 알림
* 단독 BEL

시퀀스는 BEL 또는 ST로 종료될 수 있습니다. CSI 커서 및 색상 시퀀스, OSC 팔레트 시퀀스, OSC 8 하이퍼링크, OSC 52 클립보드 쓰기, OSC 1337을 포함하여 허용 목록 외의 항목은 거부되고 필드는 무시됩니다.

Claude Code는 hook의 출력을 처리할 때 시퀀스를 직접 기록하므로 이 필드는 `Notification` 및 `StopFailure`와 같이 `systemMessage` 및 `continue`를 버리는 이벤트에서도 작동합니다. 두 가지 제한이 있습니다:

* Claude Code는 대화형 세션에서만, 그리고 인터페이스가 화면에 표시되어 있는 동안에만 시퀀스를 기록합니다. `-p` 플래그를 사용한 비대화형 모드와 Agent SDK에서는 이 필드를 무시합니다.
* `WorktreeCreate` 명령 hook은 Claude Code가 stdout을 worktree 경로로 읽기 때문에 JSON을 반환할 수 없습니다. HTTP `WorktreeCreate` hook은 JSON을 반환하므로 이 필드를 포함할 수 있습니다.

아래 예제는 `Notification` hook에서 데스크톱 알림을 발생시킵니다. 이스케이프 시퀀스는 `printf` 8진수 이스케이프로 만들어지므로 제어 바이트가 셸 명령줄에 나타나지 않으며, `jq -n --arg`로 JSON 출력을 만들어 알림 메시지의 따옴표, 백슬래시, 줄바꿈이 올바르게 이스케이프됩니다:

```bash theme={null}
#!/bin/bash
# Notification hook: ping the desktop when Claude Code needs attention.
input=$(cat)
title="Claude Code"
body=$(jq -r '.message // "Needs your attention"' <<<"$input")
seq=$(printf '\033]777;notify;%s;%s\007' "$title" "$body")
jq -nc --arg seq "$seq" '{terminalSequence: $seq}'
```

`{ "terminalSequence": "..." }` 형태는 모든 셸 또는 언어에서 동일합니다.

<h4 id="add-context-for-claude">
  Claude를 위한 컨텍스트 추가
</h4>

`additionalContext` 필드는 hook의 문자열을 Claude의 컨텍스트 윈도우로 전달합니다. Claude Code는 문자열을 [시스템 리마인더](/docs/ko/glossary#system-reminder)로 감싸고 hook이 발생한 지점에서 대화에 삽입합니다. Claude는 다음 모델 요청에서 리마인더를 읽지만, 인터페이스에 채팅 메시지로 나타나지는 않습니다.

이벤트 이름과 함께 `hookSpecificOutput` 내에 `additionalContext`를 반환합니다:

```json theme={null}
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "This file is generated. Edit src/schema.ts and run `bun generate` instead."
  }
}
```

리마인더가 나타나는 위치는 이벤트에 따라 다릅니다:

* [SessionStart](#sessionstart) 및 [SubagentStart](#subagentstart): 대화 시작 시, 첫 번째 프롬프트 전
* [UserPromptSubmit](#userpromptsubmit) 및 [UserPromptExpansion](#userpromptexpansion): 제출된 프롬프트와 함께
* [PreToolUse](#pretooluse), [PostToolUse](#posttooluse), [PostToolUseFailure](#posttoolusefailure), [PostToolBatch](#posttoolbatch): 도구 결과 옆
* [Stop](#stop) 및 [SubagentStop](#subagentstop): 턴의 끝. 대화가 계속되므로 Claude가 피드백에 따라 행동할 수 있습니다. [Stop 결정 제어](#stop-decision-control) 참조
* [PostModelSwitch](#postmodelswitch): 전환 후 다음 요청과 함께. 타이밍은 [PostModelSwitch 결정 제어](#postmodelswitch-decision-control)를 참조하세요

여러 hook이 동일한 이벤트에 대해 `additionalContext`를 반환하면 Claude는 모든 값을 받습니다.

값이 10,000자를 초과하면 Claude Code는 텍스트를 세션 디렉터리의 파일에 쓰고, 대신 최대 처음 2,000자의 미리보기와 함께 파일 경로를 Claude에 전달합니다. Claude는 파일을 읽을 수 있지만 Claude Code가 읽도록 요청하지는 않습니다.

Claude가 현재 환경 상태 또는 방금 실행된 작업에 대해 알아야 할 정보에 `additionalContext`를 사용합니다:

* **환경 상태**: 현재 브랜치, 배포 대상 또는 활성 기능 플래그
* **조건부 프로젝트 규칙**: 방금 편집한 파일에 적용되는 테스트 명령, 이 worktree에서 읽기 전용인 디렉터리
* **외부 데이터**: 사용자에게 할당된 열린 이슈, 최근 CI 결과, 내부 서비스에서 가져온 콘텐츠

변경되지 않는 지침에는 [CLAUDE.md](/docs/ko/memory)를 사용하는 것이 좋습니다. 스크립트를 실행하지 않고 로드되며 정적 프로젝트 규칙을 위한 표준 위치입니다.

텍스트는 명령형 시스템 지침이 아닌 사실 진술로 작성합니다. "배포 대상은 프로덕션입니다" 또는 "이 리포지토리는 `bun test`를 사용합니다"와 같은 표현은 프로젝트 정보로 읽힙니다. 대역 외 시스템 명령으로 표현된 텍스트는 Claude의 프롬프트 인젝션 방어를 트리거할 수 있으며, 이 경우 Claude는 텍스트를 컨텍스트로 취급하는 대신 사용자에게 표시합니다.

Claude Code는 주입된 텍스트를 세션 트랜스크립트에 저장합니다. `PostToolUse` 또는 `UserPromptSubmit`과 같은 세션 중간 이벤트의 경우 `--continue` 또는 `--resume`으로 재개하면 Claude Code는 과거 턴에 대해 hook을 다시 실행하는 대신 저장된 텍스트를 재생하므로 타임스탬프나 커밋 SHA와 같은 값은 오래된 값이 됩니다. `SessionStart` hook은 재개 시 `source`가 `"resume"`으로, `--fork-session`을 추가한 경우 `"fork"`로 설정된 상태로 다시 실행되므로 컨텍스트를 새로 고칠 수 있습니다.

<h4 id="decision-control">
  결정 제어
</h4>

모든 이벤트가 JSON을 통한 동작 차단이나 제어를 지원하는 것은 아닙니다. 이를 지원하는 이벤트는 각각 다른 필드 집합을 사용하여 결정을 표현합니다. hook을 작성하기 전에 이 표를 빠른 참조로 사용하세요:

| 이벤트 | 결정 패턴 | 주요 필드 |
| :- | :- | :- |
| UserPromptSubmit, UserPromptExpansion, PostToolUse, PostToolUseFailure, PostToolBatch, Stop, SubagentStop, ConfigChange, PreCompact | 최상위 `decision` | `decision: "block"`, `reason`. Stop 및 SubagentStop은 [대화를 계속하는 오류가 아닌 피드백](#stop-decision-control)을 위해 `hookSpecificOutput.additionalContext`도 허용합니다 |
| TeammateIdle, TaskCompleted | 종료 코드 또는 `continue: false` | 종료 코드 2는 stderr 피드백과 함께 작업을 차단합니다. JSON `{"continue": false, "stopReason": "..."}`도 `Stop` hook 동작과 마찬가지로 팀원을 완전히 중지합니다. [TaskCompleted는 `TaskUpdate` 도구가 이벤트를 트리거한 경우 이를 무시합니다](#taskcompleted-decision-control) |
| TaskCreated | 종료 코드 또는 최상위 `decision` | 종료 코드 2 또는 `decision: "block"`은 [작업을 취소](#taskcreated-decision-control)하고 메시지를 Claude에 반환합니다. `continue: false`는 무시됩니다 |
| PreToolUse | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason` |
| PreModelSwitch | `hookSpecificOutput` 또는 최상위 `decision` | `permissionDecision` (allow/deny/ask), `permissionDecisionReason`. `decision: "block"`도 [전환을 취소](#premodelswitch-decision-control)합니다 |
| PermissionRequest | `hookSpecificOutput` | `decision.behavior` (allow/deny) |
| PermissionDenied | `hookSpecificOutput` | `retry: true`는 모델에 거부된 도구 호출을 재시도할 수 있음을 알립니다. Claude Code는 [no-verdict 거부](#permissiondenied-decision-control)에 대해 이를 무시합니다 |
| WorktreeCreate | 경로 반환 | 명령 hook은 stdout에 경로를 출력합니다. HTTP hook은 `hookSpecificOutput.worktreePath`를 반환합니다. hook 실패 또는 경로 누락 시 생성이 실패합니다 |
| WorktreeRemove | 종료 코드 | 0이 아닌 종료 코드는 이후에도 디렉터리가 여전히 존재하면 제거를 실패하게 합니다. JSON 출력은 버려집니다 |
| Elicitation, ElicitationResult | `hookSpecificOutput` 또는 최상위 `decision` | `action` (accept/decline/cancel), `content` (폼 필드 값). `decision: "block"`도 [거부](#other-ways-to-decline-an-elicitation)합니다 |
| MessageDisplay | `hookSpecificOutput` | `displayContent`는 화면에 표시되는 텍스트를 대체합니다. 표시 전용: 트랜스크립트와 Claude가 보는 내용은 원본을 유지합니다 |
| SessionStart, SubagentStart, PostModelSwitch | 컨텍스트만 | `hookSpecificOutput.additionalContext`는 Claude를 위한 컨텍스트를 추가합니다. SessionStart는 [`initialUserMessage`, `watchPaths`, `sessionTitle`, `reloadSkills`](#sessionstart-decision-control)도 허용합니다. 차단 또는 결정 제어 없음 |
| Setup, Notification, SessionEnd, PostCompact, InstructionsLoaded, StopFailure, CwdChanged, DirectoryAdded, FileChanged | 없음 | 결정 제어 없음. 로깅이나 정리와 같은 부수 효과에 사용됩니다 |

일부 이벤트는 허용하거나 차단하는 것 외에 콘텐츠를 다시 작성할 수도 있습니다:

* `PreToolUse`: `hookSpecificOutput` 바로 아래의 `updatedInput`은 실행 전에 도구의 인수를 대체합니다. [PreToolUse 결정 제어](#pretooluse-decision-control) 참조
* `PermissionRequest`: `decision` 객체 내의 `updatedInput`. [PermissionRequest 결정 제어](#permissionrequest-decision-control) 참조
* `PostToolUse`: `updatedToolOutput`은 도구의 결과를 대체합니다. [PostToolUse 결정 제어](#posttooluse-decision-control) 참조
* `UserPromptSubmit`: 프롬프트를 대체할 수 없으며, 프롬프트와 함께 `additionalContext`를 주입하기만 합니다

민감 정보 제거나 변환 사용 사례의 경우 나가는 도구 입력은 `PreToolUse`에서, 들어오는 도구 결과는 `PostToolUse`에서 가로채세요.

다음은 각 패턴의 실제 예입니다:

<Tabs>
  <Tab title="최상위 결정">
    `decision`의 유일한 값은 `"block"`입니다. 작업 진행을 허용하려면 JSON에서 `decision`을 생략하거나 JSON 없이 종료 0으로 나갑니다:

    ```json theme={null}
    {
      "decision": "block",
      "reason": "Test suite must pass before proceeding"
    }
    ```
  </Tab>

  <Tab title="PreToolUse">
    더 풍부한 제어를 위해 `hookSpecificOutput`을 사용합니다: 허용, 거부 또는 사용자에게 에스컬레이션. 실행 전에 도구 입력을 수정하거나 Claude를 위한 추가 컨텍스트를 주입할 수도 있습니다. 전체 옵션은 [PreToolUse 결정 제어](#pretooluse-decision-control)를 참조하세요.

    ```json theme={null}
    {
      "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": "Database writes are not allowed"
      }
    }
    ```
  </Tab>

  <Tab title="PermissionRequest">
    `hookSpecificOutput`을 사용하여 사용자를 대신해 권한 요청을 허용하거나 거부합니다. 허용할 때는 도구의 입력을 수정하거나 권한 규칙을 적용하여 사용자에게 다시 확인을 요청하지 않도록 할 수도 있습니다. 전체 옵션은 [PermissionRequest 결정 제어](#permissionrequest-decision-control)를 참조하세요.

    ```json theme={null}
    {
      "hookSpecificOutput": {
        "hookEventName": "PermissionRequest",
        "decision": {
          "behavior": "allow",
          "updatedInput": {
            "command": "npm run lint"
          }
        }
      }
    }
    ```
  </Tab>
</Tabs>

Bash 명령 검증, 프롬프트 필터링, 자동 승인 스크립트를 포함한 확장 예제는 가이드의 [자동화할 수 있는 것](/docs/ko/hooks-guide#what-you-can-automate)과 [Bash 명령 검증기 참조 구현](https://github.com/anthropics/claude-code/blob/main/examples/hooks/bash_command_validator_example.py)을 참조하세요.

<h2 id="hook-events">
  훅 이벤트
</h2>

각 이벤트는 Claude Code의 수명 주기에서 훅이 실행될 수 있는 지점에 해당합니다. 아래 섹션은 세션 설정부터 에이전틱 루프를 거쳐 세션 종료까지, 수명 주기 순서대로 정렬되어 있습니다. 각 섹션에서는 이벤트가 발생하는 시점, 지원하는 matcher, 받는 JSON 입력, 출력을 통해 동작을 제어하는 방법을 설명합니다.

<h3 id="sessionstart">
  SessionStart
</h3>

Claude Code가 새 세션을 시작하거나 기존 세션을 재개할 때 실행됩니다. 기존 이슈나 코드베이스의 최근 변경 사항 같은 개발 컨텍스트를 로드하거나 환경 변수를 설정하는 데 유용합니다. 스크립트가 필요 없는 정적 컨텍스트에는 대신 [CLAUDE.md](/docs/ko/memory)를 사용하세요.

SessionStart는 모든 세션에서 실행되므로 이 훅은 빠르게 유지하세요. `type: "command"` 및 `type: "mcp_tool"` 훅만 지원됩니다. `mcp_tool` 훅이 실행되는 시점은 [MCP 도구 훅 필드](#mcp-tool-hook-fields)를 참조하세요.

matcher 값은 세션이 시작된 방식에 해당합니다:

| Matcher | 발생 시점 |
| :- | :- |
| `startup` | 새 세션 |
| `resume` | `--resume`, `--continue` 또는 `/resume` |
| `clear` | `/clear` |
| `compact` | 자동 또는 수동 압축 |
| `fork` | 기존 세션에서 분기된 새 세션: `--resume` 또는 `--continue`와 함께 사용한 `--fork-session`, `/fork` 백그라운드 복사본, `/branch`, 또는 [백그라운드로 옮긴](/docs/ko/agent-view#from-inside-a-session) 대화 |

v2.1.214 이전에는 분기된 세션이 source를 `"resume"`으로 보고했습니다.

대화형 세션을 시작하거나, 실행 시 `--continue` 또는 `--resume`으로 대화를 재개하거나, `/clear`를 실행하면 SessionStart 훅이 백그라운드에서 실행됩니다. 바로 입력을 시작할 수 있으며, 재개한 대화는 훅을 기다리지 않고 표시됩니다. 다만 Claude의 첫 응답은 여전히 훅이 완료될 때까지 기다리므로 훅의 컨텍스트가 Claude에 전달됩니다.

세션 내에서 `/resume`으로 대화를 전환하면 전환은 대신 훅이 완료될 때까지 기다립니다. 백그라운드 훅이 아직 실행 중일 때 `/clear`를 실행하거나 다른 대화로 전환하면 훅이 반환하는 내용은 세션에 적용되지 않습니다.

실행 시에도 재개된 세션을 포함해 동일한 대기가 적용됩니다. SessionStart 훅이 아직 실행 중일 때 보낸 프롬프트는 훅이 완료될 때까지 Claude에 전달되지 않습니다.

어느 쪽 대기 중이든 `Esc`를 누르면 프롬프트를 보내지 않고 입력란으로 되돌릴 수 있습니다. 훅은 계속 실행됩니다.

<h4 id="sessionstart-input">
  SessionStart 입력
</h4>

[공통 입력 필드](#common-input-fields) 외에도 SessionStart 훅은 `source`와, 선택적으로 `model`, `agent_type`, `session_title`을 받습니다:

| 필드 | 설명 |
| :- | :- |
| `source` | 세션이 시작된 방식: 새 세션은 `"startup"`, 재개된 세션은 `"resume"`, `/clear` 후에는 `"clear"`, 압축 후에는 `"compact"`, 기존 세션에서 분기된 새 세션은 `"fork"` |
| `model` | 활성 모델 식별자. 예를 들어 `/clear` 후나 대화 복구를 통해 세션이 복원될 때는 생략될 수 있으므로 읽기 전에 필드가 있는지 확인하세요 |
| `agent_type` | 에이전트 이름. `claude --agent <name>`으로 Claude Code를 시작할 때 존재합니다 |
| `session_title` | 세션의 사용자 지정 제목. 제목이 설정된 경우 존재하며, 예를 들어 `--name`, `/rename`, 훅의 `sessionTitle` 출력 또는 Agent SDK의 `renameSession()`으로 설정됩니다. `sessionTitle`을 내보내는 훅은 먼저 이 필드를 확인하여 기존 사용자 지정 제목을 덮어쓰지 않도록 할 수 있습니다 |

이름을 지정하지 않은 세션에도 [생성된 제목](/docs/ko/sessions#name-your-sessions)이 있을 수 있습니다. 이 제목은 사용자 지정 제목이 아니며 `session_title`에 나타나지 않습니다.

`source`가 `"resume"` 또는 `"fork"`이고 트랜스크립트에 Claude의 응답이 하나 이상 포함된 경우 SessionStart 훅은 아래 네 가지 필드도 받습니다. 훅은 이 필드를 사용하여 오래된 대화를 재개하는 데 드는 비용을 첫 요청 전에 보고할 수 있습니다(예: [`systemMessage`](#json-output)). 이 필드에는 Claude Code v2.1.251 이상이 필요합니다.

| 필드 | 설명 |
| :- | :- |
| `seconds_since_last_response` | 재개된 트랜스크립트의 마지막 응답 이후 경과한 실제 시간(초) |
| `context_tokens` | 재개된 세션의 첫 요청이 프롬프트로 다시 보내는 토큰 |
| `prompt_cache_likely_expired` | 마지막 응답이 세션의 [프롬프트 캐시 수명](/docs/ko/prompt-caching#cache-lifetime)보다 오래되었거나 이후 압축이 캐시된 대화를 대체한 경우 `true` |
| `estimated_cache_write_usd` | 세션의 모델에서 `context_tokens`를 프롬프트 캐시에 쓰는 데 드는 예상 비용(미국 달러). 응답은 제외됩니다 |

이 예시는 마지막 응답 후 90분 뒤에 재개된 세션의 입력을 보여 줍니다:

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "SessionStart",
  "source": "resume",
  "model": "claude-opus-5",
  "seconds_since_last_response": 5400,
  "context_tokens": 182340,
  "prompt_cache_likely_expired": true,
  "estimated_cache_write_usd": 1.1396
}
```

<h4 id="sessionstart-decision-control">
  SessionStart 결정 제어
</h4>

SessionStart 훅은 Claude를 위한 컨텍스트 추가, 첫 사용자 메시지 제공, 세션 제목 설정, 파일 감시, 스킬 다시 로드를 할 수 있습니다. 모든 훅에서 사용할 수 있는 [JSON 출력 필드](#json-output) 외에 각 항목에 해당하는 필드를 반환합니다.

| 필드 | 설명 |
| :- | :- |
| `additionalContext` | 대화 시작 시 첫 프롬프트 전에 Claude의 컨텍스트에 추가되는 문자열. 텍스트가 전달되는 방식과 넣을 내용은 [Claude를 위한 컨텍스트 추가](#add-context-for-claude)를 참조하세요 |
| `initialUserMessage` | `-p` 플래그를 사용하는 [비대화형 모드](/docs/ko/headless)에서 세션의 첫 사용자 메시지로 사용되는 문자열입니다. 프롬프트를 전달하지 않아도 첫 턴이 됩니다. 프롬프트를 전달하면 그 프롬프트는 다음 턴으로 이어집니다 |
| `sessionTitle` | 세션 제목을 설정하며, `/rename`과 같은 효과를 냅니다. `source`가 `"startup"`, `"resume"` 또는 `"fork"`일 때 적용됩니다 |
| `watchPaths` | 이 세션 동안 [FileChanged](#filechanged) 이벤트를 감시할 절대 경로 배열 |
| `reloadSkills` | 불리언입니다. `true`이면 SessionStart 훅이 완료된 후 Claude Code가 [스킬](/docs/ko/skills) 및 명령 디렉터리를 다시 스캔합니다. [훅이 설치한 스킬 다시 로드](#reload-skills-that-a-hook-installs)를 참조하세요 |

이 출력은 컨텍스트를 추가하고 세션 이름을 지정합니다.

```json theme={null}
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Current branch: feat/auth-refactor\nUncommitted changes: src/auth.ts, src/login.tsx\nActive issue: #4211 Migrate to OAuth2",
    "sessionTitle": "auth-refactor"
  }
}
```

컨텍스트만 추가하는 훅은 JSON을 만들지 않고 출력만 해도 됩니다. Claude Code는 SessionStart 훅의 [일반 텍스트 stdout](#exit-code-0)을 Claude의 컨텍스트에 추가하기 때문입니다.

플러그인의 SessionStart 훅이 `initialUserMessage` 또는 `sessionTitle`을 제공한다면 세션이 시작되기 전에 플러그인을 설치하세요. SessionStart 훅이 실행된 후에 설치가 완료된 플러그인의 두 필드는 Claude Code가 무시합니다.

<h4 id="reload-skills-that-a-hook-installs">
  훅이 설치한 스킬 다시 로드
</h4>

SessionStart 훅이 설치한 스킬을 같은 세션에서 사용할 수 있게 하려면 `reloadSkills`를 반환하세요. 스킬 검색은 일반적으로 SessionStart 훅이 완료되기 전에 실행되므로, 이 필드가 없으면 훅이 `~/.claude/skills/` 또는 `.claude/skills/`에 쓴 파일이 첫 프롬프트 실행 시 누락될 수 있습니다.

이 예시는 공유 스킬 저장소를 동기화하고 다시 스캔을 요청합니다.

```bash theme={null}
#!/bin/bash

git -C ~/.claude/skills/team-skills pull --quiet 2>/dev/null || \
  git clone --quiet https://git.example.com/your-org/team-skills.git ~/.claude/skills/team-skills

echo '{"hookSpecificOutput": {"hookEventName": "SessionStart", "reloadSkills": true}}'
```

저장소 URL은 예시용입니다. 자신의 스킬 저장소로 바꾸세요.

<h4 id="persist-environment-variables">
  환경 변수 유지
</h4>

SessionStart 훅은 `CLAUDE_ENV_FILE` 환경 변수에 액세스할 수 있으며, 이 변수는 이후 Bash 명령을 위해 환경 변수를 유지할 수 있는 파일 경로를 제공합니다.

개별 환경 변수를 설정하려면 `CLAUDE_ENV_FILE`에 `export` 문을 작성하세요. 다른 훅이 설정한 변수를 보존하려면 추가(`>>`)를 사용하세요:

```bash theme={null}
#!/bin/bash

if [ -n "$CLAUDE_ENV_FILE" ]; then
  echo 'export NODE_ENV=production' >> "$CLAUDE_ENV_FILE"
  echo 'export DEBUG_LOG=true' >> "$CLAUDE_ENV_FILE"
  echo 'export PATH="$PATH:./node_modules/.bin"' >> "$CLAUDE_ENV_FILE"
fi

exit 0
```

설정 명령에서 발생한 모든 환경 변경 사항을 캡처하려면 전후의 내보낸 변수를 비교하세요:

```bash theme={null}
#!/bin/bash

ENV_BEFORE=$(export -p | sort)

# Run your setup commands that modify the environment
source ~/.nvm/nvm.sh
nvm use 20

if [ -n "$CLAUDE_ENV_FILE" ]; then
  ENV_AFTER=$(export -p | sort)
  comm -13 <(echo "$ENV_BEFORE") <(echo "$ENV_AFTER") >> "$CLAUDE_ENV_FILE"
fi

exit 0
```

<Note>
  `CLAUDE_ENV_FILE`은 SessionStart, [Setup](#setup), [CwdChanged](#cwdchanged), [FileChanged](#filechanged) 훅에서 사용할 수 있습니다. 다른 훅 유형은 이 변수에 액세스할 수 없습니다.
</Note>

<h3 id="setup">
  Setup
</h3>

`--init-only`로 Claude Code를 실행하거나, `-p` 플래그를 사용하는 [비대화형 모드](/docs/ko/headless)에서 `--init` 또는 `--maintenance`로 실행할 때만 발생합니다. 일반 시작 시에는 발생하지 않습니다. 일반 세션 시작과 별도로 CI나 스크립트에서 명시적으로 트리거하는 일회성 의존성 설치나 예약된 정리에 사용하세요. 세션별 초기화에는 대신 [SessionStart](#sessionstart)를 사용하세요.

matcher 값은 훅을 트리거한 CLI 플래그에 해당합니다:

| Matcher | 발생 시점 |
| :- | :- |
| `init` | `claude --init-only` 또는 `claude -p --init` |
| `maintenance` | `claude -p --maintenance` |

`claude --init-only`를 실행하면 Claude Code는 Setup 훅과 `startup` matcher를 사용하는 `SessionStart` 훅을 실행한 다음, 대화를 시작하지 않고 종료합니다.

`-p`로 대화를 시작하거나 계속할 때는 인수로 또는 stdin 파이프를 통해 프롬프트도 제공해야 합니다. `SessionStart` 훅이 [`initialUserMessage`](#sessionstart-decision-control)를 제공하거나 [지연된 도구 호출](#defer-a-tool-call-for-later)이 있는 세션을 재개할 때는 프롬프트를 생략할 수 있습니다.

성공하면 `--init-only`는 터미널에 아무것도 출력하지 않습니다. 훅이 실행되었는지 확인하려면 `<path>`를 로그 파일 위치로 바꿔 `claude --debug-file <path> --init-only`로 시작한 다음, 로그에서 Setup 및 SessionStart 훅 항목을 확인하세요.

Setup은 모든 실행에서 발생하는 것이 아니므로, 의존성 설치가 필요한 플러그인은 Setup에만 의존할 수 없습니다. 실용적인 패턴은 처음 사용할 때 의존성을 확인하고 없으면 설치하는 것입니다. 예를 들어 `${CLAUDE_PLUGIN_DATA}/node_modules`가 있는지 테스트하고 없으면 `npm install`을 실행하는 훅이나 스킬을 사용할 수 있습니다. 설치된 의존성을 저장할 위치는 [영구 데이터 디렉터리](/docs/ko/plugins/components#path-variables-and-persistent-data)를 참조하세요. 마켓플레이스를 통해 플러그인을 배포한다면 이 패턴이 필요하지 않을 수 있습니다. Claude Code는 플러그인을 캐시할 때 [적격한 Node.js 패키지 의존성을 자동으로 설치](/docs/ko/plugins/loading#node-js-package-dependencies)합니다.

<h4 id="setup-input">
  Setup 입력
</h4>

[공통 입력 필드](#common-input-fields) 외에도 Setup 훅은 `"init"` 또는 `"maintenance"`로 설정된 `trigger` 필드를 받습니다:

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "Setup",
  "trigger": "init"
}
```

<h4 id="setup-decision-control">
  Setup 결정 제어
</h4>

Setup 훅은 차단할 수 없으며, 어떤 종료 코드에서도 실행이 계속됩니다. 모든 종료 코드에서 Claude Code는 `systemMessage`, `continue`, `hookSpecificOutput.additionalContext` 같은 Setup 훅의 [JSON 출력 필드](#json-output)를 버립니다. `-p` 사용 시 Setup 훅의 stdout, stderr, 종료 코드는 `--output-format stream-json --verbose`로 실행할 때만 [`hook_response` 이벤트](/docs/ko/headless#read-session-metadata)로 실행 출력에 나타납니다.

Setup 훅은 `CLAUDE_ENV_FILE`에 액세스할 수 있습니다. 이 파일에 쓴 변수는 [SessionStart 훅](#persist-environment-variables)과 마찬가지로 세션의 이후 Bash 명령에 유지됩니다. `Setup`에서는 `type: "command"` 훅만 실행됩니다. `Setup`의 `type: "mcp_tool"` 훅은 [MCP 도구 훅 필드](#mcp-tool-hook-fields)에서 설명한 대로 항상 건너뜁니다.

<h3 id="instructionsloaded">
  InstructionsLoaded
</h3>

`CLAUDE.md` 또는 `.claude/rules/*.md` 파일이 컨텍스트에 로드될 때 발생합니다. 이 이벤트는 즉시 로드되는 파일에 대해 세션 시작 시 발생하고, 파일이 지연 로드될 때 나중에 다시 발생합니다. 예를 들어 Claude가 중첩된 `CLAUDE.md`가 있는 하위 디렉터리에 액세스하거나 `paths:` frontmatter가 있는 조건부 규칙이 일치할 때입니다. 이 훅은 차단이나 결정 제어를 지원하지 않으며, 관찰 가능성을 위해 비동기적으로 실행됩니다.

이 이벤트는 Claude가 **Project instructions** 설정을 통해 [`AGENTS.md`를 직접 읽을](/docs/ko/memory#agents-md) 때는 발생하지 않습니다. `CLAUDE.md`가 `AGENTS.md`를 가져올 때는 다른 가져온 파일과 마찬가지로 `load_reason`이 `include`로 설정된 상태로 발생하며, `CLAUDE.md`가 해당 파일에 대한 심볼릭 링크일 때는 일반 `CLAUDE.md` 로드로 발생합니다.

matcher는 `load_reason`에 대해 실행됩니다. 예를 들어 세션 시작 시 로드된 파일에만 발생시키려면 `"matcher": "session_start"`를, 지연 로드에만 발생시키려면 `"matcher": "path_glob_match|nested_traversal"`을 사용하세요.

<h4 id="instructionsloaded-input">
  InstructionsLoaded 입력
</h4>

[공통 입력 필드](#common-input-fields) 외에도 InstructionsLoaded 훅은 다음 필드를 받습니다:

| 필드 | 설명 |
| :- | :- |
| `file_path` | 로드된 지침 파일의 절대 경로 |
| `memory_type` | 파일의 범위: `"User"`, `"Project"`, `"Local"` 또는 `"Managed"` |
| `load_reason` | 파일이 로드된 이유: `"session_start"`, `"nested_traversal"`, `"path_glob_match"`, `"include"` 또는 `"compact"`. `"compact"` 값은 압축 이벤트 후 지침 파일이 다시 로드될 때 발생합니다 |
| `globs` | 파일의 `paths:` frontmatter에 있는 경로 glob 패턴(있는 경우). `path_glob_match` 로드에만 존재합니다 |
| `trigger_file_path` | 지연 로드의 경우, 액세스하여 이 로드를 트리거한 파일의 경로 |
| `parent_file_path` | `include` 로드의 경우, 이 파일을 포함한 상위 지침 파일의 경로 |

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../transcript.jsonl",
  "cwd": "/Users/my-project",
  "hook_event_name": "InstructionsLoaded",
  "file_path": "/Users/my-project/CLAUDE.md",
  "memory_type": "Project",
  "load_reason": "session_start"
}
```

<h4 id="instructionsloaded-decision-control">
  InstructionsLoaded 결정 제어
</h4>

InstructionsLoaded 훅에는 결정 제어가 없습니다. 지침 로드를 차단하거나 수정할 수 없습니다. Claude Code는 `systemMessage`, `continue` 같은 [JSON 출력 필드](#json-output)를 버립니다. 이 이벤트는 감사 로깅, 규정 준수 추적 또는 관찰 가능성에 사용하세요.

<h3 id="userpromptsubmit">
  UserPromptSubmit
</h3>

프롬프트가 제출될 때, Claude가 처리하기 전에 실행됩니다. 이를 통해
프롬프트/대화를 기반으로 추가 컨텍스트를 추가하거나, 프롬프트를 검증하거나,
특정 유형의 프롬프트를 차단할 수 있습니다.

`UserPromptSubmit` 훅은 직접 입력한 프롬프트에서만 발생하는 것이 아닙니다. Claude Code는 다음 경우에도 이 훅을 실행합니다:

* [예약 작업](/docs/ko/scheduled-tasks)이 실행될 때(`/loop` 반복 포함)
* [백그라운드 서브에이전트](/docs/ko/sub-agents#run-subagents-in-foreground-or-background)가 자신을 시작한 세션에 결과를 보고할 때
* [다른 세션이 기본 대화로 메시지를 보낼](/docs/ko/cross-session-messaging) 때

`UserPromptSubmit` 훅은 `command`, `http`, `mcp_tool` 유형의 기본 타임아웃이 30초로, 대부분의 다른 이벤트에서 이러한 유형의 기본값인 600초보다 짧습니다. 이 훅은 모든 프롬프트 전에 실행되고 완료될 때까지 모델 처리를 차단하므로, 멈춘 훅은 세션을 정지시킵니다. 훅에 더 많은 시간이 필요하면 훅 항목에서 `timeout` 필드를 설정하세요.

[`async: true`](#run-hooks-in-the-background)로 실행하는 command 훅을 제외하고, 타임아웃에 도달한 `UserPromptSubmit` command, HTTP 또는 MCP 도구 훅은 취소되며 `additionalContext`를 포함한 출력이 버려집니다. 프롬프트는 해당 컨텍스트 없이 Claude에 전달됩니다. 대신 프롬프트를 차단하려면 command 또는 HTTP 훅에 [`onFailure: "block"`](#block-the-action-when-a-hook-fails)을 설정하십시오. 트랜스크립트에는 훅 이름, 발생한 타임아웃, 출력이 버려졌다는 사실을 알리는 알림이 표시됩니다.

`UserPromptSubmit`의 [Agent SDK 콜백 훅](/docs/ko/agent-sdk/hooks)이 타임아웃에 도달하면 훅과 타임아웃을 명시하는 메시지와 함께 프롬프트가 차단됩니다. 이 위치의 콜백은 실패 시 열려서는 안 되는(fail open) 정책 게이트 역할을 할 수 있기 때문입니다. 세션은 계속됩니다. v2.1.208 이전에는 이 이벤트에서 콜백 타임아웃이 발생하면 실행 오류와 함께 턴이 종료되었습니다.

<h4 id="userpromptsubmit-input">
  UserPromptSubmit 입력
</h4>

[공통 입력 필드](#common-input-fields) 외에도 UserPromptSubmit 훅은 제출된 텍스트가 담긴 `prompt` 필드를 받습니다. `[Pasted text #N]` 자리 표시자로 축소된 붙여넣은 콘텐츠는 제자리에 펼쳐진 상태로 전달됩니다. Claude Code가 [Claude를 위해 붙여넣은 텍스트를 표시하는](/docs/ko/terminal-config#how-claude-treats-pasted-text) 세션에서는 펼쳐진 콘텐츠가 `<pasted_content id="…">` 줄과 `</pasted_content id="…">` 줄 사이에 위치하므로, 훅이 프롬프트를 파싱한다면 이 줄을 고려하세요.

UserPromptSubmit 훅은 세션에 사용자 지정 제목이 있을 때 `session_title`도 받으며, 의미는 [SessionStart `session_title` 필드](#sessionstart-input)와 같습니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "UserPromptSubmit",
  "prompt": "Write a function to calculate the factorial of a number"
}
```

<h4 id="userpromptsubmit-decision-control">
  UserPromptSubmit 결정 제어
</h4>

`UserPromptSubmit` 훅은 제출된 프롬프트의 처리 여부를 제어하고 컨텍스트를 추가할 수 있습니다. 모든 [JSON 출력 필드](#json-output)를 사용할 수 있습니다.

종료 코드 0에서 대화에 컨텍스트를 추가하는 방법은 두 가지입니다:

* **일반 텍스트 stdout**: Claude Code는 [일반 텍스트로 처리하는](#exit-code-0) stdout을 Claude의 컨텍스트에 추가합니다
* **`additionalContext`가 포함된 JSON**: 더 세밀하게 제어하려면 아래 JSON 형식을 사용하세요. `additionalContext` 필드가 컨텍스트로 추가됩니다

두 채널 모두 트랜스크립트에 표시되는 항목을 만들지 않습니다. 일반 stdout과 `additionalContext` 값은 각각 훅 이름으로 시작하는 시스템 리마인더로 주입되며, Claude는 둘 다 읽습니다. 전달 여부를 확인하려면 [디버그 로그](#debug-hooks)를 확인하세요.

프롬프트를 차단하려면 `decision`을 `"block"`으로 설정한 JSON 객체를 반환하세요:

| 필드 | 설명 |
| :- | :- |
| `decision` | `"block"`은 프롬프트가 Claude에 도달하기 전에 중지합니다. 프롬프트 진행을 허용하려면 생략하세요 |
| `reason` | `decision`이 `"block"`일 때 사용자에게 표시됩니다. 컨텍스트에는 추가되지 않습니다 |
| `additionalContext` | 제출된 프롬프트와 함께 Claude의 컨텍스트에 추가되는 문자열. [Claude를 위한 컨텍스트 추가](#add-context-for-claude)를 참조하세요 |
| `sessionTitle` | 세션 제목을 설정합니다. 프롬프트 내용을 기반으로 세션 이름을 자동 지정하는 데 사용합니다 |
| `suppressOriginalPrompt` | 훅이 프롬프트를 차단할 때 `true`이면 차단 메시지에서 프롬프트 텍스트를 제외합니다. [차단된 프롬프트가 남기는 것](#what-a-blocked-prompt-leaves-behind)을 참조하세요 |

종료 코드 2로 차단하는 훅은 `reason`과 같은 방식으로 처리됩니다. 차단 메시지는 stderr 텍스트를 사용자에게 표시하며, 이 텍스트는 컨텍스트에 추가되지 않습니다.

```json theme={null}
{
  "decision": "block",
  "reason": "Explanation for decision",
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "My additional context here",
    "sessionTitle": "My session title",
    "suppressOriginalPrompt": true
  }
}
```

<h4 id="what-a-blocked-prompt-leaves-behind">
  차단된 프롬프트가 남기는 것
</h4>

차단된 프롬프트는 Claude에 도달하지 않지만, 그 텍스트가 모든 곳에서 제거되는 것은 아닙니다. 기본적으로 사용자에게 표시되는 차단 메시지는 `Original prompt:` 뒤에 제출된 텍스트가 오는 형태로 끝나며, Claude Code는 이 메시지를 디스크의 세션 트랜스크립트 파일에 씁니다. 메시지에서 텍스트를 제외하려면 `hookSpecificOutput` 안에 `"suppressOriginalPrompt": true`가 포함된 JSON을 출력하세요. 이는 훅이 `decision: "block"`으로 차단하든 종료 코드 2로 차단하든 작동합니다.

`suppressOriginalPrompt`는 차단 메시지만 변경합니다. 제출된 텍스트는 세션 트랜스크립트나 프롬프트 기록 같은 로컬 파일에 여전히 나타날 수 있으므로, 차단 훅은 비밀 정보를 디스크에 남기지 않는 방법이 아닙니다. 이러한 파일을 제한하거나 제거하려면 [일반 텍스트 저장](/docs/ko/claude-directory#plaintext-storage) 및 [로컬 데이터 지우기](/docs/ko/claude-directory#clear-local-data)를 참조하세요.

<h3 id="userpromptexpansion">
  UserPromptExpansion
</h3>

사용자가 입력한 명령이 Claude에 도달하기 전에 프롬프트로 확장될 때 실행됩니다. 특정 명령의 직접 호출을 차단하거나, 특정 스킬에 컨텍스트를 주입하거나, 사용자가 호출하는 명령을 로그에 기록하는 데 사용하세요. 예를 들어 `deploy`와 일치하는 훅은 승인 파일이 없으면 `/deploy`를 차단할 수 있고, 리뷰 스킬과 일치하는 훅은 팀의 리뷰 체크리스트를 `additionalContext`로 추가할 수 있습니다.

이 이벤트는 `PreToolUse`가 다루지 않는 경로를 다룹니다. `Skill` 도구와 일치하는 `PreToolUse` 훅은 Claude가 도구를 호출할 때만 발생하지만, `/skillname`을 직접 입력하면 `PreToolUse`를 우회합니다. `UserPromptExpansion`은 이 직접 경로에서 발생합니다.

`command_name`에 대해 매칭합니다. 모든 프롬프트 유형 명령에서 발생시키려면 matcher를 비워 두세요.

<h4 id="userpromptexpansion-input">
  UserPromptExpansion 입력
</h4>

[공통 입력 필드](#common-input-fields) 외에도 UserPromptExpansion 훅은 `expansion_type`, `command_name`, `command_args`, `command_source`, 원래 `prompt` 문자열을 받습니다. `expansion_type` 필드는 스킬 및 사용자 지정 명령의 경우 `slash_command`, MCP 서버 프롬프트의 경우 `mcp_prompt`입니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../00893aaf.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "UserPromptExpansion",
  "expansion_type": "slash_command",
  "command_name": "example-skill",
  "command_args": "arg1 arg2",
  "command_source": "plugin",
  "prompt": "/example-skill arg1 arg2"
}
```

<h4 id="userpromptexpansion-decision-control">
  UserPromptExpansion 결정 제어
</h4>

`UserPromptExpansion` 훅은 확장을 차단하거나 컨텍스트를 추가할 수 있습니다. 모든 [JSON 출력 필드](#json-output)를 사용할 수 있습니다.

| 필드 | 설명 |
| :- | :- |
| `decision` | `"block"`은 명령이 확장되지 않도록 합니다. 진행을 허용하려면 생략하세요 |
| `reason` | `decision`이 `"block"`일 때 사용자에게 표시됩니다 |
| `additionalContext` | 확장된 프롬프트와 함께 Claude의 컨텍스트에 추가되는 문자열. [Claude를 위한 컨텍스트 추가](#add-context-for-claude)를 참조하세요 |

종료 코드 2로 차단하는 훅은 `reason`과 같은 방식으로 처리됩니다. 차단 메시지는 stderr 텍스트를 사용자에게 표시합니다.

```json theme={null}
{
  "decision": "block",
  "reason": "This slash command is not available",
  "hookSpecificOutput": {
    "hookEventName": "UserPromptExpansion",
    "additionalContext": "Additional context for this expansion"
  }
}
```

<h3 id="messagedisplay">
  MessageDisplay
</h3>

어시스턴트 메시지가 화면으로 스트리밍되는 동안 실행됩니다. Claude Code는 메시지를 단계적으로 표시합니다. 새로 완성된 줄의 배치가 렌더링될 준비가 될 때마다 훅이 해당 줄로 한 번 실행되고, Claude Code는 그 자리에 훅의 대체 텍스트를 렌더링합니다. 긴 메시지는 여러 번 호출되며, 짧은 메시지는 한 번만 호출될 수 있습니다.

MessageDisplay는 다음 용도로 사용합니다:

* 최소한의 표시를 위해 markdown 제거
* Agent SDK 애플리케이션이 사용자에게 보여 주는 텍스트 변환
* Claude의 응답에서 API 키나 내부 호스트 이름 삭제

Claude Code는 훅이 반환할 때까지 각 배치를 보류하므로 훅을 빠르게 유지하세요. 훅이 실패하거나 시간 초과되면 Claude Code는 원래 텍스트를 표시합니다. 이 이벤트의 기본 타임아웃은 10초이며, 훅에 더 많은 시간이 필요하면 훅 항목에서 `timeout` 필드를 설정하세요.

MessageDisplay는 표시 전용입니다. 대체 텍스트는 화면에 렌더링되는 내용만 변경합니다. 트랜스크립트와 Claude가 보는 내용은 원래 텍스트를 유지하므로 Claude는 대체 텍스트를 보지 않으며, verbose 모드에서는 원래 텍스트가 표시됩니다. 훅은 어시스턴트 메시지 텍스트만 받으므로 도구 결과와 사용자가 입력한 텍스트는 변경 없이 렌더링됩니다.

MessageDisplay는 matcher를 지원하지 않으며 텍스트를 스트리밍하는 모든 어시스턴트 메시지에 대해 발생합니다. 도구 호출만 있는 응답처럼 텍스트가 없는 메시지는 이 훅을 트리거하지 않습니다.

Agent SDK 쿼리와 `claude -p`를 포함한 비대화형 실행에서 MessageDisplay는 줄 배치마다가 아니라 어시스턴트 메시지마다 한 번 실행됩니다. 이 단일 호출은 메시지가 완료된 후 도착하며 전체 메시지 텍스트를 담습니다. `index`는 `0`, `final`은 `true`이고 `delta`에는 전체 메시지가 들어 있습니다. 각 메시지의 `delta` 텍스트를 수집하는 훅은 두 모드에서 동일한 전체 텍스트를 받습니다.

<h4 id="messagedisplay-input">
  MessageDisplay 입력
</h4>

[공통 입력 필드](#common-input-fields) 외에도 MessageDisplay 훅은 턴과 메시지의 식별자, 메시지 내 이 호출의 위치, `delta`에 담긴 새 텍스트를 받습니다. 배치 경계는 텍스트가 스트리밍되는 방식에 따라 달라지므로, 줄이 특정 방식으로 그룹화될 것으로 기대하지 말고 `index`와 `final`을 사용해 메시지 진행 상황을 추적하세요.

| 필드 | 설명 |
| :- | :- |
| `turn_id` | 현재 턴의 UUID |
| `message_id` | 표시 중인 어시스턴트 메시지의 UUID. 같은 메시지의 모든 배치에서 동일합니다. API `msg_…` id가 아니므로 트랜스크립트 메시지 id와 연관시킬 수 없습니다 |
| `index` | 메시지 내 이 배치의 0부터 시작하는 인덱스 |
| `final` | 메시지의 마지막 배치에서 `true`. 각 메시지에는 정확히 하나의 마지막 배치가 있습니다 |
| `delta` | 이전 배치 이후 새로 완성된 줄(끝의 줄바꿈 포함). 줄 중간에서 끝날 수 있는 마지막 배치를 제외하고 항상 완전한 줄입니다. 대화형 실행에서 메시지가 줄바꿈으로 끝나면 마지막 배치의 delta는 비어 있으므로, 비어 있지 않은 delta가 아니라 `final`을 메시지 종료 신호로 취급하세요. Agent SDK 및 `claude -p` 실행에서는 단일 호출에 전체 메시지가 담깁니다 |

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../transcript.jsonl",
  "cwd": "/Users/my-project",
  "hook_event_name": "MessageDisplay",
  "turn_id": "0c9e6a2f-7d41-4f4e-9a15-3f4f7c2b8d10",
  "message_id": "5b2a9c8e-1f63-4d8a-b7c4-9e0d2a6f1c3b",
  "index": 0,
  "final": false,
  "delta": "Here is the plan:\n"
}
```

<h4 id="messagedisplay-output">
  MessageDisplay 출력
</h4>

모든 훅에서 사용할 수 있는 [JSON 출력 필드](#json-output) 외에도 MessageDisplay 훅은 화면의 delta를 대체하는 `displayContent`를 반환할 수 있습니다:

| 필드 | 설명 |
| :- | :- |
| `displayContent` | delta 대신 표시되는 텍스트. 원래 텍스트를 표시하려면 생략하세요 |

MessageDisplay 훅에는 결정 제어가 없습니다. 메시지를 차단하거나, 트랜스크립트에 저장되거나 Claude에 전송되는 내용을 변경할 수 없습니다. Claude Code는 JSON 출력의 `displayContent`에 따라 동작하고 `systemMessage`와 `continue`는 버립니다.

이 예시는 일반 텍스트 표시를 위해 Claude의 응답에서 markdown 서식을 제거합니다. 스크립트는 stdin에서 각 배치를 읽고, `delta`에서 굵게 표시 기호와 인라인 코드 백틱을 제거한 다음, 결과를 `displayContent`로 반환합니다.

<Tabs>
  <Tab title="macOS/Linux">
    설정 파일에 이 이벤트에 대한 command 훅을 등록하세요:

    ```json theme={null}
    {
      "hooks": {
        "MessageDisplay": [
          {
            "hooks": [
              {
                "type": "command",
                "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/plain-display.sh",
                "args": []
              }
            ]
          }
        ]
      }
    }
    ```

    이 스크립트를 프로젝트의 `.claude/hooks/plain-display.sh`에 저장하고 `chmod +x`로 실행 가능하게 만드세요:

    ```bash theme={null}
    #!/bin/bash
    jq '{hookSpecificOutput: {hookEventName: "MessageDisplay", displayContent: (.delta | gsub("\\*\\*"; "") | gsub("`"; ""))}}'
    ```
  </Tab>

  <Tab title="Windows (PowerShell)">
    PowerShell을 통해 스크립트를 실행하는 command 훅을 등록하세요:

    ```json theme={null}
    {
      "hooks": {
        "MessageDisplay": [
          {
            "hooks": [
              {
                "type": "command",
                "command": "powershell.exe",
                "args": [
                  "-NoProfile",
                  "-ExecutionPolicy",
                  "Bypass",
                  "-File",
                  "${CLAUDE_PROJECT_DIR}/.claude/hooks/plain-display.ps1"
                ]
              }
            ]
          }
        ]
      }
    }
    ```

    `-NoProfile` 플래그는 PowerShell 프로필 로드를 건너뛰어 훅이 빠르게 시작되도록 하고, `-ExecutionPolicy Bypass`는 PowerShell이 로컬 스크립트 파일을 실행할 수 있게 합니다.

    이 스크립트를 프로젝트의 `.claude/hooks/plain-display.ps1`에 저장하세요:

    ```powershell theme={null}
    $batch = [Console]::In.ReadToEnd() | ConvertFrom-Json
    $text = $batch.delta -replace '\*\*', '' -replace '`', ''
    @{
      hookSpecificOutput = @{
        hookEventName = "MessageDisplay"
        displayContent = $text
      }
    } | ConvertTo-Json
    ```
  </Tab>
</Tabs>

markdown이 없는 배치는 변경 없이 통과합니다. 예를 들어 `jq`가 없어 스크립트가 실패하면 Claude Code는 원래 텍스트를 표시하고, 실패는 세션이 아닌 [디버그 출력](#debug-hooks)에만 기록합니다.

<h3 id="pretooluse">
  PreToolUse
</h3>

Claude가 도구 매개변수를 생성한 후, 도구 호출을 처리하기 전에 실행됩니다. `EndConversation`을 제외한 모든 도구 이름에 대해 매칭합니다. 여기에는 `Bash`, `PowerShell`, `Edit`, `Write`, `Read`, `Glob`, `Grep`, `Agent`, `Workflow`, `WebFetch`, `WebSearch`, `AskUserQuestion`, `ExitPlanMode` 같은 기본 제공 도구와 모든 [MCP 도구 이름](#match-mcp-tools)이 포함됩니다.

무엇이 파일을 썼는지와 관계없이 특정 파일이 디스크에서 변경될 때 훅을 실행하려면, 파일 편집 도구를 이름으로 매칭하는 대신 [FileChanged](#filechanged)를 사용하세요. PreToolUse와 달리 Claude Code는 변경 후에 FileChanged 훅을 실행하며, 이 훅에는 결정 제어가 없으므로 쓰기를 차단할 수 없습니다.

<Warning>
  PreToolUse는 Claude가 도구를 호출할 때만 실행됩니다. [프롬프트에서 `@`로 참조하는](/docs/ko/common-workflows#reference-files-and-directories) 파일은 도구 호출 없이 추가됩니다. Claude Code는 프롬프트를 구성하는 동안 해당 파일의 내용을 삽입하므로, `Read`와 일치하는 훅을 포함해 어떤 PreToolUse 훅도 이 파일에 대해 발생하지 않습니다. `@` 참조에서 특정 경로를 차단하려면 대신 [`Read` 거부 규칙](/docs/ko/permissions#read-and-edit)을 사용하세요.

  PreToolUse는 [`EndConversation`](/docs/ko/tools-reference#endconversation-tool-behavior)에 대해서도 발생하지 않습니다.
</Warning>

[PreToolUse 결정 제어](#pretooluse-decision-control)를 사용해 도구 호출을 허용, 거부, 확인 요청 또는 지연하세요.

`PreToolUse`의 [Agent SDK 콜백 훅](/docs/ko/agent-sdk/hooks)이 타임아웃을 초과하면 도구 호출이 차단되고, Claude는 타임아웃을 명시하는 오류 결과를 받습니다. 다른 훅이 반환한 명시적 거부는 여전히 우선합니다.

<h4 id="pretooluse-input">
  PreToolUse 입력
</h4>

[공통 입력 필드](#common-input-fields) 외에도 PreToolUse 훅은 `tool_name`, `tool_input`, `tool_use_id`를 받습니다.

[MCP 도구](#match-mcp-tools)의 경우 입력에 `mcp_server`도 포함됩니다. 이는 서버의 `name`과 서버 정의의 출처를 나타내는 `source`가 있는 객체입니다. `source` 값에는 `plugin`, `sdk`, 그리고 `user`, `project` 같은 구성 범위가 포함됩니다. Agent SDK 참조의 [`McpServerProvenance`](/docs/ko/agent-sdk/typescript#mcpserverprovenance)에 전체 목록과 인식할 수 없는 값을 처리하는 방법이 나와 있습니다. 신뢰 결정은 `name`이나 `mcp__<server>__` 도구 이름 접두사가 아니라 `source`를 기준으로 하세요. `mcp_server` 필드에는 Claude Code v2.1.274 이상이 필요합니다.

파일 도구 `Write`, `Edit`, `Read`의 경우 `tool_input.file_path`는 항상 절대 경로입니다:

* Claude Code는 훅이 실행되기 전에 `~`와 상대 경로를 확장하므로, 경로를 매칭하는 훅을 `~`나 같은 경로의 상대 표기로 우회할 수 없습니다
* Windows에서는 `$PWD`가 `/c/project`처럼 보이는 Git Bash에서 훅이 실행되더라도 경로가 백슬래시 구분자로 전달됩니다
* `/src/` 검사처럼 슬래시로 작성된 비교는 백슬래시 경로와 절대 일치하지 않으며, 도구 호출은 훅이 차단할 것이 없었던 것처럼 진행됩니다
* 비교하기 전에 구분자를 정규화하세요. Bash에서는 `FILE_PATH="${FILE_PATH//\\//}"`, Python에서는 `file_path.replace("\\", "/")`를 사용한 다음, 경로가 절대 경로이므로 `^`로 고정하지 말고 `/src/` 같은 경로 세그먼트를 매칭하세요

Windows에서 `Write` 호출은 다음을 전달합니다:

```json theme={null}
{
  "hook_event_name": "PreToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "C:\\project\\src\\index.ts",
    "content": "..."
  },
  ...
}
```

`tool_input` 필드는 도구에 따라 다릅니다:

<a id="bash" />

<h5 id="bash">
  Bash
</h5>

셸 명령을 실행합니다.

| 필드 | 유형 | 예시 | 설명 |
| :- | :- | :- | :- |
| `command` | string | `"npm test"` | 실행할 셸 명령 |
| `description` | string | `"Run test suite"` | 명령이 수행하는 작업에 대한 선택적 설명 |
| `timeout` | number | `120000` | 밀리초 단위의 선택적 타임아웃. [최대값](/docs/ko/tools-reference#bash-tool-behavior)을 초과하는 값은 거부되지 않고 최대값으로 줄어듭니다 |
| `run_in_background` | boolean | `false` | 명령을 백그라운드에서 실행할지 여부 |

Bash 명령이 Git 저장소의 파일을 변경하면 Claude Code는 변경 내용을 기록할 수 있습니다. [`bashEditDiffEnabled`](/docs/ko/settings-reference#basheditdiffenabled) 설정이 기록을 켜면 모든 권한 모드에서 변경 내용을 기록하며, 어떤 파일에서 이 설정을 지정할 수 있는지는 해당 설정 항목에 나와 있습니다. 그렇지 않으면 자동 모드와 `bypassPermissions` 모드에서만, 그리고 Claude Code가 Claude에게 Bash를 통해 파일을 편집하도록 지시할 때만 기록합니다. 기록을 끄려면 `bashEditDiffEnabled`를 `false`로 설정하세요. 백그라운드 명령과 읽기 전용 명령에는 diff가 포함되지 않습니다.

그러면 [PostToolUse 훅](#posttooluse)이 `tool_response.bashEditDiff`에서 변경된 파일을 받습니다. 이 목록은 명령이 실행되는 동안 저장소에서 변경된 내용을 다룹니다. Git이 무시하는 파일과 서브모듈의 파일은 나열되지 않습니다. Claude Code v2.1.269 이상이 필요합니다.

<Note>
  이 목록은 최선의 노력(best effort) 방식으로 제공되며 공개 베타 상태입니다. Claude Code가 변경 사항을 놓치거나, 다른 프로세스가 동시에 변경한 파일을 포함하거나, 크기 제한에서 중단될 수 있습니다. 필드 형식은 변경될 수 있습니다. 이 목록은 정책을 강제하는 용도가 아니라 검토할 항목을 찾는 용도로 사용하세요.
</Note>

`changedFiles`와 `files`는 명령이 변경한 내용을 나열하고, 나머지 필드는 그 목록이 얼마나 완전하고 신뢰할 수 있는지 알려 줍니다.

| 필드 | 유형 | 예시 | 설명 |
| :- | :- | :- | :- |
| `changedFiles` | array | `["/path/to/src/app.ts"]` | 명령이 변경한 파일의 절대 경로(최대 200개). `files`에 diff가 있거나 `moreFiles`가 0보다 클 때 항상 존재합니다 |
| `files` | array | `[{"filePath": "/path/to/src/app.ts", "hunks": [...]}]` | 표시용으로 제공되는 최대 5개 변경 파일의 diff. 명령이 추가하거나 제거한 파일은 `created` 또는 `deleted`가 `true`입니다 |
| `moreFiles` | number | `2` | `files`에 diff가 없는 변경된 파일 수 |
| `unavailable` | boolean | `true` | diff가 불완전하거나 가져올 수 없을 때 설정됩니다 |
| `skipped` | boolean | `true` | `git checkout`이나 `git stash`처럼 워킹 트리를 이동하는 Git 명령에 설정되며, 이 경우 Claude Code는 diff를 가져오지 않습니다 |
| `shared` | boolean | `true` | 서브에이전트의 호출 같은 다른 Bash 도구 호출이 같은 저장소에서 동시에 실행되었을 때 설정되며, 이 경우 나열된 일부 변경 사항은 해당 명령에 의한 것일 수 있습니다 |

<a id="powershell" />

<h5 id="powershell">
  PowerShell
</h5>

PowerShell 명령을 실행합니다. 플랫폼별 사용 가능 여부는 [PowerShell 도구](/docs/ko/tools-reference#powershell-tool)를 참조하세요.

필드는 Bash 도구와 같으며, 명령 문자열은 `command`에 있습니다:

| 필드 | 유형 | 예시 | 설명 |
| :- | :- | :- | :- |
| `command` | string | `"Get-ChildItem -Recurse"` | 실행할 PowerShell 명령 |
| `description` | string | `"List files recursively"` | 명령이 수행하는 작업에 대한 선택적 설명 |
| `timeout` | number | `120000` | 밀리초 단위의 선택적 타임아웃 |
| `run_in_background` | boolean | `false` | 명령을 백그라운드에서 실행할지 여부 |

셸 명령을 검사하는 훅에서는 두 도구를 모두 다루도록 `Bash|PowerShell`을 매칭하세요:

* Windows에서 PowerShell 도구가 활성화된 경우 Claude는 PowerShell을 기본 셸로 취급하고 셸 명령을 PowerShell로 라우팅합니다.
* Git Bash가 없는 Windows에서는 이 도구가 자동으로 활성화되며 Claude Code는 Bash 도구를 전혀 등록하지 않습니다.
* `Bash`만 매칭하는 훅은 그러한 환경에서 절대 발생하지 않습니다.

<h5 id="write">
  Write
</h5>

파일을 생성하거나 덮어씁니다.

| 필드 | 유형 | 예시 | 설명 |
| :- | :- | :- | :- |
| `file_path` | string | `"/path/to/file.txt"` | 쓸 파일의 절대 경로 |
| `content` | string | `"file content"` | 파일에 쓸 내용 |

<h5 id="edit">
  Edit
</h5>

기존 파일의 문자열을 바꿉니다.

| 필드 | 유형 | 예시 | 설명 |
| :- | :- | :- | :- |
| `file_path` | string | `"/path/to/file.txt"` | 편집할 파일의 절대 경로 |
| `old_string` | string | `"original text"` | 찾아서 바꿀 텍스트 |
| `new_string` | string | `"replacement text"` | 대체 텍스트 |
| `replace_all` | boolean | `false` | 모든 항목을 바꿀지 여부 |

<h5 id="read">
  Read
</h5>

파일 내용을 읽습니다.

| 필드 | 유형 | 예시 | 설명 |
| :- | :- | :- | :- |
| `file_path` | string | `"/path/to/file.txt"` | 읽을 파일의 절대 경로 |
| `offset` | number | `10` | 읽기를 시작할 선택적 줄 번호 |
| `limit` | number | `50` | 읽을 줄 수(선택 사항) |

<h5 id="glob">
  Glob
</h5>

glob 패턴과 일치하는 파일을 찾습니다.

| 필드 | 유형 | 예시 | 설명 |
| :- | :- | :- | :- |
| `pattern` | string | `"**/*.ts"` | 파일과 매칭할 glob 패턴 |
| `path` | string | `"/path/to/dir"` | 검색할 선택적 디렉터리. 기본값은 현재 작업 디렉터리입니다 |

<h5 id="grep">
  Grep
</h5>

정규식으로 파일 내용을 검색합니다.

| 필드 | 유형 | 예시 | 설명 |
| :- | :- | :- | :- |
| `pattern` | string | `"TODO.*fix"` | 검색할 정규식 패턴 |
| `path` | string | `"/path/to/dir"` | 검색할 선택적 파일 또는 디렉터리 |
| `glob` | string | `"*.ts"` | 파일을 필터링할 선택적 glob 패턴 |
| `output_mode` | string | `"content"` | `"content"`, `"files_with_matches"` 또는 `"count"`. 기본값은 `"files_with_matches"`입니다 |
| `-i` | boolean | `true` | 대소문자를 구분하지 않는 검색 |
| `multiline` | boolean | `false` | 여러 줄 매칭 활성화 |

<h5 id="webfetch">
  WebFetch
</h5>

웹 콘텐츠를 가져와 처리합니다.

| 필드 | 유형 | 예시 | 설명 |
| :- | :- | :- | :- |
| `url` | string | `"https://example.com/api"` | 콘텐츠를 가져올 URL |
| `prompt` | string | `"Extract the API endpoints"` | 가져온 콘텐츠에 대해 실행할 프롬프트 |
| `offset` | number | `100000` | 페이지 시작 부분부터 건너뛸 선택적 문자 수입니다. Claude는 긴 페이지를 계속 읽기 위해 이 값을 설정합니다. Claude Code v2.1.290 이상이 필요합니다 |

<h5 id="websearch">
  WebSearch
</h5>

웹을 검색합니다.

| 필드 | 유형 | 예시 | 설명 |
| :- | :- | :- | :- |
| `query` | string | `"react hooks best practices"` | 검색 쿼리 |
| `allowed_domains` | array | `["docs.example.com"]` | 선택 사항: 이 도메인의 결과만 포함 |
| `blocked_domains` | array | `["spam.example.com"]` | 선택 사항: 이 도메인의 결과 제외 |

<h5 id="agent">
  Agent
</h5>

[서브에이전트](/docs/ko/sub-agents)를 생성합니다.

| 필드 | 유형 | 예시 | 설명 |
| :- | :- | :- | :- |
| `prompt` | string | `"Find all API endpoints"` | 에이전트가 수행할 작업 |
| `description` | string | `"Find API endpoints"` | 작업에 대한 짧은 설명 |
| `subagent_type` | string | `"Explore"` | 사용할 전문 에이전트 유형 |
| `model` | string | `"sonnet"` | 기본값을 재정의할 선택적 모델 별칭 |

포그라운드 Agent 호출이 완료되면 [PostToolUse 훅](#posttooluse)은 `tool_response`에서 서브에이전트의 결과와 실행 텔레메트리를 받습니다. 실행을 검사하려면 이 필드를 읽으세요. `totalTokens`와 `usage`는 최종 요청만 다루므로, 서브에이전트 전체의 토큰 및 비용 집계에는 `query_source` `"subagent"`로 필터링한 [토큰 및 비용 카운터](/docs/ko/monitoring-usage#token-counter)를 사용하세요:

| 필드 | 유형 | 예시 | 설명 |
| :- | :- | :- | :- |
| `status` | string | `"completed"` | 포그라운드 서브에이전트는 `"completed"`, 백그라운드 서브에이전트는 `"async_launched"`. 서브에이전트는 기본적으로 백그라운드에서 실행되므로 `run_in_background`를 생략한 Agent 호출도 `"async_launched"`를 생성합니다 |
| `agentId` | string | `"a4d2c8f1e0b3a297"` | 서브에이전트 실행의 식별자 |
| `content` | array | `[{"type": "text", "text": "Found 12 endpoints..."}]` | 서브에이전트의 최종 텍스트 블록. 보고서가 `SubagentHandback`을 거치는 서브에이전트의 경우 그 대신 해당 핸드백에 대한 짧은 메모 |
| `resolvedModel` | string | `"claude-sonnet-4-5"` | 서브에이전트가 시작된 모델로, 요청된 모델과 다를 수 있습니다 |
| `modelsUsed` | array | `["claude-sonnet-4-5", "claude-haiku-4-5"]` | 사용된 모델을 순서대로 나열한 목록(연속 반복은 하나로 합쳐짐). 실행 중에 모델이 교체된 경우에만 설정됩니다. Claude Code v2.1.212 이상이 필요합니다 |
| `totalTokens` | number | `12450` | 서브에이전트의 최종 API 요청에서의 토큰 수로, 입력, 출력, 캐시 토큰을 합한 값입니다. 전체 실행에 대한 합계가 아닙니다 |
| `totalDurationMs` | number | `48211` | 서브에이전트 실행의 실제 소요 시간 |
| `totalToolUseCount` | number | `7` | 서브에이전트가 수행한 도구 호출 수 |
| `usage` | object | `{"input_tokens": 8320, ...}` | 최종 API 요청의 유형별 토큰 내역: `input_tokens`, `output_tokens`, `cache_creation_input_tokens`, `cache_read_input_tokens` |

Claude Code v2.1.271 이상에서는 Claude Code가 [자동 모드](/docs/ko/permission-modes#eliminate-prompts-with-auto-mode)에서 제공하는 [`SubagentHandback`](/docs/ko/tools-reference) 도구와 함께 실행되는 서브에이전트가 보고서를 텍스트로 반환하지 않고 이 도구를 통해 전달합니다. 그러면 `completed` 결과의 `content` 필드에는 보고서 자체가 아니라 해당 핸드백에 대한 짧은 메모가 담깁니다. 보고서를 읽으려면 `SubagentHandback`에 `PreToolUse` 또는 `PostToolUse` 훅을 매칭하고 `tool_input.message`를 읽으세요.

백그라운드 서브에이전트의 경우 작업이 백그라운드로 이동할 때 도구가 반환되므로 `tool_response`에는 사용량 필드가 없습니다. 백그라운드 실행은 즉시 반환되며, Claude Code가 실행 중에 백그라운드로 보낸 포그라운드 작업은 그 전환 시점에 반환됩니다. 응답에는 `status: "async_launched"`, `agentId`, `description`, `prompt`, `outputFile`, `resolvedModel`이 있습니다.

`completed` 응답에서 `resolvedModel`은 서브에이전트가 시작된 모델을 나타내며, `availableModels`나 다른 재정의가 적용되는 경우처럼 `tool_input`의 `model` 값과 다를 수 있습니다. `async_launched` 응답에서 `resolvedModel`은 에이전트가 백그라운드로 이동할 때 사용 중이던 모델을 나타내므로, 백그라운드 전환 전에 발생한 교체가 반영됩니다. `modelsUsed`와 백그라운드 전환 시점의 `resolvedModel` 동작에는 Claude Code v2.1.212 이상이 필요합니다.

<a id="askuserquestion" />

<h5 id="askuserquestion">
  AskUserQuestion
</h5>

사용자에게 1\~4개의 객관식 질문을 합니다.

| 필드 | 유형 | 예시 | 설명 |
| :- | :- | :- | :- |
| `questions` | array | `[{"question": "Which framework?", "header": "Framework", "options": [{"label": "React", "description": "Component library"}, {"label": "Vue", "description": "Progressive framework"}], "multiSelect": false}]` | 표시할 질문. 각 질문에는 `question` 문자열, 짧은 `header`, `options` 배열, 선택적 `multiSelect` 플래그가 있습니다 |
| `answers` | object | `{"Which framework?": "React"}` | 선택 사항. 질문 텍스트를 선택된 옵션 레이블에 매핑합니다. 다중 선택 답변은 레이블을 쉼표로 연결합니다. Claude는 이 필드를 설정하지 않으므로, 프로그래밍 방식으로 답변하려면 `updatedInput`을 통해 제공하세요 |

<h5 id="exitplanmode">
  ExitPlanMode
</h5>

Claude가 [플랜 모드](/docs/ko/permission-modes#analyze-before-you-edit-with-plan-mode)를 종료하기 전에 플랜을 제시하고 사용자에게 승인을 요청합니다. Claude는 도구를 호출하기 전에 플랜을 디스크의 파일에 쓰므로, 모델이 보내는 실제 `tool_input`은 일반적으로 비어 있습니다. Claude Code는 입력을 훅에 전달하기 전에 플랜 내용과 파일 경로를 주입합니다.

| 필드 | 유형 | 예시 | 설명 |
| :- | :- | :- | :- |
| `plan` | string | `"## Refactor auth\n1. Extract..."` | Markdown 형식의 플랜 내용. 디스크의 플랜 파일에서 주입됩니다 |
| `planFilePath` | string | `"/Users/.../plans/refactor-auth.md"` | 플랜 파일 경로. 주입됩니다 |
| `allowedPrompts` | array | `[{"tool": "Bash", "prompt": "run tests"}]` | deprecated. Claude Code는 이 필드를 허용하지만 무시합니다. v2.1.205 이전에는 Claude가 플랜을 구현하기 위해 요청한 프롬프트 기반 권한을 담았습니다 |

`PostToolUse`에서 `tool_response`는 승인된 플랜을 담은 `plan` 및 `filePath` 필드와 내부 상태 플래그가 있는 객체입니다. 디스크에서 파일을 다시 읽지 말고 플랜 내용은 `tool_response.plan`에서 읽으세요.

<h4 id="pretooluse-decision-control">
  PreToolUse 결정 제어
</h4>

`PreToolUse` 훅은 도구 호출의 진행 여부를 제어할 수 있습니다. 최상위 `decision` 필드를 사용하는 다른 훅과 달리 PreToolUse는 `hookSpecificOutput` 객체 안에 결정을 반환합니다. 이를 통해 네 가지 결과(allow, deny, ask, defer)와 실행 전 도구 입력을 수정하는 기능이라는 더 풍부한 제어가 가능합니다.

| 필드 | 설명 |
| :- | :- |
| `permissionDecision` | `"allow"`는 권한 프롬프트를 건너뜁니다. 단, [어떤 모드도 자동 승인하지 않는 작업](/docs/ko/permission-modes#actions-no-mode-auto-approves)과, [`updatedInput`을 함께 사용해야 하는](#allow-with-updatedinput) `AskUserQuestion` 및 `ExitPlanMode`는 예외입니다. `"deny"`는 도구 호출을 막습니다. `"ask"`는 사용자에게 확인을 요청합니다. `"defer"`는 나중에 도구를 재개할 수 있도록 정상적으로 종료합니다. 훅이 무엇을 반환하든 [거부 및 확인 규칙](/docs/ko/permissions#manage-permissions)은 여전히 평가됩니다 |
| `permissionDecisionReason` | `"ask"`의 경우 권한 프롬프트에서 사용자에게 표시됩니다. 아무도 그 프롬프트에 응답할 수 없는 `-p` 실행에서 Claude Code가 [호출을 거부](/docs/ko/headless#turn-off-permission-prompts-in-unattended-runs)하면, Claude는 대신 도구 결과에서 이유를 읽습니다. `"deny"`의 경우 Claude에게 표시됩니다. `"allow"` 및 `"defer"`의 경우 [디버그 로그](#debug-hooks)에만 기록됩니다 |
| `updatedInput` | 실행 전에 도구의 입력 매개변수를 수정합니다. 전체 입력 객체를 대체하므로 수정된 필드와 함께 변경되지 않은 필드도 포함하세요. Claude Code는 권한 규칙과 Bash 명령의 [자동 백그라운드 적격성](/docs/ko/tools-reference#foreground-commands-that-move-to-the-background)을 Claude가 보낸 입력이 아니라 훅이 반환한 입력을 기준으로 평가합니다. 자동 승인하려면 `"allow"`와, 수정된 입력을 사용자에게 보여 주려면 `"ask"`와 함께 사용하세요. `"defer"`의 경우 무시됩니다 |
| `additionalContext` | 도구 결과와 함께 Claude의 컨텍스트에 추가되는 문자열. `permissionDecision`이 `"defer"`이면 무시됩니다. [Claude를 위한 컨텍스트 추가](#add-context-for-claude)를 참조하세요 |

여러 PreToolUse 훅이 서로 다른 결정을 반환하면 우선순위는 `deny` > `defer` > `ask` > `allow`입니다.

종료 코드 2로 차단하는 훅은 `"deny"`와 같은 방식으로 처리됩니다. Claude는 stderr 메시지를 거부 이유로 봅니다.

훅이 `"ask"`를 반환하면 사용자에게 표시되는 권한 프롬프트에 훅의 출처를 식별하는 레이블이 포함됩니다. 설정 파일이나 에이전트 frontmatter의 훅은 `[settings]`, 플러그인의 훅은 `[plugin:<name>]`, 스킬 frontmatter의 훅은 `[skill]`로 표시됩니다. 이를 통해 사용자는 어떤 구성 소스가 확인을 요청하는지 이해할 수 있습니다.

훅의 `"ask"`는 [자동 모드](/docs/ko/permission-modes#eliminate-prompts-with-auto-mode)에서도 권한 프롬프트를 강제합니다. 분류기는 여전히 도구 호출을 거부할 수 있지만 호출을 조용히 승인할 수는 없습니다. v2.1.211 이전에는 분류기가 [샌드박스](/docs/ko/sandboxing) 외부에서 실행되는 Bash 명령을 훅이 요청한 프롬프트를 표시하지 않고 승인할 수 있었습니다. 이 경우에도 분류기는 해당 명령에 자체 안전 규칙을 적용했으며, 훅의 `"deny"`는 항상 존중되었습니다.

```json theme={null}
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "My reason here",
    "updatedInput": {
      "field_to_modify": "new value"
    },
    "additionalContext": "Current environment: production. Proceed with caution."
  }
}
```

<Note>
  PreToolUse는 이전에 최상위 `decision` 및 `reason` 필드를 사용했지만, 이 이벤트에서는 deprecated되었습니다. 대신 `hookSpecificOutput.permissionDecision` 및 `hookSpecificOutput.permissionDecisionReason`을 사용하세요. deprecated 값인 `"approve"`와 `"block"`은 각각 `"allow"`와 `"deny"`에 매핑됩니다. PostToolUse와 Stop 같은 다른 이벤트는 현재 형식으로 최상위 `decision`과 `reason`을 계속 사용합니다.
</Note>

<h4 id="allow-with-updatedinput">
  사용자 상호 작용이 필요한 도구
</h4>

`AskUserQuestion`과 `ExitPlanMode`는 사용자 상호 작용이 필요합니다. `-p` 플래그를 사용하는 [비대화형 모드](/docs/ko/headless)에서 Claude Code는 Agent SDK `canUseTool` 콜백처럼 프롬프트를 받을 [권한 호스트](/docs/ko/headless#turn-off-permission-prompts-in-unattended-runs)가 실행에 있을 때만 이 도구를 제공합니다.

`PreToolUse` 훅은 다음을 수행할 때 이 요구 사항을 충족합니다:

1. stdin에서 도구의 입력을 읽습니다
2. 자체 UI를 통해 답변을 수집합니다
3. 답변을 담은 `updatedInput`과 함께 `permissionDecision: "allow"`를 반환하여 프롬프트 없이 도구가 실행되도록 합니다

이러한 도구에는 `"allow"`만 반환하는 것으로는 충분하지 않습니다.

`AskUserQuestion`의 경우 원래 `questions` 배열을 그대로 반환하고, 각 질문의 텍스트를 선택된 답변에 매핑하는 [`answers`](#askuserquestion) 객체를 추가하세요. 이 출력은 한 질문에 `React`로 답합니다:

```json theme={null}
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "updatedInput": {
      "questions": [
        {
          "question": "Which framework?",
          "header": "Framework",
          "options": [{"label": "React", "description": "Component library"}, {"label": "Vue", "description": "Progressive framework"}],
          "multiSelect": false
        }
      ],
      "answers": {"Which framework?": "React"}
    }
  }
}
```

서버가 [`_meta["anthropic/requiresUserInteraction"]`](/docs/ko/mcp#require-approval-for-a-specific-tool)으로 표시한 MCP 도구는 더 엄격합니다. 훅은 `updatedInput` 유무와 관계없이 `"allow"`로 승인 프롬프트를 건너뛸 수 없습니다. Claude Code는 훅이 도구에 필요한 상호 작용을 수집했는지 확인할 수 없기 때문입니다.

<h4 id="defer-a-tool-call-for-later">
  나중을 위해 도구 호출 지연
</h4>

`"defer"`는 Agent SDK 앱이나 Claude Code 위에 구축된 사용자 지정 UI처럼 `claude -p`를 하위 프로세스로 실행하고 JSON 출력을 읽는 통합을 위한 것입니다. 이를 통해 호출 프로세스는 도구 호출 시점에서 Claude를 일시 중지하고, 자체 인터페이스를 통해 입력을 수집한 다음, 중단한 지점에서 재개할 수 있습니다. Claude Code는 `-p` 플래그를 사용하는 [비대화형 모드](/docs/ko/headless)에서만 이 값을 따릅니다. 대화형 세션에서는 경고를 로그에 기록하고 훅 결과를 무시합니다.

`AskUserQuestion` 도구가 대표적인 경우입니다. Claude가 사용자에게 무언가를 묻고 싶지만 응답할 터미널이 없는 상황입니다. `-p` 실행은 `--permission-prompt-tool`로 전달하는 MCP 도구 같은 [권한 호스트](/docs/ko/headless#turn-off-permission-prompts-in-unattended-runs)가 있을 때만 `AskUserQuestion`을 제공하므로, 권한 호스트와 함께 실행을 시작하세요. 왕복 과정은 다음과 같습니다:

1. Claude가 `AskUserQuestion`을 호출합니다. `PreToolUse` 훅이 발생합니다.
2. 훅이 `permissionDecision: "defer"`를 반환합니다. 도구는 실행되지 않습니다. 프로세스는 `stop_reason: "tool_deferred"`와 함께 종료되며, 보류 중인 도구 호출은 트랜스크립트에 보존됩니다.
3. 호출 프로세스가 SDK 결과에서 `deferred_tool_use`를 읽고, 자체 UI에 질문을 표시한 다음, 답변을 기다립니다.
4. 호출 프로세스가 같은 권한 호스트로 `claude -p --resume <session-id>`를 실행합니다. 같은 도구 호출이 `PreToolUse`를 다시 발생시킵니다.
5. 훅이 `updatedInput`에 답변을 담아 `permissionDecision: "allow"`를 반환합니다. 도구가 실행되고 Claude가 계속 진행합니다.

`deferred_tool_use` 필드에는 도구의 `id`, `name`, `input`이 담깁니다. `input`은 Claude가 도구 호출을 위해 생성한 매개변수로, 실행 전에 캡처됩니다:

```json theme={null}
{
  "type": "result",
  "subtype": "success",
  "stop_reason": "tool_deferred",
  "session_id": "abc123",
  "deferred_tool_use": {
    "id": "toolu_01abc",
    "name": "AskUserQuestion",
    "input": { "questions": [{ "question": "Which framework?", "header": "Framework", "options": [{"label": "React", "description": "Component library"}, {"label": "Vue", "description": "Progressive framework"}], "multiSelect": false }] }
  }
}
```

타임아웃이나 재시도 제한은 없습니다. 세션은 재개할 때까지 디스크에 남아 있으며, [`cleanupPeriodDays`](/docs/ko/settings-reference#cleanupperioddays) 보존 정리의 적용을 받습니다. 이 정리는 [보존 정리 규칙](/docs/ko/claude-directory#cleaned-up-automatically)에 따라 기본적으로 30일 후 세션 파일을 삭제합니다. 재개할 때 답변이 준비되지 않았다면 훅은 다시 `"defer"`를 반환할 수 있으며, 프로세스는 같은 방식으로 종료됩니다. 호출 프로세스는 결국 훅에서 `"allow"` 또는 `"deny"`를 반환하여 루프를 끝낼 시점을 제어합니다.

`"defer"`는 Claude가 턴에서 단일 도구 호출을 할 때만 작동합니다. Claude가 여러 도구 호출을 한 번에 하면 `"defer"`는 경고와 함께 무시되고, 도구는 일반 권한 흐름을 통해 진행됩니다. 이 제약은 재개 시 하나의 도구만 다시 실행할 수 있기 때문에 존재합니다. 다른 호출을 해결되지 않은 상태로 남기지 않고 배치에서 하나의 호출만 지연할 방법은 없습니다.

재개할 때 지연된 도구를 더 이상 사용할 수 없으면, 프로세스는 훅이 발생하기 전에 `stop_reason: "tool_deferred_unavailable"` 및 `is_error: true`와 함께 종료됩니다. 이는 도구를 제공한 MCP 서버가 재개된 세션에 연결되어 있지 않을 때 발생합니다. 어떤 도구가 누락되었는지 식별할 수 있도록 `deferred_tool_use` 페이로드는 여전히 포함됩니다.

<Note>
  플랜 모드에서 지연된 세션을 재개하려면 Claude Code가 승인을 위해 플랜을 제시할 수 있도록 `--resume`과 함께 [`--permission-prompt-tool`](/docs/ko/cli-reference#cli-flags)을 전달하세요. 특정 다른 실행 플래그를 전달하면 재개된 실행이 플랜 모드로 돌아가지 않습니다. [`-p`로 플랜 모드에서 재개](/docs/ko/sessions#resume-in-plan-mode-with-p)를 참조하세요. Claude Code v2.1.246 이상이 필요합니다.

  `-p`로 재개하면 Claude Code는 저장된 다른 권한 모드를 복원하지 않습니다. 새 `claude -p` 실행이 시작되는 권한 모드로 실행을 시작하므로, 지연된 세션에서 `--permission-mode` 또는 `--dangerously-skip-permissions`를 사용했다면 다시 전달하세요. `-p` 없이 `claude --resume <session-id>`로 재개하면 Claude Code는 [재개 시 권한 모드](/docs/ko/sessions#permission-mode-on-resume)에 나열된 예외를 제외하고 저장된 권한 모드를 복원합니다.
</Note>

<h3 id="permissionrequest">
  PermissionRequest
</h3>

Claude Code가 도구 사용 권한을 요청하려 할 때 실행됩니다. [비대화형 모드](/docs/ko/headless)의 백그라운드 서브에이전트처럼 프롬프트를 표시할 수 없는 세션에서도 Claude Code는 이 훅을 실행하며, 결정을 반환하는 훅이 없으면 도구 호출을 거부합니다. `--permission-prompt-tool` 또는 Agent SDK의 [`canUseTool` 콜백](/docs/ko/agent-sdk/permissions)에 도달하는 호출의 경우 훅이 호스트와 함께 실행되며, 먼저 결정하는 쪽이 적용됩니다.
[PermissionRequest 결정 제어](#permissionrequest-decision-control)를 사용해 사용자를 대신하여 허용하거나 거부하세요.

Claude가 도구 사용 권한을 요청하는 즉시 신호가 필요할 때 이 이벤트를 사용하세요. Claude Code는 프롬프트가 약 6초 동안 대기한 후에야 `permission_prompt` 유형의 [Notification](#notification) 훅을 실행합니다.

Claude Code는 샌드박스된 명령의 [네트워크 요청](/docs/ko/sandboxing#network-isolation)에 대해서는 PermissionRequest 훅을 실행하지 않습니다. 해당 프롬프트에 대한 신호를 받으려면 `permission_prompt` 알림 유형을 사용하세요.

PreToolUse와 같은 값으로 도구 이름에 대해 매칭합니다.

<h4 id="permissionrequest-input">
  PermissionRequest 입력
</h4>

PermissionRequest 훅은 PreToolUse 훅처럼 `tool_name` 및 `tool_input` 필드를 받지만 `tool_use_id`는 받지 않습니다. MCP 도구의 경우 [`mcp_server`](#pretooluse-input) 객체도 받습니다. 선택적 `permission_suggestions` 배열에는 허용 규칙 추가나 권한 모드 변경처럼 Claude Code가 이 요청에 대해 제안하는 [권한 업데이트](#permission-update-entries)가 들어 있습니다.

각 권한 대화 상자는 자체 옵션을 구성하므로 `permission_suggestions` 배열은 화면에 표시되는 옵션의 정확한 목록이 아닙니다. 파일 편집용 대화 상자처럼 일부 대화 상자는 배열을 전혀 읽지 않고 요청 자체에서 옵션을 도출합니다. 배열을 읽는 대화 상자도 제안이 배열에 남아 있는 옵션을 숨길 수 있습니다. 예를 들어 [`allowManagedPermissionRulesOnly`](/docs/ko/settings-reference#allowmanagedpermissionrulesonly)가 규칙 저장 옵션을 숨기는 경우입니다. 또한 권한 업데이트를 통하지 않고 권한 모드를 직접 변경하는 [**Yes, and switch to auto mode**](/docs/ko/permission-modes#switch-permission-modes)처럼 제안 항목이 없는 옵션을 제공할 수도 있습니다.

PreToolUse 훅은 권한이 필요한지 여부와 관계없이 모든 도구 호출 전에 실행됩니다. PermissionRequest 훅은 Claude Code가 권한을 요청하려 할 때, 또는 프롬프트를 표시할 수 없는 호출을 자동 거부하려 할 때만 실행됩니다. 두 이벤트 모두 [`EndConversation`](/docs/ko/tools-reference#endconversation-tool-behavior)에 대해서는 발생하지 않습니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "PermissionRequest",
  "tool_name": "Bash",
  "tool_input": {
    "command": "rm -rf node_modules",
    "description": "Remove node_modules directory"
  },
  "permission_suggestions": [
    {
      "type": "addRules",
      "rules": [{ "toolName": "Bash", "ruleContent": "rm -rf node_modules" }],
      "behavior": "allow",
      "destination": "localSettings"
    }
  ]
}
```

<h4 id="permissionrequest-decision-control">
  PermissionRequest 결정 제어
</h4>

`PermissionRequest` 훅은 권한 요청을 허용하거나 거부할 수 있습니다. 모든 훅에서 사용할 수 있는 [JSON 출력 필드](#json-output) 외에도 훅 스크립트는 다음 이벤트별 필드가 있는 `decision` 객체를 반환할 수 있습니다:

| 필드 | 설명 |
| :- | :- |
| `behavior` | `"allow"`는 권한을 부여하고 `"deny"`는 거부합니다. [거부 및 확인 규칙](/docs/ko/permissions#manage-permissions)은 여전히 평가되므로 `"allow"`를 반환하는 훅이 일치하는 거부 규칙을 재정의하지 않습니다 |
| `updatedInput` | `"allow"` 전용: 실행 전에 도구의 입력 매개변수를 수정합니다. 전체 입력 객체를 대체하므로 수정된 필드와 함께 변경되지 않은 필드도 포함하세요. 수정된 입력은 거부 및 확인 규칙에 대해 다시 평가됩니다 |
| `updatedPermissions` | `"allow"` 전용: 허용 규칙 추가나 세션 권한 모드 변경처럼 적용할 [권한 업데이트 항목](#permission-update-entries) 배열 |
| `message` | `"deny"` 전용: 권한이 거부된 이유를 Claude에게 알립니다 |
| `interrupt` | `"deny"` 전용: `true`이면 Claude를 중지합니다 |

`decision` 객체 없이 종료 코드 2로 종료하는 훅은 권한 흐름을 변경하지 않으며, 해당 stderr는 버려집니다. 요청을 허용하거나 거부하려면 `decision` 객체를 반환하십시오.

```json theme={null}
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow",
      "updatedInput": {
        "command": "npm run lint"
      }
    }
  }
}
```

<h4 id="permission-update-entries">
  권한 업데이트 항목
</h4>

`updatedPermissions` 출력 필드와 [`permission_suggestions` 입력 필드](#permissionrequest-input)는 모두 동일한 항목 객체 배열을 사용합니다. 각 항목에는 나머지 필드를 결정하는 `type`과 변경 사항이 기록되는 위치를 제어하는 `destination`이 있습니다.

| `type` | 필드 | 효과 |
| :- | :- | :- |
| `addRules` | `rules`, `behavior`, `destination` | 권한 규칙을 추가합니다. `rules`는 `{toolName, ruleContent?}` 객체의 배열입니다. 도구 전체와 일치시키려면 `ruleContent`를 생략합니다. `behavior`는 `"allow"`, `"deny"` 또는 `"ask"`입니다 |
| `replaceRules` | `rules`, `behavior`, `destination` | `destination`에 있는 지정된 `behavior`의 모든 규칙을 제공된 `rules`로 대체합니다 |
| `removeRules` | `rules`, `behavior`, `destination` | 지정된 `behavior`의 일치하는 규칙을 제거합니다 |
| `setMode` | `mode`, `destination` | 권한 모드를 변경합니다. 유효한 모드는 `default`, `auto`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan`, 그리고 `default`의 별칭인 `manual`입니다 |
| `addDirectories` | `directories`, `destination` | 작업 디렉터리를 추가합니다. `directories`는 경로 문자열의 배열입니다 |
| `removeDirectories` | `directories`, `destination` | 작업 디렉터리를 제거합니다 |

<Note>
  `bypassPermissions`를 사용하는 `setMode`는 우회 모드를 이미 사용할 수 있는 상태로 세션을 시작한 경우에만 적용됩니다. 즉, `--dangerously-skip-permissions`, `--permission-mode bypassPermissions`, `--allow-dangerously-skip-permissions`, 또는 [사용자 설정, `--settings` 또는 관리형 설정](/docs/ko/settings-reference#permissions-defaultmode)의 `permissions.defaultMode: "bypassPermissions"`가 필요합니다. 그렇지 않으면 업데이트는 아무 효과가 없습니다. [`permissions.disableBypassPermissionsMode`](/docs/ko/permissions#managed-settings)가 해당 모드를 비활성화한 경우나 세션이 [제한 모드](/docs/ko/cli-reference#cli-flags)로 시작된 경우에도 업데이트는 아무 효과가 없습니다.

  `bypassPermissions`는 `destination`과 관계없이 `defaultMode`로 저장되지 않습니다.
</Note>

모든 항목의 `destination` 필드는 변경 사항이 메모리에만 유지될지 설정 파일에 저장될지를 결정합니다.

| `destination` | 기록 위치 |
| :- | :- |
| `session` | 메모리에만 유지되며 세션이 끝나면 폐기됨 |
| `localSettings` | `.claude/settings.local.json` |
| `projectSettings` | `.claude/settings.json` |
| `userSettings` | `~/.claude/settings.json` |

훅은 전달받은 `permission_suggestions` 중 하나를 자체 `updatedPermissions` 출력으로 그대로 반환할 수 있습니다.

<h3 id="posttooluse">
  PostToolUse
</h3>

도구가 성공적으로 완료된 직후에 실행됩니다.

도구 이름과 일치하며, 값은 PreToolUse와 동일합니다.

도구 이름이 적절한 필터가 아닐 때는 더 넓게 일치시킬 수 있습니다.

* 어떤 도구든 성공적으로 완료된 후 훅을 실행하려면 `matcher`를 생략하거나 `"*"`로 설정합니다. 그러면 훅이 직접 무엇이 변경되었는지 파악할 수 있습니다. 예를 들어 `git status --porcelain`을 실행하면 `git diff`가 놓치는 추적되지 않은 파일도 나열됩니다. 실패한 도구 호출의 경우 동일한 훅을 [PostToolUseFailure](#posttoolusefailure)에 추가합니다.
* 무엇이 파일을 기록했든 관계없이 특정 파일이 디스크에서 변경될 때 훅을 실행하려면 [FileChanged](#filechanged)를 사용합니다. `Bash` 명령이나 Claude Code 외부의 프로세스가 같은 파일을 다시 기록하는 경우, Claude Code는 `Edit|Write`와 일치하는 `PostToolUse` 훅을 실행하지 않습니다.

<h4 id="posttooluse-input">
  PostToolUse 입력
</h4>

`PostToolUse` 훅은 도구가 이미 성공적으로 실행된 후에 발생합니다. 입력에는 도구에 전송된 인수인 `tool_input`과 도구가 반환한 결과인 `tool_response`가 모두 포함됩니다. 두 필드의 정확한 스키마는 도구에 따라 다릅니다. 파일 도구의 `tool_input` 경로는 [PreToolUse](#pretooluse-input)와 동일한 형식으로 전달됩니다. 즉, 항상 절대 경로이며 플랫폼의 기본 구분자를 사용하므로 Windows에서는 백슬래시입니다. MCP 도구의 경우 입력에 [`mcp_server`](#pretooluse-input) 객체도 포함됩니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "PostToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file.txt",
    "content": "file content"
  },
  "tool_response": {
    "filePath": "/path/to/file.txt",
    "type": "create"
  },
  "tool_use_id": "toolu_01ABC123...",
  "duration_ms": 12
}
```

| 필드 | 설명 |
| :- | :- |
| `duration_ms` | 선택 사항. 도구 실행 시간(밀리초)입니다. 권한 프롬프트와 PreToolUse 훅에서 소요된 시간은 제외됩니다 |

<h4 id="posttooluse-decision-control">
  PostToolUse 결정 제어
</h4>

`PostToolUse` 훅은 도구 실행 후 Claude에게 피드백을 제공할 수 있습니다. 모든 훅에서 사용할 수 있는 [JSON 출력 필드](#json-output) 외에도 훅 스크립트는 다음 이벤트별 필드를 반환할 수 있습니다.

| 필드 | 설명 |
| :- | :- |
| `decision` | `"block"`은 도구 결과 옆에 `reason`을 추가합니다. Claude는 여전히 원래 출력을 봅니다. 출력을 대체하려면 `updatedToolOutput`을 사용합니다 |
| `reason` | `decision`이 `"block"`일 때 Claude에게 표시되는 설명 |
| `additionalContext` | 도구 결과와 함께 Claude의 컨텍스트에 추가되는 문자열. [Claude를 위한 컨텍스트 추가](#add-context-for-claude)를 참조하세요 |
| `classifierContext` | Claude가 아닌 [자동 모드](/docs/ko/permission-modes#eliminate-prompts-with-auto-mode) 분류기를 위한, 이 호출의 결과에 관한 짧은 메모. [자동 모드 분류기를 위한 결과 주석 달기](#annotate-a-result-for-the-auto-mode-classifier)를 참조하세요. Claude Code v2.1.236 이상이 필요합니다 |
| `updatedToolOutput` | Claude에게 전송되기 전에 도구의 출력을 제공된 값으로 대체합니다. 값은 도구의 출력 형태와 일치해야 합니다 |
| `updatedMCPToolOutput` | [MCP 도구](#match-mcp-tools)에 대해서만 출력을 대체합니다. 모든 도구에서 작동하는 `updatedToolOutput`을 사용하는 것이 좋습니다 |

아래 예시는 `Bash` 호출의 출력을 대체합니다. 대체 값은 `Bash` 도구의 출력 형태와 일치합니다.

```json theme={null}
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Additional information for Claude",
    "updatedToolOutput": {
      "stdout": "[redacted]",
      "stderr": "",
      "interrupted": false,
      "isImage": false
    }
  }
}
```

<Warning>
  `updatedToolOutput`은 Claude가 보는 내용만 변경합니다. 훅이 발생할 때는 도구가 이미 실행된 상태이므로, 기록된 파일, 실행된 명령, 전송된 네트워크 요청은 이미 적용되었습니다. OpenTelemetry 도구 스팬 및 분석 이벤트와 같은 텔레메트리도 훅이 실행되기 전에 원래 출력을 캡처합니다. 도구 호출이 실행되기 전에 이를 방지하거나 수정하려면 대신 [PreToolUse](#pretooluse) 훅을 사용하세요.

  대체 값은 도구의 출력 형태와 일치해야 합니다. 기본 제공 도구는 일반 문자열이 아닌 구조화된 객체를 반환합니다. 예를 들어 `Bash`는 `stdout`, `stderr`, `interrupted`, `isImage` 필드가 있는 객체를 반환합니다. 기본 제공 도구의 경우 도구의 출력 스키마와 일치하지 않는 값은 무시되고 원래 출력이 사용됩니다. MCP 도구 출력은 스키마 검증 없이 그대로 전달됩니다. Claude에게 필요한 오류 세부 정보를 제거하면 Claude가 잘못된 가정에 따라 작업을 진행할 수 있습니다.
</Warning>

<h4 id="annotate-a-result-for-the-auto-mode-classifier">
  자동 모드 분류기를 위한 결과 주석 달기
</h4>

`classifierContext`를 반환하면 도구 호출 결과에 관한 짧은 메모를 Claude가 아닌 [자동 모드](/docs/ko/permission-modes#eliminate-prompts-with-auto-mode) 분류기에 보낼 수 있습니다. 분류기는 [도구 결과 자체를 받지 않으므로](/docs/ko/permission-modes#how-the-classifier-evaluates-actions), 이 필드는 분류기가 이후 작업을 검토하기 전에 호출이 반환한 내용에 관해 알려 줄 수 있는 공식적인 방법입니다. 이 필드는 Claude Code v2.1.236 이상이 필요합니다.

아래 예시는 쿼리 출력의 출처를 분류기에 알려 줍니다.

```json theme={null}
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "classifierContext": "This query ran against the staging database, not production."
  }
}
```

분류기가 메모에 부여하는 가중치는 훅을 구성한 위치에 따라 달라집니다.

* **Claude Code에서 구성한 훅**: 설정 파일, 플러그인, 스킬, 에이전트 frontmatter의 훅의 경우 분류기는 메모를 검증되지 않은, 애플리케이션이 제공한 컨텍스트로 취급합니다. 메모는 사용자 의도를 확립하지 않으며, 사용자가 무언가를 승인하거나 요청했다고 주장하는 경우 분류기는 그 주장을 대화 내 사용자 본인의 메시지와 대조하여 확인합니다
* **인프로세스 Agent SDK 콜백**: Claude Code를 내장한 애플리케이션이 훅을 [TypeScript SDK 콜백](/docs/ko/agent-sdk/hooks)으로 등록하고 라이브 세션 중에 메모를 반환하는 경우, 분류기는 메모에 전달된 사용자 진술을 사용자 의도로 간주할 수 있습니다. 이러한 진술은 사용자가 보낸 메시지로 분류기가 인정하는 동의 요건을 충족할 수 있지만, 사용자 본인의 메시지로도 해제할 수 없는 차단은 해제하지 못합니다. 세션이 재개된 후에는 Claude Code가 복원된 메모를 검증되지 않은 컨텍스트로 취급합니다. 두 그룹의 훅이 모두 같은 호출에 주석을 다는 경우 분류기는 결합된 메모를 검증되지 않은 것으로 취급합니다

Claude Code는 메모를 전달할 때 다음 제한을 적용합니다.

* **길이**: Claude Code는 하나의 도구 호출에 대한 메모를 2,000자로 제한하고 나머지는 잘라냅니다. 이 제한은 해당 호출에 응답하는 모든 훅이 공유합니다
* **동기 응답만 해당**: [백그라운드에서 실행되는](#run-hooks-in-the-background) 훅의 응답은 Claude Code가 도구 결과를 기록한 후에 도착하므로, Claude Code는 해당 응답의 이 필드를 무시합니다
* **분류기가 기록하지 않는 호출**: 분류기의 트랜스크립트는 파일 읽기 및 검색과 같은 읽기 전용 조회를 생략합니다. Claude Code는 이러한 호출에 첨부된 메모를 폐기합니다
* **재작성과의 상호 작용**: 메모가 `updatedToolOutput`으로 대체하는 출력을 설명하는 경우, 같은 훅 응답에서 두 필드를 모두 반환합니다. 해당 재작성이 거부되거나 다른 훅의 재작성이 이를 대체하면 Claude Code는 메모를 삭제합니다. 재작성 없이 반환한 메모는 다른 훅이 출력을 재작성하더라도 Claude Code가 전달합니다

<Warning>
  분류기는 `classifierContext`에 넣은 내용을 세션을 호스팅하는 애플리케이션의 정보로 읽으므로, 신뢰할 수 없는 도구 출력이나 제3자 텍스트를 복사해 넣지 마세요. 메모는 출처에 관한 사실이나 해당 호출에 관한 사용자 진술처럼 이 호출 하나에 대한 짧은 주장으로 유지하세요. 이 필드를 관련 없는 메시지나 이벤트 스트림을 전달하는 데 사용하지 마세요.
</Warning>

<h3 id="posttoolusefailure">
  PostToolUseFailure
</h3>

실행을 시작한 도구가 실패할 때 실행됩니다. 즉, 도구가 오류를 발생시켰거나 MCP 도구가 오류 결과를 반환한 경우입니다. 실패를 로그에 기록하거나, 알림을 보내거나, Claude에게 수정 피드백을 제공하는 데 사용합니다.

도구 이름과 일치하며, 값은 PreToolUse와 동일합니다.

<Note>
  이 이벤트는 실행 전에 거부된 도구 호출에는 발생하지 않습니다. 예를 들어 알 수 없는 도구 이름, 스키마 또는 도구별 검증에 실패한 입력, 권한 거부가 해당합니다. 검증 거부는 `tool_use_error` 결과로 반환되며 훅이 실행되기 전에 발생하므로 `PreToolUse`와 `PostToolUseFailure` 모두 발생하지 않습니다. 권한 거부는 `PreToolUse`는 발생시키지만 이 이벤트는 발생시키지 않습니다. [PermissionDenied](#permissiondenied)를 참조하세요.
</Note>

<h4 id="posttoolusefailure-input">
  PostToolUseFailure 입력
</h4>

PostToolUseFailure 훅은 PostToolUse와 동일한 `tool_name` 및 `tool_input` 필드와 함께 최상위 필드로 오류 정보를 받습니다. MCP 도구의 경우 [`mcp_server`](#pretooluse-input) 객체도 받습니다. 예를 들어 실패한 `npm test` 명령은 다음을 전달할 수 있습니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "PostToolUseFailure",
  "tool_name": "Bash",
  "tool_input": {
    "command": "npm test",
    "description": "Run test suite"
  },
  "tool_use_id": "toolu_01ABC123...",
  "error": "Exit code 1\nError: Cannot find module 'express'",
  "is_interrupt": false,
  "duration_ms": 4187
}
```

| 필드 | 설명 |
| :- | :- |
| `error` | 무엇이 잘못되었는지 설명하는 문자열. 형식은 실패한 도구에 따라 다릅니다 |
| `is_interrupt` | 선택적 boolean. 실패가 도구가 보고한 오류가 아니라 중단(abort)으로 Claude Code에 도달한 경우 true입니다. 실행 중인 도구를 취소하면 이 훅이 발생하지 않으며, 대신 도구 결과에 중단 메시지가 포함됩니다 |
| `duration_ms` | 선택 사항. 도구 실행 시간(밀리초)입니다. 권한 프롬프트와 PreToolUse 훅에서 소요된 시간은 제외됩니다 |

`error` 문자열은 일반적으로 Claude가 실패한 도구의 결과로 받는 텍스트와 동일합니다. 형식은 도구와 실패 유형에 따라 다릅니다. 훅의 판단 기준은 `tool_name`, `is_interrupt`, 그리고 첫 줄의 `Exit code N`으로 삼고, 문자열의 나머지 부분은 안정적인 형식이 아닌 표시용 텍스트로 취급하세요.

* Bash와 PowerShell의 경우, 실행되어 종료된 명령은 첫 줄에 `Exit code N`을 생성하고, 그다음에 명령이 생성한 출력이 stdout과 stderr가 섞인 하나의 블록으로 이어집니다
* Claude Code가 셸 프로세스 자체를 시작할 수 없었던 경우, 페이로드에 종료 코드 줄 없이 실패 메시지만 포함될 수도 있습니다
* Claude Code는 긴 문자열의 중간을 `... [N characters truncated] ...` 마커를 중심으로 잘라내며, `Command timed out after 2m 0s`와 같은 자체 줄을 삽입할 수 있습니다

<h4 id="posttoolusefailure-decision-control">
  PostToolUseFailure 결정 제어
</h4>

`PostToolUseFailure` 훅은 도구 실패 후 Claude에게 컨텍스트를 제공할 수 있습니다. 모든 훅에서 사용할 수 있는 [JSON 출력 필드](#json-output) 외에도 훅 스크립트는 다음 이벤트별 필드를 반환할 수 있습니다.

| 필드 | 설명 |
| :- | :- |
| `additionalContext` | 오류와 함께 Claude의 컨텍스트에 추가되는 문자열. [Claude를 위한 컨텍스트 추가](#add-context-for-claude)를 참조하세요 |

```json theme={null}
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUseFailure",
    "additionalContext": "Additional information about the failure for Claude"
  }
}
```

<h3 id="posttoolbatch">
  PostToolBatch
</h3>

배치의 모든 도구 호출이 처리된 후, Claude Code가 모델에 다음 요청을 보내기 전에 한 번 실행됩니다. `PostToolUse`는 도구마다 한 번씩 발생하므로, Claude가 병렬 도구 호출을 하면 동시에 발생합니다. `PostToolBatch`는 전체 배치에 대해 정확히 한 번 발생하므로, 단일 도구가 아닌 실행된 도구 집합에 따라 달라지는 컨텍스트를 주입하기에 적합한 위치입니다. 이 이벤트에는 matcher가 없습니다.

<h4 id="posttoolbatch-input">
  PostToolBatch 입력
</h4>

[공통 입력 필드](#common-input-fields) 외에도 PostToolBatch 훅은 배치의 모든 도구 호출을 설명하는 배열인 `tool_calls`를 받습니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "PostToolBatch",
  "tool_calls": [
    {
      "tool_name": "Read",
      "tool_input": {"file_path": "/.../ledger/accounts.py"},
      "tool_use_id": "toolu_01...",
      "tool_response": "1\tfrom __future__ import annotations\n2\t..."
    },
    {
      "tool_name": "Read",
      "tool_input": {"file_path": "/.../ledger/transactions.py"},
      "tool_use_id": "toolu_02...",
      "tool_response": "1\tfrom __future__ import annotations\n2\t..."
    }
  ]
}
```

`tool_response`에는 모델이 해당 `tool_result` 블록에서 받는 것과 동일한 내용이 포함됩니다. 값은 도구가 내보낸 그대로의 직렬화된 문자열 또는 콘텐츠 블록 배열입니다. `Read`의 경우 원시 파일 내용이 아니라 줄 번호가 앞에 붙은 텍스트를 의미합니다. 응답이 클 수 있으므로 필요한 필드만 파싱하세요.

<Note>
  `tool_response`의 형태는 `PostToolUse`의 것과 다릅니다. `PostToolUse`는 `Write`의 경우 `{filePath: "...", type: "create"}`와 같은 도구의 구조화된 `Output` 객체를 전달하고, `PostToolBatch`는 모델이 보는 직렬화된 `tool_result` 콘텐츠를 전달합니다.
</Note>

<h4 id="posttoolbatch-decision-control">
  PostToolBatch 결정 제어
</h4>

`PostToolBatch` 훅은 Claude를 위한 컨텍스트를 주입할 수 있습니다. 모든 훅에서 사용할 수 있는 [JSON 출력 필드](#json-output) 외에도 훅 스크립트는 다음 이벤트별 필드를 반환할 수 있습니다.

| 필드 | 설명 |
| :- | :- |
| `additionalContext` | 다음 모델 호출 전에 한 번 주입되는 컨텍스트 문자열. 전달 방식, 넣을 내용, 재개된 세션이 이전 값을 처리하는 방식은 [Claude를 위한 컨텍스트 추가](#add-context-for-claude)를 참조하세요 |

```json theme={null}
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolBatch",
    "additionalContext": "These files are part of the ledger module. Run pytest before marking the task complete."
  }
}
```

`decision: "block"` 또는 `continue: false`를 반환하면 다음 모델 호출 전에 에이전틱 루프가 중지됩니다. 차단 메시지는 JSON의 `reason` 또는 `stopReason`, 또는 종료 코드 2일 때의 stderr에서 가져옵니다. 이 메시지는 트랜스크립트에 경고로 표시되며 대화에 남으므로, 대화가 계속될 때 Claude가 이를 보게 됩니다.

<h3 id="permissiondenied">
  PermissionDenied
</h3>

[자동 모드](/docs/ko/permission-modes#eliminate-prompts-with-auto-mode)가 도구 호출을 거부할 때 실행됩니다. 여기에는 [자동 모드와 별개인 안전 검사가 분류기 자체의 요청을 거부](/docs/ko/errors#auto-mode-cannot-determine-the-safety-of-an-action)했거나 분류기 응답을 파싱할 수 없어서 분류기 판정 없이 거부하는 경우도 포함됩니다. 이 훅은 자동 모드에서만 발생합니다. 사용자가 권한 대화 상자에서 직접 거부하거나, `PreToolUse` 훅이 호출을 차단하거나, `deny` 규칙이 일치하는 경우에는 실행되지 않습니다. 거부를 로그에 기록하거나, 구성을 조정하거나, 모델에게 도구 호출을 재시도해도 된다고 알리는 데 사용합니다.

도구 이름과 일치하며, 값은 PreToolUse와 동일합니다.

<h4 id="permissiondenied-input">
  PermissionDenied 입력
</h4>

[공통 입력 필드](#common-input-fields) 외에도 PermissionDenied 훅은 `tool_name`, `tool_input`, `tool_use_id`, `reason`을 받습니다. MCP 도구의 경우 [`mcp_server`](#pretooluse-input) 객체도 받습니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "auto",
  "hook_event_name": "PermissionDenied",
  "tool_name": "Bash",
  "tool_input": {
    "command": "rm -rf /tmp/build",
    "description": "Clean build directory"
  },
  "tool_use_id": "toolu_01ABC123...",
  "reason": "[Irreversible Local Destruction]"
}
```

| 필드 | 설명 |
| :- | :- |
| `reason` | 거부 사유. 분류기 판정의 경우 대부분의 세션에서 `[Data Exfiltration]`과 같이 일치한 규칙 이름을 대괄호로 표시합니다. 다른 형식은 [거부 검토](/docs/ko/auto-mode-config#review-denials)를 참조하세요. [판정 없는 거부](#permissiondenied-decision-control)의 경우 `Auto mode could not evaluate this action and is blocking it for safety`로 시작합니다. 분류기 모델을 사용할 수 없어서 거부된 경우 고정 텍스트 `Classifier unavailable`입니다 |

<h4 id="permissiondenied-decision-control">
  PermissionDenied 결정 제어
</h4>

PermissionDenied 훅은 모델에게 거부된 도구 호출을 재시도해도 된다고 알릴 수 있습니다. `hookSpecificOutput.retry`를 `true`로 설정한 JSON 객체를 반환합니다.

```json theme={null}
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionDenied",
    "retry": true
  }
}
```

`retry`가 `true`이면 Claude Code는 모델에게 도구 호출을 재시도해도 된다고 알리는 메시지를 대화에 추가합니다. Claude Code가 거부 자체를 번복하지는 않습니다. 훅이 JSON을 반환하지 않거나 `retry: false`를 반환하면 거부가 유지되고 모델은 원래 거부 메시지를 받습니다.

분류기가 [작업에 대한 판정을 내리지 못한](/docs/ko/errors#auto-mode-cannot-determine-the-safety-of-an-action) 경우, 즉 분류기 응답을 파싱할 수 없거나 자동 모드와 별개인 안전 검사가 분류기 자체의 요청을 거부한 경우, Claude Code는 `retry: true`를 무시합니다. 이러한 거부의 경우 Claude Code가 이미 거부 메시지에서 나중에 재시도할지 다음으로 넘어갈지를 모델에게 알려 줍니다.

<h3 id="notification">
  Notification
</h3>

Claude Code가 알림을 보낼 때 실행됩니다. 알림 유형과 일치합니다. 모든 알림 유형에 대해 훅을 실행하려면 matcher를 생략합니다.

데스크톱 알림을 꺼 두어도 이 훅 이벤트는 수신됩니다. `notifications_disabled`를 포함한 `preferredNotifChannel` 설정은 알림을 받는 방식만 변경할 뿐, 훅의 실행 여부에는 영향을 주지 않습니다.

| Matcher | 발생 시점 |
| :- | :- |
| `permission_prompt` | Claude가 도구 사용 또는 샌드박스 처리된 명령의 [네트워크 요청](/docs/ko/sandboxing#network-isolation)에 대한 승인을 필요로 하고, 프롬프트가 약 6초 동안 대기한 경우 |
| `idle_prompt` | Claude가 약 60초 전에 응답을 마쳤고 그 이후로 입력하지 않은 경우 |
| `auth_success` | 인증이 완료된 경우 |
| `elicitation_dialog` | MCP 서버가 elicitation 양식을 열었고 약 6초 동안 입력하지 않은 경우 |
| `elicitation_url_dialog` | MCP 서버가 브라우저 URL을 열도록 요청했고 약 6초 동안 입력하지 않은 경우 |
| `elicitation_complete` | MCP 서버가 [URL 모드 elicitation](#elicitation-input)이 완료되었다고 보고한 경우 |
| `elicitation_response` | MCP elicitation 응답이 서버로 다시 전송된 경우 |
| `agent_needs_input` | 터미널에서 [에이전트 뷰](/docs/ko/agent-view)가 열려 있는 동안 백그라운드 세션이 사용자 입력을 기다리기 시작한 경우. 터미널 세션에서 [에이전트 팀 팀원의 터미널 설정 질문](/docs/ko/agent-teams#choose-a-display-mode)이나 [분류기 요청 요금](/docs/ko/auto-mode-classifier-billing)에 관한 자동 모드 안내가 표시되고 약 6초 동안 입력하지 않은 경우에도 발생합니다 |
| `agent_completed` | 백그라운드 세션이 완료되거나 실패한 경우. 터미널에서 [에이전트 뷰](/docs/ko/agent-view)가 열려 있는 동안에만 발생합니다 |
| `quota_auto_resume_fired` | claude.ai 사용 한도로 일시 중지되었던 작업을 Claude Code가 계속하는 경우: 한도가 재설정될 때, 또는 대기 중에 Claude Code에서 사용량 크레딧 추가, 플랜 업그레이드, 모델 전환 등 사용량을 다시 사용할 수 있게 만드는 작업을 한 경우 더 일찍 계속되며, [모델 설정 예외](/docs/ko/interactive-mode#wait-for-a-usage-limit-to-reset)가 적용됩니다 |
| `quota_auto_resume_stale` | 컴퓨터가 약 30분 이상 절전 상태인 동안 claude.ai 사용 한도가 재설정된 경우. Claude Code는 계속하는 대신 `Enter`를 누를 때까지 기다립니다. 더 짧은 절전 후에는 계속 진행하며 대신 `quota_auto_resume_fired`를 발생시킵니다 |
| `quota_auto_resume_disabled` | Claude Code가 작업을 계속하지 않고 claude.ai 사용 한도 대기를 종료하는 경우: [`autoContinueAtUsageLimit`](/docs/ko/settings-reference#autocontinueatusagelimit)이 꺼졌거나 Claude Code가 스스로 시작한 대기 중에 재설정 시점이 24시간 이상 뒤로 밀린 경우, 계속된 작업이 계속 한도에 도달한 경우, 또는 계속 진행이 모델에 도달하기 전에 차단된 경우입니다. `Esc` 또는 `Ctrl+C`를 누르거나 **Don't continue automatically**를 선택한 경우에는 발생하지 않습니다 |

`quota_auto_resume_fired`, `quota_auto_resume_stale`, `quota_auto_resume_disabled` 유형은 Claude Code v2.1.234 이상이 필요합니다.

터미널 세션에서 샌드박스 처리된 명령의 네트워크 요청에 대한 `permission_prompt`는 Claude Code v2.1.246 이상이 필요합니다.

팀원의 터미널 설정 질문에 대한 `agent_needs_input`은 Claude Code v2.1.248 이상이 필요합니다.

<Note>
  `permission_prompt`, `idle_prompt`, `elicitation_dialog`, `elicitation_url_dialog` 유형은 데스크톱 알림과 타이밍을 공유하므로, 터미널 세션에서는 사용자가 터미널을 떠나 있는 것으로 보일 때만 표시됩니다.

  * `permission_prompt`는 약 6초 동안 입력하지 않으면 발생합니다. 타이머는 권한 프롬프트가 나타날 때 시작되며, 키를 누를 때마다 연기됩니다. Claude가 도구 사용 권한을 요청할 때 즉시 훅을 실행하려면 대신 [PermissionRequest](#permissionrequest)를 사용하세요.
  * `idle_prompt`는 Claude가 응답을 마친 후 약 60초 뒤에 발생하며, 그 이후로 입력하지 않았고 백그라운드 [서브에이전트](/docs/ko/sub-agents) 같은 백그라운드 에이전트가 실행 중이지 않은 경우에만 발생합니다. Claude Code는 claude.ai 사용 한도가 재설정되기를 기다리는 동안에는 `idle_prompt`를 보내지 않습니다. 대기가 스스로 종료되면 대신 `quota_auto_resume_*` 유형 중 하나가 발생합니다.
  * elicitation 양식의 경우 `elicitation_dialog`, 브라우저 URL 요청의 경우 `elicitation_url_dialog`는 약 6초 동안 입력하지 않으면 발생합니다. 두 유형 모두 `permission_prompt`와 동일한 6초 기준을 공유합니다. 타이머는 대화 상자가 나타날 때 시작되며, 키를 누를 때마다 연기됩니다.

  다른 대화 상자가 화면에 있는 동안 도착한 권한 요청이나 elicitation도 요청이 도착한 시점부터 계산되는 동일한 6초 기준이 적용됩니다. 따라서 요청이 열린 대화 상자 뒤에서 여전히 대기 중인 동안에도 해당 알림이 도착할 수 있습니다.
</Note>

Claude Code가 권한 요청을 Agent SDK의 [`canUseTool` 콜백](/docs/ko/agent-sdk/user-input)으로 보내는 세션에서는 `permission_prompt`의 타이밍이 다릅니다. Claude Desktop과 VS Code 확장 프로그램이 이 방식으로 Claude Code를 호스팅합니다.

* `permission_prompt`는 Claude가 권한을 요청한 후 약 6초 뒤에 발생합니다. 입력 중이어도 Claude Code는 이를 연기하지 않습니다.
* 사용자나 [PermissionRequest](#permissionrequest) 훅이 그보다 먼저 응답하면 Claude Code는 `permission_prompt`를 실행하지 않습니다.
* 이러한 세션에서 `permission_prompt`를 끄려면 [`CLAUDE_CODE_DISABLE_PERMISSION_PROMPT_NOTIFY_HOOKS`](/docs/ko/env-vars)를 `1`로 설정합니다.

v2.1.233 이전에는 이러한 세션에서 `permission_prompt`가 발생하지 않았습니다.

알림 유형에 따라 다른 핸들러를 실행하려면 별도의 matcher를 사용합니다. 이 구성은 Claude가 권한 승인을 필요로 할 때 권한 전용 알림 스크립트를 실행하고, Claude가 유휴 상태일 때 다른 알림을 실행합니다.

```json theme={null}
{
  "hooks": {
    "Notification": [
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/permission-alert.sh"
          }
        ]
      },
      {
        "matcher": "idle_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/idle-notification.sh"
          }
        ]
      }
    ]
  }
}
```

<h4 id="notification-input">
  Notification 입력
</h4>

[공통 입력 필드](#common-input-fields) 외에도 Notification 훅은 알림 텍스트가 담긴 `message`, 선택적 `title`, 그리고 어떤 유형이 발생했는지 나타내는 `notification_type`을 받습니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "Notification",
  "message": "Claude needs your permission",
  "title": "Permission needed",
  "notification_type": "permission_prompt"
}
```

Notification 훅은 알림을 차단하거나 수정할 수 없습니다. Claude Code는 `systemMessage` 및 `continue` 필드를 폐기하지만 [`terminalSequence`](#emit-terminal-notifications)는 여전히 내보내며, 데스크톱 알림 예시가 바로 이를 활용합니다. Notification 훅은 외부 서비스로 알림을 전달하는 것과 같은 부수 효과를 위한 것입니다.

<h3 id="subagentstart">
  SubagentStart
</h3>

Claude가 Agent 도구로 서브에이전트를 생성할 때, Claude가 [서브에이전트를 재개할 때](/docs/ko/sub-agents#resume-subagents), 그리고 인프로세스 [에이전트 팀](/docs/ko/agent-teams) 팀원이 새 메시지를 처리할 때마다 실행됩니다. 에이전트 유형 이름으로 필터링하는 matcher를 지원합니다. 기본 제공 에이전트의 경우 `general-purpose`, `Explore`, `Plan`과 같은 에이전트 이름입니다. [사용자 지정 서브에이전트](/docs/ko/sub-agents)의 경우 파일 이름이 아닌 에이전트 frontmatter의 `name` 필드입니다.

[플러그인](/docs/ko/plugins/overview)이 제공하는 서브에이전트의 경우, 에이전트 유형은 frontmatter의 이름만이 아니라 `my-plugin:reviewer`와 같은 플러그인 범위 식별자입니다. 콜론으로 인해 플러그인 범위 이름은 정규 표현식 경로로 처리되므로, 정확히 일치시키려면 matcher를 `^`와 `$`로 고정합니다: `^my-plugin:reviewer$`.

<h4 id="subagentstart-input">
  SubagentStart 입력
</h4>

[공통 입력 필드](#common-input-fields) 외에도 SubagentStart 훅은 서브에이전트의 고유 식별자가 담긴 `agent_id`와 matcher가 필터링하는 에이전트 이름이 담긴 `agent_type`을 받습니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "SubagentStart",
  "agent_id": "agent-abc123",
  "agent_type": "Explore"
}
```

SubagentStart 훅은 서브에이전트 생성을 차단할 수 없지만 서브에이전트에 컨텍스트를 주입할 수 있습니다. 모든 훅에서 사용할 수 있는 [JSON 출력 필드](#json-output) 외에도 다음을 반환할 수 있습니다.

| 필드 | 설명 |
| :- | :- |
| `additionalContext` | 서브에이전트의 대화 시작 시점, 첫 프롬프트 전에 서브에이전트의 컨텍스트에 추가되는 문자열. [Claude를 위한 컨텍스트 추가](#add-context-for-claude)를 참조하세요 |

```json theme={null}
{
  "hookSpecificOutput": {
    "hookEventName": "SubagentStart",
    "additionalContext": "Follow security guidelines for this task"
  }
}
```

같은 서브에이전트에 대해 훅이 다시 실행되면, Claude Code는 서브에이전트의 컨텍스트에 이전 실행의 사본이 아직 없는 경우에만 반환된 컨텍스트를 주입합니다. 시작 시 주입된 사본은 그대로 유지되므로 서브에이전트의 [프롬프트 캐시](/docs/ko/prompt-caching#subagents-and-the-cache)가 손상되지 않습니다. [자동 압축](/docs/ko/sub-agents#auto-compaction)이 해당 사본을 폐기한 후에는 Claude Code가 다음 실행의 컨텍스트를 다시 주입합니다.

<h3 id="subagentstop">
  SubagentStop
</h3>

Claude Code 서브에이전트가 응답을 마쳤을 때 실행됩니다. 에이전트 유형과 일치하며, 값은 SubagentStart와 동일합니다.

<h4 id="subagentstop-input">
  SubagentStop 입력
</h4>

[공통 입력 필드](#common-input-fields) 외에도 SubagentStop 훅은 `stop_hook_active`, `agent_id`, `agent_type`, `agent_transcript_path`, `last_assistant_message`를 받습니다. `agent_type` 필드는 matcher 필터링에 사용되는 값입니다. `transcript_path`는 메인 세션의 트랜스크립트이고, `agent_transcript_path`는 중첩된 `subagents/` 폴더에 저장된 서브에이전트 자체의 트랜스크립트입니다. `last_assistant_message` 필드에는 서브에이전트 최종 응답의 텍스트 내용이 포함되므로, 훅은 트랜스크립트 파일을 파싱하지 않고도 이에 접근할 수 있습니다.

모든 SubagentStop 이벤트가 Claude가 생성한 서브에이전트에서 오는 것은 아닙니다. Claude Code는 [프롬프트 제안](/docs/ko/interactive-mode#prompt-suggestions)과 [`/btw` 곁가지 질문](/docs/ko/interactive-mode#side-questions-with-%2Fbtw) 같은 일부 자체 기능을 위해 내부 에이전트도 실행하며, 이러한 에이전트가 완료될 때도 SubagentStop이 발생합니다. 이러한 이벤트의 경우 `agent_type`은 [`--agent`](/docs/ko/cli-reference#cli-flags) 또는 [`agent` 설정](/docs/ko/settings-reference#agent)으로 지정된 것과 같이 세션 자체가 실행되는 에이전트 이름이며, 세션이 에이전트 없이 실행되는 경우 빈 문자열입니다.

에이전트 유형을 지정하는 `matcher`는 빈 `agent_type`과 일치하지 않습니다. matcher가 생략되었거나, `""` 또는 `"*"`이거나, 빈 문자열과 일치하는 정규 표현식인 훅은 빈 `agent_type`을 가진 이벤트에도 실행됩니다.

Claude Code v2.1.271 이상에서는 [`SubagentHandback`](/docs/ko/tools-reference) 도구와 함께 실행되는 서브에이전트가 중지하기 전에 해당 도구를 통해 보고서를 전달합니다. 이때 `last_assistant_message` 필드에는 서브에이전트의 마무리 텍스트(있는 경우)가 담기며, 이는 전달된 보고서가 아닙니다. 보고서는 해당 호출의 `message` 입력이며, `SubagentHandback`과 일치하는 `PreToolUse` 또는 `PostToolUse` 훅이 이를 `tool_input.message`로 받습니다.

SubagentStop 훅은 [Stop 입력](#stop-input)에서 설명하는 `background_tasks` 및 `session_crons` 배열도 받습니다. 두 배열 모두 서브에이전트가 아닌 상위 세션 범위입니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../abc123.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "SubagentStop",
  "stop_hook_active": false,
  "agent_id": "def456",
  "agent_type": "Explore",
  "agent_transcript_path": "~/.claude/projects/.../abc123/subagents/agent-def456.jsonl",
  "last_assistant_message": "Analysis complete. Found 3 potential issues...",
  "background_tasks": [],
  "session_crons": []
}
```

SubagentStop 훅은 서브에이전트를 계속 실행시키는 오류가 아닌 피드백을 위해 `hookEventName`이 `"SubagentStop"`으로 설정된 `hookSpecificOutput.additionalContext`를 포함하여 [Stop 훅](#stop-decision-control)과 동일한 결정 제어 형식을 사용합니다. `reason`과 함께 `decision: "block"`을 반환하면 서브에이전트가 계속 실행되며 `reason`이 서브에이전트의 다음 지시로 전달됩니다. 종료 코드 2로 차단하는 훅은 stderr 메시지를 같은 방식으로 전달합니다. 서브에이전트가 반환된 후 상위 세션에 컨텍스트를 주입하려면 대신 `Agent` 도구에 대한 [`PostToolUse`](#posttooluse) 훅을 사용하세요.

<h3 id="taskcreated">
  TaskCreated
</h3>

`TaskCreate` 도구를 통해 작업이 생성될 때 실행됩니다. 명명 규칙을 강제하거나, 작업 설명을 필수로 하거나, 특정 작업의 생성을 방지하는 데 사용합니다. [Task 도구가 없는 세션](/docs/ko/tools-reference#task-tool-availability)에서는 이 이벤트가 발생하지 않습니다.

TaskCreated 훅은 matcher를 지원하지 않으며 모든 경우에 발생합니다.

<h4 id="taskcreated-input">
  TaskCreated 입력
</h4>

[공통 입력 필드](#common-input-fields) 외에도 TaskCreated 훅은 `task_id`, `task_subject`, 그리고 선택적으로 `task_description`, `teammate_name`, `team_name`을 받습니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "TaskCreated",
  "task_id": "task-001",
  "task_subject": "Implement user authentication",
  "task_description": "Add login and signup endpoints",
  "teammate_name": "implementer",
  "team_name": "session-a1b2c3d4"
}
```

| 필드 | 설명 |
| :- | :- |
| `task_id` | 생성 중인 작업의 식별자 |
| `task_subject` | 작업의 제목 |
| `task_description` | 작업의 상세 설명. 없을 수 있습니다 |
| `teammate_name` | 작업을 생성하는 팀원의 이름. 없을 수 있습니다 |
| `team_name` | Deprecated. 세션에서 파생된 팀 이름이며, 향후 릴리스에서 제거될 예정입니다 |
| `agent_id` | 이 이벤트에서 [공통 입력 필드](#common-input-fields)는 작업을 생성하는 서브에이전트 또는 [인프로세스 팀원](/docs/ko/agent-teams#choose-a-display-mode)을 식별합니다. 없을 수 있습니다. Claude Code v2.1.290 이상이 필요합니다 |

<h4 id="taskcreated-decision-control">
  TaskCreated 결정 제어
</h4>

TaskCreated 훅은 종료 코드 2 또는 JSON 결정으로 생성을 차단할 수 있습니다. 어느 경우든 Claude Code는 작업을 삭제하고 메시지를 도구의 오류로 Claude에 반환합니다. Claude Code는 이 이벤트의 `continue: false`를 무시하며 Claude는 계속 작업합니다.

* **종료 코드 2**: Claude Code가 stderr 텍스트를 메시지로 반환합니다.
* **JSON `{"decision": "block", "reason": "..."}`**: Claude Code가 `reason`을 메시지로 반환합니다.

이 예시는 제목이 필수 형식을 따르지 않는 작업을 차단합니다.

```bash theme={null}
#!/bin/bash
INPUT=$(cat)
TASK_SUBJECT=$(echo "$INPUT" | jq -r '.task_subject')

if [[ ! "$TASK_SUBJECT" =~ ^\[TICKET-[0-9]+\] ]]; then
  echo "Task subject must start with a ticket number, e.g. '[TICKET-123] Add feature'" >&2
  exit 2
fi

exit 0
```

<h3 id="taskcompleted">
  TaskCompleted
</h3>

작업이 완료로 표시될 때 실행됩니다. 이는 두 가지 상황에서 발생합니다. 에이전트가 TaskUpdate 도구를 통해 작업을 명시적으로 완료로 표시하는 경우, 또는 [에이전트 팀](/docs/ko/agent-teams) 팀원이 진행 중인 작업이 있는 상태로 턴을 마치는 경우입니다. 작업을 종료하기 전에 테스트 통과나 lint 검사 같은 완료 기준을 강제하는 데 사용합니다.

TaskCompleted 훅은 matcher를 지원하지 않으며 모든 경우에 발생합니다.

<h4 id="taskcompleted-input">
  TaskCompleted 입력
</h4>

[공통 입력 필드](#common-input-fields) 외에도 TaskCompleted 훅은 `task_id`, `task_subject`, 그리고 선택적으로 `task_description`, `teammate_name`, `team_name`을 받습니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "TaskCompleted",
  "task_id": "task-001",
  "task_subject": "Implement user authentication",
  "task_description": "Add login and signup endpoints",
  "teammate_name": "implementer",
  "team_name": "session-a1b2c3d4"
}
```

| 필드 | 설명 |
| :- | :- |
| `task_id` | 완료 중인 작업의 식별자 |
| `task_subject` | 작업의 제목 |
| `task_description` | 작업의 상세 설명. 없을 수 있습니다 |
| `teammate_name` | 작업을 완료하는 팀원의 이름. 없을 수 있습니다 |
| `team_name` | Deprecated. 세션에서 파생된 팀 이름이며, 향후 릴리스에서 제거될 예정입니다 |
| `agent_id` | 이 이벤트에서 [공통 입력 필드](#common-input-fields)는 작업을 완료하는 서브에이전트 또는 [인프로세스 팀원](/docs/ko/agent-teams#choose-a-display-mode)을 식별합니다. 없을 수 있습니다. Claude Code v2.1.290 이상이 필요합니다 |

<h4 id="taskcompleted-decision-control">
  TaskCompleted 결정 제어
</h4>

TaskCompleted 훅은 작업 완료를 제어하는 두 가지 방법을 지원합니다.

* **종료 코드 2**: 작업이 완료로 표시되지 않으며 stderr 메시지가 피드백으로 모델에 다시 전달됩니다.
* **JSON `{"continue": false, "stopReason": "..."}`**: 팀원이 턴을 마쳐서 이벤트가 트리거된 경우, `Stop` 훅 동작과 마찬가지로 팀원을 완전히 중지합니다. `stopReason`은 사용자에게 표시됩니다. `TaskUpdate` 도구가 이벤트를 트리거한 경우 Claude Code는 `continue: false`를 무시하며, 종료 코드 2는 여전히 완료를 차단합니다.

이 예시는 테스트를 실행하고 실패하면 작업 완료를 차단합니다.

```bash theme={null}
#!/bin/bash
INPUT=$(cat)
TASK_SUBJECT=$(echo "$INPUT" | jq -r '.task_subject')

# Run the test suite
if ! npm test 2>&1; then
  echo "Tests not passing. Fix failing tests before completing: $TASK_SUBJECT" >&2
  exit 2
fi

exit 0
```

<h3 id="stop">
  Stop
</h3>

메인 Claude Code 에이전트가 응답을 마쳤을 때 실행됩니다. 사용자 중단으로 인해
중지된 경우에는 실행되지 않습니다. API 오류가 발생하면 대신
[StopFailure](#stopfailure)가 발생합니다.

<Tip>
  [`/goal`](/docs/ko/goal) 명령은 세션 범위의 프롬프트 기반 Stop 훅을 위한 기본 제공 바로 가기입니다. 훅 구성을 작성하지 않고 Claude가 특정 조건을 향해 계속 작업하도록 하려면 이 명령을 사용하세요.
</Tip>

<h4 id="stop-input">
  Stop 입력
</h4>

[공통 입력 필드](#common-input-fields) 외에도 Stop 훅은 `stop_hook_active`, `last_assistant_message`, `background_tasks`, `session_crons`를 받습니다. `stop_hook_active` 필드는 Claude Code가 이미 stop 훅의 결과로 계속 진행 중일 때 `true`입니다. 결코 해결되지 않을 조건에서 차단하는 것을 방지하려면 이 값을 확인하거나 트랜스크립트를 처리하세요.

Claude Code는 연속 8회 계속 진행 제한을 적용합니다. stop 훅이 턴을 연속으로 8번 계속 진행시킨 후에는 Claude Code가 다음 차단을 재정의하고 턴을 종료합니다. 연속 계속 진행 횟수는 Claude가 도구를 호출할 때마다 재설정됩니다. 제한을 늘리려면 [`CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`](/docs/ko/env-vars)을 설정합니다.

`last_assistant_message` 필드에는 Claude 최종 응답의 텍스트 내용이 포함되므로, 훅은 트랜스크립트 파일을 파싱하지 않고도 이에 접근할 수 있습니다. 소리 내어 읽기나 알림 훅처럼 방금 완료된 턴에 대해 동작하는 훅의 경우 `transcript_path`를 읽는 대신 이 필드를 사용하세요. 모든 버전에서 Stop 시점에 트랜스크립트 파일에 최종 메시지가 포함된다고 보장되지는 않습니다.

`background_tasks` 및 `session_crons` 배열을 사용하면 훅이 "세션이 완료됨"과 "세션이 백그라운드 작업이 다시 깨워 주기를 기다리며 일시 중지됨"을 구별할 수 있습니다. 두 배열 모두 작업 레지스트리에 접근할 수 있을 때 존재하며, 진행 중이거나 예약된 항목이 없으면 비어 있습니다.

`background_tasks`의 각 항목은 진행 중인 작업 하나를 설명하며 다음 필드를 사용합니다.

| 필드 | 설명 |
| :- | :- |
| `id` | 작업 식별자 |
| `type` | `shell`, `subagent`, `monitor`, `workflow`, `teammate`, `cloud session`, `MCP task`와 같은 사용자 친화적인 작업 유형 레이블. 각 레이블은 어떤 Claude Code 기능이 작업을 생성했는지 나타냅니다. 인식되지 않는 유형의 경우 원시 판별 값으로 대체됩니다 |
| `status` | 현재 작업 상태 |
| `description` | 자유 형식 설명. 1000자로 제한되며, 잘린 경우 문자열 안에 `… [+N chars]` 마커가 포함됩니다 |
| `command` | 셸 명령줄. 1000자로 제한됩니다. `shell` 작업에만 존재합니다 |
| `agent_type` | 서브에이전트 유형 이름. `subagent` 작업에만 존재합니다 |
| `server` | MCP 서버 이름. `monitor` 및 `MCP task` 작업에만 존재합니다 |
| `tool` | MCP 도구 이름. `monitor` 및 `MCP task` 작업에만 존재합니다 |
| `name` | 워크플로 이름. `workflow` 작업에만 존재합니다 |

`session_crons`의 각 항목은 `CronCreate`, `ScheduleWakeup`, `/loop`에서 생성된 세션 범위의 예약된 깨우기 하나를 설명합니다.

| 필드 | 설명 |
| :- | :- |
| `id` | Cron 작업 식별자 |
| `schedule` | Cron 표현식. 예: `0 9 * * 1-5` |
| `recurring` | 일정이 단일 실행 시각을 나타내는 일회성 깨우기는 `false`, 일치할 때마다 다시 실행되는 작업은 `true` |
| `prompt` | cron이 실행될 때 제출되는 프롬프트. 1000자로 제한되며 동일한 `… [+N chars]` 마커를 사용합니다 |

이 예시는 진행 중인 셸 작업 하나와 반복 cron 하나가 있는 Stop 입력을 보여 줍니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "Stop",
  "stop_hook_active": true,
  "last_assistant_message": "I've completed the refactoring. Here's a summary...",
  "background_tasks": [
    {
      "id": "task-001",
      "type": "shell",
      "status": "running",
      "description": "tail logs",
      "command": "tail -f /var/log/syslog"
    }
  ],
  "session_crons": [
    {
      "id": "cron-001",
      "schedule": "0 9 * * 1-5",
      "recurring": true,
      "prompt": "check the build"
    }
  ]
}
```

<h4 id="stop-decision-control">
  Stop 결정 제어
</h4>

`Stop` 및 `SubagentStop` 훅은 Claude가 계속할지 여부를 제어할 수 있습니다. 모든 훅에서 사용할 수 있는 [JSON 출력 필드](#json-output) 외에도 훅 스크립트는 다음 이벤트별 필드를 반환할 수 있습니다.

| 필드 | 설명 |
| :- | :- |
| `decision` | `"block"`은 Claude가 중지하는 것을 방지합니다. Claude가 중지하도록 허용하려면 생략합니다 |
| `reason` | `decision`이 `"block"`일 때 필수입니다. Claude에게 계속해야 하는 이유를 알려 줍니다 |
| `hookSpecificOutput.additionalContext` | Claude를 위한 오류가 아닌 피드백. Claude가 이에 따라 행동할 수 있도록 대화가 계속되지만, `decision: "block"`과 달리 트랜스크립트에 훅 오류가 아닌 훅 피드백으로 표시됩니다 |

종료 코드 2로 차단하는 훅은 `reason`과 같은 방식으로 전달됩니다. Claude는 stderr 메시지를 계속해야 하는 이유에 대한 설명으로 받습니다.

```json theme={null}
{
  "decision": "block",
  "reason": "Must be provided when Claude is blocked from stopping"
}
```

훅이 설계대로 동작하면서 "완료하기 전에 테스트 스위트를 실행하세요"와 같이 Claude에게 지침을 제공하는 경우에는 `additionalContext`를 사용하세요. 이는 `decision: "block"`과 동일한 루프 보호 장치, 즉 `stop_hook_active` 입력과 연속 8회 계속 진행 제한을 통해 대화를 계속 진행시키지만, 트랜스크립트에는 `Stop hook feedback`으로 레이블이 지정되며 훅 오류 알림은 표시되지 않습니다.

```json theme={null}
{
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "additionalContext": "Please run the test suite before finishing"
  }
}
```

<h3 id="stopfailure">
  StopFailure
</h3>

API 오류로 인해 턴이 종료될 때 [Stop](#stop) 대신 실행됩니다. Claude Code는 [`terminalSequence`](#emit-terminal-notifications)를 제외하고 훅의 출력과 종료 코드를 무시합니다. 속도 제한, 인증 문제 또는 기타 API 오류로 인해 Claude가 응답을 완료할 수 없을 때 실패를 로그에 기록하거나, 알림을 보내거나, 복구 작업을 수행하는 데 사용합니다.

<h4 id="stopfailure-input">
  StopFailure 입력
</h4>

[공통 입력 필드](#common-input-fields) 외에도 StopFailure 훅은 `error`, 선택적 `error_details`, 선택적 `last_assistant_message`를 받습니다. `error` 필드는 오류 유형을 식별하며 matcher 필터링에 사용됩니다.

| 필드 | 설명 |
| :- | :- |
| `error` | 오류 유형: `rate_limit`, `overloaded`, `authentication_failed`, `oauth_org_not_allowed`, `account_on_hold`, `billing_error`, `invalid_request`, `model_not_found`, `server_error`, `max_output_tokens`, `cloud_credential_error` 또는 `unknown` |
| `error_details` | 가능한 경우 오류에 대한 추가 세부 정보 |
| `last_assistant_message` | 대화에 표시되는 렌더링된 오류 텍스트. 이 필드에 Claude의 대화 출력이 담기는 `Stop` 및 `SubagentStop`과 달리, `StopFailure`의 경우 `"API Error: Rate limit reached"`와 같은 API 오류 문자열 자체가 포함됩니다 |

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "StopFailure",
  "error": "rate_limit",
  "error_details": "429 Too Many Requests",
  "last_assistant_message": "API Error: Rate limit reached"
}
```

StopFailure 훅에는 결정 제어가 없습니다. 알림 및 로깅 목적으로만 실행됩니다.

<h3 id="teammateidle">
  TeammateIdle
</h3>

[에이전트 팀](/docs/ko/agent-teams) 팀원이 턴을 마친 후 유휴 상태가 되려고 할 때 실행됩니다. lint 검사 통과를 요구하거나 출력 파일이 존재하는지 확인하는 것처럼, 팀원이 작업을 멈추기 전에 품질 기준을 강제하는 데 사용합니다.

TeammateIdle 훅은 matcher를 지원하지 않으며 모든 경우에 발생합니다.

<h4 id="teammateidle-input">
  TeammateIdle 입력
</h4>

[공통 입력 필드](#common-input-fields) 외에도 TeammateIdle 훅은 `teammate_name`과 `team_name`을 받습니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "TeammateIdle",
  "teammate_name": "researcher",
  "team_name": "session-a1b2c3d4"
}
```

| 필드 | 설명 |
| :- | :- |
| `teammate_name` | 유휴 상태가 되려는 팀원의 이름 |
| `team_name` | Deprecated. 세션에서 파생된 팀 이름이며, 향후 릴리스에서 제거될 예정입니다 |
| `agent_id` | 이 이벤트에서 [공통 입력 필드](#common-input-fields)는 유휴 상태가 되려는 [인프로세스 팀원](/docs/ko/agent-teams#choose-a-display-mode)을 식별합니다. 없을 수 있습니다. Claude Code v2.1.290 이상이 필요합니다 |

<h4 id="teammateidle-decision-control">
  TeammateIdle 결정 제어
</h4>

TeammateIdle 훅은 팀원 동작을 제어하는 두 가지 방법을 지원합니다.

* **종료 코드 2**: 팀원이 stderr 메시지를 피드백으로 받고 유휴 상태가 되는 대신 계속 작업합니다.
* **JSON `{"continue": false, "stopReason": "..."}`**: `Stop` 훅 동작과 마찬가지로 팀원을 완전히 중지합니다. `stopReason`은 사용자에게 표시됩니다.

이 예시는 팀원이 유휴 상태가 되도록 허용하기 전에 빌드 산출물이 존재하는지 확인합니다.

```bash theme={null}
#!/bin/bash

if [ ! -f "./dist/output.js" ]; then
  echo "Build artifact missing. Run the build before stopping." >&2
  exit 2
fi

exit 0
```

<h3 id="configchange">
  ConfigChange
</h3>

세션 중에 설정 파일이 변경될 때 실행됩니다. 설정 변경을 감사하거나, 보안 정책을 강제하거나, 설정 파일에 대한 무단 수정을 차단하는 데 사용합니다.

Claude Code는 설정 파일, 관리형 정책 파일 또는 스킬 파일이 변경될 때 ConfigChange 훅을 실행합니다. 관리형 정책의 경우 `managed-settings.json` 또는 `managed-settings.d/`의 파일이 변경될 때만 실행합니다. [서버 관리형 설정](/docs/ko/server-managed-settings)과 macOS 관리형 환경설정 또는 Windows 레지스트리 정책의 변경 사항은 훅을 실행하지 않고 적용합니다. [`wslInheritsWindowsSettings`](/docs/ko/settings-reference#wslinheritswindowssettings)를 사용하는 WSL에서도 정책 폴링 시 변경된 Windows 측 관리형 설정 파일을 훅을 실행하지 않고 적용합니다.

matcher는 구성 출처를 기준으로 필터링합니다.

| Matcher | 발생 시점 |
| :- | :- |
| `user_settings` | `~/.claude/settings.json`이 변경된 경우 |
| `project_settings` | `.claude/settings.json`이 변경된 경우 |
| `local_settings` | `.claude/settings.local.json`이 변경된 경우 |
| `policy_settings` | `managed-settings.json` 또는 `managed-settings.d/`의 파일이 변경된 경우 |
| `skills` | `.claude/skills/`의 스킬 파일이 변경된 경우 |

이 예시는 보안 감사를 위해 모든 구성 변경을 로그에 기록합니다.

```json theme={null}
{
  "hooks": {
    "ConfigChange": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/audit-config-change.sh",
            "args": []
          }
        ]
      }
    ]
  }
}
```

<h4 id="configchange-input">
  ConfigChange 입력
</h4>

[공통 입력 필드](#common-input-fields) 외에도 ConfigChange 훅은 `source`와 선택적으로 `file_path`를 받습니다. `source` 필드는 어떤 구성 유형이 변경되었는지 나타내고, `file_path`는 수정된 특정 파일의 경로를 제공합니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "ConfigChange",
  "source": "project_settings",
  "file_path": "/Users/.../my-project/.claude/settings.json"
}
```

<h4 id="configchange-decision-control">
  ConfigChange 결정 제어
</h4>

ConfigChange 훅은 구성 변경이 적용되지 않도록 차단할 수 있습니다. 변경을 방지하려면 종료 코드 2 또는 JSON `decision`을 사용합니다. 차단되면 새 설정이 실행 중인 세션에 적용되지 않습니다.

| 필드 | 설명 |
| :- | :- |
| `decision` | `"block"`은 구성 변경이 적용되지 않도록 합니다. 변경을 허용하려면 생략합니다 |
| `reason` | 허용되지만 표시되지 않습니다 |

```json theme={null}
{
  "decision": "block",
  "reason": "Configuration changes to project settings require admin approval"
}
```

`policy_settings` 변경은 차단할 수 없습니다. 머신의 관리형 설정 파일이 변경되면 `policy_settings` 출처에 대해서도 훅이 발생하므로 이를 사용해 해당 편집을 로그에 기록할 수 있지만, 차단 결정은 무시됩니다. 이를 통해 엔터프라이즈 관리형 설정이 항상 적용되도록 보장합니다. [서버 관리형 설정](/docs/ko/server-managed-settings)이 도착하거나 새로 고쳐질 때 Claude Code는 `ConfigChange` 훅을 실행하지 않습니다.

Claude Code는 ConfigChange 훅의 JSON 출력에서 차단 결정에 따라 동작하고 `systemMessage`와 `continue`는 폐기합니다. `reason`으로 차단하든 종료 코드 2의 stderr로 차단하든, 차단된 변경은 사용자나 Claude에게 아무 메시지도 표시하지 않습니다. Claude Code는 디버그 로그에 한 줄만 기록합니다.

<h3 id="cwdchanged">
  CwdChanged
</h3>

메인 대화의 셸 명령이 작업 디렉터리를 변경할 때 실행됩니다. 예를 들어 Claude가 `cd` 명령을 실행하는 경우입니다. 디렉터리 변경에 대응하는 데 사용합니다. 환경 변수를 다시 로드하거나, 프로젝트별 툴체인을 활성화하거나, 설정 스크립트를 자동으로 실행할 수 있습니다. 디렉터리별 환경을 관리하는 [direnv](https://direnv.net/) 같은 도구를 위해 [FileChanged](#filechanged)와 함께 사용합니다.

CwdChanged 훅은 [`CLAUDE_ENV_FILE`](#persist-environment-variables)에 접근할 수 있습니다. 해당 파일에 기록된 변수는 다음 CwdChanged 이벤트에서 Claude Code가 지울 때까지 이후의 Bash 명령에 유지됩니다.

CwdChanged는 matcher를 지원하지 않으며 모든 경우에 발생합니다.

<h4 id="cwdchanged-input">
  CwdChanged 입력
</h4>

[공통 입력 필드](#common-input-fields) 외에도 CwdChanged 훅은 `old_cwd`와 `new_cwd`를 받습니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../transcript.jsonl",
  "cwd": "/Users/my-project/src",
  "hook_event_name": "CwdChanged",
  "old_cwd": "/Users/my-project",
  "new_cwd": "/Users/my-project/src"
}
```

<h4 id="cwdchanged-output">
  CwdChanged 출력
</h4>

모든 훅에서 사용할 수 있는 [JSON 출력 필드](#json-output) 외에도 CwdChanged 훅은 [FileChanged](#filechanged)가 감시하는 파일 경로를 동적으로 설정하기 위해 `watchPaths`를 반환할 수 있습니다.

| 필드 | 설명 |
| :- | :- |
| `watchPaths` | 절대 경로의 배열. 현재 동적 감시 목록을 대체합니다. `matcher` 구성의 경로는 항상 감시됩니다. 빈 배열을 반환하면 동적 목록이 지워지며, 이는 새 디렉터리에 진입할 때 일반적입니다 |

CwdChanged 훅에는 결정 제어가 없습니다. 디렉터리 변경을 차단할 수 없습니다.

Claude Code는 JSON 출력에서 `watchPaths`와 `systemMessage`를 읽고 `continue`는 폐기합니다. 대화형 세션에서는 `systemMessage`를 짧은 터미널 알림으로 표시합니다. 이 메시지는 SDK 메시지 스트림에 도달하지 않습니다.

<h3 id="directoryadded">
  DirectoryAdded
</h3>

세션 도중 `/add-dir` 명령으로 작업 디렉터리를 추가한 후, 또는 SDK 클라이언트가 `register_repo_root` 제어 요청으로 작업 디렉터리를 추가한 후에 실행됩니다. 새로 추가된 저장소를 준비하는 데 사용합니다. 예를 들어 해당 저장소의 의존성을 설치할 수 있습니다.

Claude Code는 다음 경우에 이 이벤트를 발생시키지 않습니다.

* `--add-dir` 시작 플래그로 디렉터리를 전달한 경우. 해당 디렉터리는 [SessionStart](#sessionstart)가 처리합니다
* `/permissions` Workspace 탭에서 디렉터리를 추가한 경우
* 이미 작업 디렉터리이거나 작업 디렉터리 내부에 있는 디렉터리를 추가한 경우

Claude Code는 샌드박스 및 권한 상태를 새로 고친 후 DirectoryAdded를 발생시키므로, 훅이 실행될 때 샌드박스 처리된 도구는 이미 새 디렉터리를 인식합니다. 훅 명령 자체는 샌드박스 없이 실행됩니다.

Claude Code는 훅을 기다리지 않습니다. 추가는 즉시 완료되며, 훅은 600초 기본 타임아웃으로 백그라운드에서 실행됩니다.

matcher는 디렉터리가 추가된 방식을 기준으로 필터링합니다.

| Matcher | 발생 시점 |
| :- | :- |
| `slash_command` | `/add-dir`로 디렉터리를 추가한 경우 |
| `register_repo_root` | SDK 클라이언트가 `register_repo_root` 제어 요청으로 디렉터리를 추가한 경우 |

<h4 id="directoryadded-input">
  DirectoryAdded 입력
</h4>

[공통 입력 필드](#common-input-fields) 외에도 DirectoryAdded 훅은 `directory`와 `source`를 받습니다.

| 필드 | 설명 |
| :- | :- |
| `directory` | 추가된 디렉터리의 절대 경로 |
| `source` | 디렉터리가 추가된 방식. `/add-dir`의 경우 `"slash_command"`, SDK 제어 요청의 경우 `"register_repo_root"` |

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../transcript.jsonl",
  "cwd": "/Users/my-project",
  "hook_event_name": "DirectoryAdded",
  "directory": "/Users/my-other-repo",
  "source": "slash_command"
}
```

DirectoryAdded 훅에는 결정 제어가 없습니다. 훅이 실행될 때 이미 완료된 추가를 차단할 수 없습니다. Claude Code는 JSON 출력에서 `continue` 필드를 폐기하고, 나머지는 출처에 따라 다르게 표시합니다.

* `slash_command`: Claude Code는 훅의 `systemMessage`를 사용자에게 표시하지 않고 다음 대화 턴에서 Claude에게 컨텍스트로 전달합니다. 실패한 훅의 개수가 트랜스크립트에 표시됩니다. 전체 실패 출력은 디버그 로그에 기록됩니다
* `register_repo_root`: Claude Code는 `systemMessage` 출력과 실패 출력을 디버그 로그에만 기록합니다

<h3 id="filechanged">
  FileChanged
</h3>

감시 중인 파일이 디스크에서 변경될 때 실행됩니다. Claude Code는 도구 호출을 검사하는 것이 아니라 파일 시스템 감시자로 변경을 감지하므로, 무엇이 파일을 변경했든 훅을 실행합니다. `Edit` 또는 `Write` 도구 호출, Claude가 `Bash`로 실행하는 스크립트, 또는 완전히 Claude Code 외부의 프로세스가 모두 해당됩니다. 일반적인 용도는 프로젝트 설정 파일이 변경될 때 환경 변수를 다시 로드하는 것입니다.

이 이벤트의 `matcher`는 두 가지 역할을 합니다.

* **감시 목록 구성**: 값은 `|`로 분할되며 각 세그먼트는 작업 디렉터리의 리터럴 파일 이름으로 등록되므로, `".envrc|.env"`는 정확히 그 두 파일을 감시합니다. 여기서는 정규 표현식 패턴이 유용하지 않습니다. `^\.env`와 같은 값은 문자 그대로 `^\.env`라는 이름의 파일을 감시합니다.
* **실행할 훅 필터링**: 감시 중인 파일이 변경되면 동일한 값이 변경된 파일의 basename에 대해 표준 [matcher 규칙](#matcher-patterns)을 사용하여 실행할 훅 그룹을 필터링합니다.

이 예시는 `Bash` 명령이나 외부 스크립트가 파일을 다시 기록하는 경우를 포함하여 모든 변경 후 `data.csv`의 줄 끝을 정규화합니다.

```json theme={null}
{
  "hooks": {
    "FileChanged": [
      {
        "matcher": "data.csv",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/normalize-line-endings.sh"
          }
        ]
      }
    ]
  }
}
```

훅은 stdin으로 받는 [JSON 입력](#filechanged-input)의 `file_path` 필드에서 변경된 파일의 절대 경로를 읽습니다. `grep` 가드는 `perl`이 제거하는 것과 동일한 대상, 즉 줄 끝의 CR을 검사하므로, 정규화 후의 실행은 파일을 건드리지 않고 종료됩니다. 가드가 더 느슨하면 무한 루프가 발생합니다. `perl -i`는 아무것도 치환하지 않아도 파일을 다시 기록하고, Claude Code는 다시 기록될 때마다 훅을 다시 실행하기 때문입니다. 이 스크립트를 `/path/to/normalize-line-endings.sh`에 저장하고 실행 가능하게 만드세요.

```bash theme={null}
#!/bin/bash
FILE=$(jq -r .file_path)
if grep -q $'\r$' "$FILE"; then
  perl -pi -e 's/\r$//' "$FILE"
fi
```

훅이 작동하는지 확인하려면 Claude에게 `Bash` 명령으로 `data.csv`에 CRLF 줄을 추가하도록 요청하세요. Claude Code가 훅을 실행하고 파일은 LF 줄 끝으로 바뀝니다.

미리 이름을 지정할 수 없는 파일을 감시하려면 훅에서 [`watchPaths`](#filechanged-output)를 반환하여 감시 목록을 동적으로 업데이트합니다. Claude Code는 감시할 파일이 지정된 경우에만 감시자를 시작하므로, matcher가 최소 하나의 파일을 지정하는 FileChanged 그룹이나 `watchPaths`를 반환하는 [SessionStart](#sessionstart-decision-control) 또는 [CwdChanged](#cwdchanged) 훅으로 목록을 초기화하세요. 감시 중인 파일이 변경될 때 matcher는 여전히 실행할 훅 그룹을 필터링하므로, 동적 경로를 처리하는 그룹은 matcher를 생략하세요. 생략된 matcher는 감시 중인 모든 파일과 일치하며 감시 목록에는 아무것도 추가하지 않습니다. `"*"` matcher도 모든 파일과 일치하지만, Claude Code는 이를 다른 값과 마찬가지로 `*`라는 리터럴 파일로 감시 목록에 등록합니다.

FileChanged 훅은 [`CLAUDE_ENV_FILE`](#persist-environment-variables)에 접근할 수 있습니다. 해당 파일에 기록된 변수는 다음 [CwdChanged](#cwdchanged) 이벤트에서 Claude Code가 지울 때까지 이후의 Bash 명령에 유지됩니다.

<h4 id="filechanged-input">
  FileChanged 입력
</h4>

[공통 입력 필드](#common-input-fields) 외에도 FileChanged 훅은 `file_path`와 `event`를 받습니다.

| 필드 | 설명 |
| :- | :- |
| `file_path` | 변경된 파일의 절대 경로 |
| `event` | 발생한 일: 수정된 파일은 `"change"`, 생성된 파일은 `"add"`, 삭제된 파일은 `"unlink"` |

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../transcript.jsonl",
  "cwd": "/Users/my-project",
  "hook_event_name": "FileChanged",
  "file_path": "/Users/my-project/.envrc",
  "event": "change"
}
```

<h4 id="filechanged-output">
  FileChanged 출력
</h4>

모든 훅에서 사용할 수 있는 [JSON 출력 필드](#json-output) 외에도 FileChanged 훅은 감시할 파일 경로를 동적으로 업데이트하기 위해 `watchPaths`를 반환할 수 있습니다.

| 필드 | 설명 |
| :- | :- |
| `watchPaths` | 절대 경로의 배열. 현재 동적 감시 목록을 대체합니다. `matcher` 구성의 경로는 항상 감시됩니다. 훅 스크립트가 변경된 파일을 기반으로 감시할 추가 파일을 발견할 때 사용합니다 |

FileChanged 훅에는 결정 제어가 없습니다. 파일 변경이 발생하는 것을 차단할 수 없습니다.

Claude Code는 JSON 출력에서 `watchPaths`와 `systemMessage`를 읽고 `continue`는 폐기합니다. 대화형 세션에서는 `systemMessage`를 짧은 터미널 알림으로 표시합니다. 이 메시지는 SDK 메시지 스트림에 도달하지 않습니다.

<h3 id="worktreecreate">
  WorktreeCreate
</h3>

`claude --worktree`, [`isolation: "worktree"`를 사용하는 서브에이전트](/docs/ko/sub-agents#choose-the-subagent-scope), 또는 Claude Code가 자체 worktree에 격리하는 [백그라운드 세션](/docs/ko/agent-view#how-file-edits-are-isolated) 등 worktree가 생성될 때 실행됩니다. 기본적으로 Claude Code는 `git worktree`로 격리된 작업 사본을 만듭니다. WorktreeCreate 훅을 구성하면 이 기본 git 동작을 대체하므로 SVN, Perforce, Mercurial과 같은 다른 버전 관리 시스템을 사용할 수 있습니다.

훅이 기본 동작을 완전히 대체하므로 [`.worktreeinclude`](/docs/ko/worktrees#copy-gitignored-files-into-worktrees)는 처리되지 않습니다. `.env`와 같은 로컬 설정 파일을 새 워크트리로 복사해야 한다면 훅 스크립트 안에서 복사하십시오.

훅은 생성된 worktree 디렉터리의 경로를 반환해야 합니다. Claude Code는 이 경로를 격리된 세션의 작업 디렉터리로 사용합니다. 각 훅 유형이 경로를 반환하는 방법은 [WorktreeCreate 출력](#worktreecreate-output)을 참조하십시오.

Claude Code는 훅의 성공 여부와 반환된 경로에 따라 동작하며, `systemMessage`와 `continue`는 버립니다.

다음 예시는 SVN 작업 사본을 만들고 Claude Code가 사용할 경로를 출력합니다. 저장소 URL을 사용자의 URL로 바꾸십시오.

```json theme={null}
{
  "hooks": {
    "WorktreeCreate": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'NAME=$(jq -r .name); DIR=\"$HOME/.claude/worktrees/$NAME\"; svn checkout https://svn.example.com/repo/trunk \"$DIR\" >&2 && echo \"$DIR\"'"
          }
        ]
      }
    ]
  }
}
```

이 훅은 stdin의 JSON 입력에서 worktree `name`을 읽고, 새 디렉터리에 새 사본을 체크아웃한 다음 디렉터리 경로를 출력합니다. 마지막 줄의 `echo`가 Claude Code가 worktree 경로로 읽는 부분입니다. 경로와 충돌하지 않도록 다른 출력은 모두 stderr로 리디렉션하십시오.

<h4 id="worktreecreate-input">
  WorktreeCreate input
</h4>

[공통 입력 필드](#common-input-fields)에 더해 WorktreeCreate 훅은 `name` 필드를 받습니다. 이는 사용자가 지정했거나 자동 생성된 새 worktree의 슬러그 식별자이며, 예를 들면 `bold-oak-a3f2`와 같습니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "WorktreeCreate",
  "name": "feature-auth"
}
```

<h4 id="worktreecreate-output">
  WorktreeCreate output
</h4>

WorktreeCreate 훅은 표준 허용/차단 결정 모델을 사용하지 않습니다. 대신 훅의 성공 또는 실패가 결과를 결정합니다. 훅은 생성된 worktree 디렉터리의 경로를 반환해야 합니다.

* **명령 훅** (`type: "command"`): stdout의 비어 있지 않은 마지막 줄에 경로를 출력합니다. Claude Code는 해당 줄을 읽기 전에 ANSI 이스케이프 코드를 제거하므로 `echo` 전에 출력되는 셸 시작 배너는 무시됩니다. 훅의 다른 출력은 모두 stderr로 리디렉션하십시오.
* **HTTP 훅** (`type: "http"`): 응답 본문에 `{ "hookSpecificOutput": { "hookEventName": "WorktreeCreate", "worktreePath": "/absolute/path" } }`를 반환합니다.

훅이 실패하거나 경로를 생성하지 않으면 worktree 생성이 오류와 함께 실패합니다.

Claude Code는 상대 경로를 훅이 실행된 디렉터리를 기준으로 해석하며, 경로 안의 `.` 또는 `..` 세그먼트를 정리합니다. 결과 경로가 Claude Code가 들어갈 수 있는 디렉터리가 아니면 세션은 해당 경로를 명시한 오류를 출력하고 코드 1로 종료됩니다.

Claude Code는 `.` 또는 `..` 세그먼트가 포함된 절대 경로와 저장소 루트 아래의 심볼릭 링크를 거치는 모든 경로를 거부합니다. 저장소에 커밋된 심볼릭 링크가 worktree를 저장소 외부로 리디렉션할 수 있기 때문입니다. 오류 메시지에는 거부된 구성 요소가 표시됩니다. 저장소 내부의 심볼릭 링크를 거치지 않는 정규화된 경로를 반환하십시오. v2.1.216 이전에는 worktree 생성 시 이러한 검사 없이 훅의 경로를 그대로 따랐습니다.

<h3 id="worktreeremove">
  WorktreeRemove
</h3>

Claude Code가 [`WorktreeCreate`](#worktreecreate) 훅으로 생성된 worktree를 정리할 때 실행됩니다. 이 이벤트는 다음과 같은 경우에 발생합니다.

* 대화형 [worktree 세션](/docs/ko/worktrees#start-claude-in-a-worktree)을 종료하고 Claude Code가 확인을 요청할 때 worktree 제거를 선택하는 경우
* [이름을 지정](/docs/ko/sessions#name-your-sessions)하지 않은 대화형 worktree 세션을 종료하고, Claude Code가 변경되거나 추적되지 않는 파일을 찾지 못해 묻지 않고 worktree를 제거하는 경우
* worktree에서 실행되는 [백그라운드 세션](/docs/ko/agent-view#what-deleting-a-session-removes)을 삭제하는 경우

Claude Code는 git을 사용해 변경되거나 추적되지 않는 파일을 찾으므로, git 체크아웃이 아니거나 git 체크아웃 내부에 있지 않은 worktree에서는 디렉터리에 커밋되지 않은 작업이 있더라도 아무것도 찾지 못합니다. WorktreeRemove 훅에서 무언가를 삭제하기 전에 그러한 작업이 있는지 확인하십시오.

git 기반 worktree의 경우 Claude Code는 `git worktree remove`로 정리를 자동 처리합니다. WorktreeCreate 훅을 구성했다면 WorktreeRemove 훅과 함께 사용하여 해당 훅이 생성한 워크트리의 정리를 제어하십시오.

* **WorktreeRemove 훅이 없는 경우**: worktree 세션을 종료하면서 Claude Code가 worktree를 제거할 때, WorktreeCreate 훅이 반환한 경로에 대해 `git worktree remove --force`로 폴백하므로 git이 인식하는 worktree는 제거됩니다. git이 인식하지 못하는 worktree, 예를 들어 훅이 git이 아닌 버전 관리 시스템으로 생성한 worktree는 디스크에 남습니다. [백그라운드 세션](/docs/ko/agent-view#what-deleting-a-session-removes)을 삭제할 때 훅으로 생성된 worktree가 어떻게 처리되는지는 에이전트 뷰의 삭제 규칙을 참조하십시오.
* **훅이 0으로 종료되는 경우**: worktree가 제거된 것으로 간주됩니다. Claude Code는 훅에서 다른 내용을 읽지 않으므로 훅이 디렉터리를 삭제했는지 확인하십시오.
* **훅이 0이 아닌 코드로 종료되는 경우**: 이후에도 `worktree_path`의 디렉터리가 여전히 존재하면 제거가 실패하고, git 폴백 없이 worktree가 디스크에 남습니다. 0이 아닌 코드로 종료하기 전에 디렉터리를 삭제한 훅은 제거된 것으로 간주됩니다. 실패가 보고되는 방식은 [WorktreeRemove 입력](#worktreeremove-input)을 참조하십시오.

Claude Code는 WorktreeCreate 훅이 반환한 경로만 알고 있으므로 훅으로 생성된 worktree에 속한 브랜치를 삭제하지 않습니다. WorktreeCreate 훅이 브랜치를 생성한다면 WorktreeRemove 훅에서 삭제하십시오.

Claude Code는 WorktreeRemove 훅의 `systemMessage`, `continue` 등 [JSON 출력 필드](#json-output)를 버립니다.

백그라운드 세션 삭제의 경우 Claude Code는 훅을 실행하기 전에 저장된 worktree 경로를 검증하며, 심볼릭 링크이거나 저장소 루트 아래의 심볼릭 링크를 거치는 경로를 거부합니다. 여전히 파일이 포함된 worktree에 대해서는 [에이전트 뷰](/docs/ko/agent-view#what-deleting-a-session-removes)에서 삭제를 확인한 경우에만 훅이 실행되며, 이러한 worktree에 대해 [`claude rm`](/docs/ko/agent-view#manage-sessions-from-the-shell)은 대신 세션과 worktree를 유지합니다. v2.1.216 이전에는 이러한 검사 없이 저장된 경로에 대해 훅이 실행되었습니다.

Claude Code는 WorktreeCreate가 반환한 경로를 훅 입력의 `worktree_path`로 전달합니다. 다음 예시는 해당 경로를 읽고 디렉터리를 제거합니다.

```json theme={null}
{
  "hooks": {
    "WorktreeRemove": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'jq -r .worktree_path | xargs rm -rf'"
          }
        ]
      }
    ]
  }
}
```

<h4 id="worktreeremove-input">
  WorktreeRemove input
</h4>

[공통 입력 필드](#common-input-fields)에 더해 WorktreeRemove 훅은 제거되는 worktree의 절대 경로인 `worktree_path` 필드를 받습니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "WorktreeRemove",
  "worktree_path": "/Users/.../my-project/.claude/worktrees/feature-auth"
}
```

WorktreeRemove 훅의 종료 코드가 결과를 결정합니다. 훅이 0이 아닌 코드로 종료되고 이후에도 `worktree_path`의 디렉터리가 여전히 존재하면 제거가 실패합니다.

* worktree는 디스크에 남고, 훅의 명령과 stderr는 [디버그 로그](#debug-hooks)에 기록됩니다.
* 백그라운드 세션을 삭제하던 중이었다면 세션도 유지됩니다. [에이전트 뷰](/docs/ko/agent-view#what-deleting-a-session-removes)의 거부 메시지는 `exited 1`과 같이 훅이 어떻게 종료되었는지 보고하고, stderr의 앞부분을 인용하며, 세션을 다시 삭제하면 디렉터리가 어쨌든 제거되는지 여부를 알려 줍니다.

<h3 id="precompact">
  PreCompact
</h3>

Claude Code가 압축 작업을 실행하기 직전에 실행됩니다.

matcher 값은 압축이 수동으로 트리거되었는지 자동으로 트리거되었는지를 나타냅니다.

| Matcher | 실행 시점 |
| :- | :- |
| `manual` | `/compact` |
| `auto` | 대화가 [자동 압축 윈도우](/docs/ko/model-config#set-the-auto-compact-window)에 도달했을 때의 자동 압축 |

압축을 차단하려면 코드 2로 종료하십시오. 수동 `/compact`의 경우 stderr 메시지가 사용자에게 표시됩니다. `"decision": "block"`이 포함된 JSON을 반환하여 차단할 수도 있습니다.

자동 압축을 차단하면 실행 시점에 따라 효과가 다릅니다. 컨텍스트 한도에 도달하기 전에 압축이 선제적으로 트리거된 경우 Claude Code는 압축을 건너뛰고 압축되지 않은 상태로 대화를 계속합니다. API가 이미 반환한 컨텍스트 한도 오류에서 복구하기 위해 압축이 트리거된 경우에는 원래 오류가 표시되고 현재 요청이 실패합니다.

Claude Code는 PreCompact 훅의 `systemMessage` 및 `continue` 필드를 버립니다.

<h4 id="precompact-input">
  PreCompact input
</h4>

[공통 입력 필드](#common-input-fields)에 더해 PreCompact 훅은 `trigger`와 `custom_instructions`를 받습니다. `manual`의 경우 `custom_instructions`에는 사용자가 `/compact`에 전달한 내용이 포함되며, 아무것도 전달하지 않으면 `null`입니다. `auto`의 경우 `custom_instructions`는 `null`입니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "PreCompact",
  "trigger": "manual",
  "custom_instructions": null
}
```

<h3 id="postcompact">
  PostCompact
</h3>

Claude Code가 압축 작업을 완료한 후 실행됩니다. 이 이벤트를 사용하면 새로 압축된 상태에 대응할 수 있습니다. 예를 들어 생성된 요약을 로그에 기록하거나 외부 상태를 업데이트할 수 있습니다. Claude Code는 PostCompact 훅의 `systemMessage` 및 `continue` 필드를 버립니다.

`PreCompact`와 동일한 matcher 값이 적용됩니다.

| Matcher | 실행 시점 |
| :- | :- |
| `manual` | `/compact` 이후 |
| `auto` | 대화가 [자동 압축 윈도우](/docs/ko/model-config#set-the-auto-compact-window)에 도달하여 자동 압축된 이후 |

<h4 id="postcompact-input">
  PostCompact input
</h4>

[공통 입력 필드](#common-input-fields)에 더해 PostCompact 훅은 `trigger`와 `compact_summary`를 받습니다. `compact_summary` 필드에는 압축 작업으로 생성된 대화 요약이 포함됩니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "PostCompact",
  "trigger": "manual",
  "compact_summary": "Summary of the compacted conversation..."
}
```

PostCompact 훅에는 결정 제어 기능이 없습니다. 압축 결과에 영향을 줄 수는 없지만 후속 작업을 수행할 수 있습니다.

<h3 id="premodelswitch">
  PreModelSwitch
</h3>

사용자나 클라이언트가 요청한 모델 전환을 Claude Code가 적용하기 전에 실행됩니다. 전환을 차단하거나, 확인을 요구하거나, 전환이 일어나기 전에 전환 비용을 보여 주는 데 사용할 수 있습니다.

PreModelSwitch를 사용하려면 Claude Code v2.1.251 이상이 필요합니다. Claude Code는 다음 요청에 대해 이 훅을 실행합니다.

* `/model <name>` 및 `/model` 선택기
* `Option+P` 또는 `Alt+P` 모델 선택기
* `/config`의 Model 설정
* 세션의 모델을 변경하는 경우의 [빠른 모드](/docs/ko/fast-mode) 켜기
* [Agent SDK](/docs/ko/agent-sdk/typescript#query-object) 호스트 또는 [Remote Control](/docs/ko/remote-control)에서 보낸 `set_model` 요청 또는 `apply_flag_settings` 요청의 모델 변경

Claude Code는 [자동 모델 폴백](/docs/ko/model-config#automatic-model-fallback)이나 세션 재개 시 모델 복원처럼 자체적으로 수행하는 전환에 대해서는 PreModelSwitch 훅을 실행하지 않습니다. 이러한 변경은 [PostModelSwitch](#postmodelswitch)에만 전달됩니다.

Claude Code는 `[1m]` 접미사를 무시하고, 세션이 전환하려는 모델의 정식 이름과 matcher를 비교합니다. `opus`와 같은 별칭, 날짜가 포함된 모델 ID, Amazon Bedrock 모델 ID와 같은 공급자별 ID는 모두 해석되는 하나의 정식 이름과 일치하므로 `claude-opus-5`는 Opus 5의 모든 표기를 포괄합니다.

예를 들어 사용자의 [LLM 게이트웨이](/docs/ko/llm-gateway)만 알고 있는 사용자 지정 모델 ID처럼 Claude Code가 대상의 정식 이름을 확인할 수 없는 경우, matcher와 관계없이 모든 PreModelSwitch 훅을 실행합니다. 따라서 차단하는 훅은 matcher에만 의존하지 말고 입력의 `to_model`을 확인해야 합니다.

matcher는 정확한 이름, `claude-opus-4-6|claude-opus-5`와 같이 `|`로 구분된 목록, 또는 `.*opus.*`와 같은 정규 표현식으로 작성합니다. 다음 예시는 정확한 이름 matcher를 사용하는 동시에 훅 입력의 `to_model`도 확인하므로, 코드 2로 종료하여 Opus 4.6으로의 전환을 거부하고 다른 대상은 허용합니다.

<Tabs>
  <Tab title="macOS/Linux">
    이 명령은 `jq`로 `to_model`을 확인합니다.

    ```json theme={null}
    {
      "hooks": {
        "PreModelSwitch": [
          {
            "matcher": "claude-opus-4-6",
            "hooks": [
              {
                "type": "command",
                "command": "jq -e '.to_model | test(\"opus-4-6\")' > /dev/null && { echo 'Opus 4.6 is retired for this project. Use a newer model.' >&2; exit 2; }; exit 0"
              }
            ]
          }
        ]
      }
    }
    ```
  </Tab>

  <Tab title="Windows (PowerShell)">
    PowerShell을 통해 스크립트를 실행하는 명령 훅을 등록합니다.

    ```json theme={null}
    {
      "hooks": {
        "PreModelSwitch": [
          {
            "matcher": "claude-opus-4-6",
            "hooks": [
              {
                "type": "command",
                "command": "powershell.exe",
                "args": [
                  "-NoProfile",
                  "-ExecutionPolicy",
                  "Bypass",
                  "-File",
                  "${CLAUDE_PROJECT_DIR}/.claude/hooks/block-opus-46.ps1"
                ]
              }
            ]
          }
        ]
      }
    }
    ```

    이 스크립트를 프로젝트의 `.claude/hooks/block-opus-46.ps1`에 저장합니다.

    ```powershell theme={null}
    $hookInput = [Console]::In.ReadToEnd() | ConvertFrom-Json
    if ($hookInput.to_model -match 'opus-4-6') {
      [Console]::Error.WriteLine('Opus 4.6 is retired for this project. Use a newer model.')
      exit 2
    }
    exit 0
    ```
  </Tab>
</Tabs>

훅이 작동하는지 확인하려면 다른 모델을 실행 중인 세션에서 `/model claude-opus-4-6`을 실행하십시오. Claude Code는 현재 모델을 유지하고, PreModelSwitch 훅이 전환을 차단했다는 사실을 사용자의 메시지를 사유로 하여 보고합니다.

<h4 id="premodelswitch-input">
  PreModelSwitch input
</h4>

[공통 입력 필드](#common-input-fields)에 더해 PreModelSwitch 훅은 이 표의 필드를 받습니다. 마지막 다섯 개 필드는 대화를 새 모델로 다시 보내는 비용을 설명하므로 훅이 전환 전에 해당 수치를 보여 줄 수 있습니다.

| 필드 | 유형 | 설명 |
| :- | :- | :- |
| `from_model` | string | 전환 이전의 모델 ID |
| `to_model` | string | 전환 대상 모델 ID. matcher는 이 모델의 정식 이름과 비교됩니다 |
| `requested_model` | string 또는 `null` | 요청에서 지정한 모델: `opus`와 같은 별칭, 전체 모델 ID, 또는 기본 모델을 요청한 경우 `null` |
| `source` | string | 요청 출처: `/model <name>`, `/config`의 Model 설정, 빠른 모드 켜기는 `"command"`, 모델 선택기는 `"picker"`, Agent SDK 호스트 또는 Remote Control에서 보낸 `set_model` 요청이나 `apply_flag_settings` 요청의 모델 변경은 `"sdk"` |
| `context_tokens` | number | 다음 요청이 프롬프트로 다시 보내는 토큰 수: 메인 대화의 마지막 응답의 입력, 캐시 읽기, 캐시 생성, 출력 토큰을 합한 값. 첫 응답 이전에는 `0` |
| `prompt_cache_warm` | boolean | 현재 모델의 프롬프트 캐시가 아직 유효할 가능성이 높은지 여부. 즉, 전환 시 이를 잃게 됨을 의미합니다 |
| `cache_ttl` | string | Claude Code가 이 세션에 요청하는 [프롬프트 캐시 수명](/docs/ko/prompt-caching#cache-lifetime): `"5m"` 또는 `"1h"` |
| `estimated_cache_write_usd` | number | `cache_ttl` 요율로 `to_model`의 프롬프트 캐시에 `context_tokens`를 쓰는 추정 비용(미국 달러), 다음 응답은 제외. 서버가 전체 컨텍스트를 다시 캐시할 필요가 없을 수도 있으므로 추정치로 취급하십시오 |
| `pricing` | string | Claude Code가 `estimated_cache_write_usd`를 산정한 방식: 조직이 자체 요율을 구성한 경우 해당 요율로 산정한 `"configured"`, 정가로 산정한 `"catalog"`, 또는 `to_model`의 가격을 알 수 없어 Claude Code가 기본 요율을 가정한 `"default"` |

다음 예시는 Sonnet 5를 실행 중인 세션에서 `/model opus`를 실행했을 때의 입력을 보여 줍니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "PreModelSwitch",
  "from_model": "claude-sonnet-5",
  "to_model": "claude-opus-5",
  "requested_model": "opus",
  "source": "command",
  "context_tokens": 182340,
  "prompt_cache_warm": true,
  "cache_ttl": "5m",
  "estimated_cache_write_usd": 1.1396,
  "pricing": "catalog"
}
```

<h4 id="premodelswitch-decision-control">
  PreModelSwitch decision control
</h4>

`PreModelSwitch` 훅은 전환을 취소하거나, 사용자에게 확인을 요청하거나, 진행하도록 허용할 수 있습니다. 종료 코드 2 또는 최상위 `decision: "block"`은 전환을 취소합니다.

더 세밀하게 제어하려면 [PreToolUse](#pretooluse-decision-control)에서와 같이 `hookSpecificOutput` 객체에 `permissionDecision`과 `permissionDecisionReason`을 반환하십시오. `PreModelSwitch`는 `"allow"`, `"deny"`, `"ask"`를 허용합니다. `"defer"`, `updatedInput`, `additionalContext`는 허용하지 않습니다. 아래 표는 두 필드를 설명합니다.

| 필드 | 설명 |
| :- | :- |
| `permissionDecision` | `"allow"`는 전환을 진행하며 [프롬프트 캐시가 유효한 동안 Claude Code가 표시하는 확인](/docs/ko/prompt-caching#switching-models)을 건너뜁니다. `"deny"`는 전환을 취소합니다. `"ask"`는 사용자에게 확인을 요청합니다 |
| `permissionDecisionReason` | `"deny"`의 경우 전환이 차단된 사유로 사용자에게 표시되거나 `set_model` 요청에 대한 오류로 반환됩니다. `"ask"`의 경우 확인 프롬프트에 표시됩니다. `"allow"`의 경우 무시됩니다 |

대화형 세션의 `/model`만 `"ask"` 프롬프트를 표시할 수 있습니다. `-p` 플래그를 사용하는 비대화형 모드, `/config`, `set_model` 요청을 포함한 다른 모든 사용 환경에서 Claude Code는 `"ask"`를 거부로 처리합니다.

다음 예시는 사용자에게 확인을 요청하며 `context_tokens`의 토큰 수를 인용합니다.

```json theme={null}
{
  "hookSpecificOutput": {
    "hookEventName": "PreModelSwitch",
    "permissionDecision": "ask",
    "permissionDecisionReason": "Switching now re-sends about 180k tokens to the new model. Continue?"
  }
}
```

여러 PreModelSwitch 훅이 서로 다른 결정을 반환하면 우선순위는 `deny` > `ask` > `allow`입니다.

Claude Code는 결정과 관계없이 훅이 반환한 `systemMessage`를 사용자에게 표시하므로, 비용 보고 훅은 `{"systemMessage": "..."}`를 반환하고 0으로 종료할 수 있습니다.

타임아웃 전에 응답하지 않는 PreModelSwitch 훅은 전환을 차단합니다. 다른 이벤트에서 타임아웃이 미치는 영향은 [Timeouts](#timeouts)를 참조하십시오. 이 이벤트의 기본 타임아웃은 30초입니다. `PreModelSwitch`는 `command`, `http`, `mcp_tool` 훅만 실행하므로 `prompt` 및 `agent` 기본값은 적용되지 않습니다.

0 또는 2가 아닌 코드로 종료하고 JSON 결정을 출력하지 않는 훅은 [기타 종료 코드](#other-exit-codes)에 설명된 대로 차단하지 않는 오류입니다.

<h3 id="postmodelswitch">
  PostModelSwitch
</h3>

세션의 모델이 변경된 후 실행됩니다. 모든 CLAUDE.md를 편집하지 않고도 Claude에게 모델별 지침을 제공하는 데 사용할 수 있습니다. 예를 들어 특정 모델에 적용되는 조직 전체 지침을 제공할 수 있습니다.

PostModelSwitch를 사용하려면 Claude Code v2.1.251 이상이 필요합니다. 모델이 이미 변경되었으므로 차단할 수 없습니다. Claude Code는 다음 변경 후에 PostModelSwitch 훅을 실행합니다.

* 사용자나 클라이언트가 요청한 전환
* 세션의 모델을 변경하는 [자동 모델 폴백](/docs/ko/model-config#automatic-model-fallback)
* [`opusplan`](/docs/ko/model-config#opusplan-model-setting)과 같은 설정이 플랜 모드에 들어가거나 나가는 경우
* 세션을 재개할 때 Claude Code가 모델을 복원하는 경우

[폴백 모델 체인](/docs/ko/model-config#fallback-model-chains)의 모델이 턴을 처리하는 경우에는 Claude Code가 PostModelSwitch 훅을 실행하지 않습니다. 이 대체는 한 턴 동안만 지속되며 세션의 모델을 변경하지 않기 때문입니다.

matcher는 [PreModelSwitch](#premodelswitch)와 동일한 규칙을 따릅니다. Claude Code는 세션이 전환한 모델의 정식 이름과 matcher를 비교합니다.

다음 예시는 세션의 모델이 Opus 모델로 변경될 때마다 지침을 추가합니다.

```json theme={null}
{
  "hooks": {
    "PostModelSwitch": [
      {
        "matcher": ".*opus.*",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'On Opus, delegate implementation work to subagents and keep this conversation for planning and review.'"
          }
        ]
      }
    ]
  }
}
```

훅이 작동하는지 확인하려면 다른 모델을 실행 중인 세션에서 Opus 모델로 전환한 다음(예: Sonnet 세션에서 `/model opus` 실행), Claude에게 현재 모델에 관해 어떤 지침을 갖고 있는지 물어보십시오.

<h4 id="postmodelswitch-input">
  PostModelSwitch input
</h4>

PostModelSwitch 훅은 [PreModelSwitch](#premodelswitch-input)와 동일한 필드를 받으며, `hook_event_name`은 `"PostModelSwitch"`로 설정되고 `source` 값이 두 가지 더 있습니다. 자동 폴백이나 Claude Code가 자체적으로 수행한 기타 변경의 경우 `"auto"`, 세션을 재개할 때 복원된 모델의 경우 `"resume"`입니다.

`source`가 `"auto"`이면 `requested_model`은 `null`입니다. `source`가 `"resume"`이면 Claude Code가 복원한 저장된 모델 설정입니다.

<h4 id="postmodelswitch-decision-control">
  PostModelSwitch decision control
</h4>

Claude Code는 종료 코드 0일 때 훅의 [일반 텍스트 stdout](#exit-code-0) 또는 JSON 출력의 `additionalContext`를 가져와 전환 후 다음 요청과 함께 Claude에게 전달합니다. 모든 훅에서 사용할 수 있는 [JSON 출력 필드](#json-output)에 더해 다음을 반환할 수 있습니다.

| 필드 | 설명 |
| :- | :- |
| `additionalContext` | 다음 요청과 함께 Claude의 컨텍스트에 추가되는 문자열. [Claude에 컨텍스트 추가](#add-context-for-claude)를 참조하십시오 |

다음 프롬프트를 보낸 후 5초 이내에 훅이 완료되지 않으면 Claude Code는 출력 없이 해당 요청을 보내고 대신 그다음 요청에 출력을 첨부합니다. 다음 요청 전에 모델이 여러 번 변경되면 Claude Code는 마지막 전환의 대상 모델에 대한 출력만 전달합니다.

<h3 id="sessionend">
  SessionEnd
</h3>

Claude Code 세션이 종료될 때 실행됩니다. 정리 작업, 세션
통계 로깅, 세션 상태 저장에 유용합니다. 종료 사유로 필터링하는 matcher를 지원합니다.

훅 입력의 `reason` 필드는 세션이 종료된 이유를 나타냅니다.

| 사유 | 설명 |
| :- | :- |
| `clear` | `/clear` 명령으로 세션이 지워짐 |
| `resume` | 대화형 `/resume`을 통해 세션이 전환됨 |
| `logout` | 사용자가 로그아웃함 |
| `prompt_input_exit` | 프롬프트 입력이 표시된 상태에서 사용자가 종료함 |
| `other` | 기타 종료 사유 |
| `bypass_permissions_disabled` | v2.1.234에서 제거되었으며 Claude Code는 이를 보내지 않습니다. `SessionEnd` matcher에서 제거하십시오 |

<h4 id="sessionend-input">
  SessionEnd input
</h4>

[공통 입력 필드](#common-input-fields)에 더해 SessionEnd 훅은 세션이 종료된 이유를 나타내는 `reason` 필드를 받습니다. 모든 값은 위의 [사유 표](#sessionend)를 참조하십시오.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "SessionEnd",
  "reason": "other"
}
```

SessionEnd 훅에는 결정 제어 기능이 없습니다. 세션 종료를 차단할 수는 없지만 정리 작업을 수행할 수 있습니다. Claude Code는 `systemMessage` 등 해당 훅의 [JSON 출력 필드](#json-output)를 버립니다.

SessionEnd 훅의 기본 타임아웃은 1.5초입니다. 이는 종료하거나, `/clear`를 실행하거나, 대화형 `/resume`으로 세션을 전환할 때 적용됩니다. 훅에 더 많은 시간을 주는 방법은 두 가지입니다.

* **훅별 `timeout`**: 해당 훅의 구성에서 `timeout`을 설정합니다. 전체 예산은 설정 파일에 있는 가장 높은 훅별 `timeout`에 맞춰 최대 60초까지 자동으로 늘어납니다. 이 방법으로 예산을 늘리더라도 자체 `timeout`이 없는 훅은 여전히 기본값을 유지합니다. 플러그인이 제공하는 훅에 설정된 타임아웃은 예산을 늘리지 않습니다.
* **`CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS`**: 이 환경 변수를 밀리초 단위로 설정하여 예산을 명시적으로 재정의합니다. 설정한 값은 자체 `timeout`이 없는 각 훅의 타임아웃이 되기도 합니다.

다음 예시는 예산을 5초로 설정합니다.

```bash theme={null}
CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS=5000 claude
```

v2.1.268 이전에는 `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS`가 전체 예산만 늘렸으며, 자체 `timeout`이 없는 훅은 여전히 1.5초 후에 취소되었습니다.

<h3 id="elicitation">
  Elicitation
</h3>

MCP 서버가 작업 도중 사용자 입력을 요청할 때 실행됩니다. 기본적으로 Claude Code는 사용자가 응답할 수 있는 대화형 대화 상자를 표시합니다. 훅은 이 요청을 가로채 프로그래밍 방식으로 응답하여 대화 상자를 완전히 건너뛸 수 있습니다.

설정 항목과 스크립트를 포함한 완전한 훅은 [스크립트에서 양식 요청에 응답하기](#answer-a-form-request-from-a-script)를 참조하십시오.

matcher 필드는 MCP 서버 이름과 비교됩니다.

<h4 id="elicitation-input">
  Elicitation input
</h4>

[공통 입력 필드](#common-input-fields)에 더해 Elicitation 훅은 `mcp_server_name`, `message`와 선택적 필드인 `mode`, `url`, `elicitation_id`, `requested_schema`를 받습니다.

가장 일반적인 경우인 양식 모드 elicitation의 예는 다음과 같습니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "Elicitation",
  "mcp_server_name": "my-mcp-server",
  "message": "Please provide your credentials",
  "mode": "form",
  "requested_schema": {
    "type": "object",
    "properties": {
      "username": { "type": "string", "title": "Username" }
    }
  }
}
```

브라우저 기반 인증에 사용되는 URL 모드 elicitation의 예는 다음과 같습니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "Elicitation",
  "mcp_server_name": "my-mcp-server",
  "message": "Please authenticate",
  "mode": "url",
  "url": "https://auth.example.com/login"
}
```

<h4 id="elicitation-output">
  Elicitation output
</h4>

Elicitation 훅은 사용자 대신 요청에 응답하거나, 요청을 거절 또는 취소하거나, 대화 상자에 맡길 수 있습니다. 응답, 거절 또는 취소하려면 0으로 종료하고 `action`이 포함된 `hookSpecificOutput` 객체를 출력하십시오. 서버는 응답을 받고 대화 상자는 표시되지 않습니다. 이 표의 각 행은 하나의 결과에 대해 반환할 내용과 MCP 서버가 받는 내용을 보여 줍니다.

| 목적 | 반환 | 서버가 받는 내용 |
| :- | :- | :- |
| 사용자 대신 응답 | `content`에 양식 필드 값을 포함한 `"action": "accept"` | 사용자의 `content`가 포함된 `accept` |
| 요청 거절 | `"action": "decline"` | `decline` |
| 요청 취소 | `"action": "cancel"` | `cancel` |
| 요청을 사용자에게 맡김 | 출력 없음, 종료 코드 0 | [대화 상자](/docs/ko/mcp#respond-to-mcp-elicitation-requests)에서 받은 사용자의 응답 |

다음 출력은 [Elicitation 입력](#elicitation-input)에 표시된 양식 모드 요청에 응답합니다. `content`의 키는 해당 요청의 `requested_schema`에 있는 속성 이름입니다.

```json theme={null}
{
  "hookSpecificOutput": {
    "hookEventName": "Elicitation",
    "action": "accept",
    "content": {
      "username": "alice"
    }
  }
}
```

다음 출력은 요청을 거절합니다.

```json theme={null}
{
  "hookSpecificOutput": {
    "hookEventName": "Elicitation",
    "action": "decline"
  }
}
```

대화 상자에서 **Decline**을 선택하면 `decline`이 전송되고 `Esc`를 누르면 `cancel`이 전송되므로, 서버가 받기를 원하는 값을 반환하십시오.

URL 모드 요청의 경우 `accept`를 반환하는 훅은 대화 상자를 건너뛰므로 URL이 열리지 않습니다.

Claude Code는 반환하는 `action`과 관계없이 Elicitation 훅의 JSON 출력에서 `reason`, `systemMessage`, `continue`를 버립니다.

<h4 id="other-ways-to-decline-an-elicitation">
  Other ways to decline an elicitation
</h4>

훅은 다음과 같은 방법으로도 거절할 수 있습니다. 서버는 `"action": "decline"`의 경우와 동일한 `decline`을 받습니다.

* **코드 2로 종료**: Claude Code는 같은 훅이 출력한 `hookSpecificOutput`을 무시합니다
* **최상위 `"decision": "block"` 출력**: 차단이 같은 출력의 `action`보다 우선합니다

여러 훅이 같은 요청과 일치하는 경우, 그중 하나의 거절이 다른 훅의 `accept` 또는 `cancel`보다 우선합니다.

다음 스크립트는 URL 모드 요청을 거절하고 양식 요청은 대화 상자에 맡깁니다.

```bash theme={null}
#!/bin/bash
if [ "$(jq -r '.mode')" = "url" ]; then
  exit 2
fi
```

Claude Code는 stderr나 `reason`을 표시하지 않으므로 사용자와 서버 모두 훅이 거절한 이유를 알 수 없습니다.

Claude Code는 v2.1.105부터 v2.1.284에서 수정될 때까지 `Elicitation` 및 `ElicitationResult` 훅의 최상위 `decision`을 무시했습니다.

<h4 id="answer-a-form-request-from-a-script">
  Answer a form request from a script
</h4>

다음 예시는 사용자 대신 반복되는 질문 하나에 응답합니다. `issue-tracker`라는 MCP 서버가 양식에서 프로젝트 키를 요청하면 훅이 `DOCS`를 채워 넣습니다. 스크립트는 `project_key`가 양식의 유일한 필드일 때 수락합니다. 다른 요청에는 아무것도 출력하지 않으므로 대화 상자가 표시됩니다.

<Tabs>
  <Tab title="macOS/Linux">
    설정 파일에서 서버 이름을 matcher로 하여 이벤트에 대한 명령 훅을 등록합니다.

    ```json theme={null}
    {
      "hooks": {
        "Elicitation": [
          {
            "matcher": "issue-tracker",
            "hooks": [
              {
                "type": "command",
                "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/answer-project-key.sh",
                "args": []
              }
            ]
          }
        ]
      }
    }
    ```

    이 스크립트를 프로젝트의 `.claude/hooks/answer-project-key.sh`에 저장하고 `chmod +x`로 실행 가능하게 만듭니다.

    ```bash theme={null}
    #!/bin/bash
    input=$(cat)
    fields=$(jq -c '.requested_schema.properties // {} | keys' <<<"$input")

    if [ "$fields" = '["project_key"]' ]; then
      jq -n '{hookSpecificOutput: {hookEventName: "Elicitation", action: "accept", content: {project_key: "DOCS"}}}'
    fi
    ```
  </Tab>

  <Tab title="Windows (PowerShell)">
    서버 이름을 matcher로 하여 PowerShell을 통해 스크립트를 실행하는 명령 훅을 등록합니다.

    ```json theme={null}
    {
      "hooks": {
        "Elicitation": [
          {
            "matcher": "issue-tracker",
            "hooks": [
              {
                "type": "command",
                "command": "powershell.exe",
                "args": [
                  "-NoProfile",
                  "-ExecutionPolicy",
                  "Bypass",
                  "-File",
                  "${CLAUDE_PROJECT_DIR}/.claude/hooks/answer-project-key.ps1"
                ]
              }
            ]
          }
        ]
      }
    }
    ```

    이 스크립트를 프로젝트의 `.claude/hooks/answer-project-key.ps1`에 저장합니다.

    ```powershell theme={null}
    $request = [Console]::In.ReadToEnd() | ConvertFrom-Json
    $fields = @($request.requested_schema.properties.PSObject.Properties.Name)

    if ($fields.Count -eq 1 -and $fields[0] -eq 'project_key') {
      @{
        hookSpecificOutput = @{
          hookEventName = "Elicitation"
          action = "accept"
          content = @{ project_key = "DOCS" }
        }
      } | ConvertTo-Json -Depth 3
    }
    ```
  </Tab>
</Tabs>

훅이 작동하는지 확인하려면 `claude --debug`로 Claude Code를 시작하고, 서버가 프로젝트 키를 요청하게 만드는 작업을 Claude에게 주십시오. 대화 상자가 표시되지 않으며, [디버그 로그](#debug-hooks)에 `Elicitation resolved by hook: {"action":"accept","content":{"project_key":"DOCS"}}`로 끝나는 줄이 기록됩니다.

<h3 id="elicitationresult">
  ElicitationResult
</h3>

사용자가 MCP elicitation에 응답한 후 실행됩니다. 훅은 응답이 MCP 서버로 다시 전송되기 전에 응답을 관찰, 수정 또는 차단할 수 있습니다.

[Elicitation](#elicitation) 훅이 요청에 응답하면 Claude Code는 ElicitationResult 훅을 실행하지 않고 해당 응답을 서버로 보냅니다.

matcher 필드는 MCP 서버 이름과 비교됩니다.

<h4 id="elicitationresult-input">
  ElicitationResult input
</h4>

[공통 입력 필드](#common-input-fields)에 더해 ElicitationResult 훅은 `mcp_server_name`, `action`과 선택적 필드인 `mode`, `elicitation_id`, `content`를 받습니다.

```json theme={null}
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "ElicitationResult",
  "mcp_server_name": "my-mcp-server",
  "action": "accept",
  "content": { "username": "alice" },
  "mode": "form"
}
```

<h4 id="elicitationresult-output">
  ElicitationResult output
</h4>

ElicitationResult 훅은 사용자의 응답을 그대로 통과시키거나, 값을 변경하거나, 차단할 수 있습니다. 응답을 변경하거나 차단하려면 0으로 종료하고 `action`이 포함된 `hookSpecificOutput` 객체를 출력하십시오. 이 표의 각 행은 하나의 결과에 대해 반환할 내용과 MCP 서버가 받는 내용을 보여 줍니다.

| 목적 | 반환 | 서버가 받는 내용 |
| :- | :- | :- |
| 응답 통과 | 출력 없음, 종료 코드 0 | 변경되지 않은 사용자의 응답 |
| 제출된 값 변경 | `content`에 새 값을 포함한 `"action": "accept"` | 사용자의 값 대신 훅의 `content`가 포함된 `accept` |
| 응답 차단 | `"action": "decline"` | 사용자의 값이 없는 `decline` |
| 요청 취소 | `"action": "cancel"` | 사용자가 제출한 값과 함께 `cancel`. 값을 보내지 않으려면 `"decline"`을 반환하십시오 |

다음 출력은 [ElicitationResult 입력](#elicitationresult-input)에 표시된 응답을 변경하므로, 사용자가 `alice`를 제출한 자리에 서버는 `alice@example.com`을 받습니다.

```json theme={null}
{
  "hookSpecificOutput": {
    "hookEventName": "ElicitationResult",
    "action": "accept",
    "content": {
      "username": "alice@example.com"
    }
  }
}
```

훅의 `content`는 사용자의 `content` 객체 전체를 대체하므로 변경하지 않는 필드도 포함하십시오. Claude Code는 `action`이 없는 `hookSpecificOutput`을 무시하므로 `action`도 함께 반환하십시오.

ElicitationResult 훅은 사용자가 거절하거나 취소할 때도 실행되며, 훅의 `action`이 사용자의 것을 대체합니다. `accept`를 반환하기 전에 입력의 `action`이 `accept`인지 확인하십시오. 그렇지 않으면 훅이 거절된 요청을 수락된 요청으로 바꾸게 됩니다. 다음 스크립트는 사용자가 수락한 경우 동일한 변경을 수행하고 다른 필드를 유지하며, 그 외의 경우에는 아무것도 출력하지 않습니다.

```bash theme={null}
#!/bin/bash
input=$(cat)

if [ "$(jq -r '.action' <<<"$input")" = "accept" ]; then
  jq '{hookSpecificOutput: {hookEventName: "ElicitationResult", action: "accept", content: (.content + {username: (.content.username + "@example.com")})}}' <<<"$input"
fi
```

다음 출력은 응답을 차단합니다.

```json theme={null}
{
  "hookSpecificOutput": {
    "hookEventName": "ElicitationResult",
    "action": "decline"
  }
}
```

종료 코드 2와 최상위 `"decision": "block"`도 응답을 차단합니다. 훅이 이들을 함께 사용할 때 어느 것이 적용되는지, 사용자에게 무엇이 표시되는지, 어떤 버전이 `decision`을 무시했는지는 [elicitation을 거절하는 다른 방법](#other-ways-to-decline-an-elicitation)에서 다룹니다.

Claude Code는 반환하는 `action`과 관계없이 ElicitationResult 훅의 JSON 출력에서 `reason`, `systemMessage`, `continue`를 버립니다.

<h2 id="prompt-based-hooks">
  프롬프트 기반 훅
</h2>

명령, HTTP, MCP 도구 훅 외에도 Claude Code는 LLM을 사용해 작업을 허용할지 차단할지 평가하는 프롬프트 기반 훅(`type: "prompt"`)과 도구 접근 권한을 가진 에이전트형 검증자를 생성하는 에이전트 훅(`type: "agent"`)을 지원합니다. 모든 이벤트가 모든 훅 유형을 지원하지는 않습니다.

다섯 가지 훅 유형(`command`, `http`, `mcp_tool`, `prompt`, `agent`)을 모두 지원하는 이벤트:

* `PermissionDenied`
* `PostToolBatch`
* `PostToolUse`
* `PostToolUseFailure`
* `PreToolUse`
* `Stop`
* `SubagentStop`
* `TaskCompleted`
* `TaskCreated`
* `TeammateIdle`
* `UserPromptExpansion`
* `UserPromptSubmit`

`PermissionRequest`는 `command`, `http`, `mcp_tool`, `prompt` 훅을 지원하지만 `agent` 훅은 지원하지 않습니다. 이 이벤트에 에이전트 훅을 구성하면 Claude Code는 이를 건너뛰고 권한 흐름은 변경 없이 진행됩니다. 훅에서 허용하거나 거부하려면 명령 또는 HTTP 훅에서 [결정 객체](#permissionrequest-decision-control)를 반환하십시오.

`command`, `http`, `mcp_tool` 훅은 지원하지만 `prompt`나 `agent`는 지원하지 않는 이벤트:

* `ConfigChange`
* `CwdChanged`
* `DirectoryAdded`
* `Elicitation`
* `ElicitationResult`
* `FileChanged`
* `InstructionsLoaded`
* `MessageDisplay`
* `Notification`
* `PostCompact`
* `PostModelSwitch`
* `PreCompact`
* `PreModelSwitch`
* `SessionEnd`
* `StopFailure`
* `SubagentStart`
* `WorktreeCreate`
* `WorktreeRemove`

`SessionStart`와 `Setup`은 `command` 및 `mcp_tool` 훅을 지원하며, 이들의 `mcp_tool` 훅이 언제 실행되는지는 [MCP 도구 훅 필드](#mcp-tool-hook-fields)에서 설명합니다. 이 이벤트들은 `http`, `prompt`, `agent` 훅을 지원하지 않습니다.

<h3 id="how-prompt-based-hooks-work">
  프롬프트 기반 훅의 작동 방식
</h3>

프롬프트 기반 훅은 Bash 명령을 실행하는 대신 다음과 같이 작동합니다.

1. 훅 입력과 프롬프트를 Claude 모델로 전송합니다. 기본적으로 Claude Code가 [백그라운드 기능](/docs/ko/costs#background-token-usage)에 사용하는 모델이 사용됩니다
2. LLM이 결정을 담은 구조화된 JSON으로 응답합니다
3. Claude Code가 결정을 자동으로 처리합니다

<h3 id="prompt-hook-configuration">
  프롬프트 훅 구성
</h3>

`type`을 `"prompt"`로 설정하고 `command` 대신 `prompt` 문자열을 제공합니다. `$ARGUMENTS` 플레이스홀더를 사용하여 훅의 JSON 입력 데이터를 프롬프트 텍스트에 삽입합니다.

프롬프트 훅이나 [에이전트 훅](#agent-based-hooks)에서는 `prompt`를 "`.env` 파일을 읽는 모든 Bash 명령을 차단"처럼 무엇을 차단하거나 허용할지에 대한 규칙으로 작성하거나, "모든 단위 테스트 통과"처럼 충족되어야 하는 조건으로 작성할 수 있습니다.

이 `Stop` 훅은 Claude가 작업을 마치도록 허용하기 전에 모든 작업이 완료되었는지 LLM에 평가를 요청합니다.

```json theme={null}
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Evaluate if Claude should stop: $ARGUMENTS. Check if all tasks are complete."
          }
        ]
      }
    ]
  }
}
```

| 필드 | 필수 | 설명 |
| :- | :- | :- |
| `type` | 예 | 반드시 `"prompt"`여야 합니다 |
| `prompt` | 예 | LLM에 전송할 프롬프트 텍스트입니다. 훅 입력 JSON의 플레이스홀더로 `$ARGUMENTS`를 사용합니다. `$ARGUMENTS`가 없으면 입력 JSON이 프롬프트 끝에 추가됩니다 |
| `model` | 아니요 | 평가에 사용할 모델입니다. 기본값은 Claude Code가 [백그라운드 기능](/docs/ko/costs#background-token-usage)에 사용하는 모델입니다 |
| `timeout` | 아니요 | 초 단위 타임아웃입니다. 기본값: 30 |
| `continueOnBlock` | 아니요 | 적용되는 이벤트에서 `true`로 설정하면 턴을 종료하는 대신 `ok: false` 사유를 Claude에 다시 전달하고 계속 진행합니다. 기본값: `false`. 이벤트별 동작은 [응답 스키마](#response-schema)를 참조하십시오 |

<h3 id="response-schema">
  응답 스키마
</h3>

LLM은 다음을 포함하는 JSON으로 응답해야 합니다.

```json theme={null}
{
  "ok": true | false,
  "reason": "Explanation for the decision",
  "impossible": true | false
}
```

| 필드 | 설명 |
| :- | :- |
| `ok` | 허용하려면 `true`입니다. `false`인 경우 아래의 이벤트별 동작을 참조하십시오 |
| `reason` | `ok`가 `false`일 때 필수입니다 |
| `impossible` | 선택 사항입니다. 모델은 조건이 절대 충족될 수 없다고 판단하면 `ok: false`와 함께 이 값을 반환합니다. `Stop` 및 `SubagentStop`에서는 이 경우 Claude Code가 사유를 다시 전달하는 대신 턴이 종료되도록 합니다. 에이전트 훅과 다른 이벤트는 이 값을 무시합니다 |

`ok: false`일 때 발생하는 동작은 이벤트에 따라 다릅니다.

* `Stop` 및 `SubagentStop`: 사유가 Claude의 다음 지시로 다시 전달되고 턴이 계속됩니다. 단, 응답에서 `impossible: true`도 함께 설정한 경우에는 Claude Code가 중지를 허용하고 턴이 종료됩니다
* `PreToolUse`: 도구 호출이 거부됩니다. 기본적으로 턴이 종료되고 거부 사유가 채팅에 경고 줄로 표시됩니다. 대신 사유를 도구 오류로 Claude에 반환하여 Claude가 조정하고 계속 진행할 수 있게 하려면 `continueOnBlock: true`를 설정하십시오. 이는 명령 훅의 `permissionDecision: "deny"`와 동일합니다. v2.1.210 이전에는 거부 사유가 도구 오류로 Claude에 반환되고 턴이 계속되었습니다
* `PostToolUse`: 기본적으로 턴이 종료되고 사유가 채팅에 경고 줄로 표시됩니다. 대신 사유를 Claude에 다시 전달하고 턴을 계속하려면 `continueOnBlock: true`를 설정하십시오
* `PostToolBatch`, `UserPromptSubmit`, `UserPromptExpansion`: 턴이 종료되고 사유가 경고 줄로 표시됩니다. 이 이벤트들은 `continue`와 관계없이 `decision: "block"`에서 턴을 종료합니다
* `PostToolUseFailure` 및 `TaskCreated`: `continueOnBlock`과 관계없이 사유가 도구 오류로 Claude에 반환되고 턴이 계속됩니다
* `TaskCompleted`: 턴 중에 작업이 완료로 표시되어 실행된 경우, `continueOnBlock`과 관계없이 사유가 도구 오류로 Claude에 반환되고 턴이 계속됩니다. 팀원이 중지하여 실행된 경우에는 `TeammateIdle`처럼 동작하며 기본적으로 팀원을 중단시킵니다
* `TeammateIdle`: 기본적으로 팀원이 중지되고 사유가 경고 줄로 표시됩니다. 대신 사유를 팀원에게 다시 전달하고 계속 작업하게 하려면 `continueOnBlock: true`를 설정하십시오
* `PermissionRequest`: `ok: false`는 아무런 효과가 없습니다. 훅에서 승인을 거부하려면 `hookSpecificOutput.decision.behavior: "deny"`를 반환하는 [명령 훅](#command-hook-fields)을 사용하십시오
* `PermissionDenied`: 거부가 이미 발생했으므로 `ok: false`는 아무런 효과가 없습니다. 이 이벤트가 읽는 유일한 출력은 `hookSpecificOutput.retry`이며, 프롬프트 훅과 에이전트 훅은 이를 설정할 수 없습니다. 이 훅들은 이 이벤트에서 실행되지만 출력은 폐기됩니다. `retry`를 반환하려면 [명령 훅](#command-hook-fields)을 사용하십시오

어떤 이벤트에서든 더 세밀한 제어가 필요하다면 [결정 제어](#decision-control)에 설명된 이벤트별 필드와 함께 [명령 훅](#command-hook-fields)을 사용하십시오.

<h3 id="check-multiple-conditions-before-stopping">
  중지 전에 여러 조건 확인하기
</h3>

이 `Stop` 훅은 상세한 프롬프트를 사용하여 Claude의 중지를 허용하기 전에 세 가지 조건을 확인합니다. `SubagentStop` 훅도 같은 형식을 사용하여 [서브에이전트](/docs/ko/sub-agents)가 중지해야 하는지 평가합니다. 조건이 아직 충족되지 않아 모델이 `"ok": false`를 반환하면, Claude는 제공된 사유를 다음 지시로 삼아 작업을 계속합니다.

```json theme={null}
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "You are evaluating whether Claude should stop working. Context: $ARGUMENTS\n\nAnalyze the conversation and determine if:\n1. All user-requested tasks are complete\n2. Any errors need to be addressed\n3. Follow-up work is needed\n\nRespond with JSON: {\"ok\": true} to allow stopping, or {\"ok\": false, \"reason\": \"your explanation\"} to continue working.",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

<h2 id="agent-based-hooks">
  에이전트 기반 hook
</h2>

<Warning>
  에이전트 hook은 실험적입니다. 동작 및 구성은 향후 릴리스에서 변경될 수 있습니다. 프로덕션 워크플로우의 경우 [명령 hook](#command-hook-fields)을 선호합니다.
</Warning>

에이전트 기반 훅 (`type: "agent"`)은 프롬프트 기반 훅과 유사하지만 다중 턴 도구 액세스가 있습니다. 단일 LLM 호출 대신 에이전트 훅은 파일을 읽고, 코드를 검색하고, 코드베이스를 검사하여 조건을 확인할 수 있는 서브에이전트를 생성합니다. 에이전트 훅은 `PermissionRequest`를 제외하고 [프롬프트 기반 훅](#prompt-based-hooks)과 동일한 이벤트를 지원합니다.

<h3 id="how-agent-hooks-work">
  에이전트 hook이 어떻게 작동하는지
</h3>

에이전트 hook이 발생할 때:

1. Claude Code는 프롬프트와 hook의 JSON 입력을 가진 subagent를 생성합니다
2. subagent는 Read, Grep, Glob과 같은 도구를 사용하여 조사할 수 있습니다
3. 최대 50턴 후 subagent는 구조화된 `{ "ok": true/false }` 결정을 반환합니다
4. Claude Code는 `ok`가 `true`이면 작업을 허용합니다. `ok`가 `false`이면 Claude Code는 [응답 스키마](#response-schema)에 나열된 해당 이벤트에서 `continueOnBlock: true`를 사용하는 프롬프트 hook과 동일한 방식으로 블록을 처리합니다

에이전트 hook은 검증이 hook 입력 데이터만으로 평가하는 것이 아니라 실제 파일이나 테스트 출력을 검사해야 할 때 유용합니다.

<h3 id="agent-hook-configuration">
  에이전트 hook 구성
</h3>

`type`을 `"agent"`로 설정하고 hook 입력 JSON에 대한 자리 표시자로 `$ARGUMENTS`를 사용하여 `prompt` 문자열을 제공합니다. 구성 필드는 [프롬프트 hook](#prompt-hook-configuration)과 동일하지만 에이전트 hook은 60초의 더 긴 기본 시간 초과를 가지며 `continueOnBlock` 필드가 없습니다.

응답 스키마는 허용하려면 `{ "ok": true }`이거나 차단하려면 `{ "ok": false, "reason": "..." }`입니다. `ok: false`일 때 Claude Code는 동일한 이벤트에서 [`continueOnBlock: true`를 사용하는 프롬프트 hook](#response-schema)을 처리하는 방식으로 에이전트 hook을 처리합니다. 에이전트 hook은 `continueOnBlock` 필드가 없으며 프롬프트 hook의 `impossible` 필드를 지원하지 않습니다.

이 `Stop` hook은 Claude가 완료되기 전에 모든 단위 테스트가 통과하는지 확인합니다:

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

<h2 id="run-hooks-in-the-background">
  백그라운드에서 hook 실행
</h2>

기본적으로 hook은 완료될 때까지 Claude의 실행을 차단합니다. 배포, 테스트 스위트 또는 외부 API 호출과 같은 장기 실행 작업의 경우 `"async": true`를 설정하여 Claude가 계속 작업하는 동안 백그라운드에서 hook을 실행합니다. 비동기 hook은 차단하거나 Claude의 동작을 제어할 수 없습니다: `decision`, `permissionDecision`, `continue`와 같은 응답 필드는 효과가 없습니다. 제어했을 작업이 이미 완료되었기 때문입니다.

<h3 id="configure-an-async-hook">
  비동기 hook 구성
</h3>

hook 구성에 `"async": true`를 추가하여 Claude를 차단하지 않고 백그라운드에서 실행합니다. 이 필드는 `type: "command"` hook에서만 사용 가능합니다.

이 hook은 모든 `Write` 도구 호출 후 테스트 스크립트를 실행합니다. Claude는 `run-tests.sh`가 실행되는 동안 즉시 계속 작업합니다. 스크립트가 완료되면 출력이 다음 대화 턴에 전달됩니다:

```json theme={null}
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/run-tests.sh",
            "async": true
          }
        ]
      }
    ]
  }
}
```

비동기 hook이 백그라운드에서 실행되면 Claude Code는 `timeout`을 적용하지 않습니다. Claude Code는 여전히 `asyncRewake`로 실행하는 hook에 `timeout`을 적용합니다.

Claude Code는 비동기 hook의 결과를 세션이 실행되는 동안에만 전달합니다:

* `-p` 플래그가 있는 [비대화형 모드](/docs/ko/headless)에서 Claude Code는 종료 시 여전히 실행 중인 비동기 hook을 종료하고 결과를 `cancelled`로 완료합니다
* hook의 작업이 `claude -p` 세션을 초과해야 하는 경우 완전히 분리된 프로세스를 시작합니다

<h3 id="how-async-hooks-execute">
  비동기 hook이 어떻게 실행되는지
</h3>

비동기 hook이 발생하면 Claude Code는 hook 프로세스를 시작하고 완료를 기다리지 않고 즉시 계속합니다. hook은 동기 hook과 동일한 JSON 입력을 stdin을 통해 받습니다.

백그라운드 프로세스가 종료된 후 Claude Code는 hook의 JSON 응답에서 `additionalContext` 및 `systemMessage` 필드를 다음 대화 턴에서 Claude에 전달합니다. 동기 hook의 `systemMessage`와 달리 두 필드 모두 사용자에게 표시되지 않습니다.

Claude Code는 JSON 응답을 동기 hook과 동일한 [출력 스키마](#json-output)에 대해 검증하고, `systemMessage`가 문자열이 아닌 경우와 같이 값의 유형이 잘못된 필드를 전달하지 않고 삭제합니다. `--debug`로 실행하여 삭제된 각 필드의 이름을 지정하는 경고를 확인합니다. v2.1.202 이전에는 비동기 hook의 잘못된 형식의 JSON 출력이 세션을 충돌시킬 수 있었고, 세션이 재개될 때마다 충돌이 반복되었습니다.

비동기 hook 완료 알림은 기본적으로 억제됩니다. 보려면 `Ctrl+O`로 자세한 모드를 활성화하거나 `--verbose`로 Claude Code를 시작합니다.

<h3 id="run-tests-after-file-changes">
  파일 변경 후 테스트 실행
</h3>

이 hook은 Claude가 파일을 쓸 때마다 백그라운드에서 테스트 스위트를 시작한 후 테스트가 완료되면 결과를 Claude에 보고합니다. 이 스크립트를 프로젝트의 `.claude/hooks/run-tests-async.sh`에 저장하고 `chmod +x`로 실행 가능하게 만듭니다:

```bash theme={null}
#!/bin/bash
# run-tests-async.sh

# stdin에서 hook 입력을 읽습니다
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# 소스 파일에 대해서만 테스트를 실행합니다
if [[ "$FILE_PATH" != *.ts && "$FILE_PATH" != *.js ]]; then
  exit 0
fi

# 테스트를 실행하고 additionalContext를 통해 결과를 Claude에 보고합니다
RESULT=$(npm test 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
  MSG="Tests passed after editing $FILE_PATH"
else
  MSG="Tests failed after editing $FILE_PATH: $RESULT"
fi
jq -nc --arg msg "$MSG" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $msg}}'
```

그런 다음 프로젝트 루트의 `.claude/settings.json`에 이 구성을 추가합니다. `async: true` 플래그를 사용하면 Claude가 테스트 실행 중에 계속 작업할 수 있습니다:

```json theme={null}
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/run-tests-async.sh",
            "args": [],
            "async": true
          }
        ]
      }
    ]
  }
}
```

<h3 id="limitations">
  제한 사항
</h3>

비동기 hook은 동기 hook과 비교하여 여러 제약이 있습니다:

* Hook 출력은 다음 대화 턴에 전달됩니다. 세션이 유휴 상태이면 응답은 다음 사용자 상호 작용까지 기다립니다. 예외: `asyncRewake` hook이 종료 코드 2로 종료되면 세션이 유휴 상태일 때도 Claude를 즉시 깨웁니다.
* 각 실행은 별도의 백그라운드 프로세스를 생성합니다.

<h2 id="security-considerations">
  보안 고려 사항
</h2>

<h3 id="disclaimer">
  면책 조항
</h3>

<Warning>
  명령 hook은 전체 사용자 권한으로 셸 명령을 실행합니다. 사용자 계정이 액세스할 수 있는 모든 파일을 수정, 삭제 또는 액세스할 수 있습니다. 구성에 추가하기 전에 모든 hook 명령을 검토하고 테스트하세요.
</Warning>

<h3 id="workspace-trust">
  작업 공간 신뢰
</h3>

Claude Code는 설정 파일에서 hook을 실행하기 전에 작업 공간 신뢰를 확인합니다. 신뢰할 수 있는 것으로 간주되는 것은 세션 유형에 따라 다릅니다:

* **대화형 세션**: Claude Code는 사용자의 `~/.claude/settings.json`을 포함한 모든 설정 파일의 hook을 보류하며, 폴더에 대한 [작업 공간 신뢰 대화](/docs/ko/permissions#project-allow-rules-and-workspace-trust)를 수락하거나 신뢰가 확장되는 상위 디렉토리에 대해 수락할 때까지 보류합니다
* **`-p` 또는 SDK 세션**: Claude Code는 대화를 표시하지 않으며 폴더를 신뢰할 수 있는 것으로 취급하므로, 리포지토리의 `.claude/settings.json`에 커밋된 hook은 신뢰한 적이 없는 폴더에서 실행됩니다

작성하지 않은 리포지토리에 대해 `claude -p`를 스크립팅하기 전에 해당 `.claude/` 설정 파일을 검토하고, [`--bare`](/docs/ko/headless#start-faster-with-bare-mode)로 시작하거나, `--settings '{"disableAllHooks": true}'`를 사용하여 [해당 실행에 대해 hook을 비활성화](#disable-or-remove-hooks)하세요. 프로젝트 서브에이전트의 frontmatter hook은 설정 파일 hook보다 더 엄격한 규칙을 따릅니다. [폴더를 신뢰하기 전에 실행되는 것](/docs/ko/permissions#what-runs-before-you-trust-a-folder)은 세션 유형별로 각 종류의 리포지토리 콘텐츠를 나열합니다.

<h3 id="security-best-practices">
  보안 모범 사례
</h3>

hook을 작성할 때 이러한 사례를 염두에 두세요:

* **입력 검증 및 살균**: 입력 데이터를 맹목적으로 신뢰하지 마세요
* **항상 셸 변수를 따옴표로 감싸세요**: `$VAR` 대신 `"$VAR"` 사용
* **경로 순회 차단**: 파일 경로에서 `..` 확인
* **절대 경로 사용**: 스크립트의 전체 경로를 지정하세요. exec 형식에서는 `${CLAUDE_PROJECT_DIR}`을 사용하고 경로는 따옴표가 필요하지 않습니다. shell 형식에서는 큰따옴표로 감싸세요
* **민감한 파일 건너뛰기**: `.env`, `.git/`, 키 등을 피하세요

<h2 id="windows-powershell-tool">
  Windows PowerShell 도구
</h2>

Windows에서 명령 hook에 `"shell": "powershell"`을 설정하여 PowerShell에서 개별 hook을 실행할 수 있습니다. Claude Code는 PowerShell 7 이상의 실행 파일인 `pwsh.exe`를 자동 감지하고 Windows PowerShell 5.1의 `powershell.exe`로 폴백합니다.

```json theme={null}
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "shell": "powershell",
            "command": "Write-Host 'File written'"
          }
        ]
      }
    ]
  }
}
```

PowerShell 셸 형식 명령에서 프로젝트 루트를 참조하려면 `${CLAUDE_PROJECT_DIR}` 또는 `$env:CLAUDE_PROJECT_DIR`을 작성합니다. Claude Code는 훅이 `settings.json`, 플러그인 또는 스킬에 정의되어 있는지 여부와 관계없이 PowerShell 셸 형식 명령에서 `${CLAUDE_PROJECT_DIR}`, `${CLAUDE_PLUGIN_ROOT}` 및 `${CLAUDE_PLUGIN_DATA}` 자리 표시자를 PowerShell의 `${env:NAME}` 형식으로 다시 작성합니다. PowerShell은 구문 분석 후 내보낸 환경에서 값을 확인하므로 자리 표시자는 큰따옴표로 묶인 문자열 내에서는 작동하지만 PowerShell이 변수를 확장하지 않는 작은따옴표로 묶인 문자열 내에서는 작동하지 않습니다.

PowerShell hook에서 `$CLAUDE_PROJECT_DIR`의 단순한 형식을 작성하지 마십시오. PowerShell은 이를 정의되지 않은 로컬 변수로 구문 분석하고 `$null`로 확인하므로 스크립트 경로가 프로젝트 루트 접두사 없이 남습니다. Claude Code는 해당 형식을 다시 작성하지 않으며 대신 [디버그 로그](#debug-hooks)에 경고를 기록합니다.

아래 예제는 `$env:` 형식으로 프로젝트 스크립트를 실행하는 `settings.json` 훅을 보여줍니다:

```json theme={null}
{
  "type": "command",
  "shell": "powershell",
  "command": "& \"$env:CLAUDE_PROJECT_DIR\\.claude\\hooks\\check.ps1\""
}
```

<h2 id="debug-hooks">
  Hook 디버그
</h2>

Hook 실행 세부 정보는 디버그 로그 파일에 기록됩니다. `claude --debug-file <path>`로 Claude Code를 시작하여 로그를 알려진 위치에 작성하거나 `claude --debug`를 실행하고 `~/.claude/debug/<session-id>.txt`에서 로그를 읽습니다. `--debug` 플래그는 터미널에 인쇄하지 않습니다.

예를 들어, `Write`에서 `hook-ran`을 인쇄하는 명령을 가진 `PostToolUse` hook은 다음과 같은 항목을 생성합니다:

```text theme={null}
2026-07-19T02:03:24.382Z [DEBUG] Hook output does not start with {, treating as plain text
2026-07-19T02:03:24.382Z [DEBUG] "Hook PostToolUse:Write (PostToolUse) success:\nhook-ran"
```

더 세밀한 hook 일치 세부 정보를 보려면 `CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose`를 설정하여 hook matcher 수 및 쿼리 일치와 같은 추가 로그 줄을 확인합니다.

hook이 발생하지 않음, 무한 Stop hook 루프 또는 구성 오류와 같은 일반적인 문제 해결은 가이드의 [제한 사항 및 문제 해결](/docs/ko/hooks-guide#limitations-and-troubleshooting)을 참조하세요. `/context`, `/doctor` 및 설정 우선순위를 다루는 더 광범위한 진단 안내는 [구성 디버그](/docs/ko/debug-your-config)를 참조하세요.
