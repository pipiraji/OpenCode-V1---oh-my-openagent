# `omo.jsonc` 작성 가이드

이 문서는 OpenCode V1 + `oh-my-openagent` 환경에서 `omo.jsonc`를 작성하는 방법을 설명합니다.

특히 다음 내용을 다룹니다.

- OMO 설정 파일의 위치와 적용 범위
- provider ID와 model key를 어떻게 조합하는지
- 개인 LLM provider를 OMO agent/category에 연결하는 방법
- model chain, reasoning, background task 설정
- 자주 발생하는 설정 오류

> OMO 설정 schema와 agent 이름은 OMO 버전에 따라 변경될 수 있습니다. 배포 전 실제 설치 버전의 schema와 대조해야 합니다.

---

# 1. 파일 위치와 설정 계층

## 사용자 설정

현재 unified OMO 설정 파일은 다음과 같습니다.

```text
~/.omo/omo.jsonc
```

사용자 설정은 모든 프로젝트의 기본값입니다.

## 프로젝트 설정

```text
<project>/.omo/omo.jsonc
```

현재 작업 디렉터리에서 `$HOME` 방향으로 부모 디렉터리를 검색합니다. 더 가까운 프로젝트 설정이 우선합니다.

적용 순서:

```text
사용자 ~/.omo/omo.jsonc
→ 상위 프로젝트 .omo/omo.jsonc
→ 현재 프로젝트 .omo/omo.jsonc
```

## JSONC 형식

`.jsonc`이므로 주석과 trailing comma를 사용할 수 있습니다.

```jsonc
{
  // 주석
  "telemetry": false,
}
```

## Schema 연결

```jsonc
{
  "$schema": "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/omo.schema.json"
}
```

Schema URL은 개발 브랜치이므로 배포 시에는 고정된 release 또는 사내 schema mirror를 사용하는 것이 안정적입니다.

---

# 2. provider와 model key의 관계

OMO에 모델을 입력할 때 다음 네 가지 이름을 구분해야 합니다.

| 이름 | 위치 | 예시 |
|---|---|---|
| Provider ID | OpenCode `provider` key | `personal` |
| OpenCode model key | OpenCode `provider.personal.models` key | `coder` |
| 서버 실제 model ID | OpenCode model의 `id` | `personal-server-coder` |
| OMO model reference | OMO `model` 값 | `personal/coder` |

기본 구조:

```text
personal/coder
│        └── OpenCode model key
└─────────── OpenCode provider ID
```

OpenCode 설정:

```jsonc
{
  "provider": {
    "personal": {
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "http://personal-llm:8000/v1",
        "apiKey": "PERSONAL_TOKEN"
      },
      "models": {
        "coder": {
          "id": "personal-server-coder",
          "name": "Personal Coder"
        }
      }
    }
  }
}
```

OMO 설정:

```jsonc
{
  "[opencode]": {
    "agents": {
      "librarian": {
        "model": "personal/coder"
      }
    }
  }
}
```

실제 요청에서 서버로 전송되는 model ID는 다음과 같습니다.

```text
personal-server-coder
```

즉, OMO의 `personal/coder`와 서버의 `personal-server-coder`가 달라도 괜찮습니다. OpenCode의 `id`가 둘을 연결합니다.

---

# 3. Provider는 `opencode.jsonc`에 정의합니다

OMO 설정은 provider endpoint나 token을 새로 만드는 것이 아니라, OpenCode에 이미 정의된 provider/model을 참조합니다.

## OpenCode에 provider 정의

```jsonc
{
  "provider": {
    "personal": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Personal LLM",

      "options": {
        "baseURL": "http://personal-llm:8000/v1",
        "apiKey": "PERSONAL_TOKEN"
      },

      "models": {
        "fast": {
          "id": "server-model-fast",
          "name": "Personal Fast"
        },
        "standard": {
          "id": "server-model-standard",
          "name": "Personal Standard"
        }
      }
    }
  }
}
```

## OMO에서 사용 가능한 model 확인

먼저 OpenCode에서 실제 model reference가 확인되어야 합니다.

```bash
personal-opencode models
```

예상 결과:

```text
personal/fast
personal/standard
```

OMO에는 이 문자열을 그대로 사용합니다.

---

# 4. 최소 OMO 설정

개인 provider의 `personal/standard`만 사용한다면 다음 정도가 최소 설정입니다.

