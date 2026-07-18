# nvim-config

Personal Neovim configuration written in Lua. The repository owns reusable
configuration and a locked plugin graph; downloaded plugins, Mason packages,
Tree-sitter parsers, sessions, caches, and credentials remain machine-local.

Last reviewed: 2026-07-18.

## Support

Neovim 0.12.3 is the primary, fully featured baseline. Neovim 0.10 and 0.11
use the same configuration and lockfile, but incompatible features are disabled
by centralized version gates. The exact matrix and actual test status are in
[Compatibility](docs/reference/compatibility.md).

Plugins are managed by lazy.nvim and resolved through the committed
`lazy-lock.json`. A plugin checkout being present does not by itself mean the
plugin is active on the current Neovim version.

## Quick Start

On the currently validated Linux path:

```sh
git clone https://github.com/darkroam/nvim-config ~/.config/nvim
nvim
```

The first start bootstraps the pinned lazy.nvim manager and restores locked
plugin commits. Mason tools and initial Tree-sitter parsers are explicit,
machine-local installation steps. Follow the complete
[Installation and recovery guide](docs/guide/installation.md) before treating
the environment as ready for language work.

## Documentation

Start here:

- [Installation and recovery](docs/guide/installation.md)
- [Daily usage](docs/guide/usage.md)
- [Language capabilities](docs/guide/languages.md)
- [Custom keymaps](docs/guide/keymaps.md)

Reference:

- [Architecture](docs/reference/architecture.md)
- [Compatibility](docs/reference/compatibility.md)
- [Dependencies](docs/reference/dependencies.md)
- [Plugin inventory](docs/reference/plugins.md)

Maintenance:

- [Change workflow](docs/maintenance/workflow.md)
- [Roadmap](docs/maintenance/roadmap.md)
- [History](docs/maintenance/history.md)
- [Repository instructions](AGENTS.md)

## Maintenance

Every change follows the same sequence: inspect, propose, obtain explicit
approval, update owner documentation, implement the approved scope, validate
code and documentation together, then commit. Push is never implicit.

Run the offline documentation contract check with:

```sh
python3 scripts/check-docs.py
```

A zero exit code from headless Neovim is not sufficient when its output still
contains startup or provider errors.
