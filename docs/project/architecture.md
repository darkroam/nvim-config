# 架构与设计

## 目的与读者

本文面向维护者和自动化代理，说明本仓库的结构、启动顺序、兼容性模型、责任边界和语言能力。
日常使用见 [`../user/usage-zh.md`](../user/usage-zh.md)，具体快捷键见
[`../user/keybindings-zh.md`](../user/keybindings-zh.md)。

## 支持模型

仓库采用“一个配置、一个插件锁文件、多个运行能力档位”：

| Neovim | 档位 | LSP | Telescope | Tree-sitter |
| --- | --- | --- | --- | --- |
| 0.12.3 | 主路径、完整功能 | 启用 | 启用 | `main` 新 API 与 Textobjects 启用 |
| 0.11.7+ | 降级兼容 | 启用 | 启用 | 当前 `main` 栈禁用 |
| 0.11.3–0.11.6 | 降级兼容 | 启用 | 当前锁定版本禁用 | 当前 `main` 栈禁用 |
| 0.11.0–0.11.2 | 基础编辑 | 当前 nvim-lspconfig 禁用 | 禁用 | 禁用 |
| 0.10.x | 基础编辑 | 当前 nvim-lspconfig 禁用 | 禁用 | 禁用 |

“兼容”首先保证启动不执行已知不兼容插件、基础编辑路径可用，不表示旧版拥有与 0.12.3 相同的功能。
0.12.3 和本机 0.10.4 有实际 headless/runtime 验证；完整 GUI、剪贴板和人工键入体验仍按 planning
状态记录。0.11 各档位在获得对应二进制前是配置设计目标，不能写成已经运行验证。

`lua/darkroam/compat.lua` 是版本门槛的唯一源码。当前能力门槛为：

- LSP 配置栈：Neovim 0.11.3；
- Telescope：Neovim 0.11.7；
- nvim-treesitter `main` 与配套 Textobjects：Neovim 0.12.0。

Lazy spec 使用 `cond` 查询能力，不在旧版加载插件代码。插件相关快捷键放在同一 spec 的 `keys` 或
插件配置中，因此 provider 被禁用时不会留下仓库创建的失效映射。

## 仓库边界

本仓库只跟踪可复用的 Neovim 配置：

- lazy.nvim bootstrap 固定 commit，`lazy-lock.json` 固定其管理的插件 commit；
- `stdpath("data")` 下的 lazy.nvim checkout、插件、Mason 软件包和 Tree-sitter parser 不跟踪；
- `stdpath("state")`、`stdpath("cache")` 下的日志、shada、缓存和临时状态不跟踪；
- 会话、凭据、项目历史、编译产物以及外部工具下载不跟踪。

一个 `lazy-lock.json` 不能同时把同一插件锁到多个分支。因此 0.11 不自动改用 nvim-treesitter
`master`，而是禁用 0.12 的 `main` 栈。若以后要求旧版完整 Tree-sitter，必须另行确认独立 data root、
独立 lockfile 和独立验证矩阵，不能在当前档位内暗中切换 commit。

## 目录和所有权

| 路径 | 职责 |
| --- | --- |
| `init.lua` | 启用 Lua loader，固定核心模块加载顺序，并选择 OS 专用选项 |
| `lua/darkroam/options.lua` | 编辑器选项和命名 augroup 的仓库自定义 autocommand |
| `lua/darkroam/keymaps.lua` | 仅保存插件无关的全局按键 |
| `lua/darkroam/languages.lua` | LSP、Mason、Conform 和 Tree-sitter 共用的语言开关 |
| `lua/darkroam/compat.lua` | Neovim 版本比较、功能门槛和当前能力查询 |
| `lua/darkroam/lazy.lua` | 固定 lazy.nvim bootstrap commit、锁文件路径和 spec import |
| `lua/darkroam/plugins/editor.lua` | 基础编辑、注释、surround、autopairs 与 Toggle Alternate |
| `lua/darkroam/plugins/ui.lua` | 主题、图标、文件树、状态栏、bufferline、终端和 ZenMode |
| `lua/darkroam/plugins/completion.lua` | nvim-cmp、LuaSnip、snippet 和补全 source |
| `lua/darkroam/plugins/lsp.lua` | Mason、LSP、诊断、原生 document highlight 与 Conform |
| `lua/darkroam/plugins/telescope.lua` | Telescope、file-browser 与相关按键 |
| `lua/darkroam/plugins/treesitter.lua` | 0.12 parser/filetype、内置高亮、缩进和 Textobjects |
| `lua/darkroam/plugins/git.lua` | Gitsigns |
| `lua/darkroam/macos.lua`、`lua/darkroam/windows.lua` | 平台剪贴板选项 |
| `ftdetect/emacs-lisp.lua` | 将 `.el` 与 `.emacs` 识别为 `lisp` filetype |
| `docs/project/` | 稳定架构、依赖、插件事实和维护政策 |
| `docs/planning/` | 审计证据、活动工作、恢复条件和完成历史 |
| `docs/user/` | 自洽的安装、使用、排障和快捷键资料 |
| `scripts/check-docs.py` | 文档结构、Lazy 声明和源码—文档关系的只读检查器 |