```jsonc
{
  "$schema": "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/omo.schema.json",

  "telemetry": false,

  "disabled_hooks": [
    "auto-update-checker"
  ],

  "[opencode]": {
    "agents": {
      "explore": {
        "model": "personal/standard"
      },
      "librarian": {
        "model": "personal/standard"
      },
      "plan-consultant": {
        "model": "personal/standard"
      },
      "plan-reviewer": {
        "model": "personal/standard"
      }
    },

    "categories": {
      "quick": {
        "model": "personal/standard"
      },
      "unspecified-low": {
        "model": "personal/standard"
      },
      "unspecified-high": {
        "model": "personal/standard"
      }
    }
  }
}
```

현재 OMO의 기본 agent 이름:

| Agent | 기본 역할 |
|---|---|
| `explore` | 빠른 코드 탐색 |
| `librarian` | 외부 문서/코드 검색 |
| `plan-consultant` | 계획 검토 |
| `plan-reviewer` | 최종 계획 검증 |

메인 세션 모델은 OMO agent 설정이 아니라 `opencode.jsonc`의 root `model`이 우선합니다.

```jsonc
{
  "model": "personal/standard"
}
```

---

# 5. Agent 설정

## `model`

model 하나를 지정합니다.

```jsonc
{
  "[opencode]": {
    "agents": {
      "explore": {
        "model": "personal/fast"
      }
    }
  }
}
```

형식:

```text
provider/model
```

provider ID와 model key는 대소문자를 구분합니다.

```text
personal/fast
personal/Fast
```

위 두 값은 서로 다릅니다.

## `models`: 순서 있는 model chain

기본 model을 먼저 시도하고 실패하면 다음 model을 시도하도록 지정합니다.

```jsonc
{
  "[opencode]": {
    "agents": {
      "librarian": {
        "models": [
          "personal/fast",
          "personal/standard"
        ]
      }
    }
  }
}
```

chain은 앞에 있는 model부터 사용합니다.

## chain 항목에 설정 추가

```jsonc
{
  "[opencode]": {
    "agents": {
      "plan-consultant": {
        "models": [
          {
            "model": "personal/standard",
            "reasoning": "high"
          },
          {
            "model": "personal/fast",
            "reasoning": "low"
          }
        ]
      }
    }
  }
}
```

개인 LLM이 reasoning 기능을 지원하지 않으면 해당 값을 제거하십시오.

## `reasoning`

```jsonc
{
  "[opencode]": {
    "agents": {
      "plan-reviewer": {
        "model": "personal/standard",
        "reasoning": "high"
      }
    }
  }
}
```

provider/model이 지원하는 값만 사용해야 합니다. 일반적인 값은 다음과 같습니다.

```text
none
minimal
low
medium
high
```

일부 model/provider는 추가 수준을 지원할 수 있습니다. 실제 지원 여부는 LLM 서버와 provider package에 따라 달라집니다.

## `temperature`

```jsonc
{
  "[opencode]": {
    "agents": {
      "explore": {
        "model": "personal/fast",
        "temperature": 0.2
      }
    }
  }
}
```

일부 reasoning model은 temperature 설정을 허용하지 않을 수 있습니다.

## `prompt_append`

기존 agent prompt 뒤에 내용을 추가합니다.

```jsonc
{
  "[opencode]": {
    "agents": {
      "plan-consultant": {
        "model": "personal/standard",
        "prompt_append": "항상 실행 가능한 단계와 검증 방법을 함께 제시하십시오."
      }
    }
  }
}
```

## `tools`

특정 tool을 끄거나 켭니다.

```jsonc
{
  "[opencode]": {
    "agents": {
      "plan-reviewer": {
        "model": "personal/standard",
        "tools": {
          "write": false,
          "edit": false
        }
      }
    }
  }
}
```

tool 이름은 실제 OMO/OpenCode tool ID를 사용해야 합니다.

## `disable`

agent을 끕니다.

```jsonc
{
  "[opencode]": {
    "agents": {
      "librarian": {
        "disable": true
      }
    }
  }
}
```

---

# 6. Category 설정

Category는 subagent가 어떤 종류의 작업을 수행할 때 어떤 model chain을 사용할지 정의합니다.

