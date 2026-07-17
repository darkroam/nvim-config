# 依赖清单

本文是外部运行时、命令和提供者的权威来源。插件名称和配置状态见 [`plugins.md`](plugins.md)；
某台机器的安装快照见 [`../planning/repository-audit.md`](../planning/repository-audit.md)。

要求级别含义：

- **核心**：当前配置的正常启动或基础命令直接依赖。
- **功能必需**：只有使用对应已启用功能时需要。
- **可选**：缺失时应只损失局部界面或辅助动作。
- **维护**：仅用于验证仓库，不属于编辑器运行时。

## 核心环境

| 软件或能力 | 级别 | 用途与边界 |
| --- | --- | --- |
| Neovim 0.11+ | 核心 | `plugin/lspconfig.lua` 直接使用 `vim.lsp.config()` 和 `vim.lsp.enable()`；当前上游 Telescope 与 Mason-LSPConfig 也要求 0.11 |
| Git | 核心 | Packer bootstrap、插件同步和版本库功能 |
| `zsh` | 核心 | `vim.opt.shell` 的固定值，也是 ToggleTerm 和 `:!` 命令的 shell；缺失时 shell 功能失败 |
| 网络与 TLS 证书 | 功能必需 | 首次 Git bootstrap、Packer 同步、Mason 和 Tree-sitter 下载；稳定离线编辑不应持续依赖网络 |
| UTF-8 locale 和真彩终端 | 功能必需 | 当前图标、诊断符号和 `termguicolors` 界面 |

## 插件和资源管理

| 提供者 | 管理内容 | 仓库边界 |
| --- | --- | --- |
| Packer | `lua/darkroam/plugins.lua` 中的插件 | 下载到 `stdpath("data")`，不跟踪；当前无 lock file 或 commit pin |
| Mason | `lua_ls`、`clangd`，以及启用 Go 后的 `gopls` | 下载到 Mason data 目录，不跟踪；会把自己的 `bin` 加入 Neovim PATH |
| Tree-sitter | 语言开关选中的 parser | parser 二进制和构建产物不跟踪 |
| LuaSnip / friendly-snippets | snippet engine 和 snippet 集合 | 插件提供；仓库没有自定义 snippet 数据 |

Packer、Mason 和 Tree-sitter 的成功安装不能从仓库文件存在推断，必须在目标机器检查。

## 语言工具链

| 语言键 | 状态 | LSP | Formatter | 其他要求 |
| --- | --- | --- | --- | --- |
| `lua` | 启用 | Mason `lua-language-server`（配置名 `lua_ls`） | `stylua`，可由 Mason 提供 | `lua` Tree-sitter parser |
| `c` | 启用 | Mason 或系统 `clangd` | `clang-format`（Conform 名 `clang_format`）；当前 Mason `clangd` 包不自动等价于该命令 | C 编译工具链用于 parser/原生构建路径 |
| `elisp` | 启用 | 无 | 无 | `commonlisp` parser；`.el` 与 `.emacs` 使用 `lisp` filetype |
| `go` | 禁用 | 启用后需要 `gopls` | 启用后需要 Go 工具链的 `gofmt` | 启用后需要 Go parser family；Go 本身不是当前核心依赖 |

改变状态时必须同步 `lua/darkroam/languages.lua`、架构、插件行为、用户指南和检查结果。

## 搜索、项目和 Git 功能

| 软件或能力 | 级别 | 用途与缺失行为 |
| --- | --- | --- |
| `rg` | 功能必需 | Telescope `live_grep`；缺失时 `,dd` 不可用 |
| `fd` 或 `fdfind` | 可选 | Telescope 文件枚举的高性能后端；具体 fallback 由 Telescope 决定 |
| Git 工作树 | 可选 | Gitsigns、Lualine branch/diff 和 project.nvim 的完整版本库功能 |
| `lazygit` | 可选 | ToggleTerm 定义了 `_LAZYGIT_TOGGLE()`，但仓库没有绑定按键 |

Neogit、git.nvim 和 Fugitive 当前不是已声明能力，不应为了遗留配置而写成安装要求。

## 终端和辅助命令

ToggleTerm 为以下命令定义了全局 Lua toggle 函数，但没有仓库级按键：

| 命令 | 函数 | 级别 |
| --- | --- | --- |
| `node` | `_NODE_TOGGLE()` | 可选 |
| `ncdu` | `_NCDU_TOGGLE()` | 可选 |
| `htop` | `_HTOP_TOGGLE()` | 可选 |
| `python` | `_PYTHON_TOGGLE()` | 可选；注意命令名是 `python` 而非 `python3` |

缺少这些命令不影响 ToggleTerm 的普通 shell，只影响显式调用对应函数后的终端进程。

## UI、字体和剪贴板

| 软件或能力 | 级别 | 用途与边界 |
| --- | --- | --- |
| Nerd Font 或兼容图标字体 | 可选 | Web-devicons、Lualine、Telescope 和补全菜单图标；缺失时可能显示方框 |
| 系统剪贴板 provider | 功能必需 | `clipboard=unnamedplus`；X11 常用 `xclip`/`xsel`，Wayland 常用 `wl-copy`，平台也可使用原生 provider |
| 支持真彩和 undercurl 的终端 | 可选 | Neosolarized 与诊断下划线的完整显示 |

## 构建与维护工具

| 软件或能力 | 级别 | 用途 |
| --- | --- | --- |
| C compiler、`make` 及标准构建环境 | 功能必需 | Tree-sitter parser 或插件原生构建路径 |
| Python 3 | 维护 | 运行 `scripts/check-docs.py`；也是当前文档架构唯一额外检查运行时 |
| `git diff --check` | 维护 | 检查空白错误和冲突标记 |
| Headless Neovim | 维护 | Lua/startup 验证；必须同时审阅输出和退出码 |

旧 README 中的 Cargo、Node、全局 Prettier、Pyright、eslint_d、Black、Flake8、Go 工具等安装步骤
不再作为无条件清单保留。只有当声明的功能、语言开关或已确认的后续方案实际需要它们时，才在本文件
加入相应要求级别和提供者。

## 验证原则

- 先检查命令或 Mason provider 是否实际可用，再把功能记为通过。
- 系统 PATH 中缺少命令，不代表 Mason 路径中一定缺少；两者必须分开记录。
- 配置存在不代表功能启用，语言状态以 `languages.lua` 为准。
- 插件模块被 `pcall` 跳过不代表其用户快捷键安全可用。
- 新增依赖时先更新本文件，再实施代码，并在用户指南说明安装或降级行为。
