# Neovim 使用指南

## 当前支持基线

本配置使用 Neovim 0.11 的 LSP API，支持基线是 **Neovim 0.11+**。如果使用 0.10，当前会在 LSP、
Telescope 和 Mason-LSPConfig 路径报错；不要把能打开部分界面误认为完整启动成功。

基础使用至少需要 Git 和 `zsh`。首次安装插件、LSP server 和 parser 需要网络。完整依赖及可选项见
[`../project/dependencies.md`](../project/dependencies.md)。

## 安装

先备份原有 Neovim 配置和 data 目录，再执行：

```sh
git clone https://github.com/darkroam/nvim-config ~/.config/nvim
nvim
```

首次启动会尝试下载 Packer 并同步插件。完成后重启 Neovim；必要时运行：

```vim
:PackerSync
```

随后可用以下入口检查状态：

```vim
:checkhealth
:Mason
:LspInfo
:ConformInfo
:Telescope
```

Packer 当前没有锁文件；插件同步后若出现新的最低版本错误，先记录 Neovim 版本和完整 startup
output，不要反复同步并假定问题会自行消失。

## 启动后的主要界面

- Colorscheme 是 Neosolarized，状态栏由 Lualine 提供。
- `,e` 打开 NvimTree；LSP buffer 中同一按键会被局部映射覆盖为当前行诊断浮窗。
- Tab 与 Shift-Tab 在 Bufferline 的 tab 模式中切换。
- `,rr` 搜索文件，`,dd` 使用 ripgrep 搜索文本，`,xf` 打开 Telescope file browser。
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

不能只安装一个工具就改变开关。需要新增或关闭语言时，应先提出方案，确认 LSP、Mason、Conform、
Tree-sitter、依赖和本文如何同步，再修改配置。

## 补全、诊断和格式化

插入模式下：

- Ctrl-Space 主动打开补全；Ctrl-n/Ctrl-p 选择候选；Enter 只确认明确选中的候选。
- Tab 依次尝试下一候选、snippet 展开/跳转、触发补全，最后才插入普通 Tab。
- Shift-Tab 选择上一候选或向前跳转 snippet。

LSP attach 后提供 definition、reference、hover、rename、code action、诊断跳转和手动格式化。保存时
Conform 根据 filetype 尝试 formatter，并允许 LSP fallback。

Mason 已配置安装 `lua_ls` 和 `clangd`，但 `clang-format` 是独立命令。`:ConformInfo` 显示无可用
formatter 时，应先核对 provider，不要把 `clangd` 的存在自动等同于 `clang-format`。

## 搜索与项目目录

Telescope 提供文件、文本、buffer、帮助、诊断和按键查询。`live_grep` 依赖 `rg`；文件搜索在存在
`fd` 或 `fdfind` 时更完整。project.nvim 以 `.git`、Makefile、`package.json` 等 pattern 判断项目根并
可能改变当前目录。

NvimTree 与 Telescope file browser 是两个独立入口：前者适合持续文件树，后者适合当前 buffer
目录的临时浏览。

## Git 功能

当前仓库明确提供 Gitsigns 和 Lualine 的 Git 信息。Neogit、git.nvim 和 Fugitive 没有在 Packer 中
声明，因此：

- `,gg` 当前不可用；
- Lualine 的 Fugitive extension 不构成已支持功能；
- 不应依靠 data 目录中残留的旧插件判断另一台机器也能使用。

这些遗留入口将在单独方案中决定删除或恢复。

## 常见故障

### 出现 `vim.lsp.config` 或 `vim.lsp.enable` nil

先运行 `:version`。Neovim 0.10 没有当前配置使用的 0.11 API，需要执行已确认的版本升级或兼容方案，
不能通过重装同一批最新插件解决。

### Telescope 提示至少需要 Neovim 0.11

这是核心与插件版本不匹配，不是某个 Telescope 按键错误。记录 Neovim、插件 commit 和完整输出，
按维护流程处理版本基线。

### `:!` 或 ToggleTerm 无法启动

运行环境必须能找到 `zsh`。当前配置没有自动回退到 `sh`/`bash`；如果 shell 功能失败，先用
`:set shell?` 和系统的 `command -v zsh` 核对实际解析结果。

### `,gg`、`,md` 或 Markdown table 按键报未知命令/模块

这些是已记录的遗留按键，provider 当前未声明。它们不是安装完成后的保证能力；详见
[`../project/plugins.md`](../project/plugins.md)。

### 系统 shell 找不到 LuaLS、clangd 或 StyLua

Mason 可以只在 Neovim 运行环境中加入自己的 `bin`。用 `:Mason` 和 `:ConformInfo` 检查，不要只用
登录 shell 的 `command -v` 下结论；反之也不能因为 Mason package 目录存在就假定 server 已成功启动。

## 修改配置

本仓库使用方案确认、文档先行、实现、验证、提交的顺序。任何语言、插件、按键、依赖或版本调整都先
参考 [`../project/maintenance-policy.md`](../project/maintenance-policy.md) 和
[`../planning/change-template.md`](../planning/change-template.md)。
