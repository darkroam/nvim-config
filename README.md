# nvim-config

Personal Neovim configuration written in Lua. The repository owns editor
configuration only; downloaded plugins, Mason packages, Tree-sitter parsers,
sessions, caches, and credentials remain machine-local.

Last reviewed: 2026-07-17.

## Compatibility status

The current configuration uses the Neovim 0.11 LSP APIs
`vim.lsp.config()` and `vim.lsp.enable()`. Neovim **0.11 or newer** is therefore
the supported baseline. The 2026-07-17 audit found Neovim 0.10.4 on the current
machine and reproduced startup errors from the LSP, Telescope, and
Mason-LSPConfig paths; see the
[repository audit](docs/planning/repository-audit.md).

Plugins are currently managed by Packer without a lock file or pinned commits.
An installed plugin tree can consequently move beyond the compatibility of an
older Neovim executable. Reproducible plugin resolution remains active work.

## Installation

Back up any existing configuration, then clone this repository into Neovim's
standard configuration directory:

```sh
git clone https://github.com/darkroam/nvim-config ~/.config/nvim
nvim
```

The first start bootstraps Packer through Git and synchronizes declared
plugins. Restart Neovim after bootstrap and run `:PackerSync` if synchronization
did not finish. Mason and Tree-sitter may then install resources selected by
the language switches, so initial setup requires network access.

The core runtime requires Git and `zsh`; editor integrations additionally use
tools such as a clipboard provider, `rg`, `fd`/`fdfind`, a C toolchain, and a
Nerd Font according to the enabled features. The authoritative requirement
levels and providers are in [dependencies](docs/project/dependencies.md).

## Startup flow

```text
init.lua
  |-- options and custom autocommands
  |-- global keymaps
  |-- Packer bootstrap and plugin declarations
  |-- neosolarized colorscheme
  `-- optional impatient profiling and OS-specific options

Neovim runtime loading
  |-- plugin/*.lua        LSP setup and dormant Lspsaga hook
  `-- after/plugin/*.lua  configuration for available start plugins
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