```jsonc
{
  "[opencode]": {
    "categories": {
      "quick": {
        "model": "personal/fast"
      },
      "unspecified-low": {
        "model": "personal/standard"
      },
      "unspecified-high": {
        "models": [
          "personal/standard",
          "personal/fast"
        ]
      }
    }
  }
}
```

기본 category 예시:

| Category | 용도 |
|---|---|
| `quick` | 단순/빠른 작업 |
| `writing` | 문서와 prose 작성 |
| `visual-engineering` | UI/프런트엔드 작업 |
| `deep-low` | 복잡한 탐색/구현 |
| `deep-high` | 고신뢰도 작업 |
| `ultrabrain` | 최고 난이도 strategic 작업 |

개인 LLM이 특정 category를 처리할 만큼 강하지 않으면 그 category를 비활성화할 수 있습니다.

```jsonc
{
  "[opencode]": {
    "categories": {
      "visual-engineering": {
        "disable": true
      }
    }
  }
}
```

---

# 7. OMO model alias 사용

반복해서 사용하는 긴 model reference는 OMO alias로 정의할 수 있습니다.

```jsonc
{
  "models": {
    "fast": {
      "model": "personal/fast",
      "reasoning": "low"
    },
    "deep": {
      "model": "personal/standard",
      "reasoning": "high"
    }
  },

  "[opencode]": {
    "agents": {
      "librarian": {
        "model": "fast"
      },
      "plan-consultant": {
        "model": "deep"
      }
    },

    "categories": {
      "quick": {
        "model": "fast"
      },
      "unspecified-high": {
        "model": "deep"
      }
    }
  }
}
```

이 top-level `models`는 OMO의 짧은 이름 catalog입니다.

다음을 구분하십시오.

- OMO `models`: 짧은 alias
- OpenCode `provider.personal.models`: 실제 provider model catalog
- OMO `model`: alias 또는 `provider/model` reference

개인 provider가 하나뿐이라면 alias 없이 `personal/fast`, `personal/standard`를 직접 써도 됩니다.

---

# 8. Background task 설정

```jsonc
{
  "[opencode]": {
    "background_task": {
      "defaultConcurrency": 3,
      "maxDepth": 2,

      "providerConcurrency": {
        "personal": 3
      },

      "modelConcurrency": {
        "personal/fast": 2,
        "personal/standard": 1
      }
    }
  }
}
```

## `defaultConcurrency`

provider/model 제한이 없을 때 기본 동시 실행 수입니다.

```jsonc
"defaultConcurrency": 3
```

## `providerConcurrency`

provider별 동시 실행 수입니다.

```jsonc
"providerConcurrency": {
  "personal": 3
}
```

여기의 key는 provider ID인 `personal`입니다. `/model`을 붙이지 않습니다.

## `modelConcurrency`

model별 동시 실행 수입니다.

```jsonc
"modelConcurrency": {
  "personal/fast": 2,
  "personal/standard": 1
}
```

여기의 key는 전체 model reference입니다.

우선순위:

```text
modelConcurrency
> providerConcurrency
> defaultConcurrency
```

개인 LLM 서버의 동시 처리 능력을 초과하지 않도록 보수적으로 시작하십시오.

---

# 9. Telemetry와 hook 설정

## Telemetry 비활성화

```jsonc
{
  "telemetry": false
}
```

wrapper에서도 다음 변수를 설정합니다.

```bash
export OMO_DISABLE_POSTHOG=1
export OMO_SEND_ANONYMOUS_TELEMETRY=0
```

## Auto-update hook 비활성화

공용 read-only release를 사용할 때:

```jsonc
{
  "disabled_hooks": [
    "auto-update-checker"
  ]
}
```

이 설정은 OMO가 사용자별로 업데이트를 시도하지 않게 합니다.

## Hook 추가 비활성화

실제로 필요하지 않은 hook은 이름이 정확할 때만 추가합니다.

```jsonc
{
  "disabled_hooks": [
    "auto-update-checker",
    "ast-grep-sg-provision"
  ]
}
```

`ast-grep-sg-provision`을 끄기 전에 공용 release에 `ast-grep` binary가 준비되어 있어야 합니다.

---

# 10. Provider policy와 OMO의 관계

OpenCode에서 다른 provider를 차단하려면 `opencode.jsonc`에 allowlist를 둡니다.

```jsonc
{
  "enabled_providers": ["personal"]
}
```

또는 policy를 사용합니다.

```jsonc
{
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
}
```

