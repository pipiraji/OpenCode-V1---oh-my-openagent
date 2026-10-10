> ## Documentation Index
> Fetch the complete documentation index at: https://code.claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# CLI 참조

> Claude Code 명령줄 인터페이스의 완전한 참조로, 명령어와 플래그를 포함합니다.

<h2 id="cli-commands">
  CLI 명령
</h2>

이러한 명령을 사용하여 세션을 시작하고, 콘텐츠를 파이프하고, 대화를 재개하고, 업데이트를 관리할 수 있습니다:

| 명령 | 설명 | 예시 |
| :- | :- | :- |
| `claude` | 대화형 세션 시작 | `claude` |
| `claude "query"` | 초기 프롬프트로 대화형 세션 시작 | `claude "explain this project"` |
| `claude -p "query"` | SDK를 통해 쿼리하고 종료 | `claude -p "explain this function"` |
| `cat file \| claude -p "query"` | 파이프된 콘텐츠 처리 | `cat logs.txt \| claude -p "explain"` |
| `claude -c` | 현재 디렉토리에서 가장 최근 대화 계속 | `claude -c` |
| `claude -c -p "query"` | SDK를 통해 계속 | `claude -c -p "Check for type errors"` |
| `claude -r "<session>" "query"` | ID 또는 이름으로 세션 재개 | `claude -r "auth-refactor" "Finish this PR"` |
| `claude update` | 최신 버전으로 업데이트 | `claude update` |
| `claude gateway` | 자체 호스팅 [Claude 앱 게이트웨이](/docs/ko/claude-apps-gateway) 서버를 시작합니다. Amazon Bedrock, Google Cloud의 Agent Platform 또는 Microsoft Foundry의 Claude Code 앞에 SSO 및 정책을 배포하는 관리자용입니다. [`gateway.yaml`](/docs/ko/claude-apps-gateway-config)을 가리키는 `--config`가 필요합니다. | `claude gateway --config gateway.yaml` |
| `claude install [version]` | 네이티브 바이너리를 설치하거나 재설치합니다. `2.1.118`과 같은 버전, 또는 `stable` 또는 `latest`를 허용합니다. [특정 버전 설치](/docs/ko/setup#install-a-specific-version) 참조 | `claude install stable` |
| `claude auth login` | Anthropic 계정에 로그인합니다. `--email`을 사용하여 이메일 주소를 미리 입력하고, `--sso`를 사용하여 SSO 인증을 강제하고, `--console`을 사용하여 Claude 구독 대신 API 사용 청구를 위해 Anthropic Console로 로그인할 수 있습니다 | `claude auth login --console` |
| `claude auth logout` | Anthropic 계정에서 로그아웃합니다 | `claude auth logout` |
| `claude auth status` | 인증 상태를 JSON으로 표시합니다. 사람이 읽을 수 있는 출력을 위해 `--text`를 사용합니다. 로그인된 경우 코드 0으로 종료되고, 로그인되지 않은 경우 1로 종료됩니다. JSON에는 CLI가 사용하는 [구성 디렉토리](/docs/ko/claude-directory)의 이름을 지정하는 `configDirectory` 필드가 포함됩니다. 이 필드는 Claude Code v2.1.268 이상이 필요합니다. JSON의 `authMethod` 필드는 `none`, `claude.ai`, `oauth_token`, `api_key`, `api_key_helper` 또는 `third_party` 중 하나입니다 | `claude auth status` |
| `claude agents` | [에이전트 보기](/docs/ko/agent-view)를 열어 병렬 백그라운드 세션을 모니터링하고 디스패치합니다. `--cwd <path>`를 사용하여 해당 디렉토리 아래에서 시작된 세션만 표시하거나, `--json`을 사용하여 스크립팅을 위해 활성 세션을 JSON 배열로 인쇄합니다(`--json --all`은 완료된 백그라운드 세션도 포함합니다). `--permission-mode`, `--model`, `--effort` 또는 `--agent`를 전달하여 [디스패치된 세션의 기본값](/docs/ko/agent-view#permission-mode-model-and-effort)을 설정합니다. 최상위 `claude` 명령처럼 `--settings`, `--add-dir`, `--plugin-dir` 및 `--mcp-config`를 허용합니다. 에이전트 보기를 열려면 대화형 터미널이 필요합니다 | `claude agents --json` |
| `claude attach <id\|name>` | 이 터미널에서 [백그라운드 세션](/docs/ko/agent-view#manage-sessions-from-the-shell)에 연결합니다. ID 대신 세션 이름의 일부를 전달하려면 Claude Code v2.1.290 이상이 필요합니다 | `claude attach 7c5dcf5d` |
| `claude auto-mode defaults` | 기본 제공 [자동 모드](/docs/ko/permission-modes#eliminate-prompts-with-auto-mode) 분류기 규칙을 JSON으로 인쇄합니다. `claude auto-mode config`를 사용하여 설정이 적용된 유효한 구성을 확인합니다. `--label <prefix>`는 해당 접두사로 시작하는 레이블이 있는 규칙만 인쇄합니다(대소문자 구분 안 함). Claude Code v2.1.208 이상이 필요합니다 | `claude auto-mode defaults --label 'Git Destructive'` |
| `claude auto-mode reset` | 사용자 설정 파일에서 `autoMode` 섹션을 제거하여 기본 [자동 모드](/docs/ko/permission-modes#eliminate-prompts-with-auto-mode) 구성을 복원합니다. 작성하기 전에 확인을 요청합니다. `-y`/`--yes`를 전달하여 프롬프트를 건너뜁니다. [관리형 설정](/docs/ko/server-managed-settings) 또는 `--settings` 플래그의 규칙은 여전히 적용됩니다. Claude Code v2.1.212 이상이 필요합니다. [기본값 및 유효한 구성 검사](/docs/ko/auto-mode-config#inspect-the-defaults-and-your-effective-config) 참조 | `claude auto-mode reset --yes` |
| `claude daemon logs` | 백그라운드 세션 [감독자](/docs/ko/agent-view#the-supervisor-process)의 로그 파일 `~/.claude/daemon.log`를 팔로우하며, `Ctrl+C`를 누를 때까지 새 줄이 들어오는 대로 인쇄합니다 | `claude daemon logs` |
| `claude daemon run` | 백그라운드 세션 [감독자](/docs/ko/agent-view#the-supervisor-process)를 이 터미널의 포그라운드에서 실행하고 로그를 인쇄합니다 | `claude daemon run` |
| `claude daemon status` | 백그라운드 세션 [감독자](/docs/ko/agent-view#the-supervisor-process)의 상태, 버전, 소켓 디렉토리 및 진단을 위한 워커 수를 인쇄합니다. 감독자가 실행 중이 아니면 1로 종료됩니다 | `claude daemon status` |
| `claude daemon stop --any` | 백그라운드 세션 [감독자](/docs/ko/agent-view#the-supervisor-process)와 이를 호스팅하는 세션을 중지합니다. `--keep-workers`를 전달하여 백그라운드 세션을 실행 중인 상태로 두면 다음 감독자가 이들에 다시 연결됩니다. `--any`는 기본값인 온디맨드 감독자 중지를 확인합니다. 이를 사용하여 [응답하지 않는 감독자](/docs/ko/agent-view#agent-view-says-the-background-service-did-not-respond)에서 복구합니다 | `claude daemon stop --any --keep-workers` |
| `claude doctor` | 세션을 시작하지 않고 터미널에서 읽기 전용 설치 및 설정 진단을 인쇄합니다. 설치 상태, 설정 파일 검증 오류 및 Remote Control 적격성을 포함합니다. 수정을 적용할 수도 있는 세션 내 설정 점검을 위해 [`/doctor`](/docs/ko/commands#all-commands)를 실행합니다 | `claude doctor` |
| `claude import [source]` | 다른 코딩 에이전트의 구성을 Claude Code로 가져오기 위해 [`/import`](/docs/ko/commands#all-commands)를 실행하는 대화형 세션을 시작합니다. 명령과 동일한 `--dry-run` 및 `--yes` 옵션을 허용합니다. Amazon Bedrock, Google Cloud의 Agent Platform, Microsoft Foundry 또는 AWS의 Claude Platform에서는 사용할 수 없습니다. [기능 플래그 가져오기](/docs/ko/env-vars#features-that-need-feature-flag-fetching)를 끈 경우에도 사용할 수 없습니다. Claude Code v2.1.213 이상이 필요합니다 | `claude import codex --dry-run` |
| `claude logs <id\|name>` | [백그라운드 세션](/docs/ko/agent-view#manage-sessions-from-the-shell)의 최근 출력을 인쇄합니다. ID 대신 세션 이름의 일부를 전달하려면 Claude Code v2.1.290 이상이 필요합니다 | `claude logs 7c5dcf5d` |
| `claude mcp` | Model Context Protocol (MCP) 서버 구성 | [Claude Code MCP 문서](/docs/ko/mcp) 참조 |
| `claude mcp login <name>` | 구성된 MCP 서버의 OAuth 흐름을 대화형 `/mcp` 패널을 열지 않고 실행합니다. HTTP, SSE 및 claude.ai 커넥터 서버에서 작동합니다. SSH를 통해 접속한 경우 `--no-browser`를 추가하면 브라우저를 여는 대신 인증 URL을 인쇄합니다. HTTP 또는 SSE 서버의 경우 리다이렉트 URL을 프롬프트에 다시 붙여넣습니다. claude.ai 커넥터의 경우 [셸에서 커넥터 다시 인가](/docs/ko/remote-control#authorize-a-connector-again-from-your-shell)를 참조하세요. [명령줄에서 인증](/docs/ko/mcp#authenticate-from-the-command-line) 참조 | `claude mcp login sentry` |
| `claude mcp logout <name>` | MCP 서버에 대해 저장된 OAuth 자격 증명을 지웁니다 | `claude mcp logout sentry` |
| `claude plugin` | Claude Code [플러그인](/docs/ko/plugins/overview)을 관리합니다. 별칭: `claude plugins`. 하위 명령은 [플러그인 참조](/docs/ko/plugins/cli-reference#claude-plugin-commands)를 참조하세요 | `claude plugin install code-review@claude-plugins-official` |
| `claude purge [path]` | 프로젝트의 모든 로컬 Claude Code 상태를 삭제합니다: 트랜스크립트, 작업 목록, 디버그 로그, 파일 편집 기록, 프롬프트 기록 라인 및 `~/.claude.json`의 프로젝트 항목. `[path]`를 생략하면 대화형 목록에서 선택할 수 있습니다. 플래그: `--dry-run`으로 미리 보기, `-y`/`--yes`로 확인 건너뛰기, `-i`/`--interactive`로 각 항목 확인, `--all`로 모든 프로젝트. [로컬 데이터 지우기](/docs/ko/claude-directory#clear-local-data) 참조 | `claude purge ~/work/repo --dry-run` |
| `claude remote-control` | Claude.ai 또는 Claude 앱에서 Claude Code를 제어하기 위한 [Remote Control](/docs/ko/remote-control) 서버를 시작합니다. 서버 모드에서 실행됩니다(로컬 대화형 세션 없음). [서버 모드 플래그](/docs/ko/remote-control#start-a-remote-control-session) 참조. 서버를 중지한 후 이를 제공하던 세션을 다시 가져올 수 있습니다. [서버 중지 후 세션 재개](/docs/ko/remote-control#resume-sessions-after-stopping-the-server) 참조 | `claude remote-control --name "My Project"` |
| `claude respawn <id>` | 대화를 유지하면서 실행 중이거나 중지된 [백그라운드 세션](/docs/ko/agent-view#manage-sessions-from-the-shell)을 다시 시작합니다. `--all`을 사용하여 모든 실행 중인 세션을 다시 시작합니다(예: 업데이트된 Claude Code 바이너리를 선택하기 위해) | `claude respawn 7c5dcf5d` |
| `claude rm <id>` | [백그라운드 세션](/docs/ko/agent-view#manage-sessions-from-the-shell)을 목록에서 제거합니다. 제거가 [세션의 worktree를 통해 거부](/docs/ko/agent-view#what-deleting-a-session-removes)되고 두 번째 `claude rm`이 이를 해결할 수 있을 때, 거부는 전달할 정확한 플래그와 값을 인쇄합니다: `--discard-unpushed <commit>@<worktree-id>`는 푸시되지 않은 커밋이 있는 worktree를 해당 커밋과 함께 삭제하고, `--force-remove-worktree <worktree-id>`는 git 또는 `WorktreeRemove` 훅이 제거할 수 없는 worktree 디렉토리를 삭제합니다. `--discard-unpushed`는 Claude Code v2.1.260 이상이 필요하고, `--force-remove-worktree`는 v2.1.268 이상이 필요합니다. 대화 트랜스크립트는 로컬 머신에 남아 있으며 `claude --resume`을 통해 사용할 수 있습니다 | `claude rm 7c5dcf5d` |
| `claude self-hosted-runner` | 이 머신 또는 컨테이너를 [자체 호스팅 환경](/docs/ko/self-hosted-environments)에 등록하고 인프라에서 Claude Code 클라우드 세션을 호스팅하는 러너 프로세스를 시작합니다. 안내식 운영자 연습을 위해 `claude self-hosted-runner setup`을 실행하고, 배포된 러너를 [진단](/docs/ko/self-hosted-environments-deploy#troubleshooting)하기 위해 `claude self-hosted-runner doctor`를 실행하고, [온디맨드 러너](/docs/ko/self-hosted-environments-configuration#on-demand-runners)를 생성하기 위해 `claude self-hosted-runner orchestrator`를 실행합니다. Claude Code v2.1.224 이상이 필요합니다 | `claude self-hosted-runner setup` |
| `claude setup-token` | CI 및 스크립트를 위한 장기 OAuth 토큰을 생성합니다. 토큰을 저장하지 않고 터미널에 인쇄합니다. Claude 구독이 필요합니다. [장기 토큰 생성](/docs/ko/authentication#generate-a-long-lived-token) 참조 | `claude setup-token` |
| `claude stop <id>` | [백그라운드 세션](/docs/ko/agent-view#manage-sessions-from-the-shell)을 중지합니다. `claude kill`도 허용됩니다 | `claude stop 7c5dcf5d` |
| `claude ultrareview [target]` | [ultrareview](/docs/ko/ultrareview#run-ultrareview-non-interactively)를 비대화형으로 실행합니다. 결과를 stdout으로 인쇄하고 성공 시 0으로 종료되거나 실패 시 1로 종료됩니다. 원본 페이로드는 `--json`을 사용하고 45분 기본값을 재정의하려면 `--timeout <minutes>`를 사용합니다. `github.com` 풀 리퀘스트 대상에서 `--post`를 사용하여 완료된 결과를 GitHub 계정에서 PR에 일반 댓글로 게시합니다. `--no-post`가 기본값입니다. `--post` 및 `--no-post`는 Claude Code v2.1.227 이상이 필요합니다. [풀 리퀘스트에 결과 게시](/docs/ko/ultrareview#post-findings-to-the-pull-request) 참조 | `claude ultrareview 1234 --json` |

하위 명령을 잘못 입력하면 Claude Code는 가장 가까운 일치를 제안하고 세션을 시작하지 않고 종료합니다. 예를 들어, `claude udpate`는 `Did you mean claude update?`를 인쇄합니다.

`claude --dangerously-skip-permissions daemon <subcommand>`는 `daemon` 하위 명령을 실행하므로, `claude`가 플래그를 포함하도록 별칭이 지정된 경우에도 하위 명령이 작동합니다. 선행 `--dangerously-skip-permissions` 또는 `--allow-dangerously-skip-permissions`만 이 방식으로 `daemon`으로 라우팅됩니다. `daemon` 앞에 다른 플래그가 있으면 하위 명령이 실행되지 않습니다.

<h2 id="cli-flags">
  CLI 플래그
</h2>

Claude Code의 동작을 이러한 명령줄 플래그로 사용자 정의합니다. `claude --help`는 모든 플래그를 나열하지 않으므로, 플래그가 `--help`에 없다고 해서 사용할 수 없다는 의미는 아닙니다.

| 플래그 | 설명 | 예시 |
| :- | :- | :- |
| `--add-dir` | Claude가 파일을 읽고 편집할 수 있도록 추가 작업 디렉터리를 추가합니다. 파일 액세스 권한을 부여합니다. Claude Code는 이러한 디렉터리에서 대부분의 `.claude/` 구성을 [검색하지 않습니다](/docs/ko/permissions#additional-directories-grant-file-access-not-configuration). 각 경로가 디렉터리로 존재하는지 검증합니다. `\\server\share`와 같은 대부분의 [네트워크 경로](/docs/ko/errors#working-directory-is-a-network-path)를 추가할 수 없습니다. 이러한 디렉터리를 세션 간에 유지하려면 설정에서 [`permissions.additionalDirectories`](/docs/ko/settings-reference#permissions-additionaldirectories)를 설정합니다 | `claude --add-dir ../apps ../lib` |
| `--advisor <model>` | 이 세션에 대해 모델 별칭 `fable`, `opus` 또는 `sonnet`, 또는 전체 모델 ID를 사용하여 서버 측 [advisor 도구](/docs/ko/advisor)를 활성화합니다. 세션에 대해 `advisorModel` 설정보다 우선합니다. `fable`은 [Fable 액세스](/docs/ko/advisor#choose-an-advisor-model)가 필요합니다 | `claude --advisor opus` |
| `--agent` | 현재 세션에 대한 에이전트를 지정합니다(`agent` 설정 재정의) | `claude --agent my-custom-agent` |
| `--agents` | JSON을 통해 사용자 정의 서브에이전트를 동적으로 정의합니다. [CLI 정의 서브에이전트에 대해 나열된 필드](/docs/ko/sub-agents#choose-the-subagent-scope)를 허용합니다. `--print`를 사용하면 값이 대신 JSON 객체를 보유하는 JSON 파일의 경로일 수 있습니다. 파일 형식에는 Claude Code v2.1.281 이상이 필요합니다. Claude Code는 시작 시 값을 검증하고 잘못된 값에서 종료합니다. 메시지 및 검증을 건너뛰는 플래그와 환경 변수는 [`Invalid --agents configuration`](/docs/ko/errors#invalid-agents-configuration)을 참조하세요. 검증에는 Claude Code v2.1.242 이상이 필요합니다 | `claude --agents '{"reviewer":{"description":"Reviews code","prompt":"You are a code reviewer"}}'` |
| `--allow-dangerously-skip-permissions` | `Shift+Tab` 모드 사이클에 `bypassPermissions`를 추가하되 시작하지 않습니다. `plan`과 같은 다른 모드에서 시작하고 나중에 `bypassPermissions`로 전환할 수 있습니다. [권한 모드](/docs/ko/permission-modes#skip-all-checks-with-bypasspermissions-mode)를 참조하세요 | `claude --permission-mode plan --allow-dangerously-skip-permissions` |
| `--allowedTools`, `--allowed-tools` | 권한을 묻지 않고 실행되는 도구입니다. 패턴 매칭에 대해 [권한 규칙 구문](/docs/ko/settings-reference#permission-rule-syntax)을 참조하세요. 사용 가능한 도구를 제한하려면 대신 `--tools`를 사용하세요. [작업 추적 도구](/docs/ko/tools-reference#task-tool-availability) 중 하나를 여기에 이름 지으면 Claude Code도 세션을 옵트인합니다 | `"Bash(git log *)" "Bash(git diff *)" "Read"` |
| `--append-subagent-system-prompt` | [포크된 서브에이전트](/docs/ko/sub-agents#fork-the-current-conversation)를 제외한 모든 [서브에이전트](/docs/ko/sub-agents)의 시스템 프롬프트 끝에 사용자 정의 텍스트를 추가합니다. 포크된 서브에이전트는 대화 자체의 프롬프트를 재사용합니다. 중첩된 서브에이전트를 포함합니다. `-p`를 사용한 비대화형 모드에서만 적용됩니다. Claude Code v2.1.205 이상이 필요합니다 | `claude -p --append-subagent-system-prompt "Cite file paths in every answer" "query"` |
| `--append-subagent-system-prompt-file` | 파일에서 텍스트를 로드하고 [서브에이전트](/docs/ko/sub-agents) 시스템 프롬프트에 추가합니다. 명령줄에 전달하기에 너무 긴 텍스트의 경우 `--append-subagent-system-prompt`의 대안입니다. 두 플래그를 결합할 수 없습니다. `-p`를 사용한 비대화형 모드에서만 적용됩니다. Claude Code v2.1.261 이상이 필요합니다 | `claude -p --append-subagent-system-prompt-file ./subagent-rules.txt "query"` |
| `--append-system-prompt` | 기본 시스템 프롬프트 끝에 사용자 정의 텍스트를 추가합니다 | `claude --append-system-prompt "Always use TypeScript"` |
| `--append-system-prompt-file` | 파일에서 추가 시스템 프롬프트 텍스트를 로드하고 기본 프롬프트에 추가합니다 | `claude --append-system-prompt-file ./extra-rules.txt` |
| `--autocompact <auto\|tokens>` | 저장된 설정을 변경하지 않고 이 세션에 대해 [auto-compact 윈도우](/docs/ko/model-config#set-the-auto-compact-window)를 설정합니다. `/autocompact`와 동일한 값을 허용합니다. 해당 섹션에서 값 형식과 플래그를 재정의하는 것을 다룹니다. Claude Code v2.1.221 이상이 필요합니다 | `claude --autocompact 500k` |
| `--ax-screen-reader` | 스크린 리더 친화적 출력을 렌더링합니다: 장식 테두리나 애니메이션 없는 평면 텍스트입니다. 클래식 렌더러를 강제하므로 [`tui`](/docs/ko/settings-reference#tui) 설정은 효과가 없습니다. 연결된 [백그라운드 세션](/docs/ko/agent-view)은 여전히 전체 화면으로 렌더링됩니다. [`CLAUDE_AX_SCREEN_READER`](/docs/ko/env-vars) 및 [`axScreenReader`](/docs/ko/settings-reference#axscreenreader) 설정보다 우선합니다. Claude Code v2.1.181 이상이 필요합니다 | `claude --ax-screen-reader` |
| `--bare` | 최소 모드: 훅, 스킬, 사용자 정의 명령, 서브에이전트, 설치된 플러그인, MCP 서버, 자동 메모리 및 CLAUDE.md의 자동 검색을 건너뜁니다. 스크립트된 호출이 더 빠르게 시작됩니다. `--add-dir`로 전달하는 디렉터리의 스킬은 여전히 로드됩니다. Claude는 Bash, 파일 읽기 및 파일 편집 도구에 액세스할 수 있습니다. [`CLAUDE_CODE_SIMPLE`](/docs/ko/env-vars)을 설정합니다. [베어 모드](/docs/ko/headless#start-faster-with-bare-mode)를 참조하세요 | `claude --bare -p "query"` |
| `--betas` | API 요청에 포함할 베타 헤더입니다(API 키 사용자만 해당) | `claude --betas interleaved-thinking` |
| `--bg`, `--background` | 세션을 [백그라운드 에이전트](/docs/ko/agent-view)로 시작하고 즉시 반환합니다. 세션 ID 및 관리 명령을 인쇄합니다. `--exec`와 결합하여 Claude 세션 대신 셸 명령을 백그라운드 작업으로 실행하거나, `--agent`와 결합하여 특정 서브에이전트를 실행합니다. 디렉터리에 대한 [작업 영역 신뢰](/docs/ko/permissions#project-allow-rules-and-workspace-trust)를 확인합니다. `-p`/`--print`와 결합할 수 없습니다. [오류 참조](/docs/ko/errors#command-line-errors)를 참조하세요 | `claude --bg "investigate the flaky test"` |
| `--channels` | (연구 미리보기) Claude가 이 세션에서 수신해야 하는 [채널](/docs/ko/channels) 알림이 있는 MCP 서버입니다. `plugin:<name>@<marketplace>` 항목의 공백으로 구분된 목록입니다. claude.ai 또는 Console API 키를 통한 Anthropic 인증이 필요합니다 | `claude --channels plugin:my-notifier@my-marketplace` |
| `--chrome` | 웹 자동화 및 테스트를 위해 [Chrome 브라우저 통합](/docs/ko/chrome)을 활성화합니다 | `claude --chrome` |
| `--cloud` | 작업 설명을 사용하여 새 [클라우드 세션](/docs/ko/claude-code-on-the-web)을 만듭니다. 세션 ID(`session_...` 또는 `cse_...`) 또는 claude.ai/code URL을 사용하여 `-p`로 기존 세션에 메시지를 대기열에 넣습니다. [후속 메시지 전송](/docs/ko/claude-code-on-the-web#send-follow-ups-from-the-cli)을 참조하세요. | `claude --cloud "Fix the login bug"` |
| `--continue`, `-c` | 현재 디렉터리에서 가장 최근 대화를 로드합니다. [완료된 백그라운드 세션](/docs/ko/sessions#resume-a-session)을 포함합니다. 완료된 백그라운드 세션을 열려면 Claude Code v2.1.257 이상이 필요합니다. `claude -p` 또는 Agent SDK로 생성된 세션과 첫 번째 프롬프트가 `/loop`인 세션을 건너뜁니다. `claude -p --continue`는 `-p`, SDK 및 `/loop` 세션을 포함합니다. 이 디렉터리를 `/add-dir`로 추가한 세션을 포함합니다 | `claude --continue` |
| `--dangerously-load-development-channels` | 로컬 개발을 위해 승인된 허용 목록에 없는 [채널](/docs/ko/channels-reference#test-during-the-research-preview)을 활성화합니다. `plugin:<name>@<marketplace>` 및 `server:<name>` 항목을 허용합니다. 확인을 요청하므로 대화형 세션에서 적용됩니다. `-p`를 사용하면 Claude Code는 이 플래그를 무시합니다 | `claude --dangerously-load-development-channels server:webhook` |
| `--dangerously-skip-permissions` | 권한 프롬프트를 건너뜁니다. `--permission-mode bypassPermissions`과 동등합니다. 이것이 건너뛰는 것과 건너뛰지 않는 것에 대해 [권한 모드](/docs/ko/permission-modes#skip-all-checks-with-bypasspermissions-mode)를 참조하세요. `--bg`로 시작된 세션의 경우, 모드는 [감독자가 세션을 다시 시작할 때 유지됩니다](/docs/ko/agent-view#permission-mode-model-and-effort) | `claude --dangerously-skip-permissions` |
| `--debug` | `--debug='mcp,startup'` 또는 `--debug='!1p'`와 같은 선택적 카테고리 필터링으로 디버그 모드를 활성화합니다. 필터는 `=` 형식에서만 바인딩됩니다. 공백으로 구분된 필터는 필터링 없이 디버그 모드를 활성화합니다 | `claude --debug='mcp,startup'` |
| `--debug-file <path>` | 특정 파일 경로에 디버그 로그를 작성합니다. 암묵적으로 디버그 모드를 활성화합니다. `CLAUDE_CODE_DEBUG_LOGS_DIR`보다 우선합니다 | `claude --debug-file /tmp/claude-debug.log` |
| `--desktop` | [Claude Desktop 앱](/docs/ko/desktop)을 현재 디렉터리에서 열고 터미널에서 세션을 시작하지 않고 종료합니다. `--continue` 또는 `--resume`을 세션 ID와 함께 추가하여 [대신 Desktop에서 해당 세션을 열 수 있습니다](/docs/ko/desktop#coming-from-the-cli). 여기서 `--resume`은 세션 ID만 사용하며 이름이나 트랜스크립트 경로는 사용하지 않습니다. 프롬프트와 `--verbose` 및 `--debug` 플래그를 제외한 다른 플래그를 사용하지 않습니다. 앱이 세션을 시작하기 때문입니다. Claude 구독으로 로그인했을 때 macOS 및 x64 Windows에서 사용 가능합니다. Claude Code v2.1.285 이상이 필요합니다 | `claude --desktop` |
| `--disable-slash-commands` | 이 세션에 대해 모든 스킬 및 명령을 비활성화합니다 | `claude --disable-slash-commands` |
| `--disallowedTools`, `--disallowed-tools` | 거부 규칙입니다. 베어 도구 이름은 Claude의 컨텍스트에서 일치하는 도구를 제거합니다: `"Edit"`는 Edit를 제거하고, `"*"`는 모든 도구를 제거하며, `"mcp__*"`는 모든 MCP 도구를 제거합니다. `Bash(rm *)`와 같은 범위 지정 규칙은 도구를 사용 가능하게 두고 [작성된 대로](/docs/ko/permissions#bash-rule-limits) 일치하는 호출만 거부합니다. [`EndConversation`](/docs/ko/tools-reference#endconversation-tool-behavior)을 이름 지은 규칙은 다른 도구가 남아 있는 동안 제거할 수 없습니다 | `"Bash(git log *)" "Bash(git diff *)" "Edit"` |
| `--effort` | 현재 세션에 대해 [노력 수준](/docs/ko/model-config#adjust-effort-level)을 설정합니다. 옵션: `low`, `medium`, `high`, `xhigh`, `max` 또는 `ultracode`입니다. 사용 가능한 수준은 모델에 따라 다릅니다. `ultracode`는 [ultracode](/docs/ko/workflows#let-claude-decide-with-ultracode)가 켜진 상태에서 `xhigh` 노력을 요청하며, Claude Code v2.1.203 이상이 필요합니다. 이 세션에 대해 [`modelSettings`](/docs/ko/settings-reference#modelsettings) 및 [`effortLevel`](/docs/ko/settings-reference#effortlevel) 설정을 재정의하고 유지되지 않습니다 | `claude --effort high` |
| `--enable-auto-mode` | v2.1.111에서 제거됨. 자동 모드는 이제 `Shift+Tab` 사이클에 기본적으로 있습니다. `--permission-mode auto`를 사용하여 시작합니다 | `claude --permission-mode auto` |
| `--environment <environment-id>` | 주어진 ID를 가진 [자체 호스팅 환경](/docs/ko/self-hosted-environments)에서 실행되는 새 클라우드 세션을 만듭니다. 환경 ID는 `ccpool_`로 시작합니다. 디스패치 동작 및 거부하는 플래그 조합에 대해 [`--environment` 디스패치 동작](/docs/ko/self-hosted-environments-testing#environment-dispatch-behavior)을 참조하세요. Claude Code v2.1.224 이상이 필요합니다 | `claude -p "Fix the login bug" --environment ccpool_abc123` |
| `--exclude-dynamic-system-prompt-sections` | 자동 메모리 위치와 같은 사용자별 컨텍스트를 시스템 프롬프트에서 첫 번째 사용자 메시지로 이동합니다. 동일한 작업을 실행하는 다양한 사용자 및 머신 간에 프롬프트 캐시 재사용을 개선합니다. 기본 시스템 프롬프트에만 적용됩니다. `--system-prompt` 또는 `--system-prompt-file`이 설정되면 무시됩니다. 스크립트된 다중 사용자 워크로드에 `-p`와 함께 사용합니다 | `claude -p --exclude-dynamic-system-prompt-sections "query"` |
| `--exec` | Claude 세션을 시작하는 대신 PTY 지원 백그라운드 작업으로 셸 명령을 실행합니다. 셸에서 시작하려면 `--bg`와 함께 사용합니다 | `claude --bg --exec 'pytest -x'` |
| `--fallback-model` | 기본 모델이 과부하되거나 사용할 수 없을 때(예: 폐기된 모델) 지정된 모델로 자동 폴백을 활성화합니다. 순서대로 시도되는 쉼표로 구분된 목록을 허용합니다. [폴백 모델 체인](/docs/ko/model-config#fallback-model-chains)을 참조하세요. 세션 간에 체인을 유지하려면 이 플래그가 재정의하는 [`fallbackModel` 설정](/docs/ko/settings-reference#fallbackmodel)을 사용합니다 | `claude --fallback-model sonnet,haiku` |
| `--fork-session` | 재개할 때 원본을 재사용하는 대신 새 세션 ID를 만듭니다(`--resume` 또는 `--continue`와 함께 사용) | `claude --resume abc123 --fork-session` |
| `--forward-subagent-text` | [서브에이전트](/docs/ko/sub-agents) 텍스트 및 사고 블록을 `parent_tool_use_id` 설정된 `assistant` 및 `user` 메시지로 출력 스트림에 내보내므로 각 서브에이전트의 트랜스크립트를 재구성할 수 있습니다. 이 플래그 없이 Claude Code는 [포그라운드](/docs/ko/sub-agents#run-subagents-in-foreground-or-background)에서 실행되는 서브에이전트의 텍스트 및 사고 블록을 생략합니다. `--print` 및 `--output-format stream-json`이 필요합니다. 중첩된 서브에이전트, 포크된 스킬 및 각각에 필요한 버전은 [서브에이전트 메시지 따라가기](/docs/ko/headless#follow-subagent-messages)를 참조하세요. [`CLAUDE_CODE_FORWARD_SUBAGENT_TEXT`](/docs/ko/env-vars) 환경 변수는 동일한 동작을 활성화합니다. Claude Code v2.1.211 이상이 필요합니다 | `claude -p --output-format stream-json --verbose --forward-subagent-text "query"` |
| `--from-pr` | 특정 풀 요청에 연결된 세션으로 필터링된 세션 선택기를 엽니다. PR 번호, GitHub 또는 GitHub Enterprise PR URL, GitLab 병합 요청 URL 또는 Bitbucket 풀 요청 URL을 허용합니다. Claude가 풀 요청을 만들 때 세션이 자동으로 연결됩니다 | `claude --from-pr 123` |
| `--ide` | 정확히 하나의 유효한 IDE를 사용할 수 있는 경우 시작 시 IDE에 자동으로 연결합니다 | `claude --ide` |
| `--init` | `init` 매처를 사용하여 세션 전에 [Setup 훅](/docs/ko/hooks#setup)을 실행합니다(인쇄 모드만 해당) | `claude -p --init "query"` |
| `--init-only` | [Setup](/docs/ko/hooks#setup) 및 `SessionStart` 훅을 실행한 다음 대화를 시작하지 않고 종료합니다 | `claude --init-only` |
| `--include-hook-events` | 훅 수명 주기 이벤트를 출력 스트림에 포함합니다. `SessionStart` 및 `Setup` 훅 이벤트는 항상 포함되며 이 플래그가 필요하지 않습니다. `Notification`, `SessionEnd`, `PreCompact` 및 `PostCompact`와 같은 일부 훅 이벤트는 이 플래그를 사용하더라도 `hook_started` 이벤트를 생성하지 않습니다. 이러한 이벤트의 경우 Claude Code는 여전히 `hook_progress`를 내보내며, 1초 이상 실행되는 명령 훅은 출력을 생성하고, [백그라운드에서 실행되는 훅](/docs/ko/hooks#run-hooks-in-the-background)이 완료될 때만 `hook_response`를 내보냅니다. `--output-format stream-json`이 필요합니다 | `claude -p --output-format stream-json --verbose --include-hook-events "query"` |
| `--include-partial-messages` | 출력에 부분 스트리밍 이벤트를 포함합니다. `--print` 및 `--output-format stream-json`이 필요합니다 | `claude -p --output-format stream-json --verbose --include-partial-messages "query"` |
| `--input-format` | 인쇄 모드에 대한 입력 형식을 지정합니다(옵션: `text`, `stream-json`) | `claude -p --output-format json --input-format stream-json` |
| `--json-schema` | 에이전트가 워크플로우를 완료한 후 JSON 스키마와 일치하는 검증된 JSON 출력을 가져옵니다(인쇄 모드만 해당). [구조화된 출력](/docs/ko/agent-sdk/structured-outputs)을 참조하세요. Claude Code는 잘못된 스키마에서 오류로 종료되고 클라이언트 측 검증 없이 주석으로 `format` 키워드를 허용합니다 | `claude -p --json-schema '{"type":"object","properties":{...}}' "query"` |
| `--maintenance` | `maintenance` 매처를 사용하여 세션 전에 [Setup 훅](/docs/ko/hooks#setup)을 실행합니다(인쇄 모드만 해당) | `claude -p --maintenance "query"` |
| `--max-budget-usd` | API 호출에 대한 예상 지출이 이 금액에 도달하면 실행을 중지합니다(인쇄 모드만 해당). Claude Code는 [클라이언트 측 비용 추정치](/docs/ko/agent-sdk/cost-tracking#estimates-not-billing)를 기준으로 한도를 확인하며, 이는 실제 청구 금액과 다를 수 있습니다. [서브에이전트](/docs/ko/sub-agents)의 지출이 한도에 포함됩니다. 지출이 한도를 초과할 수 있으므로 [여유를 두세요](/docs/ko/agent-sdk/agent-loop#budget-headroom). `--continue` 또는 `--resume`으로 대화로 돌아올 때 [이전 실행에서 복원된](/docs/ko/agent-sdk/cost-tracking#accumulate-costs-across-multiple-calls) 합계는 이에 포함되지 않습니다. 지출이 한도에 도달하면 다른 서브에이전트를 생성하면 `Budget limit reached`로 실패하고 Claude Code는 여전히 실행 중인 백그라운드 서브에이전트를 중지합니다. 한도 적용 동작에는 Claude Code v2.1.217 이상이 필요합니다 | `claude -p --max-budget-usd 5.00 "query"` |
| `--max-turns` | 에이전트 턴의 수를 제한합니다(인쇄 모드만 해당). 한도에 도달하면 오류로 종료됩니다. 기본적으로 제한이 없습니다. `--input-format stream-json`을 사용하면 한도가 턴을 끝낼 때 여전히 대기열에 있는 메시지는 대기열에 남아 있고 자체 한도로 새 턴을 시작합니다 | `claude -p --max-turns 3 "query"` |
| `--mcp-config` | JSON 파일 또는 문자열에서 MCP 서버를 로드합니다(공백으로 구분). 이 플래그를 `-p`와 함께 전달하면 Claude Code는 첫 번째 턴을 실행하기 전에 여전히 보류 중인 서버가 연결될 때까지 기다립니다. [`MCP_TIMEOUT`](/docs/ko/env-vars) 시작 타임아웃(기본값 30초)까지입니다. [캐시된 도구 목록](/docs/ko/mcp#managing-your-servers)이 있는 서버는 대기를 건너뛰고 처음 사용할 때 연결됩니다. [자체 호스팅 환경](/docs/ko/self-hosted-environments-configuration#connection-timing)에서는 대신 더 짧은 대기가 적용됩니다. 대기에는 Claude Code v2.1.221 이상이 필요합니다 | `claude --mcp-config ./mcp.json` |
| `--model` | `sonnet`, `opus`, `haiku` 또는 `fable`과 같은 [모델 별칭](/docs/ko/model-config#model-aliases) 또는 모델의 전체 이름으로 현재 세션에 대한 모델을 설정합니다. [`model`](/docs/ko/settings-reference#model) 설정 및 [`ANTHROPIC_MODEL`](/docs/ko/model-config#environment-variables)을 재정의합니다 | `claude --model claude-sonnet-5` |
| `--name`, `-n` | 세션의 표시 이름을 설정합니다. `/resume` 및 터미널 제목에 표시됩니다. `claude --resume <name>`으로 명명된 세션을 재개할 수 있습니다. 대화형 세션에서 이 머신의 다른 라이브 세션이 이미 이름을 사용하는 경우 Claude Code는 [그 변형을 적용합니다](/docs/ko/sessions#name-your-sessions). <br /><br />[`/rename`](/docs/ko/commands)은 세션 중에 이름을 변경하고 프롬프트 표시줄에도 표시합니다 | `claude -n "my-feature-work"` |
| `--no-chrome` | 이 세션에 대해 [Chrome 브라우저 통합](/docs/ko/chrome)을 비활성화합니다 | `claude --no-chrome` |
| `--no-session-persistence` | 세션 지속성을 비활성화하므로 세션이 디스크에 저장되지 않고 재개할 수 없습니다. 인쇄 모드만 해당입니다. [`CLAUDE_CODE_SKIP_PROMPT_HISTORY`](/docs/ko/env-vars) 환경 변수는 모든 모드에서 동일한 작업을 수행합니다 | `claude -p --no-session-persistence "query"` |
| `--output-format` | 인쇄 모드에 대한 출력 형식을 지정합니다(옵션: `text`, `json`, `stream-json`) | `claude -p "query" --output-format json` |
| `--permission-mode` | 지정된 [권한 모드](/docs/ko/permission-modes)에서 시작합니다. `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` 또는 `manual`을 `default`의 별칭으로 허용합니다. `manual` 별칭은 UI가 Manual로 레이블 지정하는 권한 모드를 선택하며 Claude Code v2.1.200 이상이 필요합니다. `claude --help`는 `default` 대신 이를 나열하고 두 값 모두 작동합니다. 설정 파일의 `defaultMode`를 재정의합니다. 이 플래그 또는 `--dangerously-skip-permissions` 없이 새 세션은 [세션이 시작되는 권한 모드](/docs/ko/permission-modes#which-mode-a-session-starts-in)에 설명된 권한 모드에서 시작됩니다. `-p`의 경우 아무것도 구성되지 않으면 `default`입니다 | `claude --permission-mode plan` |
| `--permission-prompt-tool` | 비대화형 모드에서 권한 프롬프트를 처리할 MCP 도구를 지정합니다. Claude Code는 첫 번째 턴을 실행하기 전에 해당 도구의 MCP 서버가 연결될 때까지 기다립니다. [`MCP_TIMEOUT`](/docs/ko/env-vars) 시작 시간 초과(기본값 30초)까지입니다. <br /><br />프롬프트 도구는 [사용자 상호 작용이 필요한 것으로 표시된](/docs/ko/mcp#require-approval-for-a-specific-tool) MCP 도구를 승인할 수 없습니다. Claude Code는 하나에 대한 `allow` 결과를 거부로 변환합니다. 이 제한에는 Claude Code v2.1.199 이상이 필요합니다 | `claude -p --permission-prompt-tool mcp_auth_tool "query"` |
| `--permission-prompts` | 인쇄 모드에서 권한 프롬프트에 응답하는 사람을 설정합니다. 기본 `host`를 사용하면 Claude Code는 Agent SDK 호스트 또는 `--permission-prompt-tool` 도구로 보냅니다. 아무도 응답할 수 없을 때 `none`을 전달하면 Claude Code는 대신 거부합니다. [무인 실행에서 권한 프롬프트 끄기](/docs/ko/headless#turn-off-permission-prompts-in-unattended-runs)를 참조하세요. Claude Code v2.1.259 이상이 필요합니다 | `claude -p --permission-prompts none "query"` |
| `--plugin-dir` | 이 세션에만 디렉터리 또는 `.zip` 아카이브에서 플러그인을 로드하거나 [플러그인 폴더](/docs/ko/plugins/create#load-a-directory-or-archive-for-one-session)에서 여러 개를 로드합니다. 각 플래그는 하나의 경로를 사용합니다. 더 많은 경로에 대해 플래그를 반복합니다: `--plugin-dir A --plugin-dir B.zip`. 플러그인 폴더를 전달하려면 Claude Code v2.1.265 이상이 필요합니다 | `claude --plugin-dir ./my-plugin` |
| `--plugin-url` | 이 세션에만 URL에서 플러그인 `.zip` 아카이브를 가져옵니다. 여러 플러그인에 대해 플래그를 반복하거나 단일 따옴표 값에 공백으로 구분된 URL을 전달합니다 | `claude --plugin-url https://example.com/plugin.zip` |
| `--print`, `-p` | 대화형 모드 없이 응답을 인쇄합니다([프로그래밍 방식 사용에 대한 Agent SDK 문서](/docs/ko/agent-sdk/overview) 참조). 여전히 실행 중인 백그라운드 세션에서 `--resume`을 사용하는 경우 [실행 중인 백그라운드 세션 재개](/docs/ko/sessions#resume-a-running-background-session)를 참조하세요 | `claude -p "query"` |
| `--prompt-suggestions` | 각 턴 후에 예측된 다음 사용자 프롬프트를 사용하여 `prompt_suggestion` 메시지를 내보냅니다. 매우 짧은 대화는 없을 수 있습니다. `--print`, `--output-format stream-json` 및 `--verbose`가 필요합니다. [프롬프트 제안](/docs/ko/interactive-mode#prompt-suggestions)을 참조하세요 | `claude -p --prompt-suggestions --output-format stream-json --verbose "query"` |
| `--ref <branch>` | `--environment`를 사용하면 새 세션의 체크아웃을 로컬 `HEAD` 대신 명명된 ref를 기반으로 합니다 | `claude -p "Run the smoke test" --environment ccpool_abc123 --ref main` |
| `--remote` | `--cloud`의 더 이상 사용되지 않는 별칭. 기존 세션 형식 포함 | `claude --remote "Fix the login bug"` |
| `--remote-control`, `--rc` | [Remote Control](/docs/ko/remote-control#start-a-remote-control-session)이 활성화된 대화형 세션을 시작하므로 claude.ai 또는 Claude 앱에서도 제어할 수 있습니다. 선택적으로 세션의 이름을 전달합니다 | `claude --remote-control "My Project"` |
| `--remote-control-session-name-prefix <prefix>` | 명시적 이름이 설정되지 않은 경우 자동 생성된 [Remote Control](/docs/ko/remote-control) 세션 이름의 접두사입니다. 기본값은 머신의 호스트 이름이며 `myhost-graceful-unicorn`과 같은 이름을 생성합니다. 동일한 효과를 위해 `CLAUDE_REMOTE_CONTROL_SESSION_NAME_PREFIX`를 설정합니다 | `claude remote-control --remote-control-session-name-prefix dev-box` |
| `--replay-user-messages` | stdin에서 사용자 메시지를 다시 내보내 stdout으로 승인합니다. `--input-format stream-json` 및 `--output-format stream-json`이 필요합니다 | `claude -p --input-format stream-json --output-format stream-json --verbose --replay-user-messages` |
| `--restricted` | 제한된 모드에서 시작합니다. 평가 하네스가 공유 머신에서 `claude`를 구동하고 Claude Code가 해당 머신의 명령을 실행하거나 사용자 및 프로젝트 설정을 읽지 않아야 할 때 사용합니다. Claude Code는 명령을 실행하거나 코드를 실행하는 기본 제공 도구와 WebFetch를 제거합니다. `--tools`에서 개별적으로 이름을 지정하지 않는 한 `default` 사전 설정을 통해서는 제거합니다. 또한 기본 제공 파일 도구를 [작업 디렉터리](/docs/ko/permissions#working-directories)로 제한하고, [관리되는 설정](/docs/ko/managed-settings) 및 `--settings`만 로드하며, [`bypassPermissions`](/docs/ko/permission-modes#skip-all-checks-with-bypasspermissions-mode)를 거부하고, [제한된 세션에서 클라우드 세션을 만드는 것을 거부합니다](/docs/ko/errors#cloud-sessions-cannot-be-created-from-a-restricted-session). Claude Code v2.1.248 이상이 필요합니다 | `claude --restricted -p "query"` |
| `--resume`, `-r` | ID 또는 이름으로 특정 세션을 재개하거나 세션을 선택할 대화형 선택기를 표시합니다. ID 대신 세션의 `.jsonl` [트랜스크립트 파일](/docs/ko/sessions#where-transcripts-are-stored)의 절대 경로를 전달할 수 있습니다. 선택기 및 이름 검색에는 이 디렉터리를 `/add-dir`로 추가한 세션이 포함됩니다. 세션 ID를 전달하면 Claude Code는 현재 프로젝트 디렉터리 및 해당 git 워크트리를 검색한 다음 이 머신의 다른 모든 프로젝트를 검색합니다. v2.1.223 이전에는 ID 검색이 현재 프로젝트 디렉터리 및 해당 git 워크트리만 다루었습니다. [백그라운드 세션](/docs/ko/agent-view)은 `bg`로 표시된 선택기에 나타납니다. 여전히 실행 중인 세션을 재개하면 [해당 세션](/docs/ko/sessions#resume-a-running-background-session)을 `claude attach`를 통해 이 터미널에서 열고, 명령줄에 전달한 프롬프트는 다음 턴으로 이동합니다. v2.1.285 이전에는 Claude Code가 거부하고 대신 실행할 `claude attach` 명령을 인쇄했습니다 | `claude --resume auth-refactor` |
| `--safe-mode` | 손상된 구성을 문제 해결하기 위해 모든 사용자 정의를 비활성화하여 시작합니다: CLAUDE.md, 스킬, 플러그인, 훅, MCP 서버, 사용자 정의 명령 및 에이전트, 출력 스타일, 워크플로우, 사용자 정의 테마, 사용자 정의 키 바인딩, 상태 줄 및 파일 제안 명령, LSP 서버 및 자동 메모리는 로드되지 않습니다. 인증, 모델 선택, 기본 제공 도구 및 권한은 정상적으로 작동하며, 이는 [`--bare`](/docs/ko/headless#start-faster-with-bare-mode)와 다릅니다. 관리되는 설정 정책은 여전히 적용되며, 정책 구성 훅, 상태 줄 및 파일 제안 명령을 포함합니다. 관리되는 플러그인, 관리되는 스킬, 관리되는 CLAUDE.md 및 정책 구성 MCP 서버는 포함되지 않습니다. [자동 모델 폴백](/docs/ko/model-config#automatic-model-fallback)을 트리거하는 사용자 정의를 확인하는 데 유용합니다. [`CLAUDE_CODE_SAFE_MODE`](/docs/ko/env-vars)를 설정합니다 | `claude --safe-mode` |
| `--session-id` | 대화에 특정 세션 ID를 사용합니다(유효한 UUID여야 함) | `claude --session-id "550e8400-e29b-41d4-a716-446655440000"` |
| `--setting-sources` | 로드할 설정 소스의 쉼표로 구분된 목록(`user`, `project`, `local`). [에이전트 뷰](/docs/ko/agent-view#what-carries-over-when-you-background) 및 [에이전트 팀](/docs/ko/agent-teams#context-and-communication)을 참조하여 이 세션에서 시작하는 세션이 목록을 상속하는 경우를 확인하세요 | `claude --setting-sources user,project` |
| `--settings` | 설정 JSON 파일 또는 인라인 JSON 문자열의 경로입니다. 여기서 설정한 값은 이 세션에 대해 `settings.json` 파일의 동일한 키를 재정의합니다. 생략한 키는 파일 기반 값을 유지합니다. 파일은 2 MiB 이하의 일반 파일이어야 합니다. [설정 우선 순위](/docs/ko/settings#settings-precedence)를 참조하세요 | `claude --settings ./settings.json` |
| `--strict-mcp-config` | `--mcp-config`의 MCP 서버만 사용하고 다른 모든 MCP 구성을 무시합니다. 관리되는 MCP 파일에서 플래그가 수행하는 작업에 대해 [managed-mcp.json으로 독점 제어](/docs/ko/managed-mcp#exclusive-control-with-managed-mcp-json)를 참조하세요 | `claude --strict-mcp-config --mcp-config ./mcp.json` |
| `--system-prompt` | 전체 시스템 프롬프트를 사용자 정의 텍스트로 바꿉니다 | `claude --system-prompt "You are a Python expert"` |
| `--system-prompt-file` | 파일에서 시스템 프롬프트를 로드하여 기본 프롬프트를 바꿉니다 | `claude --system-prompt-file ./custom-prompt.txt` |
| `--system-prompt-snapshot` | `off`를 전달하여 [대화의 첫 번째 요청에 기록된 프롬프트](#system-prompt-flags-in-resumed-conversations)를 재사용하는 대신 모든 요청에서 시스템 프롬프트를 다시 빌드합니다. 예를 들어 `--continue` 실행 간에 `--append-system-prompt` 텍스트를 반복할 때입니다. Claude Code v2.1.257 이상이 필요합니다 | `claude --system-prompt-snapshot off` |
| `--teleport` | 로컬 터미널에서 [클라우드 세션](/docs/ko/claude-code-on-the-web)을 재개합니다 | `claude --teleport` |
| `--teammate-mode` | [에이전트 팀](/docs/ko/agent-teams) 팀원이 표시되는 방식을 설정합니다: `in-process`(기본값), `auto`, `tmux` 또는 `iterm2`. 이 세션에 대해 [`teammateMode`](/docs/ko/settings-reference#teammatemode) 설정을 재정의합니다. [디스플레이 모드 선택](/docs/ko/agent-teams#choose-a-display-mode)을 참조하세요 | `claude --teammate-mode auto` |
| `--tmux` | 워크트리에 대한 tmux 세션을 만듭니다. `--worktree`가 필요합니다. 사용 가능할 때 iTerm2 네이티브 창을 사용합니다. 기존 tmux의 경우 `--tmux=classic`을 전달합니다 | `claude -w feature-auth --tmux` |
| `--tools` | Claude가 사용할 수 있는 기본 제공 도구를 제한합니다. 모두 비활성화하려면 `""`, 기본 집합의 경우 `"default"` 또는 `"Bash,Edit,Read"`와 같은 도구 이름을 사용합니다. macOS, Linux 및 WSL에서 기본 집합은 [Glob 도구 동작](/docs/ko/tools-reference#glob-tool-behavior)에 설명된 대로 `Glob` 및 `Grep`을 제외합니다. [작업 추적 도구](/docs/ko/tools-reference#task-tool-availability) 중 하나를 여기에 이름 지으면 Claude Code도 세션을 옵트인합니다. 플래그는 MCP 도구에 영향을 주지 않습니다. 이들도 거부하려면 `--disallowedTools "mcp__*"`를 사용합니다. [`EndConversation`](/docs/ko/tools-reference#endconversation-tool-behavior)을 생략하는 목록은 제거하지 않습니다. `""`는 MCP 도구가 남아 있지 않을 때만 제거합니다 | `claude --tools "Bash,Edit,Read"` |
| `--verbose` | 자세한 로깅을 활성화하고 전체 턴별 출력을 표시합니다. 이 세션에 대해 [`viewMode`](/docs/ko/settings-reference#viewmode) 설정을 재정의합니다 | `claude --verbose` |
| `--version`, `-v` | 버전 번호를 출력합니다 | `claude -v` |
| `--worktree`, `-w` | Claude를 `<repo>/.claude/worktrees/<name>`의 격리된 [git 워크트리](/docs/ko/worktrees)에서 시작합니다. 이름을 지정하지 않으면 Claude Code가 생성합니다. `#<number>`, GitHub 풀 요청 URL 또는 GitLab 병합 요청 URL을 전달하여 [해당 PR 또는 MR을 `origin`에서 가져오고 워크트리를 분기합니다](/docs/ko/worktrees#branch-from-a-pull-request). GitLab 병합 요청에서 분기하려면 Claude Code v2.1.233 이상이 필요합니다 | `claude -w feature-auth` |

<h3 id="system-prompt-flags">
  시스템 프롬프트 플래그
</h3>

Claude Code는 시스템 프롬프트를 사용자 정의하기 위한 5개의 플래그를 제공합니다. 4개는 텍스트를 설정하고, `--system-prompt-snapshot`을 사용하면 대화가 시작한 텍스트를 유지하는지 여부를 제어합니다. 5개 모두 대화형 및 비대화형 모드에서 작동합니다.

| 플래그 | 동작 | 예시 |
| :- | :- | :- |
| `--system-prompt` | 전체 기본 프롬프트를 바꿉니다 | `claude --system-prompt "You are a Python expert"` |
| `--system-prompt-file` | 파일 내용으로 바꿉니다 | `claude --system-prompt-file ./prompts/review.txt` |
| `--append-system-prompt` | 기본 프롬프트에 추가합니다 | `claude --append-system-prompt "Always use TypeScript"` |
| `--append-system-prompt-file` | 파일 내용을 기본 프롬프트에 추가합니다 | `claude --append-system-prompt-file ./style-rules.txt` |
| `--system-prompt-snapshot` | `off`를 사용하면 모든 요청에서 프롬프트를 다시 빌드합니다. `on`(기본값)을 사용하면 [기록이 적용되는 경우](#system-prompt-flags-in-resumed-conversations) 기록된 프롬프트를 재사용합니다 | `claude --append-system-prompt "Draft rules" --system-prompt-snapshot off` |

이러한 플래그는 결합할 수 있습니다. 기본 프롬프트를 바꾸면서도 자체 텍스트를 추가하려면 `--append-system-prompt` 또는 `--append-system-prompt-file`을 `--system-prompt` 또는 `--system-prompt-file`과 함께 전달합니다. Claude Code v2.1.283 이상에서는 `--append-system-prompt`와 `--append-system-prompt-file`처럼 플래그를 자체 파일 형식과 함께 전달할 수도 있으며, Claude Code는 둘 다 사용합니다.

예를 들어, 셸에서 다음을 실행하면 파일의 스타일 가이드와 추가 지침 하나를 모두 추가합니다:

```bash theme={null}
claude -p --append-system-prompt-file ./style.md --append-system-prompt "Always reply in French" "Summarize README.md"
```

Claude는 기본 시스템 프롬프트 뒤에 `style.md`의 내용, 빈 줄, 그리고 `Always reply in French`가 이어진 프롬프트를 받습니다. `--append-system-prompt`를 `--append-system-prompt-file`보다 먼저 전달하더라도 파일 내용이 먼저 옵니다.

대체 텍스트가 모든 실행에서 동일한 지침과 실행마다 변경되는 컨텍스트를 결합할 때 지침과 컨텍스트 사이에만 `__SYSTEM_PROMPT_DYNAMIC_BOUNDARY__`를 포함하는 줄을 추가합니다. Claude Code는 첫 번째 이러한 줄에서 프롬프트를 분할하고 해당 줄을 제거하므로 위의 부분은 캐시된 상태로 유지되고 아래의 부분은 변경됩니다. Claude Code v2.1.275 이상이 필요합니다. [사용자 정의 프롬프트의 정적 부분 캐시](/docs/ko/agent-sdk/modifying-system-prompts#cache-the-static-part-of-a-custom-prompt)는 분할이 적용되는 구성을 나열합니다.

Claude Code의 기본 정체성이 여전히 작업에 맞는지 여부에 따라 선택합니다. Claude가 추가 규칙도 따르는 코딩 어시스턴트로 남아 있어야 할 때 추가 플래그를 사용합니다: 호출별 지침, 출력 형식 또는 `-p` 스크립트에 대한 도메인 컨텍스트입니다. 추가하면 기본 도구 지침, 안전 지침 및 코딩 규칙이 유지되므로 다른 것만 제공하면 됩니다. 표면, 정체성 또는 권한 모델이 Claude Code와 다를 때 대체 플래그를 사용합니다. 예를 들어 인간이 감시하지 않는 파이프라인의 비코딩 에이전트입니다. 대체하면 도구 지침 및 안전 지침을 포함한 전체 기본 프롬프트가 삭제되므로 작업에 여전히 필요한 것에 대해 책임을 집니다.

프로젝트 간에 전환하고 공유할 수 있는 영구 페르소나의 경우 [출력 스타일](/docs/ko/output-styles)을 사용합니다. Claude가 항상 따라야 하는 프로젝트 규칙의 경우 [CLAUDE.md](/docs/ko/memory)를 사용합니다. [시스템 프롬프트에 대한 Agent SDK 가이드](/docs/ko/agent-sdk/modifying-system-prompts#decide-on-a-starting-point)는 더 깊이 있는 동일한 결정을 다룹니다.

<h4 id="system-prompt-flags-in-resumed-conversations">
  재개된 대화에서 시스템 프롬프트 플래그
</h4>

기본적으로 Claude Code는 시스템 프롬프트를 한 번 빌드합니다. 대화의 첫 번째 요청에서 적용된 시스템 프롬프트 플래그의 텍스트를 사용하고 세션에 기록합니다. 대화가 압축될 때까지 이후의 모든 요청은 `--resume` 또는 `--continue`로 대화로 돌아온 후를 포함하여 기록된 프롬프트를 사용합니다. 나중에 시작할 때 다른 시스템 프롬프트 플래그 텍스트를 전달하거나 아무것도 전달하지 않으면 대화가 압축되거나 새 대화를 시작할 때 적용됩니다.

[클라우드 세션](/docs/ko/cloud-environments) 외부에서 `--bare`를 전달하거나 `CLAUDE_CODE_SIMPLE=1`을 설정하여 Claude Code를 [베어 모드](/docs/ko/headless#start-faster-with-bare-mode)에서 시작하면 `--system-prompt-snapshot on`을 전달하지 않는 한 기록이 꺼집니다. v2.1.268 이전에는 [기능 플래그를 가져오지 않는](/docs/ko/env-vars#features-that-need-feature-flag-fetching) 세션(Amazon Bedrock, Google Cloud의 Agent Platform 및 Microsoft Foundry의 세션 포함)이 모든 요청에서 프롬프트를 다시 빌드했고 `--system-prompt-snapshot`은 효과가 없었습니다.

대신 모든 요청에서 프롬프트를 다시 빌드하려면(예: `--continue` 실행 간에 해당 단어를 반복할 때) `--system-prompt-snapshot off`를 전달합니다. v2.1.265 이전에는 시스템 프롬프트 플래그 중 하나를 전달하면 `--system-prompt-snapshot on`을 전달하지 않는 한 기록이 꺼졌습니다.

<h2 id="see-also">
  참고 항목
</h2>

* [Chrome 확장 프로그램](/docs/ko/chrome) - 브라우저 자동화 및 웹 테스트
* [대화형 모드](/docs/ko/interactive-mode) - 바로 가기, 입력 모드 및 대화형 기능
* [빠른 시작 가이드](/docs/ko/quickstart) - Claude Code 시작하기
* [일반적인 워크플로우](/docs/ko/common-workflows) - 고급 워크플로우 및 패턴
* [설정](/docs/ko/settings) - 구성 옵션
* [Agent SDK 문서](/docs/ko/agent-sdk/overview) - 프로그래밍 방식 사용 및 통합
