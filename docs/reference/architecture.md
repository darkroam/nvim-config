# 架构与设计

## 目的与边界

本文面向维护者和自动化代理，说明仓库结构、启动顺序、模块关系和 machine-local 状态边界。准确版本
矩阵见 [`compatibility.md`](compatibility.md)，日常使用见
[`../guide/usage.md`](../guide/usage.md)，语言能力见
[`../guide/languages.md`](../guide/languages.md)。

仓库只跟踪可复用配置：

- lazy.nvim bootstrap commit 固定在代码中，插件 commit 固定在 `lazy-lock.json`；
- `stdpath("data")` 下的插件、Mason 软件包和 parser 不跟踪；
- `stdpath("state")`、`stdpath("cache")` 下的日志、shada、undo、swap 和缓存不跟踪；
- 会话、凭据、项目历史、编译产物和外部工具下载不跟踪。

## 目录和所有权

| 路径 | 职责 |
| --- | --- |
| `init.lua` | 启用 Lua loader，固定核心模块顺序，选择 OS 专用选项 |
| `lua/darkroam/options.lua` | 编辑器选项和仓库 autocommand |
| `lua/darkroam/keymaps.lua` | 插件无关的全局按键 |
| `lua/darkroam/languages.lua` | LSP、Mason、Conform 和 Tree-sitter 共用的语言开关 |
| `lua/darkroam/compat.lua` | 版本比较、功能门槛和能力查询 |
| `lua/darkroam/lazy.lua` | 固定 lazy.nvim、锁文件路径和 spec import |
| `lua/darkroam/bootstrap.lua` | 提前注册显式工具链 bootstrap 和退出 guard，生成版本化计划并汇总单次结果 |
| `lua/darkroam/plugins/editor.lua` | 基础编辑、注释、surround、autopairs 和 Toggle Alternate |
| `lua/darkroam/plugins/ui.lua` | 主题、图标、文件树、状态栏、bufferline、终端和 ZenMode |
| `lua/darkroam/plugins/completion.lua` | nvim-cmp、LuaSnip、snippet 和补全 source |
| `lua/darkroam/plugins/lsp.lua` | Mason、LSP、诊断、document highlight 和 Conform |
| `lua/darkroam/plugins/telescope.lua` | Telescope、file-browser 和相关按键 |
| `lua/darkroam/plugins/treesitter.lua` | parser、filetype、高亮、缩进和 Textobjects |
| `lua/darkroam/plugins/git.lua` | Gitsigns |
| `lua/darkroam/macos.lua` | macOS 剪贴板选项 |
| `lua/darkroam/windows.lua` | Windows 剪贴板选项 |
| `ftdetect/emacs-lisp.lua` | 将 `.el` 和 `.emacs` 识别为 `lisp` filetype |
| `docs/guide/` | 安装、使用、语言和按键的任务式指南 |
| `docs/reference/` | 架构、兼容性、依赖和插件的权威事实 |
| `docs/maintenance/` | 变更流程、roadmap 和精简历史 |
| `scripts/check-docs.py` | 离线验证文档合同及其与配置的静态关系 |
| `scripts/check-compat.py` | 用显式 Neovim 二进制和预恢复 Lazy data 编排离线兼容性矩阵 |
| `scripts/compat-smoke.lua` | 在真实 Neovim 进程内检查版本门槛、插件状态、命令、按键、基础触发和取消路径 |

不使用仓库根的 `plugin/*.lua` 或 `after/plugin/*.lua` 配置入口。活动插件的声明、加载条件、配置和仓库
按键由对应 Lazy spec 共同拥有，避免 provider 被禁用后仍由 runtime 自动执行配置。

## 启动顺序

```text
init.lua
  |-- vim.loader.enable()（API 存在时）
  |-- darkroam.options
  |-- darkroam.keymaps
  |-- darkroam.bootstrap.setup()（只注册命令和退出 guard）
  |-- darkroam.lazy
  |     |-- bootstrap/加载固定版本 lazy.nvim
  |     |-- 读取 lazy-lock.json
  |     `-- import darkroam.plugins.*
  `-- darkroam.macos 或 darkroam.windows（按平台）
```

首次缺少 lazy.nvim 时，manager bootstrap 只取得代码中固定的 commit；失败会停止插件层，但不会撤销
已经设置的核心选项和插件无关按键。普通启动不更新插件，也不自动安装 Mason 软件包或首次 parser；
`darkroam.bootstrap.setup()` 只依赖核心兼容/语言表，注册 `:DarkroamBootstrap` 和 `VimLeavePre` guard，
不加载 provider 或访问网络。它位于 Lazy 前，使 guard 的执行顺序早于 Mason terminator。

Lazy 重置 runtimepath 前会探测 Neovim 自带 `parser/lua.so` 的非 data runtime 根并显式保留，避免发行版
把 parser 放在不同 lib 目录时丢失内置 parser。降级档位还会移除公共 `data/site`，防止读取旧 Packer
start package 或不兼容 parser；原因和准确版本边界见兼容性文档。

## 插件加载策略

- nvim-treesitter `main` 在支持档位使用 `lazy=false`；
- 主题在启动阶段加载，避免界面先显示默认主题；
- NvimTree、Telescope、ToggleTerm 和 ZenMode 由命令或按键加载；
- cmp 和 autopairs 在 `InsertEnter` 加载，Gitsigns 在文件事件加载；
- LSP 在支持档位的启动阶段建立 config/enable，避免首个文件错过 FileType attach；
- Mason UI 按命令加载，但在 LSP 路径中先建立 Mason PATH；
- dependency 必须由 spec 声明，不依靠 data 目录残留的 start package。

