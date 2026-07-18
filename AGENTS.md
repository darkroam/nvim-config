# Repository instructions

These instructions apply to the entire repository. The canonical maintenance
policy is `docs/maintenance/workflow.md`.

## Mandatory change workflow

1. Inspect current code, documentation, Git state, and relevant runtime facts
   without modifying tracked files.
2. Present a concrete proposal covering scope, non-goals, documentation impact,
   implementation steps, validation, risks, and rollback.
3. Do not modify tracked files until the user explicitly approves the proposal.
4. After approval, update canonical documentation and roadmap state before
   changing runtime code or configuration.
5. Implement only the approved scope. Non-blocking findings go to
   `docs/maintenance/roadmap.md`.
6. Validate code and documentation together. A command that exits successfully
   while printing Neovim errors is not a passing check.
7. Review the final diff and repository status before committing. Commit only
   after applicable checks pass or accepted baseline failures are accurately
   recorded. Never push without explicit authorization.

Documentation-only changes use the same proposal and approval gate. For these
changes, step 4 means updating the relevant owner document before navigation,
history, or generated support files.

## Documentation ownership

- `README.md` is the concise entry point and documentation index.
- `docs/guide/installation.md` owns clean installation, recovery, and platform
  boundaries.
- `docs/guide/usage.md` owns daily workflows and user troubleshooting.
- `docs/guide/languages.md` owns language switches and user-visible LSP,
  formatter, and parser behavior.
- `docs/guide/keymaps.md` owns repository-defined keybindings.
- `docs/reference/architecture.md` owns structure, startup flow, module
  responsibility, and state boundaries.
- `docs/reference/compatibility.md` owns the complete version matrix, feature
  gates, degradation behavior, and validation status.
- `docs/reference/dependencies.md` owns external commands, runtimes, providers,
  and requirement levels.
- `docs/reference/plugins.md` owns plugin declarations, configuration hooks,
  loading conditions, and status.
- `docs/maintenance/workflow.md` owns change and validation policy.
- `docs/maintenance/roadmap.md` and `history.md` own incomplete and completed
  work respectively.

When behavior changes, update every affected owner document. Changes to
`languages.lua`, compatibility gates, plugin declarations, dependencies, or
custom keymaps must update their corresponding owner before implementation.

## Required checks

Run at minimum:

```sh
python3 scripts/check-docs.py
git diff --check
git status --short
```

Also run focused Lua and Neovim checks appropriate to the change. Capture
Neovim output as well as its exit status because headless startup can return
zero after reporting startup errors. Keep logs, caches, sessions, downloaded
plugins, Mason packages, parser builds, and other machine state out of Git.

Except for the root `README.md` and this instruction file, project-maintained
documentation should normally be written in Chinese. Preserve command names,
paths, code identifiers, and literal output in their original form.