不再使用仓库根的 `plugin/*.lua` 或 `after/plugin/*.lua` 配置入口。活动插件的声明、加载条件、配置与
仓库按键由对应 spec 共同拥有，避免配置文件在 provider 被条件禁用时仍由 Neovim runtime 自动执行。

## 启动和加载顺序

```text
init.lua
  |-- vim.loader.enable()（API 存在时）
  |-- darkroam.options
  |-- darkroam.keymaps
  |-- darkroam.lazy
  |     |-- bootstrap/加载固定版本 lazy.nvim
  |     |-- 读取 lazy-lock.json
  |     `-- import darkroam.plugins.*
  `-- darkroam.macos 或 darkroam.windows（按平台）
```

加载策略：

- nvim-treesitter `main` 明确不支持 lazy-load，在兼容版本上使用 `lazy=false`；
- 主题在启动阶段加载，避免界面先使用默认主题再切换；
- NvimTree、Telescope、ToggleTerm 和 ZenMode 由命令或按键加载；
- cmp/autopairs 在 `InsertEnter` 加载，Gitsigns 在文件事件加载；
- LSP 在兼容版本的启动阶段建立 config/enable，确保命令行直接打开的首个文件不会错过 FileType attach；
- Mason UI 按命令加载，但在 LSP 路径上先于 server enable 建立 PATH；
- plugin dependency 由 Lazy spec 明确声明，不依靠本机残留的 start package。

Lazy 重置 runtimepath 前会捕获 Neovim 自带 `parser/lua.so` 的非 data runtime 根并显式保留，避免发行版
同时存在 `/usr/lib64`、但 parser 实际位于另一 lib 目录时丢失内置 parser。该探测来自当前 runtime，
不硬编码某个操作系统路径。0.11 及以下还会从活动 runtimepath 移除 machine-local 公共 `data/site`；
当前配置的插件由 Lazy 管理、0.12 parser 已隔离，因此该档位不需要公共 site，也不会误读遗留 ABI 15
parser。

首次缺少 lazy.nvim 时，bootstrap 只负责取得代码中固定的 manager commit；失败会给出明确错误并停止
插件层，不应破坏已经设置的核心选项和插件无关按键。普通启动不自动执行插件更新、Mason 安装或
Tree-sitter parser 下载。

## 语言能力模型

`lua/darkroam/languages.lua` 是语言状态的唯一源码：

| 语言键 | 状态 | LSP 与 Mason | 格式化 | Tree-sitter / filetype |
| --- | --- | --- | --- | --- |
| `lua` | 启用 | `lua_ls` | `stylua` | `lua` |
| `c` | 启用 | `clangd` | `clang_format` | `c` |
| `elisp` | 启用 | 无 | 无 | `commonlisp` parser 注册到 `lisp` |
| `go` | 禁用 | 启用时使用 `gopls` | 启用时使用 `gofmt` | 启用时加载 Go parser family |

消费关系是：

```text
languages.lua
  |-- plugins/lsp.lua          选择 LSP、Mason server 和 formatter
  `-- plugins/treesitter.lua   选择 parser 和 filetype
