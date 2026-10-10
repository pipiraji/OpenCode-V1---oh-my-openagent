# Copilot instructions

## Project overview

This repository is an example deployment for OpenCode V1 (the README targets 1.15.x) with the `oh-my-openagent` (OMO) plugin and a personal LLM provider. It contains configuration, a launcher, and Korean operational documentation; there is no application source tree.

The launcher in `examples/v1-personal-opencode/bin/personal-opencode` connects two separate installations: a shared, read-only OpenCode/OMO release and per-user configuration and data. It validates the release and personal config, creates private XDG directories, clears inherited `OPENCODE_*` config/permission overrides, prioritizes the shared release's helper binaries, sets the OMO telemetry variables, and replaces itself with the OpenCode process. Preserve this separation when changing the launcher.

OpenCode provider credentials, the `personal/coder` model, permissions, and the absolute path to the shared OMO plugin are configured in `examples/v1-personal-opencode/config/opencode.jsonc`. OMO agent/category model choices and OMO behavior are configured separately in `config/omo.jsonc`; the deployed OMO user config lives at `~/.omo/omo.jsonc`, not under the wrapper's XDG config root. OMO model references use `<OpenCode provider ID>/<OpenCode model key>`; the server's model ID is configured separately in OpenCode's model entry.

The root README describes installation and deployment. The two documents under `docs/` cover OMO config semantics and wrapper environment variables. These operational documents are in Korean; update the relevant documentation when changing setup, config behavior, or environment handling.

## Build, test, and lint

There is no repository-defined build, test, or lint command, and no automated test suite or single-test selector. The wrapper can be syntax-checked with:

```bash
bash -n examples/v1-personal-opencode/bin/personal-opencode
```

When a configured OpenCode V1 release and provider are available, use the documented runtime smoke checks:

```bash
personal-opencode --version
personal-opencode models
personal-opencode debug config
```

`debug config` output may contain credentials; redact sensitive values before sharing it. To verify a live model request, the README documents:

```bash
personal-opencode run --model personal/coder "OK라고만 답해줘"
```

This requires a working provider endpoint and may send a prompt to that service. For OMO diagnostics, use the CLI from the configured shared release rather than downloading an unpinned latest version:

```bash
/opt/company-opencode/current/runtime/node_modules/.bin/oh-my-openagent doctor
```

## Repository-specific conventions

- Keep the shared release read-only. Do not add runtime installation, auto-update, or user credentials to it; the wrapper expects the executable at `runtime/bin/opencode` and OMO at `runtime/node_modules/oh-my-openagent`. If `COMPANY_OPENCODE_ROOT` is changed from the example path, also update the absolute OMO plugin path in `config/opencode.jsonc`; the wrapper does not rewrite that setting.
- Keep actual API tokens out of tracked example files. `opencode.jsonc` contains placeholders; real user config should be installed with restrictive permissions as described in the README. Never pass tokens as wrapper command-line arguments.
- The wrapper-specific `COMPANY_OPENCODE_ROOT` and `PERSONAL_OPENCODE_*_HOME` variables select roots; OpenCode and OMO receive the resulting paths through standard `XDG_*` variables. `HOME` intentionally remains unchanged so Git/SSH settings and `~/.omo/omo.jsonc` continue to resolve normally.
- The example uses OpenCode V1 singular keys such as `provider`, `plugin`, and `enabled_providers`. Do not convert these to V2-style plural keys without intentionally changing the target version and updating the docs.
- Keep OpenCode provider/model definitions and OMO model references consistent: changing a provider ID or model key also requires updating the root model and every OMO agent/category reference that uses it.
- Treat `.jsonc` as JSON with comments and trailing commas; preserve the format and its schema declarations when editing configuration.
