# 架构与设计

## 目的与读者

本文面向维护者和自动化代理，说明本仓库的结构、启动顺序、责任边界和语言能力模型。它不代替
日常使用说明；用户操作见 [`../user/usage-zh.md`](../user/usage-zh.md)，具体快捷键见
[`../user/keybindings-zh.md`](../user/keybindings-zh.md)。

## 仓库边界

本仓库只跟踪可复用的 Neovim 配置。以下内容是运行时或机器状态，不属于仓库：

- `stdpath("data")` 下的 Packer 插件、Mason 软件包和 Tree-sitter parser；
- `stdpath("state")` 与 `stdpath("cache")` 下的日志、shada、缓存和临时状态；
- 会话、凭据、个人项目历史以及工具下载产物；
- 由外部包管理器安装的编译器、语言运行时、字体和剪贴板程序。

插件声明目前没有 commit pin 或锁文件，因此仓库能够复现配置意图，但不能单独复现某一天的完整
插件树。该差距记录在 [`../planning/todo.md`](../planning/todo.md)。

## 目录和所有权

| 路径 | 职责 |
| --- | --- |
| `init.lua` | 固定核心模块加载顺序，并加载少量 OS 专用选项 |
| `lua/darkroam/options.lua` | 编辑器选项和仓库自定义 autocommand |
| `lua/darkroam/keymaps.lua` | 插件无关的全局按键及指向插件命令的历史按键 |
| `lua/darkroam/plugins.lua` | Packer bootstrap 和直接插件声明的唯一来源 |
| `lua/darkroam/languages.lua` | LSP、Mason、Conform 和 Tree-sitter 共用的语言开关 |
| `lua/darkroam/colorscheme.lua` | 活动 colorscheme 及基础 UI 颜色选项 |
| `lua/darkroam/impatient.lua` | 可选的 `impatient.nvim` profiling |
| `lua/darkroam/macos.lua`、`lua/darkroam/windows.lua` | 平台剪贴板选项 |
| `plugin/lspconfig.lua` | LSP capability、诊断、buffer-local 映射和 server 配置 |
| `plugin/lspsaga.rc.lua` | 未声明 Lspsaga 的遗留可选配置；当前不会生效 |
| `after/plugin/*.lua` | 已加载 start plugin 的后置配置，或明确保留的禁用/遗留钩子 |
| `ftdetect/emacs-lisp.lua` | 将 `.el` 与 `.emacs` 识别为 `lisp` filetype |
| `docs/project/` | 稳定架构、依赖、插件事实和维护政策 |
| `docs/planning/` | 审计证据、活动工作、恢复条件和完成历史 |
| `docs/user/` | 自洽的安装、使用、排障和快捷键资料 |
| `scripts/check-docs.py` | 文档结构和源码—文档关系的只读检查器 |

插件文件的逐项归属和生效状态由 [`plugins.md`](plugins.md) 维护。

## 启动和加载顺序

`init.lua` 按以下顺序加载核心模块：

```text
darkroam.options
  -> darkroam.keymaps
  -> darkroam.plugins
  -> darkroam.colorscheme
  -> darkroam.impatient
  -> darkroam.macos 或 darkroam.windows（按平台）
```

关键关系如下：

1. `options.lua` 先设置编辑器全局状态。
2. `keymaps.lua` 在插件配置前创建全局映射；其中部分历史映射即使命令提供者缺失也会存在。
3. `plugins.lua` 在 `stdpath("data")/site/pack/packer/start/packer.nvim` 缺失时使用 Git bootstrap，
   然后向 Packer 注册全部直接插件。
4. `colorscheme.lua` 尝试启用 `neosolarized`；缺失时只通知并返回，不阻止其余初始化。
5. Neovim 的标准 runtime 阶段随后执行 `plugin/*.lua`，再执行 `after/plugin/*.lua`。

绝大多数插件配置以 `pcall(require, ...)` 开始，因此未安装插件通常只会让对应配置返回。但这不等于
所有指向该插件的全局按键都会消失，也不能保护已经成功 `require`、但调用了不兼容 API 的路径。

## 语言能力模型

`lua/darkroam/languages.lua` 是语言状态的唯一源码来源。文档、LSP、Mason、Conform 和
Tree-sitter 必须保持下表一致：

| 语言键 | 状态 | LSP 与 Mason | 格式化 | Tree-sitter / filetype |
| --- | --- | --- | --- | --- |
| `lua` | 启用 | `lua_ls` | `stylua` | `lua` |
| `c` | 启用 | `clangd` | `clang_format` | `c` |
| `elisp` | 启用 | 无 | 无 | `commonlisp` parser 注册到 `lisp` |
| `go` | 禁用 | 启用时使用 `gopls` | 启用时使用 `gofmt` | 启用时加载 `go`、`gomod`、`gosum`、`gowork` |