```

版本门槛优先于语言开关：例如 Lua 开关在 0.10 仍为启用，但新版 LSP 和 Tree-sitter provider 因兼容
档位禁用；这不等于配置偷偷关闭了 Lua 语言意图。

## LSP、Mason 和格式化

Neovim 0.11.3+ 使用 `vim.lsp.config()` 和 `vim.lsp.enable()`。nvim-lspconfig 提供 server config，
仓库只配置并启用语言表选中的 `lua_ls`、`clangd` 和可选 `gopls`。

Mason-LSPConfig 设置 `automatic_enable=false`，只在显式调用 `:LspInstall`/`:LspUninstall` 时加载并
处理语言表生成的 `ensure_installed` 意图；普通 LSP attach 不刷新远端 registry。它不得扫描 Mason 中
所有软件包并自动作为 LSP 启动。StyLua 是 Conform formatter，不是本仓库启用的 LSP。

命名 `LspAttach` augroup 负责 buffer-local 导航、重命名、code action、诊断和格式化按键。
Conform 是格式化入口，`lsp_format="fallback"` 只在没有可用 formatter 时回退 LSP。LuaLS 的
formatting capability 保持关闭，避免与 StyLua 重复。

Neovim 0.12 使用内置 `:lsp` 和 `:checkhealth vim.lsp`；不能把没有旧 `:LspInfo` 命令误判为故障。
0.10 和 0.11.0–0.11.2 不维护 legacy `require("lspconfig")` 或手写 `vim.lsp.start()` fallback。

## Tree-sitter 与 Textobjects

0.12 路径使用 nvim-treesitter `main` 的新接口：`require("nvim-treesitter").setup()` 配置安装目录，
Neovim 内置 `vim.treesitter.start()` 在选定 filetype 启动高亮，并按需使用新版 indent expression。
`commonlisp` parser 显式注册到 `lisp` filetype。

Parser 安装与更新是显式维护操作：0.12 parser 使用版本专用的
`stdpath("data")/treesitter-0.12`，避免 ABI 15 二进制被共享 data root 中的 0.10 runtime 误加载。新机器
使用 `:DarkroamTSInstall` 按语言开关安装 parser（或直接使用 `:TSInstall`），插件升级后使用
`:TSUpdate`；普通启动不因 parser 缺失隐式联网。Textobjects 使用独立新版 setup，并显式建立
`af`/`if` 的 function outer/inner operator 与 visual 映射。

0.11 及以下不加载当前 Tree-sitter plugin 和 Textobjects。内置 Vim syntax、filetype detection 和
不依赖 Tree-sitter 的编辑能力仍可使用。

## 状态、失败边界和维护规则

- 锁文件只保证 Git plugin commit；Mason 包、parser、外部命令和 lazy.nvim data checkout 仍需实机检查。
- `cond=false` 的插件可保留在 data 目录，但不得加入 runtimepath 或执行配置。
- Packer 的旧 start package 目录会绕过 Lazy 条件加载，迁移时必须先备份移出活动 `packpath`。
- 旧版档位有意不消费 machine-local `data/site`；若用户另有依赖该目录的私有 runtime，必须另行设计
  版本专用路径，不能重新暴露 0.12 parser。
- Headless Neovim 可能打印 startup error 后返回 0；验证同时检查输出和退出码。
- 插件更新必须显式更新 lockfile，并重新执行 0.12.3、0.10.4 和可取得的 0.11 验证矩阵。
- 新增能力门槛时先修改 `compat.lua` 对应表和本文；不得在各 spec 内散落互相矛盾的版本判断。
- 外部依赖只在 [`dependencies.md`](dependencies.md) 定义，逐插件状态只在
  [`plugins.md`](plugins.md) 定义。
- 任何行为修改遵循 [`maintenance-policy.md`](maintenance-policy.md) 的方案确认、文档先行、联合验证
  和提交规则。

迁移回滚必须成套进行：恢复迁移前配置 commit，再把 Packer 备份恢复到原 `site/pack/packer`；或保持
当前 commit 并继续使用 Lazy。不得在当前 Lazy 配置下重新激活旧 start tree。`lazy/`、
`treesitter-0.12/` 和 Packer 备份都是 machine-local 状态，确认不再需要前不做破坏性删除。
