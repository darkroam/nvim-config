# 依赖清单

本文是外部运行时、命令和提供者的权威来源。插件名称和配置状态见 [`plugins.md`](plugins.md)，
版本档位见 [`compatibility.md`](compatibility.md)，安装顺序见
[`../guide/installation.md`](../guide/installation.md)。

要求级别含义：

- **核心**：当前配置的正常启动或基础命令直接依赖。
- **功能必需**：只有使用对应已启用功能时需要。
- **可选**：缺失时应只损失局部界面或辅助动作。
- **维护**：仅用于验证仓库，不属于编辑器运行时。

## 核心环境

| 软件或能力 | 级别 | 用途与边界 |
| --- | --- | --- |
| 受支持的 Neovim | 核心 | 完整和降级档位的准确版本、功能与实测状态只在兼容性文档维护；Linux 官方 tarball 使用版本化用户目录，日常版本由 machine-local `profile.local` 和 `current` symlink 选择，不硬编码到仓库配置 |
| Git | 核心 | 固定版本 lazy.nvim bootstrap、锁定插件恢复和版本库功能 |
| `zsh` | 核心 | `vim.opt.shell` 的固定值，也是 ToggleTerm 和 `:!` 命令的 shell；缺失时 shell 功能失败 |
| 网络与 TLS 证书 | 功能必需 | 首次 Lazy bootstrap/插件恢复、Mason 和 Tree-sitter 下载；稳定离线编辑不应持续依赖网络 |
| UTF-8 locale 和真彩终端 | 功能必需 | 当前图标、诊断符号和 `termguicolors` 界面 |

## 插件和资源管理

| 提供者 | 管理内容 | 仓库边界 |
| --- | --- | --- |
| lazy.nvim | `lua/darkroam/plugins/*.lua` 中的插件 | manager bootstrap commit 固定在 `lazy.lua`；插件 commit 固定在 tracked `lazy-lock.json`；checkout 不跟踪 |
| Mason | 基础档位的 `stylua`、`clang-format`；LSP 档位的 `lua-language-server`、`clangd` 和可选 `gopls`；Tree-sitter 档位的 `tree-sitter-cli` | 下载到 Mason data 目录，不跟踪；会把自己的 `bin` 加入 Neovim PATH；由用户显式 `:DarkroamBootstrap` 统一处理 |
| Tree-sitter | 语言开关选中的 parser | 0.12 parser 安装到 `stdpath("data")/treesitter-0.12`，不与 0.10 的公共 `site` runtime 混用；二进制和构建产物不跟踪 |
| LuaSnip / friendly-snippets | snippet engine 和 snippet 集合 | 插件提供；仓库没有自定义 snippet 数据 |

lazy.nvim、Mason 和 Tree-sitter 的成功安装不能从仓库文件存在推断，必须在目标机器检查。锁文件不锁
Mason package 或 parser；旧 Packer `site/pack/packer/start` 目录也必须移出活动路径，避免绕过版本门槛。

## 语言工具链

语言启用状态和用户行为见 [`../guide/languages.md`](../guide/languages.md)。依赖层只定义 provider：

| 工具链 | LSP | Formatter | 其他要求 |
| --- | --- | --- | --- |
| Lua | Mason `lua-language-server`（配置名 `lua_ls`） | `stylua`，可由 Mason 提供 | `lua` Tree-sitter parser |
| C | Mason 或系统 `clangd` | Mason `clang-format`（Conform 同名） | C 编译工具链和 `c` parser |
| Emacs Lisp | 无 | 无 | `commonlisp` parser；`.el` 与 `.emacs` 使用 `lisp` filetype |
| Go（开关启用时） | `gopls` | Go 工具链的 `gofmt` | Go parser family；Go 不是当前核心依赖 |

`:DarkroamBootstrap` 只安装表中可由 Mason 管理且当前版本档位支持的项目，以及 Tree-sitter parser。
`clang-format` 与 `clangd` 是两个独立 Mason package；前者在基础档位即可提供 C 格式化，后者只在 LSP
档位加入计划。`gofmt` 和 C 编译工具链不会由命令安装：前者缺失时报告 `PARTIAL`，后者缺失时由 parser
安装结果暴露失败。命令不调用系统包管理器。

## 搜索、项目和 Git 功能

