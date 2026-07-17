# 仓库审计记录

- 审计日期：2026-07-17
- 代码基线：`eb0d224`（`main`，审计开始时与 `origin/main` 一致）
- 初始状态：工作树干净
- 范围：全部 tracked 配置、Git 历史摘要、参考文档结构、当前 Neovim 与本机可见依赖

## 目的与限制

本记录建立文档架构前的事实基线，用于区分仓库声明、实际代码路径和当前机器状态。审计只做读取和
诊断，没有修复运行配置、安装软件、联网更新插件或执行交互式 UI 测试。

沙箱限制 Mason 的部分异步文件操作，且当前会话不是完整的日常终端/GUI 会话。因此沙箱产生的
`EPERM` 只记为环境限制；能够直接定位到 Neovim API 或插件版本要求的错误则记为仓库兼容性事实。

## 仓库规模和结构

审计基线共 41 个 tracked 文件，其中 39 个 Lua 文件、1453 行 Lua，另有 `.gitignore` 和 30 行的
旧 README。配置分为：

- `init.lua` 和 `lua/darkroam/` 的核心选项、按键、插件、主题和语言开关；
- `plugin/` 的 LSP 与遗留 Lspsaga runtime 文件；
- `after/plugin/` 的插件后置配置；
- `ftdetect/` 的 Emacs Lisp filetype 规则。

仓库没有 CI、测试目录、版本锁文件、非 sample Git hook 或既有维护约束文件。Git 历史显示主要配置
形成于 2022 年，2026-06-25 又完成了精简、语言开关和 NullLS 到 Conform 的调整。

## 已确认的启动关系

1. `init.lua` 依次加载 options、keymaps、plugins、colorscheme、impatient，再按 OS 加载剪贴板选项。
2. Packer 的 start 目录是插件来源；缺失 Packer 时配置通过 Git clone bootstrap。
3. `plugin/lspconfig.lua` 和所有 `after/plugin/*.lua` 由 Neovim runtime 自动读取。
4. 大多数插件配置通过 `pcall(require, ...)` 在模块缺失时返回。
5. `languages.lua` 同时驱动 LSP enable、Mason ensure list、Conform formatter 和 Tree-sitter parser。

完整设计已迁入 [`../project/architecture.md`](../project/architecture.md)。

## Headless 启动结果

当前 `nvim --version` 是 `NVIM v0.10.4`。在隔离 state/cache 的 headless 启动中重现：

| 来源 | 关键错误 | 结论 |
| --- | --- | --- |
| `plugin/lspconfig.lua:98` | `attempt to call field 'config' (a nil value)` | 配置直接使用 Neovim 0.11 API，0.10 不兼容 |
| `telescope.nvim/plugin/telescope.lua` | `Telescope.nvim requires at least nvim-0.11` | 当前已安装 Telescope 上游版本要求 0.11 |
| `mason-lspconfig` automatic enable | `attempt to call field 'enable' (a nil value)` | 当前插件路径依赖 Neovim 0.11 的 LSP enable API |
| Mason async callback | `EPERM` | 沙箱文件操作限制，不能据此判断正常用户会话失败 |

该命令在打印前三类 startup error 后仍返回退出码 0。这证明以后不能只看 exit status；验证脚本或人工
检查必须同时审阅输出。

本机安装的相关插件提交日期为 2026 年，而 Packer 本身最后一个本机 commit 日期是 2023 年；仓库没有
记录或约束这些 commit。核心版本较旧、插件树较新正是当前可复现失败的直接组合。

## 语言与工具状态

代码中的状态是：

| 语言键 | 状态 | 审计结论 |
| --- | --- | --- |
| `lua` | 启用 | `lua_ls`、`stylua` 和 Lua parser 路径存在配置 |
| `c` | 启用 | `clangd` 和 C parser 存在配置；`clang-format` 是独立缺失项 |
| `elisp` | 启用 | 只有 `lisp` filetype 与 `commonlisp` parser，无 LSP/formatter |
| `go` | 禁用 | 代码保留 `gopls`、`gofmt` 与 parser 配置，但不会进入 enable/install 列表 |

当前 Mason packages 可见 `clangd`、`lua-language-server`、`stylua` 和 `tree-sitter-cli`。Mason `bin`
可见 `clangd`、`lua-language-server`、`stylua`、`tree-sitter`，但没有 `clang-format`。

当前审计 shell 中：

- Git、Python 3、Node、npm、C compiler、make、`fdfind`、Lazygit、htop 和 X11/Wayland 剪贴板工具
  至少有一个 provider 可见；
