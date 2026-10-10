> ## Documentation Index
> Fetch the complete documentation index at: https://code.claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# MCP를 통해 Claude Code를 도구에 연결하기

> Model Context Protocol을 사용하여 Claude Code를 도구에 연결하는 방법을 알아봅니다.

Claude Code는 AI 도구 통합을 위한 오픈 소스 표준인 [Model Context Protocol (MCP)](https://modelcontextprotocol.io/introduction)를 통해 수백 개의 외부 도구 및 데이터 소스에 연결할 수 있습니다. MCP 서버는 Claude Code에 도구, 데이터베이스 및 API에 대한 액세스를 제공합니다.

다른 도구(예: 이슈 추적기 또는 모니터링 대시보드)에서 채팅으로 데이터를 복사하는 자신을 발견할 때 서버를 연결하세요. 연결되면 Claude는 붙여넣은 내용에서 작업하는 대신 해당 시스템을 직접 읽고 작동할 수 있습니다.

첫 번째 서버를 연결하는 경우 단계별 안내를 위해 [MCP 빠른 시작](/docs/ko/mcp-quickstart)으로 시작하세요. 이 페이지는 전체 참고 자료입니다.

<h2 id="what-you-can-do-with-mcp">
  MCP로 할 수 있는 것
</h2>

MCP 서버가 연결되면 Claude Code에 다음을 요청할 수 있습니다:

* **이슈 추적기에서 기능 구현**: "JIRA 이슈 ENG-4521에 설명된 기능을 추가하고 GitHub에서 PR을 생성하세요."
* **모니터링 데이터 분석**: "Sentry와 Statsig을 확인하여 ENG-4521에 설명된 기능의 사용량을 확인하세요."
* **데이터베이스 쿼리**: "PostgreSQL 데이터베이스를 기반으로 기능 ENG-4521을 사용한 무작위 사용자 10명의 이메일을 찾으세요."
* **디자인 통합**: "Slack에 게시된 새로운 Figma 디자인을 기반으로 표준 이메일 템플릿을 업데이트하세요."
* **워크플로우 자동화**: "이 10명의 사용자를 새로운 기능에 대한 피드백 세션에 초대하는 Gmail 초안을 생성하세요."
* **외부 이벤트에 반응**: MCP 서버는 [채널](/docs/ko/channels)로도 작동할 수 있으며, 세션에 메시지를 푸시하므로 Claude는 자리를 비운 동안 Telegram 메시지, Discord 채팅 또는 webhook 이벤트에 반응할 수 있습니다.

<h2 id="find-and-build-mcp-servers">
  MCP 서버 찾기 및 구축
</h2>

[Anthropic Directory](https://claude.ai/directory)에서 검토된 커넥터를 찾아보세요. Directory 커넥터는 Claude Code와 동일한 MCP 인프라를 사용하므로 `claude mcp add`를 사용하여 여기에 나열된 모든 원격 서버를 추가할 수 있습니다.

<Warning>
  연결하기 전에 각 서버를 신뢰할 수 있는지 확인하세요. 외부 콘텐츠를 가져오는 서버는 [프롬프트 주입 위험](/docs/ko/security#protect-against-prompt-injection)에 노출될 수 있습니다.
</Warning>

자신만의 서버를 구축하려면 프로토콜 기본 사항에 대한 [MCP 서버 가이드](https://modelcontextprotocol.io/docs/develop/build-server)와 인증, 테스트 및 Directory 제출에 대한 [Claude 커넥터 구축 문서](https://claude.com/docs/connectors/building)를 참조하세요.

공식 [`mcp-server-dev` 플러그인](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/mcp-server-dev)을 사용하여 Claude가 서버를 스캐폴드하도록 할 수도 있습니다.

<Steps>
  <Step title="플러그인 설치">
    VS Code 확장 프로그램이나 데스크톱 앱에서는 이 단계 대신 [플러그인 설치](/docs/ko/plugins/install#install-a-plugin)를 따르세요. 터미널에서는 `claude`를 실행하여 Claude Code를 시작한 다음 프롬프트에 다음을 입력하세요:

    ```
    /plugin install mcp-server-dev@claude-plugins-official
    ```

    설치가 실패하면 Claude Code가 보고하는 메시지와 일치하는지 확인하세요:

    * `Marketplace "claude-plugins-official" not found`: `/plugin marketplace add anthropics/claude-plugins-official`로 마켓플레이스를 추가한 다음 설치를 다시 시도하세요.
    * 플러그인이 [마켓플레이스에서 찾을 수 없음](/docs/ko/plugins/install#install-a-plugin): 플러그인 이름을 확인하세요.

    설치 요약에서 `Run /reload-plugins to apply.`를 보고하면 Claude Code가 해당 리로드를 실행합니다. 리로드에서 다음 메시지가 대화를 다시 읽을 것이라고 경고하면 `/reload-plugins --force`를 실행하세요.
  </Step>

  <Step title="빌드 스킬 실행">
    ```
    /mcp-server-dev:build-mcp-server
    ```

    Claude가 사용 사례에 대해 묻고 원격 HTTP 또는 로컬 stdio 서버를 스캐폴드합니다.
  </Step>
</Steps>

<h2 id="installing-mcp-servers">
  MCP 서버 설치
</h2>

MCP 서버는 필요에 따라 여러 가지 방식으로 구성할 수 있습니다:

<h3 id="option-1-add-a-remote-http-server">
  옵션 1: 원격 HTTP 서버 추가
</h3>

HTTP 서버는 원격 MCP 서버에 연결하기 위한 권장 옵션입니다. 이는 클라우드 기반 서비스에 가장 널리 지원되는 전송 방식입니다.

```bash theme={null}
# 기본 구문
claude mcp add --transport http <name> <url>

# 실제 예: Notion에 연결
claude mcp add --transport http notion https://mcp.notion.com/mcp

# Bearer 토큰을 사용한 예
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

`.mcp.json`, `~/.claude.json` 또는 `claude mcp add-json`을 통해 JSON으로 MCP 서버를 구성할 때, `type` 필드는 `http`의 별칭으로 `streamable-http`를 허용합니다. MCP 사양은 이 전송에 대해 `streamable-http`라는 이름을 사용하므로 서버 설명서에서 복사한 구성이 수정 없이 작동합니다.

`url`은 있지만 `type`이 없는 JSON 항목은 구성 오류입니다. Claude Code는 `type`이 없는 항목을 stdio 서버로 읽기 때문입니다. Claude Code는 해당 서버를 건너뛰고 `MCP server "<name>" has a "url" but no "type"; add "type": "http" (or "sse" / "ws") to this entry`를 보고합니다. v2.1.202 이전에는 Claude Code가 이 잘못된 구성을 `command: expected string, received undefined`로 보고했습니다.

SDK 호스트 애플리케이션 (예: [Agent SDK](/docs/ko/agent-sdk/mcp) 애플리케이션 또는 [데스크톱 앱](/docs/ko/desktop))만 인프로세스 `"type": "sdk"` 서버를 등록할 수 있습니다. Claude Code는 `.mcp.json`, `~/.claude.json` 또는 설정의 `"type": "sdk"` 항목을 건너뛰고 `Skipped — MCP server "<name>" declares type "sdk", which only an SDK host application can register`를 보고합니다.

`--output-format stream-json` 실행에서 Claude Code는 또한 `system/init` 이벤트의 [`mcp_server_errors` 필드](/docs/ko/headless#stream-responses)에서 건너뛴 `--mcp-config` 항목을 보고하므로 스크립트가 서버가 로드되지 않았음을 감지할 수 있습니다. 이는 Claude Code v2.1.219 이상이 필요합니다.

<h3 id="option-2-add-a-remote-sse-server">
  옵션 2: 원격 SSE 서버 추가
</h3>

<Warning>
  SSE (Server-Sent Events) 전송은 더 이상 사용되지 않습니다. 가능한 경우 HTTP 서버를 사용하세요.
</Warning>

일부 서비스는 여전히 SSE 엔드포인트만 노출합니다. [HTTP 서버](#option-1-add-a-remote-http-server)와 동일한 `claude mcp add --transport http <name> <url>` 명령으로 추가하세요. Claude Code는 HTTP 전송을 먼저 시도하고 서버가 이를 허용하지 않을 때 SSE로 전환합니다. 자동 전환에는 Claude Code v2.1.265 이상이 필요합니다.

이전 버전에서 또는 SSE를 통해 직접 연결하려면 대신 `--transport sse`를 전달하세요:

```bash theme={null}
# 기본 구문
claude mcp add --transport sse <name> <url>

# 실제 예: Asana에 연결
claude mcp add --transport sse asana https://mcp.asana.com/sse

# 인증 헤더를 사용한 예
claude mcp add --transport sse private-api https://api.company.com/sse \
  --header "X-API-Key: your-key-here"
```

<h3 id="option-3-add-a-local-stdio-server">
  옵션 3: 로컬 stdio 서버 추가
</h3>

Stdio 서버는 컴퓨터에서 로컬 프로세스로 실행됩니다. 시스템에 직접 액세스하거나 사용자 정의 스크립트가 필요한 도구에 이상적입니다.

Claude Code는 생성된 서버의 환경에서 `CLAUDE_PROJECT_DIR`을 프로젝트 루트로 설정하므로 서버는 작업 디렉터리에 의존하지 않고 프로젝트 상대 경로를 확인할 수 있습니다. 이는 훅이 `CLAUDE_PROJECT_DIR` 변수에서 받는 것과 동일한 디렉터리입니다. 서버 프로세스 내에서 읽으세요. 예를 들어 Node에서는 `process.env.CLAUDE_PROJECT_DIR` 또는 Python에서는 `os.environ["CLAUDE_PROJECT_DIR"]`입니다.

`CLAUDE_PROJECT_DIR`은 안정적인 프로젝트 루트이며 세션 중에 작업 디렉터리를 추가하거나 제거할 때 변경되지 않습니다. 자신의 파일 시스템 액세스를 허용된 디렉터리 집합으로 제한하는 서버는 대신 MCP `roots/list` 요청을 구현해야 합니다. Claude Code는 `roots/list`에 세션의 시작 디렉터리와 `--add-dir`, `/add-dir` 또는 `additionalDirectories` 설정으로 부여한 모든 [추가 작업 디렉터리](/docs/ko/permissions#working-directories)로 응답합니다. Claude Code는 해당 집합이 변경될 때 `notifications/roots/list_changed`를 보냅니다. v2.1.203 이전에는 `roots/list`가 시작 디렉터리만 반환했고 Claude Code는 `notifications/roots/list_changed`를 보내지 않았습니다.

이 변수는 Claude Code 자체의 환경이 아닌 서버의 환경에 설정되므로 프로젝트 범위 `.mcp.json` 항목 또는 `~/.claude.json`의 로컬 범위 또는 사용자 범위 서버 항목의 `command` 또는 `args`에서 `${VAR}` 확장을 통해 참조하려면 `${CLAUDE_PROJECT_DIR:-.}`와 같은 기본값이 필요합니다. 플러그인 제공 MCP 구성은 `${CLAUDE_PROJECT_DIR}`을 직접 대체하며 기본값이 필요하지 않습니다.

```bash theme={null}
# 기본 구문
claude mcp add [options] <name> -- <command> [args...]

# 실제 예: Airtable 서버 추가
claude mcp add --env AIRTABLE_API_KEY=YOUR_KEY --transport stdio airtable \
  -- npx -y airtable-mcp-server
```

<Note>
  Stdio 서버의 경우, `--` (이중 대시)는 Claude의 자체 옵션(예: `--transport`, `--env`, `--scope`)과 서버를 실행하는 명령 및 인수를 구분합니다. `--` 이후의 모든 것은 서버에 그대로 전달됩니다.

  예를 들어:

  * `claude mcp add --transport stdio myserver -- npx server` → `npx server` 실행
  * `claude mcp add --env KEY=value --transport stdio myserver -- python server.py --port 8080` → 환경에서 `KEY=value`를 사용하여 `python server.py --port 8080` 실행

  `--`가 없으면 Claude Code는 위의 `--port`와 같은 서버의 플래그를 자신의 옵션으로 구문 분석하려고 시도합니다.

  `--env`는 여러 `KEY=value` 쌍을 허용합니다. 서버 이름이 `--env` 직후에 오면 CLI는 이름을 다른 쌍으로 읽고 거부하므로 `--env`와 서버 이름 사이에 최소한 하나의 다른 옵션(예: `--transport stdio`)을 배치하세요.
</Note>

<h3 id="option-4-add-a-remote-websocket-server">
  옵션 4: 원격 WebSocket 서버 추가
</h3>

WebSocket 서버는 지속적인 양방향 연결을 유지하므로 Claude에 예고 없이 이벤트를 푸시하는 원격 MCP 서버에 적합합니다. 서버가 요청에만 응답하는 경우 HTTP를 대신 사용하세요. HTTP는 OAuth 및 `claude mcp add --transport` 플래그를 지원하지만 WebSocket은 둘 다 지원하지 않습니다.

`.mcp.json` 또는 `claude mcp add-json`으로 WebSocket 서버를 구성하세요:

```bash theme={null}
claude mcp add-json events-server \
  '{"type":"ws","url":"wss://mcp.example.com/socket","headers":{"Authorization":"Bearer YOUR_TOKEN"}}'
```

`type: "ws"` 항목은 `http`와 동일한 `url`, `headers`, `headersHelper`, `timeout` 및 `alwaysLoad` 필드를 허용합니다. 인증은 헤더 전용이므로 `headers`에 정적 토큰을 전달하거나 [`headersHelper`](#use-dynamic-headers-for-custom-authentication)를 사용하여 연결 시 토큰을 생성하세요. `claude mcp add --transport` 플래그는 `ws`를 허용하지 않습니다.

<h3 id="add-a-server-from-setup-instructions-written-for-another-client">
  다른 클라이언트용으로 작성된 설정 지침에서 서버 추가
</h3>

MCP 서버는 Claude Code에만 해당하지 않으므로 서버의 설정 지침은 Claude Desktop, Cursor 또는 다른 MCP 클라이언트용으로 작성될 수 있으며 `claude mcp add` 명령을 제공하지 않을 수 있습니다. 어쨌든 서버를 추가하려면 해당 지침에서 URL, 시작 명령 또는 JSON 블록을 찾으세요:

* **URL** (예: `https://mcp.example.com/mcp`): 서버는 원격입니다.
* **시작 명령** (예: `npx -y @example/mcp-server`): 서버는 컴퓨터에서 실행됩니다.
* **`mcpServers` JSON 블록**: 다른 클라이언트의 설정 파일용으로 작성된 구성입니다.

각각은 [MCP 서버 설치](#installing-mcp-servers)의 네 가지 옵션 중 하나가 취하는 입력 중 하나입니다. 아래에서 보유한 형태를 찾아 Claude Code가 허용하는 명령으로 변환하세요. 각 명령은 `--scope project` 또는 `--scope user`를 추가하지 않는 한 [로컬 범위](#local-scope)에 씁니다.

<span id="from-a-url" />

<h4 id="add-a-server-from-a-url">
  URL에서 서버 추가
</h4>

URL은 서버가 원격임을 의미합니다. `https://` 엔드포인트의 경우 `--transport http`로 추가하거나, 지침에서 엔드포인트가 SSE를 사용한다고 말할 때 [옵션 2](#option-2-add-a-remote-sse-server)를 따르세요. `wss://` 엔드포인트의 경우 `--transport`가 `ws`를 허용하지 않으므로 대신 [옵션 4](#option-4-add-a-remote-websocket-server)를 사용하세요:

```bash theme={null}
claude mcp add --transport http example https://mcp.example.com/mcp
```

지침에서 API 키 또는 토큰 헤더도 제공하면 [옵션 1](#option-1-add-a-remote-http-server)에 표시된 대로 `--header`로 전달하세요.

<span id="from-an-npx-uvx-or-binary-command" />

<h4 id="add-a-server-from-an-npx-uvx-or-binary-command">
  `npx`, `uvx` 또는 바이너리 명령에서 서버 추가
</h4>

시작 명령은 서버가 로컬 stdio 프로세스로 실행됨을 의미합니다. 전체 명령을 `--` 뒤에 배치하여 Claude Code가 `-y`와 같은 플래그를 서버를 시작하는 명령에 전달하도록 하고 자신의 옵션으로 읽지 않도록 하세요. 지침에서 요청하는 환경 변수를 `--env`로 전달하세요. 서버 이름 뒤에 `--` 앞에:

```bash theme={null}
claude mcp add example --env API_KEY=your-key -- npx -y @example/mcp-server
```

[옵션 3](#option-3-add-a-local-stdio-server)은 `--` 구분자를 완전히 다룹니다.

<span id="from-an-mcpservers-json-block" />

<h4 id="add-a-server-from-an-mcpservers-json-block">
  `mcpServers` JSON 블록에서 서버 추가
</h4>

Claude Desktop과 같은 다른 MCP 클라이언트용으로 작성된 `mcpServers` 블록은 Claude Code가 읽는 래퍼 키와 항목 형태를 사용합니다. `claude mcp add-json`에 `mcpServers` 내부의 객체를 전달하세요. 래퍼는 아닙니다. 두 항목은 먼저 수리가 필요합니다:

* **`type`이 없는 `url`**: 엔드포인트와 일치하도록 `"type": "http"`, `"type": "sse"` 또는 `"type": "ws"`를 추가하세요. Claude Code는 `type`이 없는 항목을 stdio 서버로 읽으므로 `type`이 없는 `url` 항목은 실패합니다.
* **문자, 숫자, 하이픈 및 밑줄 이외의 문자가 있는 키**: 해당 문자만 사용하는 서버 이름을 선택하세요. 그렇지 않으면 키가 서버 이름입니다.

예를 들어, 이 블록:

```json theme={null}
{
  "mcpServers": {
    "example": {
      "command": "npx",
      "args": ["-y", "@example/mcp-server"]
    }
  }
}
```

이 명령이 됩니다:

```bash theme={null}
claude mcp add-json example '{"command":"npx","args":["-y","@example/mcp-server"]}'
```

[JSON 구성에서 MCP 서버 추가](#add-mcp-servers-from-json-configuration)는 셸 이스케이프 및 `add-json`의 `--scope` 플래그를 다룹니다. 대신 팀과 공유하려면 `--scope project`를 추가하거나 프로젝트 루트의 `.mcp.json`에서 `mcpServers` 아래에 항목을 추가하고 커밋하세요. [프로젝트 범위](#project-scope)는 Claude Code가 해당 파일을 로드하고 승인하는 방법을 다룹니다.

각 `claude mcp add` 및 `claude mcp add-json` 명령은 성공 시 `Added ...` 줄을 인쇄합니다. Claude Code가 연결되었는지 확인하려면 `claude mcp get <name>`을 실행하세요. [서버 상태](#server-status)는 표시되는 상태 및 `.mcp.json` 서버의 승인 단계를 다룹니다.

<h3 id="managing-your-servers">
  서버 관리
</h3>

구성한 후에는 다음 명령으로 MCP 서버를 관리할 수 있습니다:

```bash theme={null}
# 구성된 모든 서버 나열
claude mcp list

# 특정 서버의 세부 정보 가져오기
claude mcp get notion

# 서버 제거
claude mcp remove notion

# (Claude Code 내에서) 서버 상태 확인
/mcp
```

원격 서버를 제거하면 Claude Code는 해당 서버에 대해 저장한 OAuth 토큰 및 클라이언트 등록도 삭제합니다.

<h4 id="server-status">
  서버 상태
</h4>

`claude mcp add`는 `Added ...` 줄을 인쇄하여 성공적인 추가를 확인합니다. 이는 구성이 작성되었음을 의미합니다. 명령이 `was not saved` 메시지를 인쇄하면 [MCP 서버가 저장되지 않았거나 제거됨](/docs/ko/errors#mcp-server-was-not-saved-or-removed)을 참조하세요. `may not have been saved` 메시지의 경우 [MCP 서버가 저장되지 않았거나 제거되었을 수 있음](/docs/ko/errors#mcp-server-may-not-have-been-saved-or-removed)을 참조하세요.

`claude mcp list`는 나열하는 각 서버 옆에 `✔ Connected`, `! Needs authentication` 또는 `✘ Failed to connect`와 같은 상태를 표시합니다. 실패 상태는 Claude Code가 해당 서버에 연결할 수 없음을 의미하며, list 명령이 실패했음을 의미하지 않습니다.

이 목록의 상태는 연결 시도가 아닌 구성 결정을 보고하므로 Claude Code는 서버에 연결하지 않고 인쇄합니다:

* ``⏸ Pending approval (run `claude` to approve)``: 아직 승인하지 않은 `.mcp.json`의 프로젝트 범위 서버입니다. Claude Code는 `claude mcp list` 및 `claude mcp get <name>` 모두에 표시합니다. 대화형으로 `claude`를 실행하여 검토하고 승인하세요.
* `✘ Rejected (see disabledMcpjsonServers in settings)`: [`disabledMcpjsonServers`](/docs/ko/settings-reference#disabledmcpjsonservers) 항목이 거부하는 `.mcp.json` 서버입니다. Claude Code는 `claude mcp get <name>`에만 표시합니다.
* `⊘ Disabled for this project (re-enable via /mcp)`: 프로젝트의 [`disabledMcpServers`](#disable-a-server-without-removing-it) 목록이 이름을 지정하는 서버입니다. Claude Code는 `claude mcp list` 및 `claude mcp get <name>` 모두에 표시합니다. `/mcp` 패널에서 서버를 다시 켜세요.

<h4 id="project-server-approvals-and-workspace-trust">
  프로젝트 서버 승인 및 워크스페이스 신뢰
</h4>

v2.1.196부터 `claude mcp list` 및 `claude mcp get`은 `.mcp.json` 승인을 `claude`를 실행하고 워크스페이스 신뢰 대화 상자를 수락하여 워크스페이스를 신뢰할 때까지 저장소에 체크인되지 않은 설정 파일에서만 읽습니다. 복제된 저장소는 자신의 서버를 승인할 수 없습니다: 프로젝트의 `.claude/settings.json`에 커밋된 [`enableAllProjectMcpServers`](/docs/ko/settings-reference#enableallprojectmcpservers) 또는 [`enabledMcpjsonServers`](/docs/ko/settings-reference#enabledmcpjsonservers)는 신뢰할 수 없는 폴더에서 무시되며, 서버는 연결되고 상태 확인되는 대신 `⏸ Pending approval`으로 유지됩니다.

이러한 소스의 승인은 신뢰할 수 없는 폴더에서도 적용됩니다:

* 사용자 `~/.claude/settings.json`
* 관리형 설정
* `--settings`로 전달된 설정

Claude Code는 또한 추적되지 않은 `.claude/settings.local.json`의 승인을 적용하지만, git을 실행하여 파일이 추적되는지 확인하며, [신뢰할 수 있는 폴더](/docs/ko/permissions#project-allow-rules-and-workspace-trust)에서만 해당 확인을 실행합니다. 신뢰한 적이 없는 폴더에서 Claude Code는 파일의 승인을 적용하기 전에 신뢰 대화 상자를 기다립니다. 단, 폴더가 자신의 구성 홈인 경우는 제외됩니다: 홈 디렉터리 또는 `.claude`를 [`CLAUDE_CONFIG_DIR`](/docs/ko/env-vars)으로 설정한 디렉터리입니다. v2.1.207 이전에는 Claude Code가 신뢰한 적이 없는 폴더에서도 추적되지 않은 `.claude/settings.local.json`의 승인을 적용했습니다.

모든 설정 파일의 `disabledMcpjsonServers` 항목은 여전히 서버를 거부합니다.

<h4 id="server-status-detail">
  서버 상태 세부 정보
</h4>

`/mcp`에서 (서버의 메뉴 포함) 및 [`/plugin`](/docs/ko/plugins/install) 관리자에서, 이전에 사용한 원격 HTTP 또는 SSE 서버는 `cached 2h ago · connects on first use · 5 tools`와 같은 `cached` 상태를 표시할 수 있습니다. Claude Code는 이전 세션에서 저장된 검색 캐시에서 서버의 도구 목록을 로드했으며, Claude Code는 Claude가 서버의 도구 중 하나를 처음 호출할 때 서버에 연결합니다. 도구는 첫 번째 메시지부터 사용 가능하므로 아무것도 할 필요가 없습니다. 검색 캐시 및 `cached` 상태에는 Claude Code v2.1.221 이상이 필요합니다.

검색 캐시는 기본적으로 꺼져 있으며, 점진적 롤아웃이 계정에 대해 활성화하지 않는 한 꺼져 있습니다. [`MCP_DISCOVERY_CACHE=1`](/docs/ko/env-vars)을 설정하여 켜거나, 롤아웃이 활성화했을 때도 꺼진 상태로 유지하려면 `0`으로 설정하세요. v2.1.238 이전에는 캐시가 기본적으로 켜져 있었습니다.

`/mcp`의 서버 메뉴에서 **Disable** 또는 **Clear authentication**을 선택하면 Claude Code는 해당 서버의 캐시 항목도 삭제합니다. **Reconnect**는 연결되거나 실패한 서버에서도 삭제합니다. `cached` 서버에서 **Reconnect**는 지금 서버에 연결하고 항목을 유지합니다. 항목을 삭제한 후 Claude Code가 서버에 다시 연결할 때, 캐시 대신 서버에서 서버의 도구 목록을 가져옵니다.

서버의 상태가 `✘ Failed to connect`일 때, `claude mcp list`는 해당 상태 줄에 실패 세부 정보를 추가하고, `claude mcp get <name>`은 `Issue:` 줄에 표시합니다: HTTP 상태 또는 오류 코드, 그리고 서버가 반환한 오류 텍스트입니다. `/mcp`의 서버 세부 정보 보기는 `Issue:` 행에 동일한 서버 보고 텍스트를 포함합니다. Claude Code는 이 세부 정보에서 자격 증명처럼 보이는 텍스트를 가리고, 비밀을 포함할 수 있는 확장된 서버 URL은 절대 포함하지 않습니다. Claude Code는 `✘ Connection error` 상태에 세부 정보를 추가하지 않습니다. 인쇄할 예외 텍스트가 해당 URL을 포함할 수 있기 때문입니다. v2.1.219 이전에는 두 명령 모두 상태 코드 또는 서버의 오류 텍스트 없이 기본 실패 상태만 표시했습니다.

`/mcp`에서 인증을 완료하고 연결이 여전히 HTTP 상태 또는 전송 오류 코드로 실패하면 Claude Code는 시도한 후 인쇄하는 메시지에 해당 코드와 서버 URL의 원점을 추가합니다. 원점은 스킴 및 호스트, 그리고 URL이 포트를 지정할 때 포트입니다. 예: `https://mcp.example.com`.

* 경로 및 쿼리는 해당 메시지에 나타나지 않습니다.
* 로컬, 프로젝트, 사용자 [범위](#mcp-installation-scopes) 또는 관리형 MCP 구성의 서버의 경우, 원점은 해당 구성에 작성된 호스트를 표시하므로 호스트의 `${VAR}` 참조는 메시지에서 확장되지 않습니다.
* 상태 또는 오류 코드가 없는 실패의 경우 Claude Code는 원점 없이 오류 텍스트를 표시합니다.

구성의 `url`이 비어 있는 원격 서버는 `/mcp`, `claude mcp list` 및 [`/plugin`](/docs/ko/plugins/install) 관리자에서 `not configured`로 표시되며, Claude Code는 연결을 시도하지 않습니다. 플러그인은 나중에 구성할 커넥터를 위해 이와 같은 자리 표시자 항목을 포함할 수 있으므로 Claude Code는 이를 오류 또는 설정 문제로 보고하지 않습니다. `/mcp`의 서버 세부 정보 보기에는 `No URL configured for this server`가 표시됩니다. 연결하려면 항목의 `url`을 설정하세요. v2.1.208 이전에는 Claude Code가 빈 `url`을 재연결 프롬프트와 함께 구성 문제로 보고했습니다.

<h4 id="configuration-warnings">
  구성 경고
</h4>

Claude Code는 아래의 구성 문제에 대해 경고합니다. 각 항목은 Claude Code가 확인하는 내용과 경고를 지우는 방법을 설명합니다:

* **숨겨진 공백**: Claude Code는 MCP 구성 값이 숨겨진 선행 또는 후행 공백을 전달할 때 경고합니다. 이는 종종 후행 줄 바꿈이 있는 토큰을 붙여넣기에서 나옵니다. Claude Code는 `command`, `url`, 각 `args` 항목, 그리고 `env` 및 `headers` 아래의 값과 키 이름을 확인합니다. Claude Code는 `claude mcp list` 출력 및 `/mcp`에서 경고를 표시하며, 값을 그대로 보여주지 않고 영향을 받는 필드의 이름만 지정합니다. 예: `Leading or trailing whitespace in: headers.Authorization`. Claude Code는 공백을 자르지 않고 작성된 대로 정확히 값을 사용하므로 구성을 편집하여 제거하세요.
* **둘 이상의 범위에서 동일한 이름**: 다른 엔드포인트를 사용하여 둘 이상의 [범위](#mcp-installation-scopes)에서 동일한 서버 이름을 정의하면 Claude Code는 `claude mcp list` 출력 및 `/mcp`에서 충돌에 대해 경고합니다. Claude Code는 엔드포인트당 OAuth 로그인을 저장하므로 한 프로젝트에서 로드되는 정의를 인증할 때, 다른 정의가 로드되는 프로젝트에서는 여전히 별도로 로그인해야 합니다. 원하는 엔드포인트를 유지하고 `claude mcp remove <name> --scope <scope>`로 다른 엔드포인트를 제거하세요. 경고에서 Claude Code는 각 범위의 엔드포인트를 구성에 작성된 대로 인용합니다. [`${VAR}` 참조](#environment-variable-expansion-in-mcp-json)는 확장되지 않으므로 API 키와 같은 확인된 값을 표시하지 않습니다.
* **예약된 이름**: Claude Code는 `workspace`, `claude-in-chrome`, `computer-use`, `Claude Preview` 및 `Claude Browser`를 포함한 기본 제공 서버의 이름을 예약합니다. 구성에서 예약된 이름의 서버를 정의하면 Claude Code는 로드 시 이를 건너뛰고 이름을 바꾸도록 요청하는 경고를 표시합니다. `claude mcp add`는 예약된 이름을 오류로 거부합니다. `Claude Preview` 및 `Claude Browser`는 모두 [Claude Code 데스크톱 앱의 미리보기 창](/docs/ko/desktop#preview-your-app)이 사용하는 기본 제공 서버의 이름입니다.
* **누락된 환경 변수**: 서버 구성의 [`${VAR}` 참조](#environment-variable-expansion-in-mcp-json)가 설정되지 않은 변수의 이름을 지정하고 `:-default`가 없으면 Claude Code는 `claude mcp list` 출력 및 `/mcp`에서 경고하며, 변수의 이름을 지정하고, 여전히 `${VAR}` 텍스트가 확장되지 않은 상태로 서버를 로드합니다. 변수를 설정하거나 `${VAR:-default}` 폴백을 추가하세요. 원격 서버의 `url` 및 `headers`에서 일부 자격 증명 변수는 [경고 없이 비어 있는 것으로 읽습니다](#credential-variables-that-read-as-empty).

<h4 id="tool-availability">
  도구 가용성
</h4>

`/mcp` 패널은 각 연결된 서버 옆에 도구 개수를 표시하고 도구 기능을 광고하지만 도구를 노출하지 않는 서버에 플래그를 지정합니다.

요청이 백그라운드에서 아직 연결 중인 서버의 도구가 필요한 경우 Claude는 해당 서버가 연결될 때까지 기다립니다. 대기 방식은 구성에 따라 다릅니다:

* **[도구 검색](#scale-with-mcp-tool-search) 포함 (기본값)**: 대기는 `ToolSearch` 호출 내에서 발생합니다.
* **도구 검색 없음**: Claude는 대신 `WaitForMcpServers` 도구를 사용합니다. 도구 검색이 없는 구성에는 사용자 정의 `ANTHROPIC_BASE_URL`, `ENABLE_TOOL_SEARCH=false` 및 Google Cloud의 Agent Platform에서 Claude 4.5 세대보다 이전 모델이 포함됩니다.
* **Microsoft Foundry [Azure에서 호스팅되는 배포](https://platform.claude.com/docs/en/build-with-claude/claude-in-microsoft-foundry#hosting-options)**: Claude Code는 배포의 서버 측 거부를 API를 통해서만 발견하므로 Claude는 `WaitForMcpServers`가 아닌 도구 검색 경로에서 시작합니다. Claude Code가 해당 배포를 [사전 로드](#scale-with-mcp-tool-search)로 전환한 후에는 연결을 완료한 서버의 도구가 Claude의 다음 요청에서 사용 가능해집니다.

도구 검색이 활성화되면 Claude가 작업 중일 때 서버가 연결을 완료하면 Claude Code는 같은 턴의 다음 요청에서 서버의 도구 이름을 Claude에 나열합니다. 그러면 Claude는 사용자의 다음 메시지를 기다리지 않고 해당 도구를 검색하고 호출할 수 있습니다.

세션을 재개한 후에는 도구의 MCP 서버가 아직 연결 중인 동안에도 Claude가 저장된 대화의 도구를 호출할 수 있습니다. 서버가 첫 번째 연결 시도 중인 동안 Claude Code는 호출을 최대 10초 동안 보류하고 도구를 사용할 수 있게 되면 실행합니다. 서버가 제시간에 연결되지 않거나 이미 [실패한 시도 후 재시도 중](#automatic-reconnection)인 경우, 호출은 `No such tool available` [도구 오류](/docs/ko/errors#no-such-tool-available)로 실패합니다.

<h3 id="disable-a-server-without-removing-it">
  서버를 제거하지 않고 비활성화
</h3>

`/mcp` 패널에서 서버를 토글하여 Claude Code가 구성을 잃지 않고 연결하지 않도록 중지합니다. Claude Code는 여전히 `/mcp`에서 서버를 나열하며, 비활성화로 표시합니다.

서버를 토글하면 Claude Code는 `~/.claude.json`의 프로젝트당 선택을 기록합니다. 이는 분리된 서버 집합을 포함하는 두 목록 중 하나입니다:

* `disabledMcpServers`: 사용자 구성 서버, 플러그인 서버, 조직이 [관리형 설정을 통해 제공](/docs/ko/managed-mcp#provide-servers-through-managed-settings)하는 서버, Claude Code가 [자체적으로 가져오는](#how-connectors-reach-claude-code) claude.ai 커넥터 및 기본적으로 켜져 있는 기본 제공 서버에 대한 옵트아웃 목록입니다. Claude Code는 여기에 나열한 서버에 연결하지 않습니다. [claude.ai 커넥터 비활성화](#disable-claude-ai-connectors)에 설명된 프로젝트별 `/mcp` 토글로 claude.ai 커넥터를 비활성화하면 Claude Code는 이를 표시 이름 (예: `claude.ai Slack`)으로 이 목록에 씁니다.
* `enabledMcpServers`: `computer-use`와 같이 기본적으로 꺼져 있는 기본 제공 서버에 대한 옵트인 목록입니다. Claude Code는 여기에 나열할 때만 기본 꺼짐 서버에 연결합니다.

Claude Code는 각 서버에 대해 정확히 두 목록 중 하나를 참조하므로 어느 목록도 다른 목록을 재정의하지 않습니다. 일반 서버를 `enabledMcpServers`에 추가하거나 기본 꺼짐 기본 제공 서버를 `disabledMcpServers`에 추가하면 Claude Code는 항목을 무시합니다.

`disabledMcpServers` 및 `enabledMcpServers`는 [`enabledMcpjsonServers`](/docs/ko/settings-reference#enabledmcpjsonservers) 및 [`disabledMcpjsonServers`](/docs/ko/settings-reference#disabledmcpjsonservers)와 무관합니다. 이는 프로젝트의 `.mcp.json` 파일에 정의된 서버의 승인을 제어합니다.

<h3 id="mcp-client-runtimes">
  MCP 클라이언트 런타임
</h3>

Claude Code는 두 클라이언트 런타임 중 하나를 통해 MCP 서버에 연결합니다. v1 런타임은 MCP TypeScript SDK 1.x를 기반으로 합니다. v2 런타임은 [MCP TypeScript SDK 2.0](https://ts.sdk.modelcontextprotocol.io/v2/)의 동일한 코드이며, MCP 프로토콜 개정 2026-07-28을 추가합니다. 이 페이지의 나머지는 v2 런타임을 이름으로 지정하는 섹션을 제외하고 두 런타임 모두에 적용됩니다.

Claude Code는 시작할 때마다 런타임을 선택하고 종료할 때까지 유지합니다. [기능 플래그를 가져오는](/docs/ko/env-vars#features-that-need-feature-flag-fetching) 세션에서 Claude Code v2.1.232 이상에서 v2 런타임을 사용합니다.

기능 플래그를 가져오지 않는 세션에서 Claude Code는 Claude Code v2.1.274 이상에서 기본적으로 v2 런타임을 사용합니다:

* Amazon Bedrock, Claude Platform on AWS, Google Cloud의 Agent Platform 또는 Microsoft Foundry의 세션. Claude Code를 내장한 호스트 플랫폼이 [`CLAUDE_CODE_PROVIDER_MANAGED_BY_HOST`](/docs/ko/env-vars)를 설정한 경우는 제외
* [Claude 앱 게이트웨이](/docs/ko/claude-apps-gateway)를 통해 로그인한 세션
* 텔레메트리 또는 기능 플래그 가져오기를 끈 세션. 예를 들어 `DISABLE_TELEMETRY`

v2에서 Claude Code는 또한:

* HTTP, stdio 및 claude.ai 커넥터 서버에 더 새로운 개정을 지원하는지 묻고, 지원하는 서버와 함께 사용합니다. 다른 모든 서버에는 v1처럼 연결합니다.
* [열린 스트림](#notification-streams-on-the-v2-runtime)을 통해 더 새로운 개정의 서버에서 `list_changed` 알림을 받습니다.
* 더 새로운 개정에 연결되는 [채널](#push-messages-with-channels) 서버를 등록하지 않습니다. 해당 개정은 채널 메시지를 전달할 수 없기 때문입니다.
* 인증 응답이 예상치 못한 발급자의 이름을 지정하는 [MCP OAuth 로그인](#authenticate-with-remote-mcp-servers)을 실패합니다.
* [MCP OAuth](#authenticate-with-remote-mcp-servers) 자격 증명을 HTTPS를 통해 제공되거나 `localhost`, `127.0.0.1` 또는 `::1`에서 제공되는 토큰 엔드포인트에만 보냅니다. 토큰 엔드포인트가 로컬 네트워크의 장치와 같은 다른 곳에서 일반 `http://`인 서버의 로그인이 실패합니다. [HTTPS가 아닌 토큰 엔드포인트로 자격 증명 전송 거부](/docs/ko/errors#refusing-to-send-credentials-to-non-https-token-endpoint)를 참조하세요.

Anthropic은 Claude Code가 가져오는 기능 플래그를 사용하여 특정 서버를 이전 프로토콜에 유지하거나 해당 스트림에서 제외할 수 있습니다.

런타임을 직접 선택하려면 [`MCP_SDK_GENERATION`](/docs/ko/env-vars)을 `v1` 또는 `v2`로 설정하세요. Claude Code가 묻는지 결정하려면 [`MCP_PROTOCOL_NEGOTIATION`](/docs/ko/env-vars)을 `auto` 또는 `legacy`로 설정하세요.

<h3 id="dynamic-tool-updates">
  동적 도구 업데이트
</h3>

MCP 서버는 연결된 상태에서 제공하는 도구, 프롬프트 또는 리소스를 변경하고 `list_changed` 알림을 보낼 수 있습니다. 알림이 도착하면:

* **대화형 터미널 세션에서**는 Claude Code가 해당 서버에서 업데이트된 목록을 가져오므로 서버를 다시 연결할 필요가 없습니다.
* **`-p` 플래그를 사용하는 [비대화형 모드](/docs/ko/headless) 및 [Agent SDK](/docs/ko/agent-sdk/overview)에서**는 Claude Code가 이러한 알림에 대해 도구 목록만 새로 고칩니다.

새로 고침 요청이 실패하면 Claude Code는 나중에 새로 고침이 성공할 때까지 서버의 이전에 발견된 도구, 프롬프트 및 리소스를 유지합니다. v2.1.214 이전에는 새로 고침 중 일시적 오류가 서버의 도구, 프롬프트 및 리소스를 빈 목록으로 바꿨습니다.

<h4 id="notification-streams-on-the-v2-runtime">
  v2 런타임의 알림 스트림
</h4>

[v2 런타임](#mcp-client-runtimes)에서 Claude Code는 더 새로운 프로토콜 개정의 서버에서 열린 스트림을 통해 `list_changed` 알림을 받습니다. 스트림이 닫히면 Claude Code는 두 가지 제한으로 다시 엽니다:

* **스트림이 10초 이내에 다시 닫힘**: Claude Code는 최대 3번 다시 열고, 그 후 해당 연결에 대해 중지합니다.
* **스트림이 10초 이상 열려 있다가 닫힘** (서버리스 호스트에 대한 스트림이 일반적으로 하는 것처럼): 1시간에 5번 다시 열기 후 Claude Code는 다음 열기 전에 약 6시간을 기다립니다.

스트림이 다시 열릴 때까지 서버의 마지막 가져온 도구, 프롬프트 및 리소스를 유지합니다. 변경 사항을 더 빨리 선택하려면 `/mcp`에서 서버를 다시 연결하세요.

<h3 id="automatic-reconnection">
  자동 재연결
</h3>

Claude Code는 세션 중에 연결이 끊어진 원격 서버를 다시 연결하고 일시적 오류 후 HTTP 또는 SSE 서버의 첫 연결을 재시도합니다. Stdio 서버는 로컬 프로세스이며 Claude Code는 자동으로 재연결하지 않습니다.

<h4 id="mid-session-drops-of-a-remote-server">
  원격 서버의 세션 중 연결 끊김
</h4>

Claude Code는 지수 백오프를 사용하여 연결이 끊어진 원격 서버를 다시 연결합니다: 최대 5번의 시도, 1초 지연으로 시작하여 매번 두 배씩 증가합니다. 보이는 것은 Claude Code를 실행하는 방식에 따라 다릅니다:

* **대화형 세션**: `/mcp`는 Claude Code가 재연결하는 동안 서버를 보류 중으로 표시합니다. 5번의 실패 시도 후 Claude Code는 서버를 실패로 표시하거나 서버가 다시 인증이 필요할 때 인증 필요로 표시합니다. 실패로 표시할 때 `MCP server "<name>" disconnected · open /mcp to reconnect` 알림이 표시됩니다. `/mcp`에서 수동으로 재시도할 수 있습니다.
* **[`claude -p`](/docs/ko/headless) 실행 및 [Agent SDK](/docs/ko/agent-sdk/overview) 세션**: Claude Code는 동일한 일정으로 재연결하지만, 시도를 표시할 `/mcp` 패널은 없습니다.

<h4 id="failed-first-connections">
  실패한 첫 연결
</h4>

HTTP 또는 SSE 서버의 첫 연결이 5xx 응답, 연결 거부 또는 시간 초과와 같은 일시적 오류로 실패하면 Claude Code는 최대 3번 재시도합니다. 연결이 여전히 실패하면 Claude Code는 서버를 실패로 표시합니다.

Claude Code는 이 경우에 재시도하지 않습니다:

* WebSocket 서버의 첫 연결
* 인증 또는 찾을 수 없음 오류. 구성 변경이 필요하기 때문입니다. [`headersHelper`](#use-dynamic-headers-for-custom-authentication)가 서버의 `Authorization` 헤더의 유일한 소스일 때 Claude Code는 인증 오류를 재시도합니다. 각 시도에서 도우미를 다시 실행하고 새 자격 증명을 선택할 수 있기 때문입니다.

<h4 id="failed-discovery-requests">
  실패한 검색 요청
</h4>

서버가 연결된 후 Claude Code는 `tools/list`, `prompts/list` 및 `resources/list`와 같은 기능 검색 요청을 보냅니다. Claude Code는 일시적 네트워크 또는 서버 오류 후 짧은 백오프로 최대 3번 재시도합니다. 인증 오류, 4xx 응답 또는 요청 시간 초과는 재시도하지 않습니다.

<h4 id="retry-failed-servers-yourself">
  실패한 서버 직접 재시도
</h4>

실패했거나 인증이 필요한 모든 서버를 재시도하려면 `/mcp reconnect all`을 실행하세요. 대화형 터미널에서는 Claude Code v2.1.284 이상이 필요하며, 이전 버전은 그곳에서 `MCP server "all" not found`를 인쇄합니다.

<h4 id="how-claude-learns-that-a-server-failed">
  Claude가 서버 실패를 배우는 방법
</h4>

구성된 서버가 연결에 실패하면 Claude Code가 Claude에 알리는지 여부는 [도구 검색](#scale-with-mcp-tool-search)에 따라 다릅니다. 기본적으로 켜져 있습니다:

* 도구 검색을 사용하면 Claude Code는 Claude에 어느 서버가 실패했는지와 연결 오류를 알리므로, Claude는 응답에서 연결 실패를 보고합니다. Claude Code는 일치하는 도구를 찾지 못한 `ToolSearch` 결과에 동일한 정보를 포함합니다.
* [도구 검색이 없는 구성](#configure-tool-search)에서 Claude Code는 실패한 서버 연결을 Claude에 보고하지 않습니다.

<h3 id="push-messages-with-channels">
  채널을 사용한 메시지 푸시
</h3>

MCP 서버는 또한 메시지를 세션에 직접 푸시할 수 있으므로 Claude는 CI 결과, 모니터링 경고 또는 채팅 메시지와 같은 외부 이벤트에 반응할 수 있습니다. 이를 활성화하려면 서버가 `claude/channel` 기능을 선언하고 시작 시 `--channels` 플래그로 옵트인합니다. 공식적으로 지원되는 채널을 사용하려면 [채널](/docs/ko/channels)을 참조하거나, 자신만의 채널을 구축하려면 [채널 참조](/docs/ko/channels-reference)를 참조하세요.

[v2 런타임](#mcp-client-runtimes)에서 MCP 프로토콜 개정 2026-07-28을 협상하는 채널 서버는 채널 메시지를 전달할 수 없으므로 Claude Code는 이를 채널로 등록하지 않습니다. 해당 개정을 지원하지 않는 채널 서버는 이전 핸드셰이크로 연결되며 이전과 같이 등록됩니다.

Claude Code는 기본적으로 stdio 서버에 해당 개정을 요청합니다. stdio 채널 서버를 이전 핸드셰이크에 유지하려면 [`MCP_PROTOCOL_NEGOTIATION`](/docs/ko/env-vars)을 `legacy`로 설정하세요. 이렇게 하면 모든 서버가 이전 핸드셰이크에 유지됩니다.

<Tip>
  팁:

  * `-s` 또는 `--scope` 플래그를 사용하여 구성이 저장되는 위치를 지정하세요:
    * `local` (기본값): 현재 프로젝트에서만 사용자에게만 사용 가능
    * `project`: `.mcp.json` 파일을 통해 프로젝트의 모든 사람과 공유
    * `user`: 모든 프로젝트에서 사용자에게 사용 가능
  * `-e` 또는 `--env` 플래그로 환경 변수를 설정하세요 (예: `-e KEY=value`)
  * `--transport` 및 `--header` 플래그는 `-t` 및 `-H` 단축형도 허용합니다
  * `MCP_TIMEOUT` 환경 변수를 사용하여 MCP 서버 시작 시간 초과를 구성하세요 (예: `MCP_TIMEOUT=10000 claude`는 10초 시간 초과를 설정)
  * 서버당 도구 실행 시간 초과를 설정하려면 해당 서버의 `.mcp.json` 항목에 밀리초 단위의 `timeout` 필드를 추가하세요. 예를 들어 10분의 경우 `"timeout": 600000`입니다. 이는 해당 서버에만 `MCP_TOOL_TIMEOUT` 환경 변수를 재정의합니다
  * Claude Code는 MCP 도구 출력이 10,000 토큰을 초과할 때 경고를 표시하고 기본적으로 출력을 25,000 토큰으로 제한합니다. 토큰 제한을 변경하려면 `MAX_MCP_OUTPUT_TOKENS` 환경 변수를 설정하세요 (예: `MAX_MCP_OUTPUT_TOKENS=50000`). 경고 임계값은 고정됩니다. 서버가 도구 자체의 제한을 높이지 않는 한, 50,000자를 초과하는 성공한 텍스트 결과는 이 변수와 관계없이 파일에 저장됩니다. [MCP 출력 제한 및 경고](#mcp-output-limits-and-warnings)를 참조하세요
  * OAuth 2.0 인증이 필요한 원격 서버로 인증하려면 `/mcp`를 사용하세요
</Tip>

서버당 `timeout`은 도구 호출당 하드 월클록 제한이며, 서버의 진행 알림은 이를 연장하지 않습니다. 1000 미만의 값은 무시되고 `MCP_TOOL_TIMEOUT`으로 넘어가거나, 해당 변수가 설정되지 않은 경우 약 28시간의 기본값으로 넘어갑니다. HTTP, SSE 또는 [claude.ai 커넥터](/docs/ko/mcp#use-mcp-servers-from-claude-ai) 서버의 경우 서버의 첫 응답 바이트까지 각 요청을 포함하는 요청당 두 번째 타이머도 있습니다. Claude Code는 해당 타이머를 60초, 서버에 적용되는 도구 시간 초과 및 `MCP_TIMEOUT` 중 가장 큰 값으로 설정합니다. 설정되지 않은 `MCP_TOOL_TIMEOUT`의 28시간 기본값은 해당 비교에 들어가지 않으며, 60초 미만의 값은 타이머를 단축하지 않습니다. Stdio 및 WebSocket 서버에는 요청당 타이머가 없습니다.

서버당 최소 1000의 `timeout`은 또한 아래에 설명된 유휴 시간 초과의 하한으로 작동합니다: Claude Code는 서버당 `timeout`보다 더 빨리 유휴 상태로 인해 해당 서버의 도구 호출을 중단하지 않습니다. Claude Code v2.1.203 이상이 필요합니다.

MCP 서버에 대한 도구 호출이 유휴 윈도우 동안 응답 및 진행 알림을 보내지 않으면 월클록 제한을 기다리는 대신 오류로 중단됩니다. 유휴 시간 초과는 IDE 서버 및 SDK 인프로세스 서버를 제외한 모든 서버 유형에 적용됩니다. 유휴 윈도우는 HTTP, SSE, WebSocket 및 [claude.ai 커넥터](#use-mcp-servers-from-claude-ai) 서버의 경우 기본값 5분, stdio 서버의 경우 30분입니다. v2.1.203 이전에는 stdio 서버가 유휴 시간 초과에서 제외되었습니다.

[`CLAUDE_CODE_MCP_TOOL_IDLE_TIMEOUT`](/docs/ko/env-vars) 환경 변수를 밀리초 단위로 설정하여 유휴 윈도우를 변경하거나, `0`으로 설정하여 확인을 비활성화하세요.

이 시간 초과는 호출이 실행될 수 있는 기간을 제한하며, 항상 세션을 차단하는 기간을 제한하지는 않습니다: 2분을 지나 실행되는 주 대화 호출은 먼저 백그라운드 작업으로 이동합니다. [긴 도구 호출의 자동 백그라운드 처리](#automatic-backgrounding-of-long-tool-calls)를 참조하세요.

<h3 id="automatic-backgrounding-of-long-tool-calls">
  긴 도구 호출의 자동 백그라운드 처리
</h3>

주 대화에서 2분 이상 실행 중인 MCP 도구 호출은 세션을 차단하는 대신 백그라운드 작업으로 이동합니다. Claude는 작업 ID를 즉시 받고 계속 작업하며, 호출이 완료되면 결과가 작업 알림으로 도착합니다. 자동 백그라운드 처리에는 Claude Code v2.1.212 이상이 필요합니다.

작업은 [`/tasks`](/docs/ko/commands#all-commands)에 나타나며, 여기서 중지할 수도 있습니다. 작업은 세션을 종료하면 유지되지 않습니다. 작업 항목에는 서버가 보고한 최신 진행 상황이 표시됩니다.

호출이 백그라운드에서 실행되는 동안 호출당 제한이 여전히 적용됩니다: 서버당 `timeout` 또는 [`MCP_TOOL_TIMEOUT`](/docs/ko/env-vars)으로 설정된 월클록 제한 및 [`CLAUDE_CODE_MCP_TOOL_IDLE_TIMEOUT`](/docs/ko/env-vars)으로 설정된 유휴 시간 초과입니다.

[`CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS`](/docs/ko/env-vars) 환경 변수를 밀리초 단위로 설정하여 임계값을 변경하거나, `0`으로 설정하여 자동 백그라운드 처리를 끕니다. `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS`를 `1`로 설정하면 모든 다른 백그라운드 작업 기능과 함께 꺼집니다.

일부 호출은 백그라운드로 이동하지 않습니다:

* [서브에이전트](/docs/ko/sub-agents)의 호출; Claude Code는 주 대화 호출만 백그라운드 처리합니다
* IDE 서버에 대한 호출
* [비대화형 모드](/docs/ko/headless)의 호출. `CLAUDE_AUTO_BACKGROUND_TASKS`가 `1`로 설정되지 않는 한. 일회성 실행은 결과가 도착하기 전에 끝날 수 있기 때문입니다

열린 [유도 대화 상자](#respond-to-mcp-elicitation-requests)를 기다리는 호출은 대화 상자가 열려 있는 동안 백그라운드 처리되지 않습니다. 서버가 느린 것이 아니라 입력을 기다리고 있으므로 Claude Code는 대화 상자가 닫힐 때까지 이동을 연기합니다.

<h3 id="plugin-provided-mcp-servers">
  플러그인 제공 MCP 서버
</h3>

[플러그인](/docs/ko/plugins/overview)은 MCP 서버를 번들로 제공할 수 있으며, 플러그인을 활성화하면 도구 및 통합을 제공합니다.

**플러그인 MCP 서버의 작동 방식**:

* 플러그인은 플러그인 루트의 `.mcp.json` 또는 `plugin.json`에 인라인으로 MCP 서버를 정의합니다
* 플러그인을 활성화하면 Claude Code는 MCP 서버를 자동으로 시작합니다
* Claude Code는 플러그인 MCP 도구를 수동으로 구성된 MCP 도구와 함께 제공합니다
* 플러그인 서버를 추가하고 제거하려면 플러그인을 설치하거나 제거하세요. `/mcp` 명령이 아닙니다. 설치된 플러그인 서버를 `/mcp`에서 [토글하여 끌 수 있습니다](#disable-a-server-without-removing-it). 이는 플러그인을 제거하지 않고 Claude Code가 연결하지 않도록 중지합니다.

**플러그인 MCP 구성 예**:

플러그인 루트의 `.mcp.json`:

```json theme={null}
{
  "mcpServers": {
    "database-tools": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-server",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"],
      "env": {
        "DB_URL": "${DB_URL}"
      }
    }
  }
}
```

또는 `plugin.json`에 인라인:

```json theme={null}
{
  "name": "my-plugin",
  "mcpServers": {
    "plugin-api": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/api-server",
      "args": ["--port", "8080"]
    }
  }
}
```

**플러그인 MCP 기능**:

* **자동 라이프사이클**: 서버는 다음 지점에서 연결 및 연결 해제됩니다:
  * 세션 시작 시 Claude Code는 활성화된 플러그인의 서버를 자동으로 연결합니다. `/mcp`에서 이전에 사용한 원격 (HTTP 또는 SSE) 플러그인 서버는 [`cached` 상태](#server-status-detail)를 대신 표시할 수 있습니다. Claude Code는 Claude가 도구 중 하나를 처음 호출할 때 연결합니다.
  * 세션 중에 플러그인을 활성화하거나 비활성화하면 Claude Code는 변경이 적용될 때 MCP 서버를 연결하거나 연결 해제합니다. [플러그인 변경 사항을 다시 시작하지 않고 적용](/docs/ko/plugins/cli-reference#reload-plugins)은 그 시기를 설명합니다. 대화형 터미널이 없는 세션에서 `/reload-plugins`는 플러그인 MCP 서버를 연결하거나 연결 해제하지 않습니다. 이 변경 사항은 다음 세션에서 적용됩니다.
  * 다시 로드할 때 Claude Code는 구성이 변경되지 않은 플러그인 서버의 라이브 연결을 유지하고, 이름을 지정하지 않고 [Agent SDK에서 세션의 MCP 서버 목록을 바꿀 때](/docs/ko/agent-sdk/typescript#mcpsetserversresult) 동일하게 수행합니다.
  * v2.1.246 이상에서 [`/cd`로 세션을 이동](/docs/ko/permissions#move-the-session-to-another-directory)할 때 Claude Code는 새 디렉터리의 설정이 활성화하는 플러그인의 서버를 연결하고 더 이상 활성화되지 않는 플러그인의 서버를 연결 해제합니다. 이동 후 `/reload-plugins`를 실행할 필요가 없습니다.
  * [클라우드 세션](/docs/ko/claude-code-on-the-web)에서 아직 연결되지 않은 플러그인 서버에 대한 MCP 호출 (예: 유휴 세션이 깨어난 직후)은 서버를 요청 시 시작하고 연결을 기다립니다.
* **경로 자리 표시자**: `${CLAUDE_PLUGIN_ROOT}`는 플러그인의 설치 디렉터리로 확인되고, `${CLAUDE_PLUGIN_DATA}`는 [지속적인 상태](/docs/ko/plugins/components#path-variables-and-persistent-data) 디렉터리로 확인되며, `${CLAUDE_PROJECT_DIR}`은 안정적인 프로젝트 루트로 확인됩니다. 대체는 다음에 적용됩니다:
  * `stdio` 서버: `command`, `args`, `env`
  * `http`, `sse` 및 `ws` 서버: `url`, `headers` 및 `headersHelper`
* **사용자 환경 액세스**: 수동으로 구성된 서버와 동일한 환경 변수에 액세스
* **여러 전송 유형**: stdio, SSE, HTTP 및 WebSocket 전송 지원. 전송 지원은 서버에 따라 다를 수 있습니다.

플러그인 서버는 플러그인에서 온 것을 나타내는 표시기와 함께 `/mcp`에 나타납니다.

플러그인의 stdio 서버의 경우, `claude mcp get`은 `Command: stdio`, 빈 `Args:` 줄, 그리고 각 환경 변수를 `NAME=[REDACTED]`로 인쇄합니다. 값은 자격 증명을 전달할 수 있기 때문에 숨겨집니다.

**플러그인 MCP 도구 이름**:

플러그인 번들 MCP 서버의 도구는 호출 가능한 이름에 플러그인 이름과 서버 키를 모두 포함합니다. 전체 형식은 `mcp__plugin_<plugin-name>_<server-name>__<tool-name>`이며, `A-Z`, `a-z`, `0-9`, `_`, `-` 외의 모든 문자는 `_`로 바뀝니다. `my-plugin`이라는 플러그인에 번들된 `database-tools` 서버의 경우, `query` 도구는 다음과 같이 호출할 수 있습니다:

```
mcp__plugin_my-plugin_database-tools__query
```

[권한 규칙](/docs/ko/permissions)에서 도구를 참조할 때, 스킬의 `allowed-tools` 목록에서, [서브에이전트의 `tools` 필드](/docs/ko/sub-agents#available-tools)에서, 또는 [훅 matcher](/docs/ko/hooks#match-mcp-tools)에서 이 전체 이름을 사용하세요. `mcp__database-tools__.*`와 같은 베어 서버 키에 대해 작성된 훅 matcher는 플러그인 번들 서버에 대해 절대 실행되지 않습니다.

서버 자체는 `plugin:<plugin-name>:<server-name>` (예: `plugin:my-plugin:database-tools`)과 같은 범위 지정 이름으로 등록됩니다. 구성된 서버 이름이 예상되는 위치 (예: [`mcp_tool` 훅의 `server` 필드](/docs/ko/hooks#mcp-tool-hook-fields))에서 해당 이름을 사용하세요.

플러그인과 함께 MCP 서버를 번들로 제공하는 방법에 대한 자세한 내용은 [플러그인 구성 요소 참조](/docs/ko/plugins/components#mcp-servers)를 참조하세요.

<h2 id="mcp-installation-scopes">
  MCP 설치 범위
</h2>

MCP 서버는 세 가지 범위에서 구성할 수 있습니다. 선택한 범위는 서버가 로드되는 프로젝트와 구성이 팀과 공유되는지 여부를 제어합니다. 관리자는 [관리형 구성](#managed-mcp-configuration)을 통해 모든 사용자를 위해 서버를 배포하거나 제공할 수도 있습니다.

| 범위 | 로드 위치 | 팀과 공유 | 저장 위치 |
| - | - | - | - |
| [로컬](#local-scope) | 현재 프로젝트만 | 아니오 | `~/.claude.json` |
| [프로젝트](#project-scope) | 현재 프로젝트만 | 예, 버전 제어를 통해 | 프로젝트 루트의 `.mcp.json` |
| [사용자](#user-scope) | 모든 프로젝트 | 아니오 | `~/.claude.json` |

<h3 id="local-scope">
  로컬 범위
</h3>

로컬 범위는 기본값입니다. 로컬 범위 서버는 추가한 프로젝트에서만 로드되며 사용자에게만 비공개입니다. Claude Code는 해당 프로젝트의 경로 아래 `~/.claude.json`에 저장하므로 다른 프로젝트에는 동일한 서버가 나타나지 않습니다. 개인 개발 서버, 실험적 구성 또는 버전 제어에 포함하고 싶지 않은 자격 증명이 있는 서버에 로컬 범위를 사용하세요.

<Note>
  MCP 서버의 "로컬 범위"라는 용어는 일반 로컬 설정과 다릅니다. MCP 로컬 범위 서버는 `~/.claude.json` (홈 디렉토리)에 저장되고, 일반 로컬 설정은 `.claude/settings.local.json` (프로젝트 디렉토리)을 사용합니다. 설정 파일 위치에 대한 자세한 내용은 [설정](/docs/ko/settings#where-settings-live)을 참조하세요.
</Note>

```bash theme={null}
# 로컬 범위 서버 추가 (기본값)
claude mcp add --transport http stripe https://mcp.stripe.com

# 명시적으로 로컬 범위 지정
claude mcp add --transport http stripe --scope local https://mcp.stripe.com
```

명령은 `~/.claude.json` 내의 현재 프로젝트 항목에 서버를 작성합니다. 아래 예는 `/path/to/your/project`에서 실행할 때의 결과를 보여줍니다:

```json theme={null}
{
  "projects": {
    "/path/to/your/project": {
      "mcpServers": {
        "stripe": {
          "type": "http",
          "url": "https://mcp.stripe.com"
        }
      }
    }
  }
}
```

<h3 id="project-scope">
  프로젝트 범위
</h3>

프로젝트 범위 서버는 프로젝트 루트 디렉토리의 `.mcp.json` 파일에 구성을 저장하여 팀 협업을 가능하게 합니다. 프로젝트 범위 서버를 추가하면 Claude Code는 자동으로 이 파일을 생성하거나 적절한 구성 구조로 업데이트합니다. `.mcp.json`을 버전 제어에 체크인하여 팀의 모든 사람이 동일한 MCP 도구 및 서비스를 사용할 수 있도록 하세요.

```bash theme={null}
# 프로젝트 범위 서버 추가
claude mcp add --transport http shared-server --scope project https://example.com/mcp
```

결과 `.mcp.json` 파일은 표준화된 형식을 따릅니다:

```json theme={null}
{
  "mcpServers": {
    "shared-server": {
      "type": "http",
      "url": "https://example.com/mcp"
    }
  }
}
```

보안상의 이유로 Claude Code는 대화형 세션에서 `.mcp.json` 파일의 프로젝트 범위 서버를 사용하기 전에 승인을 요청합니다. 이러한 승인 선택을 재설정하려면 `claude mcp reset-project-choices`를 실행하세요.

`claude -p` 실행, [Agent SDK](/docs/ko/headless) 세션 및 [클라우드 세션](/docs/ko/claude-code-on-the-web)에서 Claude Code는 해당 프롬프트를 표시할 수 없습니다. 프로젝트 범위 서버를 묻지 않고 로드합니다. Claude Code는 또한 [`skipDangerousModePermissionPrompt`](/docs/ko/settings-reference#skipdangerousmodepermissionprompt)가 사용자 설정 또는 관리형 설정에 설정된 `bypassPermissions` 모드에서 시작한 세션에서 프롬프트를 건너뜁니다. 어쨌든 서버를 제외하려면:

* [`disabledMcpjsonServers`](/docs/ko/settings-reference#disabledmcpjsonservers)에 추가하면 모든 권한 모드에서 차단됩니다.
* [`--setting-sources`](/docs/ko/cli-reference#cli-flags)를 사용하거나 SDK의 `settingSources` 옵션으로 프로젝트 설정을 완전히 제외합니다.
* [`--strict-mcp-config`](/docs/ko/cli-reference#cli-flags)로 세션을 시작합니다. Claude Code는 `--mcp-config`로 전달한 MCP 서버만 사용합니다. Claude Code가 로드하지 않는 프로젝트 범위 서버에 대한 승인 프롬프트를 건너뛰려면 Claude Code v2.1.246 이상이 필요합니다. v2.1.246 이전에는 엄격한 세션도 승인을 기다렸으므로 백그라운드 세션이 시작 시 대기했습니다. 관리형 MCP 파일에서 플래그가 수행하는 작업에 대해서는 [관리형-mcp.json을 사용한 독점 제어](/docs/ko/managed-mcp#exclusive-control-with-managed-mcp-json)를 참조하세요.

[프로젝트 서버 승인 및 워크스페이스 신뢰](#project-server-approvals-and-workspace-trust)는 저장소에 커밋된 승인이 워크스페이스 신뢰와 상호 작용하는 방식을 다룹니다.

<h3 id="user-scope">
  사용자 범위
</h3>

사용자 범위 서버는 `~/.claude.json`에 저장되며 교차 프로젝트 접근성을 제공하므로 컴퓨터의 모든 프로젝트에서 사용할 수 있으면서 사용자 계정에만 비공개입니다. 이 범위는 개인 유틸리티 서버, 개발 도구 또는 다양한 프로젝트에서 자주 사용하는 서비스에 적합합니다.

```bash theme={null}
# 사용자 서버 추가
claude mcp add --transport http hubspot --scope user https://mcp.hubspot.com/anthropic
```

<h3 id="scope-hierarchy-and-precedence">
  범위 계층 및 우선순위
</h3>

동일한 서버가 둘 이상의 위치에 정의되면 Claude Code는 가장 높은 우선순위 소스의 정의를 사용하여 한 번 연결합니다. 해당 소스의 전체 서버 항목이 사용되며, 필드는 범위 간에 병합되지 않습니다.

1. 로컬 범위
2. 프로젝트 범위
3. 사용자 범위
4. [플러그인 제공 서버](/docs/ko/plugins/components#mcp-servers)
5. [claude.ai 커넥터](#use-mcp-servers-from-claude-ai)

세 범위는 이름으로 중복을 일치시킵니다. 플러그인과 커넥터는 엔드포인트로 일치하므로 위의 서버와 동일한 URL 또는 명령을 가리키는 것은 중복으로 처리됩니다.

두 URL 표기법은 스킴 또는 호스트의 문자 대소문자, 스킴의 기본 포트(예: `https`의 `:443`) 또는 후행 슬래시에서만 다를 때 동일한 엔드포인트로 간주됩니다. 다른 경로, 쿼리 문자열, userinfo 또는 기본이 아닌 포트는 두 서버를 구분합니다.

조직이 [`managedMcpServers`](/docs/ko/managed-mcp#provide-servers-through-managed-settings) 관리형 설정을 통해 제공하는 서버는 이 모든 것 위에 순위가 매겨지므로 이 중 하나가 중복되면 Claude Code는 조직의 정의를 연결합니다. Claude Code v2.1.259 이상이 필요합니다.

[Desktop 앱의 Code 탭](/docs/ko/desktop#mcp-servers-from-the-claude-desktop-chat-app)에서 로컬 세션을 열 때 `~/.claude.json` (사용자 범위)의 최상위 수준과 `.mcp.json`에 동일한 stdio 서버 이름이 있으면 Code 탭은 `~/.claude.json` 정의를 사용합니다.

<h3 id="environment-variable-expansion-in-mcp-json">
  `.mcp.json`의 환경 변수 확장
</h3>

Claude Code는 `.mcp.json` 파일의 환경 변수 확장을 지원하므로 팀이 구성을 공유하면서 머신 특정 경로 및 API 키와 같은 민감한 값에 대한 유연성을 유지할 수 있습니다.

<h4 id="supported-syntax">
  지원되는 구문
</h4>

* `${VAR}`: 환경 변수 `VAR`의 값으로 확장
* `${VAR:-default}`: `VAR`이 설정되면 확장, 그렇지 않으면 `default` 사용

<h4 id="expansion-locations">
  확장 위치
</h4>

환경 변수는 다음에서 확장할 수 있습니다:

* `command`: 서버 실행 파일 경로
* `args`: 명령줄 인수
* `env`: 서버에 전달되는 환경 변수
* `url`: HTTP 서버 유형의 경우
* `headers`: HTTP 서버 인증의 경우

<h4 id="example-with-variable-expansion">
  변수 확장을 사용한 예
</h4>

```json theme={null}
{
  "mcpServers": {
    "api-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

<h4 id="unset-variables-without-a-default">
  기본값이 없는 설정되지 않은 변수
</h4>

참조된 환경 변수가 설정되지 않았고 기본값이 없으면 구성은 여전히 로드됩니다. Claude Code는 `claude mcp list` 출력에서 해당 서버에 대한 누락된 변수 경고를 보고하고 확장되지 않은 `${VAR}` 텍스트를 그대로 사용합니다. 변수를 설정하거나 `:-default` 폴백을 추가하여 서버가 의도한 값으로 시작하도록 하세요. 원격 서버의 `url` 및 `headers`에서 일부 자격 증명 변수는 [경고 없이 빈 값으로 읽힙니다](#credential-variables-that-read-as-empty).

<h4 id="credential-variables-that-read-as-empty">
  빈 값으로 읽히는 자격 증명 변수
</h4>

원격 서버의 `url` 및 `headers`에서 Claude Code는 환경의 자격 증명 변수를 확장하지 않고 빈 값으로 읽습니다. 이는 프로젝트의 `.mcp.json` 또는 플러그인이 Claude Code 또는 클라우드 공급자 자격 증명을 이름이 지정된 서버로 보내는 것을 방지합니다. `Bearer ${ANTHROPIC_AUTH_TOKEN}`을 작성하면 서버는 자격 증명 없이 `Bearer `를 수신하고 일반적으로 `401`로 요청을 거부합니다. Claude Code는 이를 실패한 연결로 보고합니다.

포함된 이름은 다음과 같습니다:

* Claude Code의 자체 자격 증명(예: `ANTHROPIC_API_KEY` 및 `ANTHROPIC_AUTH_TOKEN`)
* 클라우드 공급자의 자격 증명(예: `AWS_BEARER_TOKEN_BEDROCK`)
* 환경이 전달하는 기타 자격 증명(예: `HTTPS_PROXY` 및 `NPM_TOKEN`)

포함된 이름은 변수를 설정했는지 여부와 관계없이 빈 값으로 읽히며, 이에 대한 `:-default` 폴백은 무시됩니다. `ANTHROPIC_BASE_URL`과 같은 공급자 기본 URL은 여전히 확장되므로 `"url": "${ANTHROPIC_BASE_URL}/mcp"`는 작동합니다. 단, URL의 값 자체에 사용자 이름 및 암호와 같은 자격 증명이 포함되지 않는 한입니다.

`API_KEY`와 같이 이 집합 외부의 이름은 작성된 대로 확장됩니다. 서버에 포함된 자격 증명 중 하나를 제공하려면 이를 자신의 이름을 가진 변수에 복사하고 대신 해당 이름을 참조하세요.

원격 서버의 `url` 또는 `headers`가 설정한 포함된 변수를 참조할 때 Claude Code는 디버그 로그 줄에 이름을 지정합니다. 줄을 읽으려면 `claude --debug-file /tmp/claude-debug.log`를 실행하고 해당 파일에서 `never expanded toward a remote server`를 검색하세요.

<h4 id="how-references-appear-in-/mcp-and-cli-output">
  `/mcp` 및 CLI 출력에서 참조가 표시되는 방식
</h4>

로컬, 프로젝트 또는 사용자 [범위](#mcp-installation-scopes)의 서버의 경우 다음 표면은 `${VAR}` 참조를 해결된 값이 아닌 이름으로 표시합니다:

* 서버의 `/mcp` 상세 보기의 URL 또는 명령줄
* `claude mcp list` 및 `claude mcp get` 출력

`/mcp` 상세 보기는 Claude Code v2.1.268 이상에서 이러한 방식으로 참조를 표시합니다.

조직이 `managedMcpServers` 설정을 통해 제공하는 서버의 경우 이러한 표면은 [URL의 호스트만](/docs/ko/managed-mcp#what-users-can-see-and-change) 표시합니다.

연결이 실패할 때 `claude mcp list`, `claude mcp get` 및 `/mcp`가 표시하는 내용을 확인하려면 [서버 상태 상세](#server-status-detail)를 참조하세요.

<h2 id="practical-examples">
  실제 예
</h2>

<h3 id="example-connect-to-github-for-code-reviews">
  예: 코드 검토를 위해 GitHub에 연결
</h3>

GitHub의 원격 MCP 서버는 헤더로 전달된 GitHub 개인 액세스 토큰으로 인증합니다. 하나를 얻으려면 [GitHub 토큰 설정](https://github.com/settings/personal-access-tokens)을 열고, Claude가 작업하려는 리포지토리에 액세스할 수 있는 새로운 세분화된 토큰을 생성한 다음 서버를 추가하세요:

```bash theme={null}
claude mcp add --transport http github https://api.githubcopilot.com/mcp/ \
  --header "Authorization: Bearer YOUR_GITHUB_PAT"
```

`YOUR_GITHUB_PAT`를 개인 액세스 토큰으로 바꾸세요. `claude mcp add` 명령은 자격 증명을 검증하지 않고 구성을 저장하므로 여기서 자리 표시자 값이 허용되지만 서버는 나중에 연결하지 못합니다. 연결을 확인하려면 `/mcp`를 실행하고 서버가 `connected`를 표시하는지 확인하세요. 잘못된 자격 증명이 있는 서버는 `failed`를 표시하며, 실패 세부 정보에는 서버가 반환한 HTTP 상태(예: 401)가 포함됩니다.

그런 다음 GitHub로 작업합니다:

```text wrap theme={null}
PR #456을 검토하고 개선 사항을 제안하세요
```

```text wrap theme={null}
방금 발견한 버그에 대한 새 이슈를 생성하세요
```

```text wrap theme={null}
나에게 할당된 모든 열린 PR을 보여주세요
```

<h3 id="example-query-your-postgresql-database">
  예: PostgreSQL 데이터베이스 쿼리
</h3>

[DBHub](https://github.com/bytebase/dbhub), `@bytebase/dbhub` 패키지는 `--dsn`에서 전달하는 연결 문자열을 통해 Claude를 관계형 데이터베이스에 연결하는 MCP 서버입니다. Claude가 실행하는 쿼리가 데이터를 수정할 수 없도록 연결 문자열에서 읽기 전용 데이터베이스 사용자를 사용하세요:

```bash theme={null}
claude mcp add --transport stdio db -- npx -y @bytebase/dbhub \
  --dsn "postgresql://readonly:pass@prod.db.com:5432/analytics"
```

서버가 시작되는지 확인하려면 `/mcp`를 실행하고 `db`가 `connected`를 표시하는지 확인하세요.

그런 다음 자연스럽게 데이터베이스를 쿼리합니다:

```text wrap theme={null}
이번 달 총 수익은 얼마입니까?
```

```text wrap theme={null}
주문 테이블의 스키마를 보여주세요
```

```text wrap theme={null}
지난 90일 동안 구매하지 않은 고객을 찾으세요
```

<h2 id="authenticate-with-remote-mcp-servers">
  원격 MCP 서버로 인증
</h2>

많은 클라우드 기반 MCP 서버는 인증이 필요합니다. Claude Code는 보안 연결을 위해 OAuth 2.0을 지원합니다.

Claude Code는 서버가 `401 Unauthorized` 또는 `403 Forbidden`으로 응답할 때 원격 서버가 인증이 필요한 것으로 표시합니다. Claude Code가 표시하는 내용은 서버에 따라 다릅니다.

* 아직 로그인하지 않은 서버의 경우, 두 상태 코드 중 하나가 `/mcp`에서 플래그되어 OAuth 흐름을 완료할 수 있습니다.
* [claude.ai 커넥터](#use-mcp-servers-from-claude-ai)의 경우, claude.ai가 세션 토큰을 거부하여 발생한 `401`은 커넥터를 플래그하지 않습니다. 커넥터를 다시 인증해도 로그인을 수정할 수 없기 때문입니다. Claude Code는 대신 [세션 토큰 거부 상태](/docs/ko/errors#claude-ai-rejected-the-session-token)를 표시합니다.
* `headers`에서 구성했거나 [`headersHelper`](#use-dynamic-headers-for-custom-authentication)를 통해 구성한 `Authorization` 헤더가 있는 서버의 경우, 연결 중 `401` 또는 `403`은 서버를 플래그하지 않습니다. 수정할 자격 증명은 구성한 것이기 때문입니다. Claude Code는 대신 연결이 실패했다고 보고합니다. 해당 헤더를 `${VAR}` 참조에서 설정한 경우, 해당 변수가 Claude Code [빈 값으로 읽는](#credential-variables-that-read-as-empty) 변수 중 하나인지 확인하세요.
* [클라우드 세션에 전달된](#how-connectors-reach-claude-code) 커넥터의 경우, Claude Code는 세션의 프록시가 claude.ai에서 부여한 인증으로 커넥터에 인증하기 때문에 로그인 흐름을 실행하지 않습니다. 거기서 커넥터를 다시 인증해야 할 때는 세션이 아닌 [claude.ai/customize/connectors](https://claude.ai/customize/connectors)에서 다시 연결하세요.

이미 로그인한 OAuth 서버에 대한 요청이 `401 Unauthorized`를 반환할 때, Claude Code는 저장된 토큰을 새로 고치고, 다시 연결하고, 요청을 한 번 재시도합니다. 해당 재시도도 실패한 경우에만 `/mcp`에서 서버를 플래그합니다. v2.1.206 이전에는 네트워크 오류와 같은 일시적 이유로 토큰 새로 고침이 실패하면 새로 고침 토큰이 여전히 유효했음에도 불구하고 OAuth 서버가 세션의 나머지 기간 동안 인증이 필요한 것으로 플래그되었습니다.

서버가 저장된 새로 고침 토큰을 거부하면, Claude Code는 즉시 `/mcp`를 가리키는 알림을 표시합니다. `/mcp`를 열고 서버에서 **Re-authenticate**를 선택하여 다음 도구 호출이 실패하기 전에 다시 로그인하세요.

`WWW-Authenticate` 헤더를 반환하는 사용자 정의 서버는 다른 원격 서버와 동일한 자동 검색을 받습니다.

Claude Code는 또한 하나 이상의 구성된 서버가 인증이 필요할 때 시작 알림을 표시하므로 `/mcp`를 열어서 어떤 서버가 로그인이 필요한지 확인할 필요가 없습니다. 이 알림은 Claude Code에서 로그인할 수 있는 서버만 계산합니다. v2.1.218 이전에는 claude.ai에서 연결되지 않은 [claude.ai 커넥터](#use-mcp-servers-from-claude-ai)도 계산했으며, 이는 claude.ai 설정에서만 연결할 수 있습니다.

알림은 각 서버를 한 번 발표하고 해당 서버가 연결되어 다시 로그인이 필요할 때까지 이후 시작 시 계산에서 제외합니다. `/mcp`는 여전히 로그인이 필요한 모든 서버를 나열합니다.

비대화형 모드에는 `/mcp` 패널이 없으므로 Claude Code는 OAuth 흐름을 실행할 수 없습니다. v2.1.196부터, 구성된 서버가 [도구 검색](#scale-with-mcp-tool-search)이 활성화된 `claude -p` 또는 Agent SDK 실행 중에 인증이 필요할 때(기본값), Claude Code는 Claude에 서버의 도구가 인증될 때까지 사용 불가능함을 알립니다. Claude는 서버가 구성되지 않은 것처럼 응답하는 대신 로그인이 필요한 서버의 이름을 지정할 수 있습니다. `/mcp` 또는 `claude mcp login <name>`을 사용하여 대화형 세션에서 로그인을 완료하세요.

서버에 대해 `headers.Authorization`을 구성했고 서버가 해당 헤더를 거부하면, Claude Code는 OAuth로 폴백하는 대신 연결이 실패했다고 보고합니다. 토큰이 MCP 엔드포인트에 유효한지 확인하거나 헤더를 제거하여 OAuth 흐름을 사용하세요.

<Steps>
  <Step title="인증이 필요한 서버 추가">
    [MCP 빠른 시작](/docs/ko/mcp-quickstart#connect-a-server-that-requires-sign-in)에서 이미 `sentry` 서버를 추가한 경우 이 단계를 건너뛰세요. 같은 서버 이름으로 같은 범위에서 `claude mcp add`를 다시 실행하면 `MCP server sentry already exists in local config`로 실패합니다. 그렇지 않으면 다음을 실행하세요.

    ```bash theme={null}
    claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
    ```
  </Step>

  <Step title="Claude Code 내에서 /mcp 명령 사용">
    Claude Code에서 다음 명령을 사용하세요.

    ```text wrap theme={null}
    /mcp
    ```

    그런 다음 브라우저의 단계를 따라 로그인하세요.
  </Step>
</Steps>

<Tip>
  팁:

  * 인증 토큰은 안전하게 저장되고 자동으로 새로 고쳐집니다.
  * `/mcp` 메뉴에서 "Clear authentication"을 사용하여 액세스를 취소합니다.
  * 브라우저가 자동으로 열리지 않으면 제공된 URL을 복사하여 수동으로 엽니다.
  * 인증 후 브라우저 리디렉션이 연결 오류로 실패하면 브라우저의 주소 표시줄에서 전체 콜백 URL을 복사하여 Claude Code에 나타나는 URL 프롬프트에 붙여넣으세요.
  * OAuth 인증은 HTTP 서버에서 작동합니다.
</Tip>

<h3 id="authenticate-from-the-command-line">
  명령줄에서 인증
</h3>

`claude mcp login <name>` 명령은 구성된 서버의 OAuth 흐름을 셸에서 직접 실행하므로 세션 내에서 `/mcp` 패널을 열 필요가 없습니다. claude.ai 커넥터의 경우 [셸에서 커넥터 다시 인증](/docs/ko/remote-control#authorize-a-connector-again-from-your-shell)을 따르세요.

```bash theme={null}
claude mcp login sentry
```

나중에 저장된 자격 증명을 지우려면 `claude mcp logout <name>`을 실행하세요.

`claude mcp login`은 SSH 세션 중이거나 디스플레이 서버가 없는 Linux에서와 같이 로컬 브라우저를 사용할 수 없을 때를 감지하고 브라우저를 열려고 시도하는 대신 인증 URL을 인쇄합니다. 로컬 머신에서 URL을 열고 브라우저의 주소 표시줄에서 전체 리디렉션 URL을 프롬프트에 다시 붙여넣으세요. 이 명령은 붙여넣기 단계를 위해 대화형 터미널이 필요하므로 `ssh -t`로 연결하세요. 로컬 브라우저가 감지되었을 때도 URL 프롬프트를 강제하려면 `--no-browser`를 전달하세요.

```bash theme={null}
claude mcp login sentry --no-browser
```

<h3 id="use-a-fixed-oauth-callback-port">
  고정 OAuth 콜백 포트 사용
</h3>

일부 MCP 서버는 미리 등록된 특정 리디렉션 URI가 필요합니다. 기본적으로 Claude Code는 OAuth 콜백을 위해 임의의 사용 가능한 포트를 선택합니다. `--callback-port`를 사용하여 포트를 고정하여 `http://localhost:PORT/callback` 형식의 사전 등록된 리디렉션 URI와 일치하도록 합니다. Claude Code v2.1.229에서 로그인이 리디렉션 URI 불일치로 실패하면 [사전 구성된 OAuth 자격 증명 사용](#use-pre-configured-oauth-credentials)의 버전 참고를 참조하세요.

`--callback-port`를 단독으로(동적 클라이언트 등록 사용) 또는 `--client-id`와 함께(사전 구성된 자격 증명 사용) 사용할 수 있습니다.

```bash theme={null}
# 동적 클라이언트 등록을 사용한 고정 콜백 포트
claude mcp add --transport http \
  --callback-port 8080 \
  my-server https://mcp.example.com/mcp
```

<h3 id="use-pre-configured-oauth-credentials">
  사전 구성된 OAuth 자격 증명 사용
</h3>

일부 MCP 서버는 동적 클라이언트 등록을 통한 자동 OAuth 설정을 지원하지 않습니다. "Incompatible auth server: does not support dynamic client registration"과 같은 오류가 표시되면 서버에 사전 구성된 자격 증명이 필요합니다. Claude Code는 또한 동적 클라이언트 등록 대신 클라이언트 ID 메타데이터 문서(CIMD)를 사용하는 서버를 지원하며 이를 자동으로 검색합니다. 자동 검색이 실패하면 먼저 서버의 개발자 포털을 통해 OAuth 앱을 등록한 다음 서버를 추가할 때 자격 증명을 제공하세요.

<Steps>
  <Step title="서버로 OAuth 앱 등록">
    서버의 개발자 포털을 통해 앱을 만들고 클라이언트 ID와 클라이언트 시크릿을 기록하세요.

    등록 양식에서 리디렉션 URI를 요청하면 사용 가능한 포트를 선택하고 해당 포트로 `http://localhost:PORT/callback`을 입력하세요. 다음 단계에서 같은 포트를 사용합니다.

    v2.1.229에서 Claude Code는 `http://127.0.0.1:PORT/callback`을 대신 보냈으며, 등록된 리디렉션 URI와 정확히 일치하는 서버는 리디렉션 URI 불일치로 로그인을 거부했습니다. Claude Code v2.1.231은 `localhost` 형식을 복원했습니다. v2.1.229에서 복구하려면 Claude Code를 업그레이드하거나 임시로 `http://127.0.0.1:PORT/callback` 형식을 서버의 등록된 리디렉션 URI에 추가하세요.
  </Step>

  <Step title="자격 증명으로 서버 추가">
    탭은 두 명령을 모두 다룹니다. `claude mcp add`는 클라이언트 ID와 콜백 포트를 플래그로 사용하고, `claude mcp add-json`은 `oauth` 객체에서 사용합니다. 리디렉션 URI를 등록한 경우 콜백 포트를 해당 URI의 포트로 설정하세요.

    <Tabs>
      <Tab title="claude mcp add">
        `--client-id`를 사용하여 앱의 클라이언트 ID를 전달하세요. `--client-secret` 플래그는 마스킹된 입력으로 시크릿을 프롬프트합니다.

        ```bash theme={null}
        claude mcp add --transport http \
          --client-id your-client-id --client-secret --callback-port 8080 \
          my-server https://mcp.example.com/mcp
        ```
      </Tab>

      <Tab title="claude mcp add-json">
        JSON 구성에 `oauth` 객체를 포함하고 `--client-secret`을 별도 플래그로 전달하세요.

        ```bash theme={null}
        claude mcp add-json my-server \
          '{"type":"http","url":"https://mcp.example.com/mcp","oauth":{"clientId":"your-client-id","callbackPort":8080}}' \
          --client-secret
        ```
      </Tab>

      <Tab title="claude mcp add-json (콜백 포트만)">
        콜백 포트만 고정하고 Claude Code가 클라이언트를 자동으로 등록하도록 하려면 `callbackPort`를 단독으로 설정하세요.

        ```bash theme={null}
        claude mcp add-json my-server \
          '{"type":"http","url":"https://mcp.example.com/mcp","oauth":{"callbackPort":8080}}'
        ```
      </Tab>

      <Tab title="CI / env var">
        환경 변수를 통해 시크릿을 설정하여 대화형 프롬프트를 건너뛰세요.

        ```bash theme={null}
        MCP_CLIENT_SECRET=your-secret claude mcp add --transport http \
          --client-id your-client-id --client-secret --callback-port 8080 \
          my-server https://mcp.example.com/mcp
        ```
      </Tab>
    </Tabs>
  </Step>

  <Step title="Claude Code에서 인증">
    Claude Code에서 `/mcp`를 실행하고 브라우저 로그인 흐름을 따르세요.
  </Step>
</Steps>

<Tip>
  팁:

  * 클라이언트 시크릿은 구성에 저장되지 않고 시스템 키체인(macOS) 또는 자격 증명 파일에 안전하게 저장됩니다.
  * 서버를 추가할 때만 클라이언트 시크릿을 설정할 수 있습니다. `claude mcp login` 또는 `/mcp`에서 인증할 때 Claude Code는 저장된 시크릿을 사용하며 하나를 프롬프트하거나 `MCP_CLIENT_SECRET`을 읽지 않습니다.
  * 나중에 시크릿을 추가하거나 변경하려면 `claude mcp remove <name>`으로 서버를 제거한 다음 `--client-secret`과 같은 `--scope`로 다시 추가하세요.
  * 서버가 시크릿이 없는 공개 OAuth 클라이언트를 사용하면 `--client-secret` 없이 `--client-id`만 사용하세요.
  * 이 플래그는 HTTP 및 SSE 전송에만 적용됩니다. stdio 서버에는 영향을 주지 않습니다.
  * `claude mcp get <name>`을 사용하여 OAuth 자격 증명이 서버에 대해 구성되었는지 확인하세요.
</Tip>

<h3 id="override-oauth-metadata-discovery">
  OAuth 메타데이터 검색 재정의
</h3>

기본 검색 체인을 우회하기 위해 Claude Code를 특정 OAuth 인증 서버 메타데이터 URL로 지정하세요. MCP 서버의 표준 엔드포인트가 오류를 발생시키거나 검색을 내부 프록시를 통해 라우팅하려는 경우 `authServerMetadataUrl`을 설정하세요. 기본적으로 Claude Code는 먼저 `/.well-known/oauth-protected-resource`에서 RFC 9728 보호된 리소스 메타데이터를 확인한 다음 `/.well-known/oauth-authorization-server`에서 RFC 8414 인증 서버 메타데이터로 폴백합니다.

`.mcp.json`의 서버 구성의 `oauth` 객체에 `authServerMetadataUrl`을 설정하세요.

```json theme={null}
{
  "mcpServers": {
    "my-server": {
      "type": "http",
      "url": "https://mcp.example.com/mcp",
      "oauth": {
        "authServerMetadataUrl": "https://auth.example.com/.well-known/openid-configuration"
      }
    }
  }
}
```

URL은 `https://`를 사용해야 합니다. 메타데이터 URL의 `scopes_supported`는 업스트림 서버가 광고하는 범위를 재정의합니다.

<h3 id="restrict-oauth-scopes">
  OAuth 범위 제한
</h3>

`oauth.scopes`를 설정하여 인증 흐름 중에 Claude Code가 요청하는 범위를 고정하세요. 이는 업스트림 인증 서버가 부여하려는 것보다 더 많은 범위를 광고할 때 MCP 서버를 보안 팀이 승인한 부분 집합으로 제한하는 지원되는 방법입니다. 값은 RFC 6749 §3.3의 `scope` 매개변수 형식과 일치하는 단일 공백으로 구분된 문자열입니다.

```json theme={null}
{
  "mcpServers": {
    "slack": {
      "type": "http",
      "url": "https://mcp.slack.com/mcp",
      "oauth": {
        "scopes": "channels:read chat:write search:read"
      }
    }
  }
}
```

`oauth.scopes`는 `authServerMetadataUrl`과 서버가 `/.well-known`에서 검색하는 범위 모두보다 우선합니다. MCP 서버가 요청된 범위 집합을 결정하도록 하려면 설정하지 않은 상태로 두세요.

v2.1.196부터, `oauth.scopes`가 설정되지 않으면 Claude Code는 서버의 `WWW-Authenticate` 헤더 또는 보호된 리소스 메타데이터에서 제공하는 범위를 요청하고, 둘 다 제공하지 않을 때 `scope` 매개변수를 보내지 않습니다. 더 이상 자동으로 검색된 인증 서버 메타데이터에서 전체 `scopes_supported` 카탈로그를 요청하지 않습니다. 해당 카탈로그를 요청하면 관리자 전용 또는 템플릿 범위를 광고하는 ID 공급자가 `invalid_scope` 오류로 인증 요청을 거부했습니다. 구성된 `authServerMetadataUrl`에서 가져온 메타데이터는 여전히 `scopes_supported`를 요청된 범위로 제공합니다.

인증 서버가 `scopes_supported`에서 `offline_access`를 광고하면, Claude Code는 새로운 브라우저 로그인 없이 액세스 토큰을 새로 고칠 수 있도록 고정된 범위에 추가합니다.

서버가 나중에 도구 호출에 대해 403 `insufficient_scope`을 반환하면, 호출은 서버가 요청하는 범위의 이름을 지정하는 [`needs additional permissions`](/docs/ko/errors#mcp-server-needs-you-to-sign-in-again) 메시지로 실패합니다. 서버는 `/mcp`에서 인증이 필요한 것으로 표시됩니다.

해당 범위가 고정된 `oauth.scopes`에 없으면 추가한 다음 `/mcp`를 실행하고 서버를 다시 인증하세요. Claude Code는 서버가 명명한 범위가 아닌 고정된 범위를 요청하므로, 추가하지 않고 다시 인증하면 얻은 토큰에 여전히 없습니다.

<h3 id="use-dynamic-headers-for-custom-authentication">
  사용자 정의 인증을 위해 동적 헤더 사용
</h3>

MCP 서버가 Kerberos, 단기 토큰 또는 내부 SSO와 같은 OAuth 이외의 인증 체계를 사용하면, `headersHelper`를 사용하여 연결 시간에 요청 헤더를 생성하세요. Claude Code는 명령을 실행하고 출력을 연결 헤더에 병합합니다.

```json theme={null}
{
  "mcpServers": {
    "internal-api": {
      "type": "http",
      "url": "https://mcp.internal.example.com",
      "headersHelper": "/opt/bin/get-mcp-auth-headers.sh"
    }
  }
}
```

명령은 인라인일 수도 있습니다.

```json theme={null}
{
  "mcpServers": {
    "internal-api": {
      "type": "http",
      "url": "https://mcp.internal.example.com",
      "headersHelper": "echo '{\"Authorization\": \"Bearer '\"$(get-token)\"'\"}'"
    }
  }
}
```

**요구 사항:**

* 명령은 JSON 객체의 문자열 키-값 쌍을 stdout에 작성해야 합니다.
* Claude Code는 명령을 셸에서 실행하고 10초 후 포기합니다.
* Claude Code는 [서버를 구성한 위치](#where-the-helper-runs)에 따라 명령의 작업 디렉토리를 선택하므로 스크립트를 절대 경로로 제공하거나 `PATH`에 넣으세요.
* 동적 헤더는 같은 이름의 정적 `headers`를 재정의합니다.

Claude Code는 [프로젝트 및 로컬 범위 서버에 대한 신뢰 규칙](#trust-a-folder-before-its-headershelper-runs)이 실행을 허용한 후 세션 시작 및 재연결 시 각 연결에서 헬퍼를 새로 실행합니다. 결과를 캐시하지 않으므로 스크립트는 토큰 재사용을 담당합니다.

도구 호출이 `401 Unauthorized` 또는 `403 Forbidden`을 반환하면, Claude Code는 같은 규칙 아래에서 헬퍼를 자동으로 다시 실행하고, 새로운 헤더로 다시 연결하고, 호출을 한 번 재시도합니다. Claude Code는 해당 재시도도 실패한 경우에만 `/mcp`에서 서버를 인증이 필요한 것으로 표시합니다.

헬퍼의 출력에 `Authorization` 헤더가 포함되면, Claude Code는 해당 자격 증명을 서버의 인증으로 사용하며 서버에 대해 OAuth로 폴백하지 않습니다.

헬퍼의 자격 증명이 연결 중에 서버에 의해 거부되면, Claude Code는 서버를 인증이 필요한 것으로 표시하는 대신 연결이 실패했다고 보고합니다. 헬퍼가 반환하는 자격 증명을 수정한 다음 `/mcp`에서 다시 연결하여 헬퍼를 다시 실행하세요.

Claude Code는 헬퍼를 실행할 때 다음 환경 변수를 설정합니다.

| 변수 | 값 |
| :- | :- |
| `CLAUDE_CODE_MCP_SERVER_NAME` | MCP 서버의 이름 |
| `CLAUDE_CODE_MCP_SERVER_URL` | MCP 서버의 URL |
| `CLAUDE_PLUGIN_ROOT` | 플러그인의 루트 디렉토리. [플러그인](/docs/ko/plugins/components#mcp-servers)이 서버를 제공할 때만 설정됨 |

이를 사용하여 여러 MCP 서버를 제공하는 단일 헬퍼 스크립트를 작성하세요.

플러그인 제공 `headersHelper`는 명령이 셸을 통해 실행되기 때문에 플러그인의 [`${user_config.*}`](/docs/ko/plugins/manifest-reference#user-configuration) 값을 참조할 수 없습니다. Claude Code는 서버를 [오류](/docs/ko/errors#plugin-command-references-user-config)로 잘못 구성된 것으로 보고하며 값을 대체하지 않습니다. 대신 `${user_config.KEY}`를 셸 파싱되지 않는 서버의 `headers` 필드에 넣거나 헬퍼 스크립트가 구성 파일에서 값을 읽도록 하세요. v2.1.207 이전에는 `headersHelper`가 `${user_config.*}` 값을 대체했습니다.

<h4 id="where-the-helper-runs">
  헬퍼가 실행되는 위치
</h4>

Claude Code는 서버를 선언하는 구성에서 `headersHelper` 명령의 작업 디렉토리를 선택합니다. Claude Code가 Bash에서 실행하는 `cd`는 이를 이동하지 않으며, [`/cd`](/docs/ko/permissions#move-the-session-to-another-directory)는 세션의 기본 작업 디렉토리에서 실행되는 서버에 대해서만 이를 이동합니다. 아래의 각 행은 `headersHelper` 명령의 상대 경로가 해석되는 디렉토리를 제공합니다.

| 서버를 구성한 위치 | 작업 디렉토리 |
| :- | :- |
| [플러그인](/docs/ko/plugins/components#mcp-servers) | 플러그인의 루트 디렉토리 |
| 프로젝트 `.mcp.json` 또는 [로컬 범위](#local-scope) 서버 | 서버가 선언된 프로젝트 디렉토리 |
| 프로젝트의 에이전트 파일, SDK의 `mcpServers` 옵션 또는 `setMcpServers()` 메서드의 서버, 또는 [`--mcp-config`](/docs/ko/cli-reference) | 세션의 [기본 작업 디렉토리](/docs/ko/permissions#working-directories) |
| [사용자 범위](#user-scope), [관리형 MCP](/docs/ko/managed-mcp), [claude.ai 커넥터](#use-mcp-servers-from-claude-ai), 또는 프로젝트 외부의 에이전트 파일(예: `--add-dir` 디렉토리의 파일 포함) | 구성 디렉토리, `~/.claude`(또는 [`CLAUDE_CONFIG_DIR`](/docs/ko/env-vars)을 설정한 경우) |

v2.1.238 이전에는 Claude Code도 사용자 범위, 관리형 및 claude.ai 커넥터 서버의 헬퍼와 프로젝트 외부의 에이전트 파일을 시작한 디렉토리에서 실행했습니다.

<h4 id="which-variables-a-helper-can-read">
  헬퍼가 읽을 수 있는 변수
</h4>

저장소 또는 플러그인이 제공하는 `headersHelper`는 작성하지 않은 명령이므로 Claude Code는 `ANTHROPIC_API_KEY`와 같은 환경의 자격 증명 변수 없이 실행합니다. 서버를 구성한 위치에 따라 이것이 적용되는지 결정됩니다.

* **제거됨**: 프로젝트 `.mcp.json` 또는 플러그인의 서버, 그리고 프로젝트 또는 `--add-dir` 디렉토리의 에이전트 파일의 인라인 서버
* **제거되지 않음**: [사용자](#user-scope) 또는 [로컬 범위](#local-scope)의 서버, [관리형 MCP](/docs/ko/managed-mcp), [claude.ai 커넥터](#use-mcp-servers-from-claude-ai), SDK 또는 [`--mcp-config`](/docs/ko/cli-reference)에서 제공되는 서버, 그리고 `~/.claude/agents/`, 관리형 설정 또는 `--agents`로 전달된 에이전트 파일의 인라인 서버

Git의 `GIT_CONFIG_KEY_<n>` 변수를 제외하고, Claude Code는 `TOKEN`, `SECRET`, `PASSWORD`, `KEY` 또는 `AUTH`가 포함된 이름(대소문자 상관없음)과 같이 자격 증명처럼 보이는 이름의 모든 변수를 환경에서 제거합니다. 따라서 `ANTHROPIC_API_KEY`와 `MY_REGISTRY_TOKEN` 모두 제거됩니다. Claude Code는 또한 `ANTHROPIC_CUSTOM_HEADERS`와 같이 해당 패턴을 따르지 않는 자격 증명 변수의 고정 목록을 제거합니다.

이것이 헬퍼에 적용되면, 스크립트가 파일 또는 자격 증명 저장소에서 자격 증명을 읽도록 하세요. 서버의 `url`이 [이러한 변수 중 하나의 라이브 값을 전달](#environment-variable-expansion-in-mcp-json)하면(예: `MY_REGISTRY_TOKEN`), 헬퍼가 받는 `CLAUDE_CODE_MCP_SERVER_URL` 값도 해당 부분이 `REDACTED`로 대체됩니다.

<h4 id="trust-a-folder-before-its-headershelper-runs">
  headersHelper가 실행되기 전에 폴더 신뢰
</h4>

Claude Code는 `headersHelper`를 임의의 셸 명령으로 실행합니다. 프로젝트 `.mcp.json` 또는 [로컬 범위](#local-scope)의 서버의 경우, 서버가 선언된 프로젝트 디렉토리에 대한 [신뢰 대화](/docs/ko/permissions#project-allow-rules-and-workspace-trust)를 수락한 후에만 헬퍼를 실행합니다. v2.1.238 이전에는 `claude -p` 또는 SDK 세션이 신뢰를 확인하지 않고 이러한 헬퍼를 실행했으며, 대화형 세션은 부모 폴더를 신뢰한 후 한 번 실행했습니다.

* **계산되지 않는 신뢰**: 부모 폴더의 신뢰, 그리고 `claude -p` 또는 SDK 세션이 [설정 파일의 후크](/docs/ko/permissions#what-runs-before-you-trust-a-folder)에 대해 받는 자동 신뢰
* **폴더를 신뢰할 때까지**: Claude Code는 정적 `headers`만으로 서버를 연결합니다. `claude -p` 또는 SDK 세션에서 또한 stderr에 서버당 하나의 [`headersHelper not run`](/docs/ko/errors#headershelper-not-run) 줄을 인쇄하여 신뢰를 부여하는 방법을 알려줍니다.
* **대화 없이 신뢰**: `~/.claude.json`에서 `projects["<path>"].hasTrustDialogAccepted`를 `true`로 설정하세요. `<path>`는 폴더 [프로젝트 허용 규칙 및 작업 공간 신뢰](/docs/ko/permissions#project-allow-rules-and-workspace-trust)가 Claude Code가 신뢰를 기반으로 하는 폴더입니다.

Claude Code는 [에이전트 파일](/docs/ko/sub-agents#scope-mcp-servers-to-a-subagent)에 인라인으로 선언된 서버에 같은 규칙을 적용하여 해당 에이전트 파일이 어디에서 왔는지 확인합니다. 프로젝트의 경우 `.claude/agents/` 디렉토리의 파일, 또는 `--add-dir` 디렉토리. 해당 프로젝트 또는 디렉토리 자체를 [신뢰](/docs/ko/permissions#what-runs-before-you-trust-a-folder)할 때까지, Claude Code는 서버를 로드하지 않으므로 헬퍼도 실행되지 않습니다.

<h2 id="add-mcp-servers-from-json-configuration">
  JSON 구성에서 MCP 서버 추가
</h2>

MCP 서버에 대한 JSON 구성이 있는 경우 직접 추가할 수 있습니다:

<Steps>
  <Step title="JSON에서 MCP 서버 추가">
    ```bash theme={null}
    # 기본 구문
    claude mcp add-json <name> '<json>'

    # 예: JSON 구성으로 HTTP 서버 추가
    claude mcp add-json weather-api '{"type":"http","url":"https://api.weather.com/mcp","headers":{"Authorization":"Bearer token"}}'

    # 예: JSON 구성으로 stdio 서버 추가
    claude mcp add-json local-weather '{"type":"stdio","command":"/path/to/weather-cli","args":["--api-key","abc123"],"env":{"CACHE_DIR":"/tmp"}}'

    # 예: 사전 구성된 OAuth 자격 증명으로 HTTP 서버 추가
    claude mcp add-json my-server '{"type":"http","url":"https://mcp.example.com/mcp","oauth":{"clientId":"your-client-id","callbackPort":8080}}' --client-secret
    ```
  </Step>

  <Step title="서버가 추가되었는지 확인">
    ```bash theme={null}
    claude mcp get weather-api
    ```
  </Step>
</Steps>

<Tip>
  팁:

  * JSON이 셸에서 올바르게 이스케이프되었는지 확인합니다
  * JSON은 MCP 서버 구성 스키마를 준수해야 합니다
  * `--scope user`를 사용하여 프로젝트 특정 구성 대신 사용자 구성에 서버를 추가할 수 있습니다
</Tip>

<h2 id="import-mcp-servers-from-claude-desktop">
  Claude Desktop에서 MCP 서버 가져오기
</h2>

Claude Desktop에서 MCP 서버를 이미 구성한 경우 가져올 수 있습니다:

<Steps>
  <Step title="Claude Desktop에서 서버 가져오기">
    ```bash theme={null}
    # 기본 구문 
    claude mcp add-from-claude-desktop 
    ```
  </Step>

  <Step title="가져올 서버 선택">
    명령을 실행한 후 가져올 서버를 선택할 수 있는 대화형 대화 상자가 표시됩니다.
  </Step>

  <Step title="서버가 가져와졌는지 확인">
    ```bash theme={null}
    claude mcp list 
    ```
  </Step>
</Steps>

`claude mcp` 명령을 통해 추가된 서버 이름은 문자, 숫자, 하이픈 및 언더스코어만 포함할 수 있습니다. Claude Desktop은 해당 제한을 적용하지 않으므로 공백과 같은 다른 문자를 포함하는 이름의 Claude Desktop 서버는 가져올 수 없습니다. 가져오기는 거부된 각 이름을 보고하며 선택한 다른 서버는 계속 가져옵니다. v2.1.205 이전에는 첫 번째 잘못된 이름이 가져오기를 중지했으며 선택한 서버 중 어느 것도 추가되지 않았습니다.

<Tip>
  팁:

  * 이 기능은 macOS 및 Windows Subsystem for Linux (WSL)에서만 작동합니다
  * 이러한 플랫폼의 표준 위치에서 Claude Desktop 구성 파일을 읽습니다
  * `--scope user` 플래그를 사용하여 사용자 구성에 서버를 추가합니다
  * 가져온 서버는 이름에 문자, 숫자, 하이픈 및 언더스코어만 포함될 때 Claude Desktop과 동일한 이름을 유지합니다. Claude Code는 다른 문자를 포함하는 이름의 서버를 보고하고 건너뜁니다
  * 동일한 이름의 서버가 이미 존재하면 숫자 접미사가 붙습니다 (예: `server_1`)
</Tip>

<h2 id="use-mcp-servers-from-claude-ai">
  claude.ai에서 MCP 서버 사용
</h2>

[claude.ai](https://claude.ai) 계정으로 Claude Code에 로그인한 경우, claude.ai에서 추가한 MCP 서버([커넥터](https://claude.com/docs/connectors)라고 함)가 Claude Code에서 자동으로 사용 가능합니다:

<Steps>
  <Step title="claude.ai에서 MCP 서버 구성">
    [claude.ai/customize/connectors](https://claude.ai/customize/connectors)에서 서버를 추가합니다. Team 및 Enterprise 플랜에서는 관리자만 서버를 추가할 수 있습니다.
  </Step>

  <Step title="MCP 서버 인증">
    claude.ai에서 필요한 인증 단계를 완료합니다.
  </Step>

  <Step title="Claude Code에서 서버 보기 및 관리">
    Claude Code에서 다음 명령을 사용합니다:

    ```text wrap theme={null}
    /mcp
    ```

    claude.ai의 서버는 claude.ai에서 온 것을 나타내는 표시기와 함께 목록에 나타납니다.
  </Step>
</Steps>

Anthropic은 또한 사용자나 관리자가 추가하지 않고도 일부 커넥터를 자체적으로 제공합니다. [Claude Docs](/docs/ko/artifacts#write-a-document-with-claude-docs)를 사용할 수 있는 계정에서는 `/mcp`가 설정 없이 `claude.ai Claude Docs`를 나열하며, 다른 사람을 위한 문서를 요청할 때 Claude가 이를 사용합니다. 이를 끄려면 `deniedMcpServers`에 `"claude.ai Claude Docs"`의 `serverName` 항목을 추가하거나 [claude.ai 커넥터 비활성화](#disable-claude-ai-connectors)에 설명된 `/mcp` 토글을 사용합니다.

조직이 claude.ai에서 인증을 관리할 때 Claude Code는 커넥터를 `/mcp`와 [`/plugin`](/docs/ko/plugins/install) 관리자에서 `managed`로 표시합니다. Managed 상태는 Claude Code가 커넥터에 연결하는 방식이나 조직의 [도구 제어](#organization-controls-on-connector-tools)를 적용하는 방식을 변경하지 않습니다.

한 번도 로그인하지 않은 커넥터는 claude.ai 섹션의 끝에 있는 `Show unused connectors` 행 뒤에 축소되므로 조직에서 제공한 목록이 패널을 채우지 않습니다. 행을 선택하여 확장합니다. 이전에 로그인한 커넥터는 현재 재인증이 필요한 경우에도 계속 표시됩니다.

claude.ai의 커넥터는 활성 [인증 방법](/docs/ko/authentication#authentication-precedence)이 claude.ai 구독 로그인일 때만 가져옵니다. 다음의 경우 이전에 `/login`을 실행했더라도 로드되지 않습니다:

* `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN` 또는 `apiKeyHelper`가 활성 상태
* Amazon Bedrock 또는 Google Cloud의 Agent Platform과 같은 타사 제공자가 활성 상태
* `ANTHROPIC_PROFILE`, 페더레이션 변수 또는 활성 [Anthropic 프로필](/docs/ko/authentication#anthropic-profiles-and-federation-credentials)이 자격 증명을 제공
* `CLAUDE_CODE_OAUTH_TOKEN`이 [`claude setup-token`](/docs/ko/authentication#generate-a-long-lived-token)의 토큰을 보유 중(모델 요청만 수행 가능)

`/mcp`에 추가한 커넥터가 나열되지 않으면 `/status`를 실행하여 활성 인증 방법을 확인합니다. 해당 환경 변수를 설정 해제하거나 `apiKeyHelper` 설정을 제거하거나 [프로필을 끕니다](/docs/ko/authentication#anthropic-profiles-and-federation-credentials). 그런 다음 `/login`을 실행하여 claude.ai 계정을 선택합니다.

임시 네트워크 문제로 인해 세션 시작 시 커넥터 목록이 로드되지 않으면 Claude Code는 백그라운드에서 최대 3회까지 가져오기를 다시 시도하며, 재시도가 성공하면 커넥터가 나타납니다. 여전히 나타나지 않으면 Claude Code를 다시 시작하여 목록을 다시 가져옵니다.

`/mcp`에 커넥터가 `session token rejected`로 표시되거나 세부 정보 보기에 [`claude.ai rejected the session token`](/docs/ko/errors#claude-ai-rejected-the-session-token)이 표시되면 claude.ai가 Claude Code 로그인의 토큰을 거부한 것입니다. 커넥터를 다시 인증해도 이 상태가 지워지지 않습니다. 커넥터 자체의 인증이 거부된 것이 아니기 때문입니다. 이를 지우려면:

1. `/login`을 실행하여 다시 로그인합니다.
2. `/mcp`에서 커넥터를 다시 연결합니다.

v2.1.222 이전에는 Claude Code가 커넥터를 인증이 필요한 것으로 표시했으며, 이를 인증해도 해결되지 않았습니다.

Claude Code에서 추가한 서버는 동일한 URL을 가리키는 claude.ai 커넥터보다 [우선합니다](#scope-hierarchy-and-precedence). 이 경우 `/mcp`는 커넥터를 숨김으로 나열하고 중복을 제거하려면 어떻게 해야 하는지 보여줍니다.

Microsoft 365, Gmail 및 Google Calendar와 같은 일부 Anthropic 호스팅 커넥터는 업스트림 ID 제공자가 claude.ai가 등록한 리디렉션 URL만 허용하기 때문에 Claude Code의 로컬 OAuth를 지원하지 않습니다. `claude mcp add` 또는 `.mcp.json`에서 추가한 서버가 이러한 호스트 중 하나를 가리키고 `/mcp`에서 또는 `claude mcp login`으로 로그인하면 Claude Code는 [`is Anthropic-hosted and doesn't support local OAuth`](/docs/ko/errors#anthropic-hosted-and-doesnt-support-local-oauth)를 표시하여 대신 [claude.ai/customize/connectors](https://claude.ai/customize/connectors)에서 서비스를 연결하도록 지시합니다.

`claude mcp remove <name>`으로 항목을 제거하고 claude.ai에서 서비스를 연결한 후 커넥터가 Claude Code에 자동으로 나타납니다.

<h3 id="how-connectors-reach-claude-code">
  커넥터가 Claude Code에 도달하는 방식
</h3>

claude.ai 커넥터를 제어하는 설정은 세션이 실행되는 위치에 따라 달라집니다. 일부 세션만 claude.ai에서 커넥터를 가져오기 때문입니다. 아래의 각 행은 한 종류의 세션에서 커넥터가 도착하는 방식과 그곳에서 이를 제어하는 것을 이름 지정합니다. 데스크톱 앱의 [WSL 세션](/docs/ko/desktop-wsl#what-works-in-a-wsl-session)은 아직 커넥터를 사용할 수 없으므로 행이 없습니다.

| 세션이 실행되는 위치 | 커넥터가 도착하는 방식 | 이를 제어하는 것 |
| :- | :- | :- |
| Terminal, [VS Code](/docs/ko/vs-code), [JetBrains](/docs/ko/jetbrains) 및 [Agent SDK](/docs/ko/agent-sdk/claude-code-features) 세션 | Claude Code가 claude.ai에서 가져옴 | 이 섹션의 설정 및 [관리형 MCP 구성](/docs/ko/managed-mcp) |
| [클라우드 세션](/docs/ko/claude-code-on-the-web) | 클라우드 호스트가 전달 | claude.ai 조직 설정, 그리고 세션에 도달하는 [허용 목록 및 거부 목록](/docs/ko/managed-mcp#policy-based-control-with-allowlists-and-denylists) 설정 및 이를 실행하는 호스트의 모든 `managed-mcp.json` |
| [데스크톱 앱](/docs/ko/desktop)의 로컬 및 SSH 세션 | 데스크톱 앱이 프로세스 내에서 전달 | 조직의 [커넥터 도구 제어](#organization-controls-on-connector-tools)의 `blocked` 항목 |

[`disableClaudeAiConnectors`](#disable-claude-ai-connectors), `ENABLE_CLAUDEAI_MCP_SERVERS` 및 [`allowAllClaudeAiMcps`](/docs/ko/settings-reference#allowallclaudeaimcps)는 첫 번째 행(Claude Code가 자체적으로 가져오는 커넥터)에만 작용합니다. 다른 두 행은 다음과 같은 방식으로 다릅니다:

* **클라우드 세션**: 세션에 도달하는 `allowedMcpServers` 및 `deniedMcpServers` 항목(예: [서버 관리 설정](/docs/ko/server-managed-settings)을 통해)도 전달된 커넥터를 필터링합니다. 세션의 프록시는 각 커넥터의 URL을 다시 작성하므로 커넥터 자체의 URL에 대해 작성된 `serverUrl` 패턴은 일치하지 않습니다. 자체 호스팅 환경에서 URL 허용 목록과 함께 전달된 커넥터를 허용하려면 [커넥터 트래픽이 네트워크를 떠남](/docs/ko/self-hosted-environments-deploy#connector-traffic-leaves-your-network) 아래에 나열된 `serverUrl` 항목을 추가합니다. Claude Code는 [자체 호스팅 실행기 호스트](/docs/ko/self-hosted-environments-configuration#mcp-servers)와 같이 세션을 실행하는 호스트에 `managed-mcp.json`이 있을 때 전달된 커넥터를 삭제합니다. `allowAllClaudeAiMcps`를 설정했는지 여부와 관계없이 말입니다.
* **데스크톱 앱 로컬 및 SSH 세션**: 데스크톱 앱은 커넥터를 프로세스 내 `type: "sdk"` 서버로 등록하며, MCP 설정이나 `managed-mcp.json`이 이에 도달하지 않습니다. 사용자는 [claude.ai/customize/connectors](https://claude.ai/customize/connectors)에서 연결을 끊어 자신의 세션에서 커넥터를 제외합니다. 조직은 커넥터의 [도구](#organization-controls-on-connector-tools)를 차단하거나 [데스크톱 앱에서 Claude Code를 완전히 끕니다](/docs/ko/desktop#admin-console-controls).

<h3 id="organization-controls-on-connector-tools">
  커넥터 도구에 대한 조직 제어
</h3>

조직은 [claude.ai 커넥터](https://claude.com/docs/connectors)에 도구별 제어를 설정할 수 있습니다. Claude Code는 시작 시 이러한 설정을 읽고 로컬에서 적용합니다. 단, 데스크톱 앱의 [로컬 및 SSH 세션](#how-connectors-reach-claude-code)은 예외입니다. 거기서 데스크톱 앱은 커넥터를 전달하기 전에 `blocked` 도구를 보류하며, `ask` 설정은 Claude Code에 도달하지 않으므로 모든 호출에서 프롬프트하는 대신 세션의 일반 [권한 규칙](/docs/ko/permissions)을 해당 도구에 적용합니다. Claude Code가 자체적으로 커넥터를 가져오는 세션에서는 `/mcp`를 실행하여 커넥터의 각 도구에 적용되는 설정을 확인합니다.

* **도구가 `ask`로 설정됨**: Claude Code는 `Your organization requires approval for this tool` 이유로 모든 호출에서 프롬프트합니다. 프롬프트는 `acceptEdits`, `auto` 및 `bypassPermissions` [권한 모드](/docs/ko/permissions#permission-modes)에서도 나타나며 선택을 기억하는 옵션을 제공하지 않습니다. 도구와 일치하는 [허용 규칙](/docs/ko/permissions)도 프롬프트를 건너뛰지 않습니다. 프롬프트를 하지 않는 `dontAsk` 모드에서 Claude Code는 호출을 거부합니다.
* **도구가 `blocked`로 설정됨**: Claude Code는 Claude가 보기 전에 도구를 필터링하므로 도구 목록에 나타나지 않습니다. Claude Code가 자체적으로 커넥터를 가져오는 세션에서는 `/mcp` 도구 목록이 여전히 도구를 표시하며, `disabled by your organization`으로 표시됩니다.

데스크톱 앱과 claude.ai 채팅은 동일한 `blocked` 설정을 적용하므로 Claude는 거기서도 도구를 사용할 수 없으며, 데스크톱 앱의 세션에서 도구를 보류하면서 채팅에서 사용 가능하게 유지할 수 없습니다. 데스크톱 앱은 모든 도구가 차단된 커넥터를 건너뜁니다.

<h3 id="disable-claude-ai-connectors">
  claude.ai 커넥터 비활성화
</h3>

Claude Code는 [`disableClaudeAiConnectors`](/docs/ko/settings-reference#disableclaudeaiconnectors)를 [자체적으로 가져오는](#how-connectors-reach-claude-code) 커넥터에만 적용하며, 클라우드 호스트 또는 데스크톱 앱이 전달하는 커넥터에는 적용하지 않습니다. 가져오는 커넥터를 끄려면 설정을 모든 설정 범위에서 `true`로 설정합니다:

```json theme={null}
{
  "disableClaudeAiConnectors": true
}
```

이 설정은 any-source-true 의미론을 사용합니다: 모든 설정 소스의 `true`가 우선합니다. 체크인된 프로젝트 `.claude/settings.json`은 Claude Code가 자체적으로 가져오는 커넥터를 저장소에서 제외할 수 있지만, 프로젝트 수준 `false`는 사용자 또는 정책 수준 `true`가 비활성화한 커넥터를 다시 활성화할 수 없습니다. `--mcp-config`를 통해 명시적으로 전달된 서버는 영향을 받지 않습니다.

`ENABLE_CLAUDEAI_MCP_SERVERS` 환경 변수를 `false`로 설정할 수도 있습니다. 이는 현재 셸 세션에 대해 동일한 효과를 갖습니다:

```bash theme={null}
ENABLE_CLAUDEAI_MCP_SERVERS=false claude
```

모든 claude.ai 커넥터를 차단하는 대신 개별 커넥터를 차단하려면 이름 또는 URL 패턴으로 [`deniedMcpServers`](/docs/ko/managed-mcp)에 추가합니다. 예를 들어, `serverName` 항목 `"claude.ai Slack"`은 Slack 커넥터를 차단합니다. `/mcp`를 실행하여 Claude Code가 현재 프로젝트에만 가져오는 모든 커넥터를 켜거나 끌 수도 있습니다.

<h2 id="use-claude-code-as-an-mcp-server">
  Claude Code를 MCP 서버로 사용하기
</h2>

Claude Code 자체를 다른 애플리케이션이 연결할 수 있는 MCP 서버로 사용할 수 있습니다:

```bash theme={null}
# Claude를 stdio MCP 서버로 시작합니다
claude mcp serve
```

이 명령은 시작할 때 아무것도 출력하지 않습니다. stdio MCP 서버는 stdin과 stdout을 통해 통신하므로, 침묵하고 차단된 터미널은 서버가 실행 중이며 클라이언트의 연결을 기다리고 있다는 의미입니다.

claude\_desktop\_config.json에 다음 구성을 추가하여 Claude Desktop에서 이를 사용할 수 있습니다:

```json theme={null}
{
  "mcpServers": {
    "claude-code": {
      "type": "stdio",
      "command": "claude",
      "args": ["mcp", "serve"],
      "env": {}
    }
  }
}
```

<Warning>
  **실행 파일 경로 구성**: `command` 필드는 Claude Code 실행 파일을 참조해야 합니다. `claude` 명령이 시스템의 PATH에 없으면 실행 파일의 전체 경로를 지정해야 합니다.

  전체 경로를 찾으려면:

  ```bash theme={null}
  which claude
  ```

  그런 다음 구성에서 전체 경로를 사용합니다:

  ```json theme={null}
  {
    "mcpServers": {
      "claude-code": {
        "type": "stdio",
        "command": "/full/path/to/claude",
        "args": ["mcp", "serve"],
        "env": {}
      }
    }
  }
  ```

  올바른 실행 파일 경로가 없으면 `spawn claude ENOENT`와 같은 오류가 발생합니다.
</Warning>

<Tip>
  팁:

  * Claude Desktop에서 Claude에게 디렉터리의 파일을 읽고, 편집을 수행하는 등의 작업을 요청해 보세요.
  * 이 MCP 서버는 Claude Code의 도구만 MCP 클라이언트에 노출하므로, 사용자의 클라이언트는 개별 도구 호출에 대한 사용자 확인을 구현할 책임이 있습니다.
</Tip>

<h2 id="mcp-output-limits-and-warnings">
  MCP 출력 제한 및 경고
</h2>

MCP 도구가 대용량 출력을 생성할 때, Claude Code는 토큰 사용량을 관리하여 대화 컨텍스트가 압도되지 않도록 도움을 줍니다:

* **출력 경고 임계값**: Claude Code는 MCP 도구 출력이 10,000 토큰을 초과할 때 경고를 표시합니다
* **구성 가능한 제한**: `MAX_MCP_OUTPUT_TOKENS` 환경 변수를 사용하여 최대 허용 MCP 출력 토큰을 조정할 수 있습니다
* **기본 제한**: 기본 최댓값은 25,000 토큰입니다
* **범위**: 환경 변수는 자체 제한을 선언하지 않은 도구에 적용됩니다. [`anthropic/maxResultSizeChars`](#raise-the-limit-for-a-specific-tool)를 설정한 도구는 `MAX_MCP_OUTPUT_TOKENS`가 무엇으로 설정되어 있든 관계없이 텍스트 콘텐츠에 대해 해당 값을 대신 사용합니다. 이미지 데이터를 반환하는 도구는 여전히 `MAX_MCP_OUTPUT_TOKENS`의 적용을 받습니다
* **제한 초과**: 이미지 콘텐츠가 없는 성공한 결과가 토큰 제한을 초과하면, Claude Code는 이를 파일에 저장하고 대화에서 파일 경로를 명시하는 메시지로 대체하므로, Claude는 콘텐츠가 필요할 때 파일을 읽습니다. 파일은 [`~/.claude/projects/`](/docs/ko/claude-directory#cleaned-up-automatically) 아래의 세션의 `tool-results` 디렉터리에 저장됩니다.
* **HTTP 및 SSE 서버의 응답 크기**: Claude Code는 [HTTP](#option-1-add-a-remote-http-server) 또는 [SSE](#option-2-add-a-remote-sse-server) 서버의 응답에서 하나의 JSON 응답 본문 또는 이벤트 스트림의 하나의 이벤트가 압축 해제 후 16MB를 넘으면 응답 읽기를 중단합니다. 해당 응답이 응답하는 요청은 실패합니다. 서버를 관리하는 경우, 결과를 페이지로 나누는 등의 방법으로 응답당 반환하는 데이터를 줄여 제한을 넘지 않도록 합니다

Claude Code가 [백그라운드 작업으로 전환한](#automatic-backgrounding-of-long-tool-calls) 호출은 작업 알림을 통해 결과를 보고합니다. 포그라운드에서 완료되는 호출에는 두 가지 제한이 추가로 적용됩니다:

* **텍스트 결과의 문자 제한**: [`anthropic/maxResultSizeChars`](#raise-the-limit-for-a-specific-tool)를 선언하지 않은 도구의 경우, Claude Code는 이미지 콘텐츠가 없는 성공한 결과가 토큰 수와 관계없이 50,000자를 초과하면 이를 파일에 저장합니다. `MAX_MCP_OUTPUT_TOKENS`를 설정해도 이 임계값은 변경되지 않습니다
* **오류 결과**: 도구가 `isError: true`로 표시된 결과를 반환하면, Claude는 결과의 텍스트를 도구의 오류 메시지로 받습니다. 약 11,000자보다 긴 오류 텍스트는 처음 5,000자와 마지막 5,000자만 유지되며, 그 사이에 제거된 문자 수를 알려 주는 표시가 삽입됩니다

토큰 제한을 변경하려면 Claude Code를 시작하기 전에 셸에서 `MAX_MCP_OUTPUT_TOKENS`를 설정합니다:

```bash theme={null}
export MAX_MCP_OUTPUT_TOKENS=50000
claude
```

<h3 id="raise-the-limit-for-a-specific-tool">
  특정 도구의 제한 늘리기
</h3>

MCP 서버를 구축하는 경우, 도구의 `tools/list` 응답 항목에서 `_meta["anthropic/maxResultSizeChars"]`를 설정하여 개별 도구가 기본 디스크 저장 임계값인 50,000자보다 큰 결과를 반환하도록 허용할 수 있습니다. Claude Code는 해당 도구의 임계값을 주석 처리된 값으로 올립니다. 단, 500,000자의 하드 상한선까지입니다.

이는 데이터베이스 스키마나 전체 파일 트리와 같이 본질적으로 크지만 필요한 출력을 반환하는 도구에 유용합니다. 주석 처리가 없으면 기본 임계값을 초과하는 성공한 결과는 디스크에 저장되고 대화에서 파일 참조로 대체됩니다.

```json theme={null}
{
  "name": "get_schema",
  "description": "Returns the full database schema",
  "_meta": {
    "anthropic/maxResultSizeChars": 200000
  }
}
```

주석 처리는 텍스트 콘텐츠에 대해 `MAX_MCP_OUTPUT_TOKENS`와 독립적으로 적용되므로, 사용자는 이를 선언한 도구에 대해 환경 변수를 올릴 필요가 없습니다. 이미지 데이터를 반환하는 도구는 여전히 토큰 제한의 적용을 받습니다.

<h3 id="images-in-tool-results">
  도구 결과의 이미지
</h3>

MCP 도구가 PNG, JPEG, GIF 또는 WebP 이미지를 반환하면, Claude는 대화에서 이미지를 인라인으로 봅니다. 인라인 복사본은 모델의 이미지 크기 제한에 맞도록 축소되거나 압축될 수 있습니다. Claude Code는 또한 원본 바이트를 [`~/.claude/projects/`](/docs/ko/claude-directory#cleaned-up-automatically) 아래의 세션의 `tool-results` 디렉터리에 있는 파일에 저장하고 Claude에 경로를 제공합니다. Claude는 그 후 Bash와 같은 도구를 사용하여 전체 해상도 파일을 자르거나, 변환하거나, 재사용할 수 있습니다.

[`--no-session-persistence`](/docs/ko/cli-reference#cli-flags) 또는 [`CLAUDE_CODE_SKIP_PROMPT_HISTORY`](/docs/ko/env-vars)를 사용하여 세션 지속성을 비활성화하면, Claude Code는 이미지 파일을 작성하지 않으며 Claude는 인라인 복사본만 받습니다.

MCP 이미지 결과를 파일에 저장하려면 Claude Code v2.1.283 이상이 필요합니다.

<h2 id="tool-input-schemas-with-a-root-level-combinator">
  루트 레벨 결합자가 있는 도구 입력 스키마
</h2>

일부 MCP 서버는 도구의 입력 스키마를 JSON Schema 합집합으로 선언하며, 스키마의 최상위 레벨에 `anyOf`, `oneOf` 또는 `allOf`를 포함합니다. Claude API는 스키마 루트에서 이러한 키워드를 허용하지 않습니다. 이는 `properties` 내에 중첩된 결합자를 허용하며, Claude Code는 이를 변경하지 않고 전송합니다.

루트 레벨 결합자가 있는 도구는 계속 사용 가능합니다. 도구를 API로 전송하기 전에 Claude Code는 스키마를 단일 객체로 평탄화하고 도구의 설명 앞에 어느 매개변수 그룹이 함께 속하는지 Claude에게 알려주는 문장을 추가합니다:

* `allOf`: 모든 분기의 속성이 병합되며, 각 분기의 `required` 목록은 여전히 적용됩니다
* `anyOf` 및 `oneOf`: 모든 분기의 속성이 병합되며, 각 분기의 `required` 목록은 스키마에 의해 강제되지 않고 도구 설명에 설명됩니다

서버는 Claude가 선택한 인수를 수신하므로 서버 측에서 조합을 계속 검증하십시오.

Claude Code가 API가 허용하는 스키마를 생성할 수 없거나 스키마 재작성을 활성화하는 원격 구성을 받지 않는 배포에서는 해당 도구 하나를 건너뛰고, 서버의 로그에 이유를 기록하며, 서버의 다른 도구는 사용 가능하게 유지합니다.

<h2 id="tools-with-invalid-input-schemas">
  유효하지 않은 입력 스키마를 가진 도구
</h2>

Claude API는 요청의 모든 도구의 입력 스키마를 확인하고 하나의 스키마라도 실패하면 전체 요청을 거부하므로, 형식이 잘못된 스키마를 가진 단일 MCP 도구가 있으면 이를 포함하는 모든 요청이 400 오류로 실패합니다. Claude Code는 서버의 도구를 로드할 때 API의 확인 중 두 가지를 직접 실행하고 이를 실패할 각 도구를 제외하므로, 서버의 다른 도구는 계속 작동합니다:

* 최상위 속성 이름은 1\~64자 길이여야 하며 ASCII 문자와 숫자, `_`, `.`, `-`만 사용해야 합니다
* 스키마는 JSON Schema draft 2020-12 메타스키마에 대해 유효해야 합니다. Claude Code는 `$schema`를 선언하지 않는 스키마와 draft 2020-12를 선언하는 스키마에 이 확인을 적용합니다. 다른 방언을 선언하는 스키마는 이 확인을 건너뛰지만, 위의 속성 이름 확인은 여전히 적용됩니다

Claude Code가 도구를 제외할 때, 서버의 로그에 이유를 기록하고 제외된 도구와 그 이유를 Claude에 알리므로, Claude에 도구가 누락된 이유를 물어볼 수 있습니다. 서버에서 스키마를 수정하면, Claude Code가 다음에 서버의 도구를 로드할 때 도구가 다시 나타납니다.

Claude Code는 Anthropic에서 가져오는 기능 플래그를 통해 제외를 켭니다. [플래그 가져오기가 꺼진 배포](/docs/ko/env-vars#features-that-need-feature-flag-fetching)에서 또는 에어갭 머신과 같이 플래그가 도착한 적이 없는 머신에서, Claude Code는 여전히 확인을 실행하고 서버의 로그에 어떤 도구가 거부될 것인지 기록하지만, 도구의 스키마를 API로 어쨌든 전송합니다. API는 [도구를 위치로 이름 지은 400 오류](/docs/ko/errors#tool-input-schema-is-invalid)로 해당 스키마를 포함하는 요청을 거부합니다. v2.1.216 이전에는 배포가 이러한 확인을 실행하지 않았습니다.

[루트 수준 결합자 처리](#tool-input-schemas-with-a-root-level-combinator)는 별개이며 플래그 가져오기가 꺼져 있거나 플래그가 도착한 적이 없을 때 자체 동작을 유지합니다.

<h2 id="require-approval-for-a-specific-tool">
  특정 도구에 승인 요구하기
</h2>

MCP 서버를 구축하는 경우, 도구의 `tools/list` 응답 항목에서 `_meta["anthropic/requiresUserInteraction"]`을 `true`로 설정하여 해당 도구가 매 호출마다 명시적인 승인을 요구하도록 지정할 수 있습니다. 값은 반드시 JSON 불리언 `true`여야 하며, 그 외의 값은 무시됩니다.

Claude Code는 `acceptEdits`, `auto`, `bypassPermissions` [권한 모드](/docs/ko/permissions#permission-modes)에서도 해당 도구의 권한 프롬프트를 매 호출마다 표시하며, 해당 도구에 대해서는 "다시 묻지 않기" 옵션을 제공하지 않습니다. 해당 도구와 일치하는 [허용 규칙](/docs/ko/permissions#permission-rule-syntax)도 프롬프트를 건너뛰지 않습니다. 프롬프트를 전혀 표시하지 않는 `dontAsk` 모드에서는 Claude Code가 대신 호출을 거부합니다.

프롬프트는 반드시 사람에게 전달되어야 합니다. [`--permission-prompt-tool`](/docs/ko/cli-reference#cli-flags)을 사용하는 비대화형 모드에서는, 지정된 도구에 대해 프롬프트 도구가 반환한 `allow` 결과가 `MCP tool requires user interaction; not supported via --permission-prompt-tool` 메시지와 함께 거부로 변환됩니다. Agent SDK의 [`canUseTool` 콜백](/docs/ko/agent-sdk/permissions)은 이러한 호출을 전달받아 승인할 수 있습니다. SDK 애플리케이션이 이를 사용자에게 표시할 것으로 기대되기 때문입니다.

이 기능은 권한 프롬프트 자체가 핵심인 도구에 사용하십시오. 예를 들어 동의 또는 접근 권한 부여 단계처럼, 자동 승인이 이루어지면 결국 어떤 사람도 동의한 적이 없는 상태가 되어 버리는 경우입니다. 같은 서버의 다른 도구는 기존 권한 동작을 그대로 유지합니다.

다음 `tools/list` 항목은 하나의 도구를 항상 승인이 필요한 도구로 지정합니다.

```json theme={null}
{
  "name": "grant_access",
  "description": "Requests access to a protected resource",
  "_meta": {
    "anthropic/requiresUserInteraction": true
  }
}
```

[Remote Control](/docs/ko/remote-control)이나 [Agent SDK](/docs/ko/agent-sdk/overview)로 구축한 애플리케이션과 같은 일부 사용 환경에서는 일반적으로 한 번의 탭으로 도구 호출을 승인할 수 있습니다. 이 어노테이션이 지정된 도구의 경우 Claude Code는 한 번의 탭 동작을 제공하지 않고 대신 도구의 전체 권한 프롬프트를 표시합니다. 따라서 승인은 탭이 아니라 프롬프트에 응답하는 사람으로부터 이루어집니다.

Claude Code는 터미널 대화 상자에서만 전체를 표시할 수 있는 모든 권한 요청에 대해서도 같은 방식으로 한 번의 탭 승인을 제공하지 않습니다. 예를 들어 안전 경고가 포함되어 있거나, 원격 사용 환경에서 표시할 수 없는 항상 허용 옵션이 포함된 요청이 이에 해당합니다. 이러한 요청은 Remote Control이 아닌 터미널 대화 상자에서 응답해야 합니다. Claude Code v2.1.214 이상이 필요합니다.

<h2 id="respond-to-mcp-elicitation-requests">
  MCP 유도 요청에 응답하기
</h2>

MCP 서버는 작업 중에 유도(elicitation)를 사용하여 구조화된 입력을 요청할 수 있습니다. 서버가 자체적으로 얻을 수 없는 정보가 필요할 때, Claude Code는 대화형 대화 상자를 표시하고 사용자의 응답을 서버에 다시 전달합니다. 사용자 측에서 구성할 필요가 없습니다. 유도 대화 상자는 서버가 요청할 때 자동으로 나타납니다.

서버는 두 가지 방식으로 입력을 요청할 수 있습니다.

* **양식 모드**: Claude Code는 서버에서 정의한 양식 필드가 있는 대화 상자를 표시합니다(예: 사용자 이름 및 암호 프롬프트). 필드를 채우고 제출합니다.
* **URL 모드**: Claude Code는 브라우저에서 링크를 열지 여부를 묻습니다. 서버는 이 모드를 터미널 외부에서 완료되는 흐름(예: 로그인)에 사용합니다.

URL 모드에서 Claude Code는 URL을 명령줄 인수로 시스템의 URL 핸들러에 전달하며, 해당 인수의 길이를 제한합니다. URL이 명령줄에 대해 이스케이프된 후 해당 제한을 초과하면 요청을 거부할 수만 있습니다. `%` 또는 `&`와 같이 이스케이프해야 하는 모든 문자는 제한에 대해 4배로 계산됩니다. 즉, 자신의 문자와 3개의 이스케이프 문자입니다. 이들이 없는 URL은 약 8,000자에서 제한에 도달합니다. 대부분 퍼센트 이스케이프로 구성된 URL(3번째 문자마다 `%`가 있는 경우)은 대략 4,000에서 도달합니다.

유도 요청에 대화 상자를 표시하지 않고 자동으로 응답하려면 [`Elicitation` hook](/docs/ko/hooks#elicitation)을 사용합니다.

유도를 사용하는 MCP 서버를 구축하는 경우, 프로토콜 세부 정보 및 스키마 예제는 [MCP 유도 사양](https://modelcontextprotocol.io/docs/learn/client-concepts#elicitation)을 참조합니다.

[protocol revision 2026-07-28](#mcp-client-runtimes)을 사용하는 연결에서 Claude Code는 클라이언트 기능에서 `elicitation: {form: {}, url: {}}`을 선언하므로, 해당 프로토콜의 표준 유도 요청을 통해 서버가 어느 모드든 요청할 수 있습니다.

<h2 id="use-mcp-resources">
  MCP 리소스 사용
</h2>

MCP 서버는 파일을 참조하는 방식과 유사하게 @ 멘션을 사용하여 참조할 수 있는 리소스를 노출할 수 있습니다.

<h3 id="reference-mcp-resources">
  MCP 리소스 참조
</h3>

<Steps>
  <Step title="사용 가능한 리소스 나열">
    프롬프트에서 `@`를 입력하여 연결된 모든 MCP 서버의 사용 가능한 리소스를 확인합니다. 리소스는 자동 완성 메뉴에서 파일과 함께 표시됩니다.
  </Step>

  <Step title="특정 리소스 참조">
    `@server:protocol://resource/path` 형식을 사용하여 리소스를 참조합니다:

    ```text wrap theme={null}
    Can you analyze @github:issue://123 and suggest a fix?
    ```

    ```text wrap theme={null}
    Please review the API documentation at @docs:file://api/authentication
    ```
  </Step>

  <Step title="여러 리소스 참조">
    단일 프롬프트에서 여러 리소스를 참조할 수 있습니다:

    ```text wrap theme={null}
    Compare @postgres:schema://users with @docs:file://database/user-model
    ```
  </Step>
</Steps>

<Tip>
  팁:

  * 리소스는 참조될 때 자동으로 가져와지고 첨부 파일로 포함됩니다
  * 리소스 경로는 @ 멘션 자동 완성에서 퍼지 검색 가능합니다
  * Claude Code는 서버가 지원할 때 MCP 리소스를 나열하고 읽을 수 있는 도구를 자동으로 제공합니다
  * 리소스는 MCP 서버가 제공하는 모든 유형의 콘텐츠(텍스트, JSON, 구조화된 데이터 등)를 포함할 수 있습니다
</Tip>

MCP Apps UI 리소스는 `ui://` URI 또는 `text/html;profile=mcp-app` 미디어 타입을 가진 항목입니다: Claude가 읽을 콘텐츠가 아니라 호스트 애플리케이션이 렌더링할 페이지입니다. 이들은 `@` 제안이나 리소스 목록 도구의 결과에 나타나지 않으며, UI 리소스만 제공하는 서버는 빈 리소스 목록을 표시합니다. URI로 UI 리소스를 읽는 것은 여전히 작동합니다.

<h2 id="scale-with-mcp-tool-search">
  MCP 도구 검색으로 확장하기
</h2>

도구 검색은 Claude가 필요할 때까지 도구 정의를 연기하여 MCP 컨텍스트 사용량을 낮게 유지합니다. 세션 시작 시 도구 이름과 서버 지침만 로드되므로 더 많은 MCP 서버를 추가해도 컨텍스트 윈도우에 미치는 영향이 최소화됩니다. Claude Code는 서버당 고정된 도구 상한을 부과하지 않으며, 실질적인 제한은 컨텍스트 윈도우 예산입니다.

<Note>
  도구 검색은 Microsoft Foundry [Azure에서 호스팅되는 배포](https://platform.claude.com/docs/en/build-with-claude/claude-in-microsoft-foundry#hosting-options)에서 지원되지 않으며, 이는 서버 측에서 거부합니다. Claude Code는 거부를 감지하고 해당 배포에 대해 대신 MCP 도구를 미리 로드합니다. [`ENABLE_TOOL_SEARCH`](#configure-tool-search)는 거부가 배포 자체에서 발생하므로 이를 재정의할 수 없습니다.
</Note>

<span id="for-mcp-server-authors" />

<h3 id="tool-search-for-mcp-server-authors">
  MCP 서버 작성자를 위한 도구 검색
</h3>

MCP 서버를 구축하는 경우, 도구 검색이 활성화되면 서버 지침 필드가 더욱 유용해집니다. 서버 지침은 Claude가 도구를 검색할 시기를 이해하는 데 도움이 되며, [기술](/docs/ko/skills)이 작동하는 방식과 유사합니다.

다음을 설명하는 명확하고 설명적인 서버 지침을 추가하세요:

* 도구가 처리하는 작업의 범주
* Claude가 도구를 검색해야 할 시기
* 서버가 제공하는 주요 기능

Claude Code는 각 도구 설명과 각 서버의 지침을 기본적으로 2,048자에서 자릅니다. 간결하게 유지하고 중요한 세부 정보를 시작 부분에 배치하세요.

세션의 모든 MCP 서버에 대한 제한을 변경하려면 [`CLAUDE_CODE_MAX_MCP_DESCRIPTION_LENGTH`](/docs/ko/env-vars#variables)를 문자 수로 설정하세요. 이 변수는 Claude Code v2.1.280 이상이 필요합니다.

<h4 id="per-tool-alwaysload">
  도구를 미리 로드하거나 연기된 상태로 유지하도록 표시
</h4>

서버의 도구 중 하나가 로드되는 방식을 제어하려면 해당 도구의 `_meta` 객체에 `"anthropic/alwaysLoad"`를 설정하세요. 서버를 Claude Code에 추가하는 사람도 자신의 구성에서 서버 전체에 대해 [`alwaysLoad`](#exempt-a-server-from-deferral)를 설정할 수 있으며, 그 설정이 작성자의 설정을 재정의할 수 있습니다:

| 도구의 값 | 동작 |
| :- | :- |
| `true` | 도구가 미리 로드됩니다. 이 값 때문에 시작 시 서버를 기다리지는 않습니다. 서버를 구성하는 사람은 여전히 [서버의 모든 도구를 연기](#defer-a-servers-tools)할 수 있습니다 |
| `false` | 해당 구성에서 `"alwaysLoad": true`를 설정하더라도 도구가 연기된 상태로 유지됩니다. 이는 서버가 [`--mcp-config`](/docs/ko/cli-reference#cli-flags)로 전달되거나, [Agent SDK 애플리케이션](/docs/ko/agent-sdk/mcp#in-code)에서 제공되거나, [플러그인](#plugin-provided-mcp-servers)에서 제공될 때 적용됩니다. 다른 서버에서는 도구가 미리 로드됩니다. Claude Code v2.1.285 이상이 필요합니다 |

다음 `tools/list` 항목은 하나의 도구를 미리 로드하도록 요청합니다:

```json theme={null}
{
  "name": "search_tickets",
  "description": "Searches the ticket tracker by keyword",
  "_meta": {
    "anthropic/alwaysLoad": true
  }
}
```

<h3 id="configure-tool-search">
  도구 검색 구성
</h3>

도구 검색은 기본적으로 활성화됩니다. MCP 도구는 연기되고 필요에 따라 발견됩니다. Claude Code는 `ANTHROPIC_BASE_URL`이 비자사 호스트를 가리킬 때 이를 비활성화합니다. 대부분의 프록시가 `tool_reference` 블록을 전달하지 않기 때문입니다. 해당 폴백을 재정의하려면 `ENABLE_TOOL_SEARCH`를 명시적으로 설정하세요.

[`CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS`](/docs/ko/env-vars)를 설정하면 도구 검색이 꺼집니다. `ENABLE_TOOL_SEARCH`를 직접 설정하여 재정의할 수 없습니다. 조직은 Claude Code v2.1.227 이상에서 [관리 설정](/docs/ko/managed-settings)을 통해 도구 검색을 계속 활성화할 수 있습니다. [사전 릴리스 기능 비활성화](/docs/ko/llm-gateway-protocol#disable-pre-release-capabilities)는 재정의가 적용되는 위치와 변수가 제거하는 항목을 다룹니다.

도구 검색에는 `tool_reference` 블록을 지원하는 모델이 필요합니다. Claude Sonnet 4.5, Claude Haiku 4.5, Claude Opus 4.5 및 이후 모델입니다. 현재 목록은 [API 문서의 모델 호환성](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool#model-compatibility)을 참조하세요.

Google Cloud의 Agent Platform에서 Claude Code는 모델 세대별로 결정합니다:

* **Claude Opus 4.5, Sonnet 4.5, Haiku 4.5 및 이후 모델**: 도구 검색은 기본적으로 활성화되며, Anthropic API와 동일합니다.
* **이전 Agent Platform 모델**: Claude Code는 필요한 베타 헤더를 거부하는 서빙 스택 때문에 모든 MCP 도구를 미리 로드합니다. `ENABLE_TOOL_SEARCH=true`는 이를 재정의하지 않습니다.

v2.1.221 이전에는 Claude Code가 `ENABLE_TOOL_SEARCH=true`를 설정하지 않는 한 Google Cloud의 Agent Platform의 모든 모델에 대해 도구 검색을 비활성화했습니다.

`ENABLE_TOOL_SEARCH` 환경 변수로 도구 검색 동작을 제어하세요:

| 값 | 동작 |
| :- | :- |
| (설정 안 함) | 모든 MCP 도구가 연기되고 필요에 따라 로드됩니다. Google Cloud의 Agent Platform 모델이 Claude 4.5 세대보다 이전이거나, `ANTHROPIC_BASE_URL`이 비자사 호스트이거나, Microsoft Foundry 배포가 Azure에서 호스팅될 때 미리 로드로 폴백됩니다 |
| `true` | 모든 MCP 도구가 연기됩니다. 단, Microsoft Foundry 배포가 Azure에서 호스팅될 때는 서버 측 거부가 여전히 미리 로드를 강제하고, Google Cloud의 Agent Platform 모델이 Claude 4.5 세대보다 이전일 때는 Claude Code가 도구를 미리 로드합니다. Claude Code는 프록시를 통해 베타 헤더를 전송하며, `tool_reference` 블록을 지원하지 않는 프록시에서는 요청이 실패합니다 |
| `auto` | 임계값 모드: Claude Code는 정의가 컨텍스트 윈도우의 10% 미만일 때 연기할 도구를 미리 로드하고, 정의가 10%에 도달하면 모두 연기합니다 |
| `auto:N` | 사용자 정의 백분율이 있는 임계값 모드. `N`은 0-100입니다. 예를 들어 5%의 경우 `auto:5` |
| `false` | 모든 MCP 도구가 미리 로드되고, 연기 없음 |

```bash theme={null}
# 사용자 정의 5% 임계값 사용
ENABLE_TOOL_SEARCH=auto:5 claude

# 도구 검색 완전히 비활성화
ENABLE_TOOL_SEARCH=false claude
```

또는 [settings.json `env` 필드](/docs/ko/settings-reference#env)에서 값을 설정하세요.

`ToolSearch` 도구를 특별히 비활성화할 수도 있습니다:

```json theme={null}
{
  "permissions": {
    "deny": ["ToolSearch"]
  }
}
```

<h3 id="exempt-a-server-from-deferral">
  서버를 연기에서 제외
</h3>

서버의 도구가 항상 검색 단계 없이 Claude에게 표시되어야 하는 경우, 해당 서버의 구성에서 `alwaysLoad`를 `true`로 설정하세요. 그러면 해당 서버의 도구가 `ENABLE_TOOL_SEARCH` 설정과 관계없이 컨텍스트에 로드됩니다. 각 미리 로드된 도구가 대화에 사용할 수 있는 컨텍스트를 소비하므로, Claude가 모든 턴에서 필요한 적은 수의 도구에 이를 사용하세요.

다음 `.mcp.json` 항목은 다른 서버는 연기된 상태로 두고 하나의 HTTP 서버를 제외합니다:

```json theme={null}
{
  "mcpServers": {
    "core-tools": {
      "type": "http",
      "url": "https://mcp.example.com/mcp",
      "alwaysLoad": true
    }
  }
}
```

`alwaysLoad` 필드는 모든 서버 유형에서 사용 가능합니다.

`alwaysLoad: true`를 설정하면 시작 시 서버의 도구를 기다리게 되며, 첫 번째 프롬프트가 구축될 때 도구가 있어야 하므로 표준 5초 연결 타임아웃으로 제한됩니다. 유효한 [`cached` 항목](#server-status-detail)이 있는 원격 서버는 연결하지 않고 캐시에서 도구를 제공하므로 시작을 지연시키지 않습니다. 다른 서버는 기본적으로 백그라운드에서 연결됩니다. [`MCP_CONNECTION_NONBLOCKING=0`](/docs/ko/env-vars)을 설정하여 시작이 이들을 기다리도록 하세요.

<h3 id="defer-a-servers-tools">
  서버의 도구 연기
</h3>

서버의 모든 도구를 도구 검색 뒤에 유지하려면 MCP 구성의 해당 서버 항목에 `"alwaysLoad": false`를 설정하세요. 여기에는 서버 작성자가 [미리 로드하도록 표시한](#per-tool-alwaysload) 도구도 포함됩니다. `alwaysLoad`를 생략하면 표시된 도구는 미리 로드됩니다. Claude Code v2.1.287 이상이 필요합니다.

<h2 id="use-mcp-prompts-as-commands">
  MCP 프롬프트를 명령어로 사용하기
</h2>

MCP 서버는 Claude Code에서 명령어로 사용 가능한 프롬프트를 노출할 수 있습니다.

`anthropic-skills`라는 이름의 서버에서 나온 프롬프트는 표시되지 않습니다. Claude Code는 claude.ai에서 동기화된 스킬을 위해 [해당 이름을 예약](/docs/ko/skills#names-reserved-for-synced-skills)하기 때문입니다. 서버의 도구는 여전히 작동합니다. MCP 구성에서 서버의 이름을 바꾸어 프롬프트를 나열합니다.

<h3 id="execute-mcp-prompts">
  MCP 프롬프트 실행하기
</h3>

<Steps>
  <Step title="사용 가능한 프롬프트 발견하기">
    `/`를 입력하여 MCP 서버의 프롬프트를 포함한 사용 가능한 명령어를 확인합니다. Claude Code는 각 MCP 프롬프트를 `/servername:promptname (MCP)` 형식으로 나열합니다. `/mcp__servername__promptname`을 입력하여 실행할 수도 있습니다.
  </Step>

  <Step title="인수 없이 프롬프트 실행하기">
    ```text wrap theme={null}
    /mcp__github__list_prs
    ```
  </Step>

  <Step title="인수를 포함하여 프롬프트 실행하기">
    많은 프롬프트는 인수를 허용합니다. 명령어 뒤에 공백으로 구분된 인수를 전달합니다. Claude Code는 공백을 기준으로 인수를 분할하므로 각 인수는 단일 토큰입니다:

    ```text wrap theme={null}
    /mcp__github__pr_review 456
    ```

    ```text wrap theme={null}
    /mcp__jira__create_issue login-bug high
    ```
  </Step>
</Steps>

<Tip>
  팁:

  * MCP 프롬프트는 연결된 서버에서 동적으로 발견됩니다
  * 인수는 프롬프트의 정의된 매개변수를 기반으로 구문 분석됩니다
  * 프롬프트 결과는 대화에 직접 주입됩니다
  * `/mcp__servername__promptname` 형식에서 Claude Code는 서버 이름의 `A-Z`, `a-z`, `0-9`, `_`, `-` 범위 밖의 모든 문자를 `_`로 바꾸고 서버가 선언한 프롬프트 이름을 사용합니다
</Tip>

<h2 id="managed-mcp-configuration">
  관리형 MCP 구성
</h2>

조직에서 사용자가 연결할 수 있는 MCP 서버를 중앙에서 제어해야 하는 경우 [관리형 MCP 구성](/docs/ko/managed-mcp)을 참조하십시오. 이 문서에서는 `managed-mcp.json`으로 고정 서버 세트를 배포하고, `managedMcpServers`로 모든 사용자에게 서버를 제공하며, `allowedMcpServers` 및 `deniedMcpServers`로 서버를 제한하고, 서버가 차단되었을 때 사용자에게 표시되는 내용을 다룹니다.
