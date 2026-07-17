# Neovim 使用指南

## 当前支持基线

**Neovim 0.12.3** 是完整支持和主要验证版本。Neovim 0.10/0.11 可以使用同一配置，但会根据当前
锁定插件的最低版本自动降低能力：

| Neovim | 可用档位 |
| --- | --- |
| 0.12.3 | LSP、Telescope、Tree-sitter/Textobjects 和基础插件完整启用 |
| 0.11.7+ | LSP、Telescope 和基础插件；当前 Tree-sitter 栈禁用 |
| 0.11.3–0.11.6 | LSP 和基础插件；当前 Telescope、Tree-sitter 栈禁用 |
| 0.11.0–0.11.2 | 基础编辑插件；当前 LSP、Telescope、Tree-sitter 栈禁用 |
| 0.10.x | 基础编辑插件；当前 LSP、Telescope、Tree-sitter 栈禁用 |

版本被禁用的插件不会加载，其仓库快捷键也不会创建。0.11 档位目前是按上游最低版本设计的兼容目标，
在取得对应二进制完成验证前不视为已经实测。

基础使用至少需要 Git 和 `zsh`。首次安装插件、LSP server 和 parser 需要网络。完整依赖及可选项见
[`../project/dependencies.md`](../project/dependencies.md)。

## 安装

先备份原有 Neovim 配置和 data 目录，再执行：

```sh
git clone https://github.com/darkroam/nvim-config ~/.config/nvim
nvim
```

首次启动会尝试下载代码中固定 commit 的 lazy.nvim，并按 `lazy-lock.json` 恢复插件。完成后可运行：

```vim
:Lazy
:Lazy restore
```

随后可用以下入口检查状态：

```vim
:checkhealth
:Mason
:ConformInfo
:Telescope
```

Neovim 0.12 使用 `:lsp` 和 `:checkhealth vim.lsp` 查看 LSP；0.11 可使用插件当时提供的相应命令。
`:Telescope` 只在 0.11.7+ 存在。首次准备 LSP server 时显式执行 `:LspInstall`；Mason-LSPConfig 此时才
刷新 registry 并处理语言表中的 `lua_ls`、`clangd`。不要随意执行 `:Lazy update`：更新锁文件后必须
重新验证所有支持档位。

从旧 Packer 配置迁移时，`stdpath("data")/site/pack/packer/start` 中的插件必须先备份移出活动路径，
否则 Neovim 会绕过 Lazy 的版本条件自动加载它们。旧配置位于公共 `data/site` 的 parser 也应迁入
0.12 专用目录或重新安装；0.10/0.11 档位会主动从 runtimepath 移除公共 `data/site`，防止读取 ABI 15
parser。该目录是机器状态，不应加入仓库。

## 启动后的主要界面

- Colorscheme 是 Neosolarized，状态栏由 Lualine 提供。
- `,e` 打开 NvimTree；LSP buffer 中同一按键会被局部映射覆盖为当前行诊断浮窗。
- Tab 与 Shift-Tab 在 Bufferline 的 tab 模式中切换。
- 在 0.11.7+，`,rr` 搜索文件，`,dd` 使用 ripgrep 搜索文本，`,xf` 打开 Telescope file browser。
- `,xc` 打开浮动 ToggleTerm，使用配置中的 `zsh`。
- `,ff` 切换 ZenMode。

完整仓库自定义按键见 [`keybindings-zh.md`](keybindings-zh.md)。上游插件默认按键不在本文重复列出。

## 语言能力

语言状态由 `lua/darkroam/languages.lua` 统一控制：

| 语言键 | 状态 | 当前能力 |
| --- | --- | --- |
| `lua` | 启用 | LuaLS、cmp、诊断、`stylua` 保存格式化、Lua Tree-sitter |
| `c` | 启用 | clangd、cmp、诊断、`clang_format`/LSP fallback、C Tree-sitter |
| `elisp` | 启用 | `.el`/`.emacs` 的 `lisp` filetype 与 `commonlisp` parser；无 LSP/formatter |
| `go` | 禁用 | 配置保留但不启用 `gopls`、`gofmt` 或 Go parser family |

表中是 0.12 完整档位的能力。旧版仍保留语言意图，但受兼容门槛影响的 LSP/Tree-sitter provider 不会
加载。不能只安装一个工具就改变开关；新增或关闭语言时，应先提出方案，确认 LSP、Mason、Conform、
Tree-sitter、依赖和本文如何同步，再修改配置。