- `fish`、系统 `clangd`、`clang-format`、系统 `stylua`、Go、Cargo、`fd`、ncdu 和 `python`
  命令不可见；
- `rg` 在审计进程 PATH 中可见，但来源是调用环境，不应据此保证普通登录 shell 一定可用。

系统 PATH 与 Mason PATH 是不同层次；权威要求已整理到
[`../project/dependencies.md`](../project/dependencies.md)。

## 插件声明与配置差异

### 已声明且有活动路径

编辑基础、NvimTree、Bufferline、ToggleTerm、ZenMode、Neosolarized、Lualine、cmp/LuaSnip、
LSP/Mason/Conform、Telescope/project、Tree-sitter 和 Gitsigns 均有直接声明与配置或默认行为。

### 已声明但只部分消费

- `cmp-cmdline` 已声明，但没有 `cmp.setup.cmdline()`。
- `cmp-nvim-lua` 已声明，但活动 cmp source 列表没有 `nvim_lua`。
- `popup.nvim` 没有本地直接引用，可能只是历史或间接依赖。
- Lualine 请求 `fugitive` extension，但仓库没有声明 Fugitive。

### 禁用或遗留未声明

- Colorizer、Orgmode、ts-autotag 文件明确禁用，provider 未声明。
- Lspsaga、git.nvim、lsp-colors、lspkind、Neogit、Prettier、Tokyonight 有配置文件但无 provider。
- `,gg`、Markdown table 系列和 `,md` 仍会创建按键，但目标命令/模块没有声明。

完整逐项矩阵见 [`../project/plugins.md`](../project/plugins.md)。

## README 与代码不一致

旧 README 存在以下问题：

- 仍提供 `:NullLsInfo`，但 `plugin/null-ls.rc.lua` 已在 `eb0d224` 删除并改用 Conform。
- 列出大量无条件全局安装步骤，却没有区分当前语言开关、Mason provider 和可选工具。
- 没有最低 Neovim 版本、Packer 无锁风险、启动顺序、插件状态或维护流程。
- 没有说明 Lua/C/Elisp 启用而 Go 关闭。
- 没有记录固定 `shell=fish`，也没有说明缺失插件按键。

本轮已用新的 README 和分层文档替代这些陈旧声明，不修改运行代码。

## 其他维护风险

- `lua/darkroam/options.lua` 顶部执行无 group 的 `autocmd!`；
  `after/plugin/toggleterm.rc.lua` 也执行无 augroup 的 `autocmd! TermOpen ...`。两者可能清除其他来源的
  autocommand，需要单独提案重构。
- `formatoptions` 先追加 `r`，随后又执行 `set formatoptions-=cro`，注释与最终效果不直观。
- 部分 Lua 文件带 UTF-8 BOM，Gitsigns 文件没有遵循其他文件的 tab/双引号风格；当前机器又没有系统
  StyLua，格式化基线不完整。
- `impatient.enable_profile()` 每次启动启用 profiling；是否仍值得保留尚未评估。
- Packer bootstrap、Mason ensure 和 Tree-sitter 安装都可能产生网络或本机写入，启动测试必须隔离状态
  并避免污染仓库。

这些问题均进入 [`todo.md`](todo.md)，没有在文档架构变更中顺带修改。

## 审计结论

仓库的核心责任边界清楚，但运行基线、插件可复现性、遗留 provider 和用户说明此前没有统一来源。
新文档架构以 `project / planning / user` 分层，并通过 `scripts/check-docs.py` 将 tracked Lua、Packer
声明和语言开关关联到文档。

本审计只证明文档对当前已观察状态的描述；它不宣称 Neovim 0.10 启动正常，也不替代 Neovim 0.11
正常终端和交互 UI 下的后续验证。

## 文档架构验证结果

2026-07-17 在提交前完成：

- `python3 scripts/check-docs.py` 通过必需文件、README 导航、内部链接、源码所有权、Packer 声明、
  语言表、planning 职责和可移植路径检查；
- `python3 -m py_compile scripts/check-docs.py` 通过，bytecode 输出隔离到 `/tmp`；
- 使用 `nvim --clean --headless` 的 `loadfile()` 检查通过全部 39 个 Lua 文件；
- `git diff --cached --check` 通过，staged 范围只有获批的文档、README、`AGENTS.md` 和检查器；
- 隔离 state、cache 和 log 后的真实配置启动再次复现本记录的三类 Neovim 0.10/0.11 错误，且退出码
  仍为 0；没有把它记作运行通过；
- Neovim 0.11+ 正常用户会话、联网 bootstrap 和交互 UI 没有在本轮执行，继续作为 TODO。