开关的消费关系是：

```text
languages.lua
  |-- plugin/lspconfig.lua             选择 vim.lsp.enable() 的 server
  |-- after/plugin/mason.rc.lua        选择 ensure_installed server
  |-- after/plugin/conform.rc.lua      选择 formatters_by_ft
  `-- after/plugin/treesitter.rc.lua   选择 parser 和 filetype
```

Emacs Lisp 当前只有 filetype 与 Tree-sitter 语法能力，没有 LSP 或 formatter。Go 配置保留但关闭；
不能仅依据配置代码存在就把 Go 写成已启用功能。

## LSP、诊断和格式化

`plugin/lspconfig.lua` 为 `lua_ls`、`clangd`、`gopls` 建立配置，然后只启用语言开关选中的 server。
它使用 Neovim 0.11 的 `vim.lsp.config()` 和 `vim.lsp.enable()`，因此运行基线是 Neovim 0.11+。

LSP attach 后建立 buffer-local 导航、重命名、code action、诊断和格式化按键。buffer-local
`<leader>e` 会在 LSP buffer 中覆盖全局 NvimTree `<leader>e`；这是当前行为，不应在用户文档中
隐藏。

Mason 负责所选 LSP server 的安装意图，但外部 formatter 仍必须由 Mason 或系统路径实际提供。
Conform 按保存触发格式化并允许 LSP fallback。`clang_format` 的声明不等价于 `clang-format`
已经安装。

## 编辑、导航和界面

- `nvim-cmp`、LuaSnip 和 friendly-snippets 提供插入补全和 snippet 跳转。
- Telescope 与 file-browser 承担文件、文本、buffer、帮助、诊断和项目浏览。
- NvimTree 是独立文件树；project.nvim 可按版本库或项目标志改变当前目录。
- Bufferline 使用 tab 模式，Lualine 显示 mode、branch、diff、诊断、文件和位置。
- ToggleTerm 使用 `vim.o.shell`，所以全局 `shell=zsh` 也决定浮动终端和 `:!` 命令的 shell。
- Neosolarized/Colorbuddy 是活动主题；Tokyonight 文件只保留未生效变量。
- Gitsigns 是唯一已声明的 Git UI 插件；Neogit、git.nvim 和 Fugitive 集成当前没有完整提供者。

## Tree-sitter 与 filetype

Tree-sitter parser 集合由语言开关生成，`auto_install=false`，但 `ensure_installed` 和 Packer 的更新
hook 仍可能在安装或同步期间产生下载和编译行为。旧版 `nvim-treesitter.configs` 可用时采用其
配置；新版入口可用时使用 `nvim-treesitter.setup()` 并在 `FileType` 事件启动高亮。

`ftdetect/emacs-lisp.lua` 把 Emacs Lisp 统一为 `lisp`，随后把 `commonlisp` parser 注册给该
filetype。这是有意的兼容映射，而不是完整的 Common Lisp 开发环境声明。

## 状态、可选能力和失败边界

- 插件、server、parser 和 formatter 缺失时，必须区分“配置被保护后跳过”和“用户按键仍指向
  不存在命令”。
- `pcall(require, ...)` 只处理模块缺失或加载异常；加载后的 API 不兼容仍会中断对应配置文件。
- Packer bootstrap、Mason 安装、Tree-sitter 安装和插件更新需要网络，不能作为离线启动成功的
  隐含条件。
- Headless Neovim 可能在输出 startup error 后仍返回退出码 0；验证必须同时检查标准错误内容。
- 当前机器和插件树的时间点事实见
  [`../planning/repository-audit.md`](../planning/repository-audit.md)，不得把它们误写成跨机器保证。

## 设计与维护规则

- 先按 [`maintenance-policy.md`](maintenance-policy.md) 提案并获得确认，随后先更新文档再改行为。
- 语言状态只由 `languages.lua` 决定；新增消费方必须加入上面的关系和一致性检查。
- 插件声明只放在 `plugins.lua`；配置文件、命令、按键和依赖必须在 `plugins.md` 有明确状态。
- 可选插件缺失不得破坏无关编辑能力；不可用按键必须删除、保护或在用户文档中明确标注。
- 外部命令的要求级别和提供者只在 `dependencies.md` 定义，其他文档只链接或描述行为。
- 不把下载插件、Mason 包、parser、日志、缓存、session 或本机凭据纳入仓库。
- 任何文档变更提交前都运行 `python3 scripts/check-docs.py`，并检查链接、路径、语言表、源码覆盖和
  planning 状态分工。