| 软件或能力 | 级别 | 用途与缺失行为 |
| --- | --- | --- |
| `rg` | 功能必需 | Telescope `live_grep`；缺失时 `,dd` 不可用 |
| `fd` 或 `fdfind` | 可选 | Telescope 文件枚举的高性能后端；具体 fallback 由 Telescope 决定 |
| Git 工作树 | 可选 | Gitsigns、Lualine branch/diff 和 Telescope 搜索的版本库行为 |

Neogit、git.nvim 和 Fugitive 当前不是已声明能力，不应为了遗留配置而写成安装要求。

## 终端和辅助命令

ToggleTerm 的仓库运行时依赖只有核心表中的 `zsh`。`:TermExec cmd="..."` 可以按用户要求启动任意外部
命令，但该入口不会让 Lazygit、Node、ncdu、htop、Python 或其他临时目标自动成为仓库依赖；缺失行为
属于该次命令调用。仓库不提供这些工具的全局 Lua helper、专用 user command 或按键，也不把 `python`
别名当作 `python3` 的替代。

## UI、字体和剪贴板

| 软件或能力 | 级别 | 用途与边界 |
| --- | --- | --- |
| Nerd Font 或兼容图标字体 | 可选 | Web-devicons、Lualine、Telescope 和补全菜单图标；缺失时可能显示方框 |
| 系统剪贴板 provider | 功能必需 | `clipboard=unnamedplus`；X11 常用 `xclip`/`xsel`，Wayland 常用 `wl-copy`，平台也可使用原生 provider |
| 支持真彩和 undercurl 的终端 | 可选 | Neosolarized 与诊断下划线的完整显示 |

2026-07-19 的 X11 `st` 实机样本中，Neovim 0.12.3 把 clipboard provider 解析为 `xclip`，实际通过
Neovim 到 X11 和 X11 到 Neovim 的双向哨兵传递。Fontconfig 可取得覆盖所需私用区字形的
`Maple Mono NF CN`；活动 `st` 的 X resource 虽仍是通用 `monospace:size=10`，目标窗口截图中的
Web-devicons、Telescope prompt、Lualine/诊断符号和中文均可显示，没有方框或明显宽度错位。该实测
只证明当前 X11、Fontconfig 和 `st` 组合，不能降低其他机器仍需 provider 与字体的依赖级别。

## 构建与维护工具

| 软件或能力 | 级别 | 用途 |
| --- | --- | --- |
| C compiler、`make` 及标准构建环境 | 功能必需 | Tree-sitter parser 或插件原生构建路径 |
| `tar`、`curl` | 功能必需 | nvim-treesitter `main` 下载和解包 parser source |
| `tree-sitter` CLI 0.26.1+ | 功能必需 | nvim-treesitter `main` parser 生成；可由 Mason 的 `tree-sitter-cli` 提供 |
| StyLua | 维护 | `scripts/check-lua-format.py` 的格式和 AST provider；可来自 `STYLUA`、PATH 或当前 XDG data 的 Mason，当前以 2.5.2 实测；缺失时必须记为未验证 |
| Python 3 | 维护 | 运行文档、Lua 格式检查器和离线矩阵驱动器 |
| `git diff --check` | 维护 | 检查空白错误和冲突标记 |
| Headless Neovim | 维护 | Lua/startup 验证和兼容矩阵；必须同时审阅输出、专用日志和退出码 |

旧 README 中的 Cargo、Node、全局 Prettier、Pyright、eslint_d、Black、Flake8、Go 工具等安装步骤
不再作为无条件清单保留。只有当声明的功能、语言开关或已确认的后续方案实际需要它们时，才在本文件
加入相应要求级别和提供者。

## 验证原则

- 先检查命令或 Mason provider 是否实际可用，再把功能记为通过。
- 系统 PATH 中缺少命令，不代表 Mason 路径中一定缺少；两者必须分开记录。
- 配置存在不代表功能启用，语言状态以 `languages.lua` 为准。
- 插件模块被 `pcall` 跳过不代表其用户快捷键安全可用。
- `cond=false` 只保证插件不加载；data 目录中仍可能存在其 checkout，不能据此判断功能处于活动状态。
- 新增依赖时先更新本文件，再实施代码，并在用户指南说明安装或降级行为。