## 补全、诊断和格式化

插入模式下：

- Ctrl-Space 主动打开补全；Ctrl-n/Ctrl-p 选择候选；Enter 只确认明确选中的候选。
- Tab 依次尝试下一候选、snippet 展开/跳转、触发补全，最后才插入普通 Tab。
- Shift-Tab 选择上一候选或向前跳转 snippet。

在 0.11.3+，LSP attach 后提供 definition、reference、hover、rename、code action、诊断跳转和手动
格式化。保存时 Conform 根据 filetype 尝试 formatter，并以 LSP 作为 fallback。

Mason-LSPConfig 已配置 `ensure_installed` 的 `lua_ls` 和 `clangd`，但关闭了自动 LSP enable；只有语言表
选中的 server 会启动。StyLua 是 formatter，不作为 LSP 启动。`clang-format` 是独立命令，
`:ConformInfo` 显示无可用 formatter 时应核对 provider，不要把 `clangd` 等同于 `clang-format`。

## Tree-sitter parser

0.12 的 nvim-treesitter `main` 不在普通启动中自动联网安装 parser，并使用独立
`stdpath("data")/treesitter-0.12`，防止新版 parser ABI 影响共享 data root 的 0.10。新机器在
`:Lazy restore` 完成后显式执行：

```vim
:DarkroamTSInstall
```

该命令根据 `languages.lua` 生成当前 parser 列表；也可直接执行 `:TSInstall lua c commonlisp`。插件升级后
执行 `:TSUpdate`。该路径需要 `tar`、`curl`、C compiler 和 `tree-sitter` CLI 0.26.1+。
0.11 及以下没有当前 Tree-sitter plugin 和 `af`/`if` Textobjects，仍可使用 Neovim 的 filetype 与
传统 syntax 能力。

## 搜索与项目目录

在 0.11.7+，Telescope 提供文件、文本、buffer、帮助、诊断和按键查询。`live_grep` 依赖 `rg`；文件
搜索在存在 `fd` 或 `fdfind` 时更完整。配置不再自动改变项目目录；需要时使用 `,cd` 切到当前文件目录。
旧版不会创建 Telescope 的仓库按键。

NvimTree 与 Telescope file browser 是两个独立入口：前者适合持续文件树，后者适合当前 buffer
目录的临时浏览。

## Git 功能

当前仓库明确提供 Gitsigns 和 Lualine 的 Git 信息。Neogit、git.nvim 和 Fugitive 没有声明；原 `,gg`
失效按键和 Lualine Fugitive extension 已删除。不应依靠 data 目录中残留插件判断仓库能力。

## 常见故障

### 旧版没有 LSP、Telescope 或 Tree-sitter 命令

先运行 `:version` 并核对本页兼容矩阵。若版本低于对应门槛，这是主动降级，不是 bootstrap 失败；
不能通过反复执行 `:Lazy restore` 绕过插件的最低 Neovim 版本。

### Telescope 提示至少需要 Neovim 0.11

正常情况下 0.11.6 及以下不会加载当前 Telescope。若仍出现该错误，优先检查旧 Packer start package
是否还在活动 packpath，并记录 Neovim、插件 commit 和完整输出。

### `:!` 或 ToggleTerm 无法启动

运行环境必须能找到 `zsh`。当前配置没有自动回退到 `sh`/`bash`；如果 shell 功能失败，先用
`:set shell?` 和系统的 `command -v zsh` 核对实际解析结果。

### `,gg`、`,md` 或 Markdown table 按键不再存在

这些 provider 未声明，原失效按键已经删除。若需要恢复 Neogit、Markdown Preview 或 TableMD，应按
新插件方案同时恢复声明、配置、版本门槛和用户文档。

### 系统 shell 找不到 LuaLS、clangd 或 StyLua

Mason 可以只在 Neovim 运行环境中加入自己的 `bin`。用 `:Mason` 和 `:ConformInfo` 检查，不要只用
登录 shell 的 `command -v` 下结论；反之也不能因为 Mason package 目录存在就假定 server 已成功启动。

## 修改配置

本仓库使用方案确认、文档先行、实现、验证、提交的顺序。任何语言、插件、按键、依赖或版本调整都先
参考 [`../project/maintenance-policy.md`](../project/maintenance-policy.md) 和
[`../planning/change-template.md`](../planning/change-template.md)。
