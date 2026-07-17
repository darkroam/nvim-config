# nvim-config

Personal Neovim configuration written in Lua. The repository owns editor
configuration only; downloaded plugins, Mason packages, Tree-sitter parsers,
sessions, caches, and credentials remain machine-local.

Last reviewed: 2026-07-17.

## Compatibility status

Neovim **0.12.3** is the primary, fully featured baseline. Neovim 0.10 and
0.11 are compatibility profiles: the core editor remains usable, while plugins
whose locked versions require a newer Neovim are not loaded.

| Neovim | Profile | Version-gated features |
| --- | --- | --- |
| 0.12.3 | primary, full feature set | all declared features; current headless/runtime checks recorded in history |
| 0.11.7+ | compatibility | current LSP and Telescope; no current Tree-sitter stack |
| 0.11.3-0.11.6 | compatibility | current LSP; no current Telescope or Tree-sitter stack |
| 0.11.0-0.11.2 | basic | no current LSP, Telescope, or Tree-sitter stack |
| 0.10.x | basic | no current LSP, Telescope, or Tree-sitter stack |

Plugins are managed by lazy.nvim and resolved through the committed
`lazy-lock.json`. Version gates are centralized in
`lua/darkroam/compat.lua`; disabled plugins do not leave unusable custom
keymaps behind. The exact support and validation status is documented in
[architecture](docs/project/architecture.md) and the
[repository audit](docs/planning/repository-audit.md).

## Installation

Back up any existing configuration, then clone this repository into Neovim's
standard configuration directory:

```sh
git clone https://github.com/darkroam/nvim-config ~/.config/nvim
nvim
```

The first start bootstraps the pinned lazy.nvim manager through Git, then
restores the plugin commits in `lazy-lock.json`. Use `:Lazy` to inspect the
result. Mason packages and Tree-sitter parsers are machine-local resources;
installing them is an explicit maintenance action and requires network access.

The core runtime requires Git and `zsh`; editor integrations additionally use
tools such as a clipboard provider, `rg`, `fd`/`fdfind`, a C toolchain, and a
Nerd Font according to the enabled features. The authoritative requirement
levels and providers are in [dependencies](docs/project/dependencies.md).

## Startup flow

```text
init.lua
  |-- Lua module loader
  |-- options and custom autocommands
  |-- plugin-independent global keymaps
  |-- pinned lazy.nvim bootstrap
  |-- version-gated plugin specs and configuration
  `-- OS-specific clipboard options
```

The complete ownership and load-order description is in
[architecture](docs/project/architecture.md).

## Language switches

`lua/darkroam/languages.lua` is the source of truth:

| Language key | Status | LSP | Formatter | Tree-sitter |
| --- | --- | --- | --- | --- |
| `lua` | enabled | `lua_ls` | `stylua` | `lua` |
| `c` | enabled | `clangd` | `clang_format` | `c` |
| `elisp` | enabled | none | none | `commonlisp` for `lisp` filetype |
| `go` | disabled | `gopls` when enabled | `gofmt` when enabled | Go parser family when enabled |

Changing a switch affects LSP, Mason, Conform, and Tree-sitter and must follow
the documented proposal-first workflow.

## Documentation

Project facts and policy:

- [Architecture](docs/project/architecture.md)
- [Dependencies](docs/project/dependencies.md)
- [Plugin inventory](docs/project/plugins.md)
- [Maintenance policy](docs/project/maintenance-policy.md)
- [Repository instructions](AGENTS.md)

Planning and evidence:

- [Repository audit](docs/planning/repository-audit.md)
- [Change proposal template](docs/planning/change-template.md)
- [Current TODO](docs/planning/todo.md)
- [Suspended work](docs/planning/suspended.md)
- [History](docs/planning/history.md)

User documentation:

- [Usage guide in Chinese](docs/user/usage-zh.md)
- [Custom keybindings in Chinese](docs/user/keybindings-zh.md)

## Maintenance

All repository changes use this sequence: inspect and propose, obtain explicit
approval, update documentation first, implement the approved change, validate
code and documentation together, then commit. Run the local documentation
check with:

```sh
python3 scripts/check-docs.py
```

Do not treat a zero exit code from headless Neovim as sufficient by itself;
startup output must also be free of unexpected errors.
