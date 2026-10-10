> ## Documentation Index
> Fetch the complete documentation index at: https://code.claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# MCP 서버에 연결하기

> Claude Code에 MCP 서버를 추가하고, 연결을 확인하며, 디스크에서 구성을 찾습니다.

[Model Context Protocol (MCP)](https://modelcontextprotocol.io/introduction)를 사용하면 Claude Code가 이슈 추적기 검색, 데이터베이스 쿼리, 웹 브라우저 제어 등 기본 제공 도구 이상의 도구를 사용할 수 있습니다. 이러한 도구는 사용자의 머신이나 호스팅된 서비스로 실행되는 MCP 서버에서 제공됩니다.

이 가이드는 Claude Code CLI를 사용하여 한 개의 MCP 서버를 처음부터 끝까지 연결하는 과정을 안내합니다. 완료하면 서버가 연결되어 응답하고, 디스크에서 구성이 어디에 있는지 알 수 있으며, 가장 일반적인 연결 오류를 해결하는 방법을 알게 됩니다.

<Note>
  데스크톱 앱, VS Code, 웹 등 다른 표면에서도 MCP 서버를 추가할 수 있습니다. [다른 표면에서 연결하기](#connect-from-other-surfaces)를 참조하세요.
</Note>

Claude Code에서 MCP 서버를 연결하고 구성하는 모든 방법은 [MCP 참조](/docs/ko/mcp)를 참조하세요.

<h2 id="before-you-begin">
  시작하기 전에
</h2>

다음을 확인하세요:

* [Claude Code 설치](/docs/ko/quickstart) 및 인증 완료
* 프로젝트 디렉토리에서 터미널 열기. 빈 디렉토리를 포함한 모든 디렉토리가 작동합니다.

<h2 id="add-and-verify-a-server">
  서버 추가 및 확인
</h2>

아래 예제는 [Claude Code 문서 MCP 서버](https://code.claude.com/docs/mcp)에 연결합니다. 이는 Claude Code 문서에 대한 전체 텍스트 검색이 가능한 호스팅된 서버입니다. 인증이나 특별한 구성이 필요하지 않으므로 설정 흐름을 테스트하기 위한 첫 번째 서버로 적합합니다.

단계는 모든 서버에 대해 동일합니다: 추가, 연결 상태 확인, 세션에서 사용, 선택적 정리 단계. 일부 서버는 [추가 MCP 서버 예제](#additional-mcp-server-examples)에 표시된 브라우저 로그인과 같은 단계를 추가합니다. 더 많은 서버를 연결하려면 [Anthropic Directory](/docs/ko/mcp#find-and-build-mcp-servers)를 참조하세요.

<Steps>
  <Step title="MCP 서버 추가">
    Claude Code에 서버를 등록합니다. 이를 터미널에서 실행하세요. `claude` 세션 내부가 아닙니다: 대화를 시작하기 전에 서버를 구성하고 있습니다.

    ```bash theme={null}
    claude mcp add --transport http claude-code-docs https://code.claude.com/docs/mcp
    ```

    명령의 부분:

    * `claude mcp add`: Claude Code에 서버를 등록합니다.
    * `--transport http`: 서버는 로컬 프로세스로 실행되지 않고 URL에서 호스팅됩니다.
    * `claude-code-docs`: 사용자가 만드는 이름입니다. 동일한 서버를 `docs`라고 호출해도 동일하게 작동합니다. Claude Code는 선택한 이름을 사용하여 Claude의 출력에서 서버의 도구에 레이블을 지정하고 `claude mcp remove`와 같은 명령에서 서버를 참조합니다.
    * `https://code.claude.com/docs/mcp`: 서버가 호스팅되는 URL입니다.

    명령은 `Added HTTP MCP server claude-code-docs with URL: https://code.claude.com/docs/mcp to local config`와 같은 확인을 출력합니다. 그 다음에 구성 파일을 작성한 것을 보여주는 `File modified:` 줄이 나옵니다. `local config` 부분은 서버가 이 프로젝트에서 사용자에게 등록되었음을 의미합니다: 다른 프로젝트에서 Claude Code를 시작하면 이 서버는 활성화되지 않습니다. 모든 프로젝트에 대해 한 번 서버를 등록하려면 사용자 범위에서 추가하세요. [서버 범위 변경](#change-server-scope)에서 다룹니다.
  </Step>

  <Step title="연결 상태 확인">
    서버가 서버 목록에 나타나는지 확인하고 상태를 확인합니다:

    ```bash theme={null}
    claude mcp list
    ```

    서버는 상태 표시기와 함께 나타납니다:

    | 상태 | 의미 |
    | :- | :- |
    | `✔ Connected` | 사용할 준비가 되었습니다. `claude-code-docs`에서 이것을 봐야 합니다 |
    | `! Connected · tools fetch failed` | 서버가 연결되었지만 도구를 나열할 수 없습니다. 오류 세부 정보는 `claude mcp get <name>`을 실행하세요 |
    | `! Needs authentication` | 서버에 도달할 수 있지만 브라우저 로그인이 필요하거나 `--header`로 전달된 토큰이 필요합니다. [로그인이 필요한 서버 연결하기](#connect-a-server-that-requires-sign-in)를 참조하세요 |
    | `✘ Failed to connect` | 서버가 응답하지 않았습니다. [문제 해결](#troubleshooting)을 참조하세요 |
    | `✘ Connection error` | 연결 시도에서 오류가 발생했습니다. [문제 해결](#troubleshooting)을 참조하세요 |
    | ``⏸ Pending approval (run `claude` to approve)`` | 아직 승인하지 않은 프로젝트 범위 서버입니다. [.mcp.json 직접 편집하기](#edit-mcp-json-directly)를 참조하세요 |
    | `⊘ Disabled for this project (re-enable via /mcp)` | 프로젝트의 `disabledMcpServers` 목록에 의해 이 프로젝트에 대해 꺼진 서버입니다. [서버 제거 없이 비활성화하기](/docs/ko/mcp#disable-a-server-without-removing-it)를 참조하세요 |

    Windows 10의 기본 콘솔과 같은 일부 레거시 Windows 콘솔은 이러한 Unicode 문자를 지원하지 않으며 `✔` 및 `✘` 대신 `√` 및 `×`를 표시합니다.
  </Step>

  <Step title="서버 사용">
    세션을 시작하고 Claude에 이름으로 새 서버를 사용하도록 요청합니다:

    ```bash theme={null}
    claude
    ```

    ```text wrap theme={null}
    Use the claude-code-docs server to look up what MCP_TIMEOUT does
    ```

    <Info>
      일반적으로 Claude가 자체적으로 관련 도구를 선택하므로 프롬프트에서 서버 이름을 지정할 필요가 없습니다. 여기서 이름을 지정하면 웹 가져오기와 같은 동일한 질문에 답할 수 있는 다른 도구가 아닌 새 서버를 통해 데모가 진행되도록 보장합니다.
    </Info>

    Claude Code가 처음으로 Claude가 서버를 호출할 때 권한을 요청하면 승인하세요. Claude의 출력에서 도구 호출은 서버 이름으로 레이블이 지정되어 있으므로 답변이 Claude의 기본 제공 지식이 아닌 MCP 서버에서 나왔는지 확인할 수 있습니다.
  </Step>

  <Step title="서버 제거">
    이 단계는 선택 사항입니다. 실험을 마치면 서버를 제거할 수 있습니다:

    ```bash theme={null}
    claude mcp remove claude-code-docs
    ```

    명령은 `Removed MCP server "claude-code-docs" from local config`로 확인하고 업데이트한 파일을 보여주는 `File modified:` 줄이 나옵니다.

    <Note>
      연결된 각 서버는 도구 이름과 서버 지침이 모든 세션에 로드되기 때문에 [Claude의 컨텍스트 윈도우](/docs/ko/how-claude-code-works#the-context-window)에서 일부 공간을 차지합니다. 더 이상 사용하지 않는 서버를 제거하면 해당 공간을 확보할 수 있습니다.
    </Note>
  </Step>
</Steps>

<h2 id="where-servers-are-saved">
  서버가 저장되는 위치
</h2>

`claude mcp add` 명령은 서버의 세부 정보를 구성 파일에 씁니다. 기본적으로 `local` 범위에서 서버를 등록합니다: 사용자에게만 비공개이며 현재 프로젝트에서만 활성화됩니다. `--scope user`를 전달하여 모든 프로젝트에 대해 한 번 등록하거나 `--scope project`를 전달하여 팀원과 공유합니다. [서버 범위 변경](#change-server-scope)에서 둘 다 설명합니다.

<Note>
  `claude mcp add`는 PowerShell 및 Command Prompt를 포함한 모든 셸에서 동일하게 작동합니다. `claude` 세션 내부에서 `/mcp` 명령을 사용하여 이미 추가한 서버를 확인하고 관리합니다.
</Note>

서버를 추가하는 다른 방법이 있으며, 각각은 자체 섹션이 있습니다:

* [로컬 서버 추가](#add-a-local-server): URL에 연결하는 대신 머신에서 프로그램을 실행합니다.
* [`.mcp.json` 직접 편집하기](#edit-mcp-json-directly): 명령을 사용하는 대신 JSON 항목을 직접 작성합니다.
* [로그인이 필요한 서버 연결하기](#connect-a-server-that-requires-sign-in): 도구가 작동하기 전에 브라우저 로그인이 필요한 호스팅된 서버를 추가합니다.

<h3 id="find-your-configuration-on-disk">
  디스크에서 구성 찾기
</h3>

`claude mcp add` 명령은 `--scope` 플래그에 따라 두 파일에 걸쳐 저장된 세 가지 범위 중 하나에 서버를 씁니다. 이러한 파일을 직접 편집할 필요는 없지만 위치를 알면 디버깅 및 버전 제어에 도움이 됩니다.

| 범위 | 파일 | 사용 가능 대상 |
| :- | :- | :- |
| `local` | `~/.claude.json`, 이 프로젝트의 항목 아래 | 사용자만, 이 프로젝트만. 기본값 |
| `project` | 프로젝트 루트의 `.mcp.json` | 프로젝트를 복제하는 모든 사람 |
| `user` | `~/.claude.json`, 최상위 `mcpServers` 키 아래 | 사용자만, 모든 프로젝트 |

Windows에서 `~/.claude.json`은 `%USERPROFILE%\.claude.json`으로 확인되며, 일반적으로 `C:\Users\YourName\.claude.json`입니다. [`CLAUDE_CONFIG_DIR`](/docs/ko/env-vars)을 설정한 경우 Claude Code는 대신 해당 디렉토리 내에서 `.claude.json`을 읽습니다.

`claude mcp get claude-code-docs`를 실행하여 어느 범위가 서버의 정의를 보유하는지 확인합니다. 동일한 서버가 둘 이상의 범위에서 정의될 때 범위가 상호 작용하는 방식은 [MCP 설치 범위](/docs/ko/mcp#mcp-installation-scopes)를 참조하세요.

<h2 id="change-server-scope">
  서버 범위 변경
</h2>

서버의 범위는 추가할 때 고정되므로 범위를 변경하려면 항목을 제거하고 새 범위에서 다시 추가해야 합니다. 아래의 두 경우 모두 첫 번째 연습에서 로컬 항목을 제거하여 시작하므로 서버는 정의가 하나만 있습니다. 해당 연습의 끝에서 이미 제거한 경우 이 명령을 건너뜁니다:

```bash theme={null}
claude mcp remove claude-code-docs --scope local
```

<h3 id="use-a-server-in-all-your-projects">
  모든 프로젝트에서 서버 사용
</h3>

`user` 범위에서 서버를 다시 추가하여 열 수 있는 모든 프로젝트에서 활성화하되, 여전히 사용자에게만 비공개입니다:

```bash theme={null}
claude mcp add --scope user --transport http claude-code-docs https://code.claude.com/docs/mcp
```

<h3 id="share-a-server-with-your-team">
  팀과 서버 공유
</h3>

`project` 범위에서 서버를 다시 추가하여 프로젝트 루트의 `.mcp.json`에 씁니다:

```bash theme={null}
claude mcp add --scope project --transport http claude-code-docs https://code.claude.com/docs/mcp
```

`.mcp.json`을 버전 제어에 커밋합니다. 저장소를 복제하고 Claude Code를 시작하는 팀원은 서버를 승인하라는 프롬프트를 보고 그들도 연결됩니다.

<h2 id="additional-mcp-server-examples">
  추가 MCP 서버 예제
</h2>

첫 번째 연습에서는 로그인 없이 연결되는 호스팅된 서버를 사용했습니다. 아래 예제는 동일한 추가, 확인, 사용 흐름을 포함하는 다른 두 가지 일반적인 형태를 다룹니다.

<h3 id="add-a-local-server">
  로컬 서버 추가
</h3>

로컬 stdio 서버는 Claude Code가 URL을 통해 도달하는 서비스가 아닌 머신에서 서브프로세스로 시작하는 프로그램입니다. 브라우저, 파일 시스템 또는 데이터베이스 소켓과 같은 로컬 리소스에 액세스해야 하는 도구에 사용합니다.

[Playwright MCP 서버](https://github.com/microsoft/playwright-mcp)는 시도할 좋은 서버입니다: Claude에 탐색, 클릭 및 읽을 수 있는 브라우저를 제공하며 계정이 필요하지 않습니다. `npx`를 통해 실행되므로 [Node.js](https://nodejs.org/en/download) 18 이상이 필요합니다.

<Steps>
  <Step title="Playwright 서버 추가">
    Claude Code가 시작하기 위해 실행해야 하는 명령으로 서버를 등록합니다:

    ```bash theme={null}
    claude mcp add playwright -- npx -y @playwright/mcp@latest
    ```

    이 명령은 호스팅된 예제와 세 가지 방식으로 다릅니다:

    * 로컬 서버는 기본 `stdio` 전송을 사용하므로 `--transport` 플래그가 없습니다.
    * `--` 구분 기호 뒤의 모든 것은 Claude Code가 서버를 시작하기 위해 실행하는 명령입니다.
    * `-y`는 `npx`에 프롬프트 없이 패키지를 설치하도록 지시합니다.

    명령은 `Added stdio MCP server playwright with command: npx -y @playwright/mcp@latest to local config`와 같은 확인을 출력하고, 그 뒤에 작성한 구성 파일을 보여주는 `File modified:` 줄이 따릅니다.

    Playwright는 머신에 이미 설치된 Chrome을 구동합니다. 다른 브라우저를 사용하려면 `@playwright/mcp@latest` 뒤에 `--browser`를 추가하고 브라우저 이름을 입력합니다(예: `--browser firefox`).
  </Step>

  <Step title="연결 확인">
    `Added` 확인은 항목이 저장되었음을 의미하며, 명령이 실행됨을 의미하지 않습니다. 연결을 확인합니다:

    ```bash theme={null}
    claude mcp list
    ```

    첫 번째 확인은 `npx`가 패키지를 다운로드하는 동안 `✘ Failed to connect`를 표시할 수 있으므로 잠시 기다렸다가 다시 실행합니다. 다운로드가 완료되면 상태가 `✔ Connected`로 변경됩니다. 몇 번 재시도한 후에도 여전히 `✘ Failed to connect`를 표시하면 [문제 해결](#troubleshooting)을 참조하세요.
  </Step>

  <Step title="브라우저 사용">
    Claude에 브라우저가 필요한 작업을 제공합니다:

    ```text wrap theme={null}
    Use playwright to open https://example.com and tell me the page title
    ```

    브라우저 창이 열려 작동하는 것을 볼 수 있으며, Claude의 출력에서 도구 호출은 `playwright` 서버 이름과 `browser_navigate`와 같은 작업으로 레이블이 지정됩니다.

    로컬 개발 서버를 가리켜 변경 후에도 페이지가 여전히 렌더링되는지 확인하거나 버그 보고서를 단계별로 진행하도록 합니다.
  </Step>
</Steps>

<h3 id="connect-a-server-that-requires-sign-in">
  로그인이 필요한 서버 연결하기
</h3>

Sentry, Linear, Notion과 같은 호스팅된 서비스는 OAuth 뒤에서 MCP 서버를 실행합니다: 서버의 URL을 추가한 다음 브라우저를 통해 로그인합니다.

아래 단계는 Sentry를 예제로 사용합니다. 다른 서비스에 연결하려면 [Anthropic Directory](/docs/ko/mcp#find-and-build-mcp-servers) 또는 서비스의 문서에서 찾을 수 있는 URL을 대체합니다.

<Steps>
  <Step title="서버 추가">
    `add` 명령은 Sentry의 URL을 사용하여 문서 서버와 동일합니다:

    ```bash theme={null}
    claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
    ```

    추가 후 `claude mcp list`는 서버를 `! Needs authentication`으로 표시합니다. 이는 예상된 것입니다: 다음 단계에서 로그인을 완료합니다.
  </Step>

  <Step title="브라우저에서 인증">
    Claude Code 세션을 시작하고 MCP 패널을 엽니다:

    ```text wrap theme={null}
    /mcp
    ```

    목록에서 `sentry`를 선택하고 Enter를 누른 다음 `Authenticate`를 선택합니다. 브라우저가 Sentry의 로그인 페이지로 열립니다. 거기서 연결을 승인합니다.

    Claude Code로 돌아가면 서버의 상태가 연결됨으로 변경됩니다. 로그인이 실패하거나 브라우저가 열리지 않으면 [문제 해결](#troubleshooting)을 참조하세요.
  </Step>

  <Step title="서버 사용">
    `What Sentry projects do I have access to?`와 같이 서비스가 필요한 것을 Claude에 요청하고 출력에서 `sentry` 서버 이름으로 레이블이 지정된 도구 호출을 찾습니다.
  </Step>
</Steps>

OAuth 대신 정적 토큰으로 인증하는 서버는 `--header "Authorization: Bearer <token>"`을 사용하여 추가 시간에 토큰을 가져옵니다. 작동하는 버전은 [GitHub 예제](/docs/ko/mcp#example-connect-to-github-for-code-reviews)를 참조하세요.

<h2 id="edit-mcp-json-directly">
  .mcp.json 직접 편집하기
</h2>

[범위 테이블](#find-your-configuration-on-disk)의 모든 파일은 서버 항목에 대해 동일한 JSON 형식을 사용합니다. 이 섹션은 프로젝트 범위 파일인 `.mcp.json`을 편집합니다. 저장소에 체크인되므로 팀을 위한 구성 코드로도 작동하기 때문에 손으로 작성할 가치가 있습니다.

프로젝트 루트에 `.mcp.json`을 만듭니다. 아래 예제는 이 가이드의 두 서버, HTTP를 통해 도달하는 호스팅된 문서 서버 및 로컬 `stdio` 프로세스로서의 Playwright 서버를 정의합니다:

```json theme={null}
{
  "mcpServers": {
    "claude-code-docs": {
      "type": "http",
      "url": "https://code.claude.com/docs/mcp"
    },
    "playwright": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"]
    }
  }
}
```

필드는 서버 유형에 따라 다릅니다:

* HTTP 서버의 경우 `url`은 Claude Code가 연결하는 엔드포인트입니다.
* stdio 서버의 경우 `command`와 `args`는 실행하는 프로그램입니다.

파일을 저장한 후 프로젝트에서 새 Claude Code 세션을 시작합니다. Claude Code는 시작 시 `.mcp.json`을 읽습니다.

Claude Code가 처음으로 프로젝트 범위 서버를 보면 승인하도록 요청합니다. 프롬프트는 복제한 저장소가 동의 없이 머신에서 프로세스를 시작할 수 없도록 존재합니다. 프롬프트를 승인하거나 놓친 경우 나중에 승인하려면 `/mcp`를 실행합니다.

승인한 후 `/mcp`를 실행하고 서버가 연결됨으로 표시되는지 확인합니다. 대신 오류를 표시하면 [문제 해결](#troubleshooting)을 참조하세요.

<h2 id="connect-from-other-surfaces">
  다른 표면에서 연결하기
</h2>

이 가이드는 `claude mcp` CLI 명령을 사용하지만 모든 Claude Code 표면은 MCP 서버에 연결할 수 있습니다:

* **Claude Code 데스크톱 앱**: [Connectors UI](/docs/ko/desktop#connect-external-tools)를 통해 서버를 추가합니다.
* **Claude Desktop 채팅 앱**: Claude Code와 별개의 앱입니다. `claude_desktop_config.json`에서 CLI로 서버를 복사하려면 macOS 또는 WSL에서 `claude mcp add-from-claude-desktop`을 실행합니다.
* **VS Code**: [MCP를 사용하여 외부 도구에 연결하기](/docs/ko/vs-code#connect-to-external-tools-with-mcp)를 참조하세요.
* **클라우드 세션**: 저장소에 `.mcp.json`을 커밋합니다. [.mcp.json 직접 편집하기](#edit-mcp-json-directly) 및 [설정에서 이월되는 항목](/docs/ko/cloud-environments#what-carries-over-from-your-setup)을 참조하세요.
* **Claude.ai**: [claude.ai/customize/connectors](https://claude.ai/customize/connectors)에서 추가한 커넥터는 해당 계정으로 로그인할 때 CLI에 자동으로 로드됩니다. [Claude.ai에서 MCP 서버 사용하기](/docs/ko/mcp#use-mcp-servers-from-claude-ai)를 참조하세요.

<h2 id="troubleshooting">
  문제 해결
</h2>

서버가 연결되지 않으면 세션 내부에서 `/mcp`를 사용하거나 셸에서 `claude mcp list`를 사용하여 상태를 확인한 다음 아래 증상과 일치시킵니다. `/mcp` 패널을 사용하면 세션을 떠나지 않고도 다시 연결하거나 인증할 수 있습니다.

<AccordionGroup>
  <Accordion title="/mcp shows No MCP servers configured">
    Claude Code가 현재 디렉토리에 대한 서버를 찾지 못했습니다. 가장 일반적인 원인:

    * 다른 프로젝트에서 `claude mcp add`를 실행했습니다. 로컬 범위 서버는 추가한 프로젝트에 연결됩니다: 저장소 루트 또는 git 저장소에 없는 경우 정확한 디렉토리입니다. 현재 있는 프로젝트에서 서버를 다시 추가하거나 프로젝트에 연결되지 않도록 `--scope user`로 추가합니다.
    * 잘못된 경로에서 구성 파일을 편집했습니다. 올바른 파일은 `~/.claude.json` 및 `<project>/.mcp.json`입니다. Claude Code는 `~/.claude/.mcp.json`, `~/.claude/config/mcp.json`, `~/.claude/mcp.json` 또는 `%APPDATA%\Claude\mcp.json`과 같은 경로를 읽지 않습니다. 사용자 범위 서버의 경우 `claude mcp add --scope user`를 실행하여 `~/.claude.json`의 `mcpServers` 키에 쓰고, 프로젝트 범위 서버의 경우 프로젝트 루트의 `.mcp.json`을 편집합니다.
    * `.mcp.json`에 잘못된 형식의 항목을 작성했습니다. Claude Code는 해당 항목을 건너뛰고 여전히 다른 항목을 로드합니다. 셸에서 `claude mcp list`를 실행하고 구문 분석 경고를 찾으면 문제가 있는 필드의 이름이 표시됩니다.
  </Accordion>

  <Accordion title="Status shows Failed to connect or Connection error">
    두 상태 모두 서버가 시작되지 않았거나 URL이 응답하지 않았음을 의미합니다. 또한 `headers.Authorization`에서 구성한 토큰을 거부하는 HTTP 서버에도 나타날 수 있습니다. 토큰을 구성하지 않은 서버는 대신 `! Needs authentication`을 표시하며, [로그인이 필요한 서버 연결하기](#connect-a-server-that-requires-sign-in)에서 다룹니다.

    첫 번째 단계는 표시되는 상태에 따라 다릅니다:

    * `Failed to connect`: 상태 자체의 실패 세부 정보로 시작합니다. `claude mcp list` 및 `claude mcp get <name>`은 HTTP 상태 또는 오류 코드와 서버가 반환한 오류 텍스트를 표시하며, 이는 종종 누락된 헤더 또는 거부된 토큰과 같은 문제를 직접 이름으로 지정합니다. v2.1.219 이전에는 `Failed to connect`가 기본 상태만 표시했으며, 원인을 찾기 위해 이 섹션의 나중에 있는 curl 및 명령 확인이 필요했습니다.
    * `Connection error`: Claude Code는 모든 버전에서 이 상태에 세부 정보를 추가하지 않으므로 이 섹션의 나중에 있는 curl 및 명령 확인으로 바로 이동합니다.

    세부 정보가 자격 증명 또는 URL을 가리키면 `claude mcp list` 출력의 경고도 확인합니다. Claude Code는 숨겨진 선행 또는 후행 공백이 있는 구성 값에 플래그를 지정하며, 이는 토큰을 붙여넣은 후 인증 실패의 일반적인 원인입니다.

    HTTP 서버가 `404 Not Found`를 반환하면 Claude Code는 `/mcp`에서 서버를 선택할 때 `MCP endpoint not found at <origin>. Check the URL in your MCP config.`를 표시합니다. 메시지는 경로 없이 `https://mcp.example.com`과 같은 URL의 원본 이름을 지정하므로 `claude mcp get <name>`을 실행하여 구성한 전체 URL을 확인합니다. 해당 경로를 서버의 문서화된 MCP 엔드포인트 경로와 비교한 다음 `claude mcp remove <name>`을 실행하고 올바른 URL로 다시 추가합니다. v2.1.219 이전에는 메시지에 URL의 경로도 포함되었으며, v2.1.191 이전에는 `404`가 URL 없이 일반적인 `Error POSTing to endpoint` 메시지를 표시했습니다.

    HTTP 서버의 경우 URL이 머신에서 도달 가능한지 확인합니다:

    ```bash theme={null}
    curl -I https://mcp.sentry.dev/mcp
    ```

    PowerShell에서는 `curl` 대신 `curl.exe`를 사용하여 요청이 `Invoke-WebRequest` 별칭이 아닌 실제 curl 바이너리로 이동하도록 합니다.

    응답은 어떤 종류의 문제가 있는지 알려줍니다:

    * `404` 또는 `405`: 서버가 실행 중입니다. 많은 MCP 엔드포인트는 POST 요청에만 응답하므로 이는 여전히 URL이 머신에서 도달 가능함을 확인합니다.
    * `401` 또는 `403`: 서버가 실행 중이고 인증이 필요합니다. [로그인이 필요한 서버 연결하기](#connect-a-server-that-requires-sign-in)에서 브라우저 로그인을 사용하거나 GitHub와 같이 토큰을 가져오는 서버의 경우 `claude mcp add` 명령에서 `--header "Authorization: Bearer <token>"`으로 전달합니다.
    * 응답 없음: URL과 네트워크를 확인합니다.

    stdio 서버의 경우 터미널에서 구성된 명령을 직접 실행하여 기본 오류를 확인합니다. 이 가이드의 Playwright 서버의 경우 다음을 실행합니다:

    ```bash theme={null}
    npx -y @playwright/mcp@latest
    ```

    다음에 일어나는 일은 문제가 어디에 있는지 알려줍니다:

    * 명령이 시작되고 입력을 기다립니다: 서버 자체가 작동합니다.

      `claude mcp get <name>`을 실행하고 거기에 표시된 명령이 방금 실행한 것과 일치하는지 확인합니다. 표시된 명령이 입력한 것과 다르면 서버 명령 전에 `--` 구분 기호를 생략했을 가능성이 높습니다. 서버를 제거하고 `--`를 제자리에 두고 다시 추가합니다. `.mcp.json`을 손으로 작성한 경우 구문과 위치를 확인합니다. v2.1.285 이전에는 `claude mcp get`이 `type` 필드 없이 저장된 stdio 항목(예: 손으로 작성한 `.mcp.json` 항목)에 대해 `Command` 줄을 인쇄하지 않았습니다. 이러한 버전에서는 대신 `claude mcp list`를 실행하면 어느 쪽이든 명령줄을 인쇄합니다.
    * 명령 오류: 메시지는 Node.js 또는 브라우저와 같이 누락된 것을 이름으로 지정합니다.
  </Accordion>

  <Accordion title="Connection timed out at startup">
    서버가 기본 30초 시작 시간 초과를 초과했습니다. stdio 서버의 첫 실행은 `npx`가 패키지를 다운로드하는 동안 느릴 수 있습니다. [`MCP_TIMEOUT`](/docs/ko/env-vars) 환경 변수를 사용하여 제한을 밀리초 단위로 증가시킵니다:

    ```bash theme={null}
    MCP_TIMEOUT=60000 claude
    ```

    PowerShell에서는 같은 줄의 명령 전에 변수를 설정합니다:

    ```powershell theme={null}
    $env:MCP_TIMEOUT = "60000"; claude
    ```
  </Accordion>

  <Accordion title="Server already exists">
    동일한 범위에서 해당 이름의 서버를 이미 추가했습니다. 기존 항목을 먼저 제거하거나 다른 이름을 선택합니다:

    ```bash theme={null}
    claude mcp remove claude-code-docs
    ```

    이름이 둘 이상의 범위에 있으면 `remove`는 `exists in multiple scopes`를 보고합니다. `--scope`를 전달하여 삭제할 복사본을 선택합니다(예: `claude mcp remove claude-code-docs --scope local`).
  </Accordion>

  <Accordion title="Server connects but no tools appear">
    세션 내부에서 `/mcp`를 실행하고 서버를 선택하여 도구 목록을 확인합니다. 목록이 비어 있으면 서버가 시작되었지만 도구를 등록하지 않았으며, 이는 일반적으로 API 키와 같은 필수 환경 변수가 누락되었음을 의미합니다.

    `claude mcp add`에서 `--env KEY=value`를 사용하거나 서버의 `.mcp.json` 항목의 `env` 필드에서 변수를 전달합니다. 서버의 문서는 필요한 변수를 나열합니다.
  </Accordion>

  <Accordion title="Changes to .mcp.json don't take effect">
    Claude Code는 세션 시작 시 `.mcp.json`을 읽습니다. 파일을 편집한 후 세션을 종료하고 다시 시작합니다.

    서버가 여전히 나타나지 않으면 `claude mcp list`를 실행하고 구문 분석 경고를 찾습니다. Claude Code는 잘못된 형식의 항목을 건너뛰고 거기에 문제가 있는 필드를 표시합니다.

    이전에 프롬프트에서 서버를 거부한 경우 프로젝트 승인을 재설정합니다:

    ```bash theme={null}
    claude mcp reset-project-choices
    ```
  </Accordion>

  <Accordion title="OAuth sign-in fails or browser doesn't open">
    `/mcp`를 실행하고 서버를 선택한 다음 `Authenticate`를 다시 선택합니다. 브라우저가 자동으로 열리지 않으면 터미널에 표시된 URL을 복사하여 수동으로 엽니다. 고정 콜백 포트 및 사전 구성된 자격 증명은 [원격 MCP 서버로 인증하기](/docs/ko/mcp#authenticate-with-remote-mcp-servers)를 참조하세요.
  </Accordion>
</AccordionGroup>

<h2 id="next-steps">
  다음 단계
</h2>

한 개의 서버가 연결되면 MCP가 활성화하는 나머지를 탐색합니다:

* [더 많은 MCP 서버 찾기](/docs/ko/mcp#find-and-build-mcp-servers) Anthropic Directory에서
* [설치 범위를 사용하여 팀과 서버 공유하기](/docs/ko/mcp#mcp-installation-scopes)
* [관리되는 설정 및 정책 제어로 조직을 위한 MCP 액세스 관리하기](/docs/ko/managed-mcp)
* [프롬프트에서 @ 언급으로 MCP 리소스 참조하기](/docs/ko/mcp#use-mcp-resources)
* [`/` 메뉴에서 MCP 프롬프트를 명령으로 실행하기](/docs/ko/mcp#use-mcp-prompts-as-commands)
* [MCP SDK를 사용하여 자신의 서버 구축하기](https://modelcontextprotocol.io/quickstart/server)
