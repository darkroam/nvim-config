# Repository instructions

These instructions apply to the entire repository. The canonical maintenance
policy is `docs/project/maintenance-policy.md`.

## Mandatory change workflow

1. Inspect the current code, documentation, Git state, and relevant runtime
   facts without modifying tracked files.
2. Present a concrete proposal covering scope, non-goals, documentation impact,
   implementation steps, validation, risks, and rollback.
3. Do not modify tracked files until the user explicitly approves the proposal.
4. After approval, update the canonical documentation and planning state before
   changing runtime code or configuration.
5. Implement only the approved scope. New findings go to `docs/planning/todo.md`
   unless they block the approved work.
6. Validate code and documentation together. A command that exits successfully
   while printing Neovim errors is not a passing check.
7. Review the final diff and repository status before committing. Commit only
   after all applicable checks pass or every accepted baseline failure is
   accurately recorded. Never push without explicit authorization.

Documentation-only changes follow the same proposal and approval gate. For
those changes, step 4 means updating the relevant canonical document before
navigation, history, or generated support files.

## Documentation ownership

- `README.md` is the concise project entry point and documentation index.
- `docs/project/architecture.md` owns structure, startup flow, responsibility,
  and design boundaries.
- `docs/project/dependencies.md` owns external commands, runtimes, providers,
  and requirement levels.
- `docs/project/plugins.md` owns plugin declarations, configuration hooks, and
  active, dormant, or unresolved status.
- `docs/project/maintenance-policy.md` owns the change and validation policy.
- `docs/planning/todo.md`, `suspended.md`, and `history.md` contain active,
  conditionally deferred, and completed work respectively.
- `docs/user/` contains self-contained user behavior and keybinding guidance.

When behavior changes, update every affected owner document. In particular,
changes to `lua/darkroam/languages.lua`, plugin declarations, dependencies, or
custom keymaps must update their corresponding tables before implementation.

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