OMO가 `personal/coder`를 사용하는데 OpenCode policy가 `personal`을 차단하면 해당 agent/category는 실행할 수 없습니다.

따라서 다음 두 설정은 항상 일치해야 합니다.

```text
OpenCode에서 personal provider가 사용 가능
OMO에서 personal/* model만 참조
```

---

# 11. 자주 발생하는 오류

## `No model is available`

OMO에 입력한 model이 현재 project/provider에서 사용 불가능합니다.

확인:

```bash
personal-opencode models
```

현재 project의 `opencode.json`이 provider를 덮어쓰지 않았는지 확인하십시오.

## OMO가 다른 provider 로그인을 요구함

OMO config에 다른 provider/model이 남아 있을 가능성이 있습니다.

```bash
grep -RniE '"model"[[:space:]]*:' ~/.omo .omo 2>/dev/null
```

개인 provider만 사용하려면 모든 agent/category의 `model`이 `personal/*`인지 확인합니다.

## Provider ID 오타

```text
personal/coder
```

여러분의 실제 ID가 `private`이라면:

```text
personal/coder  // 잘못됨
private/coder    // 맞음
```

## OpenCode model key 오타

OpenCode에 있는 model key가 `coder`라면:

```text
personal/coder
```

입니다. `personal/my-coder`가 아닙니다.

## 서버 model ID 오타

OpenCode model key와 서버 ID는 다를 수 있습니다.

```jsonc
"models": {
  "coder": {
    "id": "actual-server-model-id"
  }
}
```

OMO reference는 `personal/coder`를 사용합니다.

## Tool 호출 오류

개인 LLM이 tool/function calling을 지원해야 OMO가 파일 편집, shell, subagent 등의 tool을 사용할 수 있습니다.

## Reasoning 파라미터 오류

개인 LLM이 reasoning을 지원하지 않으면 다음을 제거합니다.

```jsonc
"reasoning": "high"
```

## Background task가 지나치게 많음

```jsonc
"background_task": {
  "defaultConcurrency": 1
}
```

로 낮춘 뒤 Personal LLM의 처리량과 오류율을 확인합니다.

---

# 12. 검증 절차

## 1. OpenCode model 확인

```bash
personal-opencode models
```

## 2. OMO doctor 실행

공용 release에 포함된 고정 버전 CLI를 사용합니다.

```bash
/opt/company-opencode/current/runtime/node_modules/.bin/oh-my-openagent doctor
```

`bunx oh-my-openagent@latest`처럼 사용자마다 최신판을 내려받지 않도록 합니다.

## 3. 설정 진단

```bash
personal-opencode debug config
```

출력에 token이 포함될 수 있으므로 공유 전에 민감한 값을 제거합니다.

## 4. 최소 요청

```bash
personal-opencode run --model personal/coder "OK라고만 답해줘"
```

## 5. OMO subagent 확인

```text
@explore 현재 저장소 구조를 요약해줘
@librarian 공식 문서에서 이 설정을 확인해줘
```

## 6. 로그 확인

```bash
tail -f ~/.local/share/opencode-personal/opencode/log/opencode.log
```

token, Authorization header, 프롬프트가 포함될 수 있으므로 외부 공유 전에 제거합니다.

---

# 13. 권장 기본값

개인 LLM provider로 시작할 때는 다음 정도가 안전합니다.

```jsonc
{
  "$schema": "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/omo.schema.json",

  "telemetry": false,

  "disabled_hooks": [
    "auto-update-checker"
  ],

  "[opencode]": {
    "agents": {
      "explore": {
        "model": "personal/fast"
      },
      "librarian": {
        "model": "personal/fast"
      },
      "plan-consultant": {
        "model": "personal/standard"
      },
      "plan-reviewer": {
        "model": "personal/standard"
      }
    },

    "categories": {
      "quick": {
        "model": "personal/fast"
      },
      "unspecified-low": {
        "model": "personal/fast"
      },
      "unspecified-high": {
        "model": "personal/standard"
      }
    },

    "background_task": {
      "defaultConcurrency": 2,
      "providerConcurrency": {
        "personal": 2
      },
      "modelConcurrency": {
        "personal/fast": 2,
        "personal/standard": 1
      }
    }
  }
}
```

개인 LLM의 품질, 속도, tool calling, 동시 처리 능력을 확인한 뒤 model과 concurrency를 조정하는 것이 좋습니다.
