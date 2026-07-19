# 日常使用

本文说明当前配置的主要工作流。首次部署见 [`installation.md`](installation.md)，语言工具见
[`languages.md`](languages.md)，完整按键见 [`keymaps.md`](keymaps.md)，版本降级行为见
[`../reference/compatibility.md`](../reference/compatibility.md)。

## 启动后的界面

- Colorscheme 是 Neosolarized，状态栏由 Lualine 提供；
- `,e` 在普通和 LSP buffer 中都切换 NvimTree；
- `<Tab>` 与 `<S-Tab>` 在 Bufferline 的 tab 模式中切换；
- `,xc` 打开使用 Zsh 的浮动 ToggleTerm；
- `,ff` 切换 ZenMode。

插件按事件、命令或按键加载。某个插件已经下载不表示它已进入 runtimepath；版本条件不满足时，对应
命令和仓库按键不会创建。

## 文件、搜索和目录

NvimTree 适合持续浏览文件树。支持 Telescope 的档位还提供：

- `,rr` 搜索文件，包括隐藏文件但尊重 ignore；
- `,dd` 使用 `rg` 搜索文本；
- `,bb` 切换 buffer；
- `,xf` 浏览当前文件所在目录；
- `,kk` 查询按键。

配置不会随项目自动改变工作目录；需要时使用 `,cd` 切换到当前文件目录。Telescope file browser 与
NvimTree 是两个独立入口。

## 注释续写

仓库在每个 filetype 的内置 ftplugin 完成后移除 `formatoptions` 的 `c`、`r`、`o`：注释不会因
`textwidth` 自动换行，Insert mode 按 Enter 或 Normal mode 使用 `o`/`O` 时也不会自动复制注释 leader；
C 块注释不会自动插入下一行的 `*`，但 `smartindent` 仍可能保留普通缩进。语言 ftplugin 的 `q`、`j`、
`l` 等其他行为保持不变，手工注释继续使用 Comment.nvim 按键，见 [`keymaps.md`](keymaps.md)。

## 补全、snippet 和格式化

进入 Insert mode 后加载 nvim-cmp、LuaSnip 和 autopairs：

- `<C-Space>` 主动补全，`<C-n>`/`<C-p>` 选择候选；
- `<CR>` 只确认明确选中的候选；
- `<Tab>` 依次尝试下一候选、snippet 展开/跳转、触发补全，最后才 fallback；
- `<S-Tab>` 选择上一候选或向前跳转 snippet。

保存时 Conform 根据 filetype 尝试 formatter，并在配置允许时回退到 LSP。用 `:ConformInfo` 判断当前
buffer 的 formatter，而不是假设 Mason 中存在同名软件包。C 优先使用 Mason 管理的 `clang-format`；
它读取项目 `.clang-format`，项目没有配置时使用上游 LLVM fallback。登录 shell 看不到该命令时，仍应
在 Neovim 中检查 Mason PATH 和实际格式化结果。

## LSP 与诊断

在支持 LSP 的档位并成功 attach 后，buffer-local 按键提供定义、引用、hover、重命名、code action、
诊断跳转和手动格式化；`,df` 打开当前行诊断浮窗，Neovim 内置 `<C-w>d` 仍可使用。Neovim 0.12 使用
以下入口检查：

```vim
:lsp
:checkhealth vim.lsp
```

没有 client 时依次检查 filetype、语言开关、版本档位、server 可执行文件和启动日志。

## Git

Gitsigns 提供当前文件的 Git sign 和 staged sign，Lualine 显示 branch/diff。仓库没有声明 Neogit、
git.nvim 或 Fugitive，也没有为它们保留失效按键。不要依靠 data 目录中的旧插件判断仓库能力。

## 终端与外部命令

`:!` 和 ToggleTerm 使用配置中的 `zsh`。ToggleTerm 还定义 Lazygit、Node、ncdu、htop 和 Python 的
Lua helper，但当前没有仓库按键；缺少这些可选命令不影响普通终端。

## 常见故障

### 旧版没有 LSP、Telescope 或 Tree-sitter 命令

先运行 `:version` 并检查兼容性文档。这通常是主动降级，不能通过反复执行 `:Lazy restore` 绕过。

### 旧版仍报告插件最低版本错误

检查 `stdpath("data")/site/pack/packer/start` 是否仍有旧 Packer package。它们会绕过 Lazy `cond`。

### `:!` 或 ToggleTerm 无法启动

运行 `:set shell?`，并在相同环境执行 `command -v zsh`。当前配置不会自动回退到 Bash 或 Fish。

### LSP 或 formatter 命令在登录 shell 中不可见

Mason 可能只在 Neovim 运行环境中加入自己的 `bin`。结合 `:Mason`、`:ConformInfo` 和实际 LSP client
检查，不能仅凭一侧 PATH 下结论。

### 已移除的按键不存在

Neogit、Markdown Preview、TableMD 和 Lspsaga 当前没有 provider。恢复这些功能需要新的插件方案，
不能只补一个按键。

## 修改配置

任何语言、插件、按键、依赖或版本调整都遵循
[`../maintenance/workflow.md`](../maintenance/workflow.md) 的方案确认、文档先行、实现、联合验证和提交
流程；待办状态见 [`../maintenance/roadmap.md`](../maintenance/roadmap.md)。