准确插件入口和状态见 [`plugins.md`](plugins.md)。

## 语言消费关系

`lua/darkroam/languages.lua` 是语言状态的代码来源：

```text
languages.lua
  |-- plugins/lsp.lua          选择 LSP、Mason server 和 formatter
  |-- plugins/treesitter.lua   选择 parser 和 filetype
  `-- bootstrap.lua            生成当前档位的安装与外部依赖检查计划
```

用户表格只在 [`../guide/languages.md`](../guide/languages.md) 维护。兼容门槛优先于语言开关：语言意图
启用时，provider 仍可能因当前档位不满足而不加载。

## LSP、Mason 和格式化

支持 LSP 的档位使用 `vim.lsp.config()` 和 `vim.lsp.enable()`。Mason-LSPConfig 设置
`automatic_enable=false`，只在显式调用 `:LspInstall`/`:LspUninstall` 时加载并处理语言表生成的
`ensure_installed`；它不会把 Mason 中所有软件包自动作为 LSP 启动。

`vim.lsp.config()` 会递归合并 nvim-lspconfig 的 server definition；在传入配置中省略字段或赋 Lua
`nil` 不能删除上游已有键。clangd 因此在 `before_init` 边界清理实际 initialize payload 中的旧
`capabilities.offsetEncoding`，保留核心生成的 `capabilities.general.positionEncodings` 和其他上游
clangd 配置。cmp-nvim-lsp 的 completion capability 通过 `vim.tbl_deep_extend()` 叠加到核心表，而不是
把完整核心表误作该插件的扁平 override 参数。该边界不依赖 resolved config 缓存，重新 enable 也会
再次执行。

命名 `LspAttach` augroup 建立 buffer-local 导航、重命名、code action、诊断和格式化按键。Conform
是统一格式化入口，`lsp_format="fallback"` 只在没有可用 formatter 时回退 LSP。LuaLS formatting
capability 被关闭，避免与 StyLua 重复。基础档位的 StyLua 和 clang-format 都由 Mason 管理；后者与
LSP 档位的 clangd 是两个独立 package。

`:DarkroamBootstrap` 是用户显式调用的编排层。它先同步加载基础档位可用的 Mason，跳过已安装项，只有
存在缺项时才异步刷新 registry 和并发安装；Mason 全部完成后，完整档位才调用 nvim-treesitter Task
安装 parser。最终报告重新检查 Mason package 和对应可执行命令，并实际加载 parser 验证 ABI；托管
失败记为 `FAILED`，仅外部命令缺失记为 `PARTIAL`。每次运行只有一个 active report，完成和发布均为
幂等操作；提前注册的退出 guard 将其冻结为 `CANCELLED`，后续异步回调先检查 active identity，不能
进入新阶段或发布第二次结果。模块拒绝并发重复执行，并通过 `plan()`、`is_running()`、
`last_report()` 提供只读状态。

## Tree-sitter 与 Textobjects

完整档位使用 nvim-treesitter `main` 新接口设置 `stdpath("data")/treesitter-0.12`，由 Neovim 内置
`vim.treesitter.start()` 启动高亮，并按需使用新版 indent expression。`commonlisp` parser 显式注册到
`lisp` filetype。

Parser 安装是显式操作：使用 `:DarkroamTSInstall` 按语言开关安装，插件升级后使用 `:TSUpdate`。
Textobjects 独立 setup 并建立 `af`/`if` 映射。不支持该栈的档位仍保留 filetype 和传统 syntax。

## 状态与失败边界

- lockfile 只约束 Git plugin commit，不约束 Mason 包、parser 或系统命令；
- `cond=false` 的 checkout 可以留在 data 目录，但不得进入 runtimepath 或执行配置；
- command 存在、目录存在或进程退出码为零，都不能单独证明功能通过；
- headless 输出中的 `Error detected`、`E...`、traceback 或 provider error 均需判为失败；
- 一个 lockfile 不为同一插件自动切换多个分支；需要旧版完整功能时必须另行设计；
- 安装和回退见 [`../guide/installation.md`](../guide/installation.md)；
- 所有变更遵循 [`../maintenance/workflow.md`](../maintenance/workflow.md)。

## 自动兼容性验证

`scripts/check-compat.py` 不拥有二进制、插件或下载流程。调用者通过重复的
`--case VERSION=NVIM_PATH` 提供待测 Neovim，通过 `--data-home` 提供已经完整恢复并匹配
`lazy-lock.json` 的 data home。驱动器在启动前检查全部 checkout 和 commit；缺失或不一致时直接失败，
不会调用网络、Lazy restore、Mason、parser 安装或 build。

每个 case 使用临时 HOME、config/state/cache/runtime 和 data wrapper；仓库配置与只读意图的 Lazy
checkout 通过 symlink 接入，日志和其他运行状态留在临时目录。`scripts/compat-smoke.lua` 在进程内按
当前 `vim.version()` 检查集中门槛、Lazy spec、runtimepath、命令和仓库按键，并真实触发基础插件与
当前版本允许的 Telescope 路径。Python 驱动器同时检查进程状态、成功标记、完整输出和专用 Neovim
日志；`Error detected`、`E[0-9]{3,}:`、traceback、provider error 或非空内部日志都会令对应 case
失败。

该 smoke 证明启动和插件门槛，没有安装或启动语言 server，也不构建 parser，不替代真实 buffer、
formatter、GUI、字体、剪贴板或交互终端验证。准确命令和前置条件见安装指南，版本实测状态见兼容性
文档。
