> ## Documentation Index
> Fetch the complete documentation index at: https://code.claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Checkpointing

> Claude의 편집 및 대화를 추적, 되돌리기 및 요약하여 세션 상태를 관리합니다.

Claude Code는 작업하면서 Claude의 파일 편집을 자동으로 추적하므로 변경 사항을 빠르게 실행 취소하고 문제가 발생한 경우 이전 상태로 되돌릴 수 있습니다.

<h2 id="how-checkpoints-work">
  Checkpoint의 작동 방식
</h2>

Claude와 함께 작업할 때 checkpointing은 각 사용자 프롬프트가 시작하는 턴 전에 코드의 상태를 자동으로 캡처합니다.

<h3 id="automatic-tracking">
  자동 추적
</h3>

Claude Code는 파일 편집 도구로 수행된 모든 변경 사항을 추적합니다:

* 시작하는 턴마다 보내는 모든 프롬프트는 새로운 checkpoint를 생성합니다
* Claude Code는 세션의 가장 최근 100개 checkpoint에 대한 파일 스냅샷을 유지합니다. 이전 checkpoint를 삭제하면 남은 checkpoint가 참조하지 않는 스냅샷 파일이 삭제되며, 각 파일의 첫 번째 스냅샷은 예외입니다. 이 스냅샷은 VS Code 확장이 세션 diff의 기준선으로 사용합니다.
* Checkpoint는 세션과 함께 저장되므로 재개된 세션에서도 `/rewind`를 사용할 수 있습니다
* Claude Code는 [retention sweep](/docs/ko/claude-directory#cleaned-up-automatically)에서 세션의 파일 스냅샷을 삭제합니다. 기본적으로 세션이 마지막으로 저장된 후 약 30일 후입니다. 스냅샷이 없는 checkpoint로 되돌리면 [`No files were restored`](/docs/ko/errors#no-files-were-restored) 오류가 발생할 수 있습니다. 스냅샷을 더 오래 유지하려면 [`cleanupPeriodDays`](/docs/ko/settings-reference#cleanupperioddays)를 설정하세요.

<h3 id="rewind-and-summarize">
  되돌리기 및 요약
</h3>

`/rewind`를 실행하거나 프롬프트 입력이 비어 있을 때 `Esc`를 두 번 눌러 rewind 메뉴를 엽니다.

<Note>
  프롬프트 입력에 텍스트가 포함되어 있으면 `Esc`를 두 번 누르면 메뉴를 열지 않고 대신 텍스트를 지웁니다. 지워진 텍스트는 입력 기록에 저장되므로 rewind 메뉴에서 작업을 마친 후 `Up`을 눌러 복구할 수 있습니다.
</Note>

Rewind 메뉴는 세션 중에 보낸 프롬프트를 나열합니다. 작업할 지점을 선택한 다음 작업을 선택합니다:

* **코드 및 대화 복원**: 코드와 대화를 해당 지점으로 되돌립니다
* **대화 복원**: 현재 코드를 유지하면서 해당 메시지로 되돌립니다
* **코드 복원**: 대화를 유지하면서 파일 변경 사항을 되돌립니다
* **여기서부터 요약**: 이 지점부터 이후의 대화를 요약으로 압축하여 context window 공간을 확보합니다
* **여기까지 요약**: 이 지점 이전의 대화를 요약으로 압축하여 이후 메시지를 그대로 유지합니다
* **취소**: 변경 사항을 적용하지 않고 메시지 목록으로 돌아갑니다

두 코드 복원 옵션은 선택한 checkpoint에 되돌릴 추적된 파일 변경 사항이 있을 때만 나타납니다. 해당 지점 이후에 파일 편집이 캡처되지 않은 경우 메뉴는 **대화 복원**, 요약 옵션 및 **취소**만 제공합니다.

대화를 복원하거나 여기서부터 요약을 선택한 후 선택한 메시지의 원본 프롬프트가 입력 필드에 복원되므로 다시 보내거나 편집할 수 있습니다.

여기까지 요약을 선택하면 대화의 끝에 남겨지며 입력 필드는 비어 있습니다. 두 요약 옵션 중 하나를 사용하면 압축된 메시지가 있던 대화에 **Summarized conversation** 마커가 나타납니다.

<h4 id="rewind-past-a-cleared-conversation">
  이전 세션의 지워진 대화로 되돌리기
</h4>

동일한 Claude Code 프로세스에서 이전에 `/clear`를 실행한 경우 rewind 메뉴는 목록 맨 위에 `/resume <session-id> (이전 세션)`이라는 레이블이 지정된 추가 항목을 표시합니다. 이를 선택하여 `/clear`가 실행되기 전에 활성화되었던 대화를 재개합니다. 이 항목은 Claude Code를 종료하거나 다른 세션을 재개할 때까지 사용 가능합니다.

<h4 id="guide-a-summary">
  요약 안내
</h4>

요약은 디스크의 파일을 변경하지 않으며 원본 메시지는 세션 기록에 남아 있으므로 Claude가 여전히 세부 정보를 참조할 수 있습니다. 요약이 초점을 맞출 내용을 안내하려면 화살표 키로 **Summarize** 옵션을 강조 표시하고 행에 \*\*add context (optional)\*\*이라고 표시된 위치에 지침을 입력한 다음 `Enter`를 누르세요. 숫자 키로 옵션을 선택하면 지침 없이 즉시 요약합니다.

<Note>
  Summarize는 동일한 세션에 유지되고 범위를 좁힌 `/compact`처럼 context를 압축합니다. 원본 세션을 그대로 유지하면서 갈라져 나와 다른 접근 방식을 시도하고 싶다면 대신 [`/branch`](/docs/ko/sessions#branch-a-session) 또는 `claude --continue --fork-session`을 사용하세요.
</Note>

<h2 id="common-use-cases">
  일반적인 사용 사례
</h2>

Checkpoint는 다음과 같은 경우에 특히 유용합니다:

* **대안 탐색**: 시작점을 잃지 않으면서 다양한 구현 접근 방식을 시도합니다
* **실수 복구**: 버그를 도입하거나 기능을 손상시킨 변경 사항을 빠르게 실행 취소합니다
* **기능 반복**: 작동하는 상태로 되돌릴 수 있다는 확신을 가지고 변형을 실험합니다
* **Context 공간 확보**: 초기 지침을 그대로 유지하면서 중간 지점부터 시작하여 자세한 디버깅 세션을 요약합니다

<h2 id="limitations">
  제한 사항
</h2>

<h3 id="bash-command-changes-not-tracked">
  Bash 명령 변경 사항이 추적되지 않음
</h3>

Checkpointing은 Bash 명령으로 수정된 파일을 추적하지 않습니다. 예를 들어 Claude Code가 다음을 실행하는 경우:

```bash theme={null}
rm file.txt
mv old.txt new.txt
cp source.txt dest.txt
```

이러한 파일 수정 사항은 rewind를 통해 실행 취소할 수 없습니다. Claude의 파일 편집 도구를 통해 직접 수행된 파일 편집만 추적됩니다.

<h3 id="subagent-edits-not-restored">
  Subagent 편집이 복원되지 않음
</h3>

[Subagent](/docs/ko/sub-agents)는 Claude의 파일 편집 도구로 편집을 수행하지만, Claude Code는 일반적으로 세션의 checkpoint에서 이러한 편집을 캡처하지 않습니다. Rewind가 이를 복원하는지 여부는 subagent가 실행되는 방식에 따라 달라집니다:

* **Foreground forked skill**: [foreground에서 실행되는 `context: fork`가 있는 skill](/docs/ko/skills#run-skills-in-a-subagent)은 사용자의 차례 동안 작업 트리를 편집하므로, rewind는 일반적으로 편집을 복원합니다. `background: false`를 설정하여 fork를 foreground에서 실행합니다. 몇 가지 상황([skills 페이지에 나열됨](/docs/ko/skills#run-skills-in-a-subagent))은 설정과 관계없이 foreground에서 실행됩니다.
* **다른 모든 subagent**: rewind는 편집을 복원하지 않습니다. git을 사용하여 되돌립니다. 여기에는 background에서 실행되는 forked skill(기본값)과 background [`/code-review --fix`](/docs/ko/code-review) 실행이 포함됩니다.

<h3 id="external-changes-not-tracked">
  외부 변경 사항이 추적되지 않음
</h3>

Checkpointing은 현재 세션 내에서 편집된 파일만 추적합니다. Claude Code 외부에서 수동으로 수행한 파일 변경 사항과 다른 동시 세션의 편집은 현재 세션과 동일한 파일을 수정하는 경우를 제외하고는 일반적으로 캡처되지 않습니다.

<h3 id="messages-sent-mid-turn-not-checkpointed">
  차례 중간에 전송된 메시지가 checkpoint되지 않음
</h3>

[Claude가 작업하는 동안 대기열에 추가한](/docs/ko/interactive-mode#queue-messages-while-claude-works) 메시지가 실행 중인 턴 내에서 Claude에 도달하면, 새로운 턴을 시작하는 대신 해당 턴에 합류합니다. 메시지는 대화에 나타나지만, Claude Code는 이에 대한 체크포인트를 생성하지 않습니다. Claude Code가 새로운 턴의 일부로 전송하는 대기열 메시지는 평소대로 체크포인트를 받으며, 여러 대기열 메시지가 [해당 턴을 공유](/docs/ko/interactive-mode#when-claude-code-sends-what-you-queued)하는 경우도 포함됩니다.

이러한 메시지 이후 Claude가 수행한 편집을 실행 취소하려면, 턴을 시작한 프롬프트로 rewind합니다. 이렇게 하면 메시지가 도착하기 전에 Claude가 수행한 작업을 포함하여 전체 턴이 rewind됩니다.

<h3 id="symlinked-and-hard-linked-paths-not-restored">
  Symlink 및 hard link 경로가 복원되지 않음
</h3>

Checkpointing은 symlink 또는 hard link된 파일을 rewind하지 않습니다. `/rewind` 메뉴에서 **Restore code** 또는 **Restore code and conversation**을 선택하면, Claude Code는 symlink 또는 hard link인 추적된 경로를 건너뛰고 `Restored the code, but skipped N files` 경고를 표시합니다. 건너뛴 파일은 현재 내용을 유지합니다. 세션의 변경 사항 중 하나를 실행 취소하려면 Claude에 편집을 되돌리도록 요청하거나 파일을 직접 편집합니다. dotfile manager가 프로젝트에 symlink하는 구성 파일과 pnpm이 제자리에 hard link하는 파일 모두 이 범주에 해당합니다.

restore가 건너뛰는 경로를 확인하려면 restore 전에 `/debug`로 debug logging을 켭니다: `~/.claude/debug/<session-id>.txt`의 debug log는 건너뛴 각 경로를 나열합니다. 모든 건너뛰기 이유와 복구 단계는 [error reference의 skipped-files 항목](/docs/ko/errors#restored-the-code-but-skipped-files)을 참조합니다.

<h3 id="not-a-replacement-for-version-control">
  버전 관리의 대체가 아님
</h3>

Checkpoint는 빠른 세션 수준의 복구를 위해 설계되었습니다. 영구적인 버전 기록 및 협업을 위해 Git과 같은 버전 관리를 계속 사용하여 커밋, 분기 및 장기 기록을 유지합니다.

<h2 id="see-also">
  참고 항목
</h2>

* [Interactive mode](/docs/ko/interactive-mode) - 키보드 단축키 및 세션 제어
* [Commands](/docs/ko/commands) - `/rewind`를 사용하여 checkpoint에 액세스
* [CLI reference](/docs/ko/cli-reference) - 명령줄 옵션
