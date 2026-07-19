# 自定义快捷键

Leader 和 LocalLeader 都是逗号 `,`。本文只记录仓库明确创建或配置的按键；Targets、Visual Multi 等
插件的全部上游默认键位不在这里复制。

“活动插件”表示 provider 已在 `lua/darkroam/plugins/*.lua` 声明；带版本门槛的按键只在对应 plugin
spec 的 `cond` 成立时创建。准确档位见
[`../reference/compatibility.md`](../reference/compatibility.md)。表格尽量使用 Lua 配置中的字面键名，
便于静态检查。

## 交互验收边界

静态文档检查负责核对本表与 Lua 声明，兼容矩阵负责核对各档位实际存在的映射；两者都不能证明终端
收到了用户按下的字节序列。2026-07-19 在真实 X11 `st` 中使用 Neovim 0.12.3 完成交互样本：最终干净
运行核对 80/80 个全局或插件映射和 clangd attach 后的 11/11 个 LSP buffer-local 映射，并用实际键盘
事件触发标签页、分屏、目录、Alternate、Comment、Surround、Autopairs、Tree-sitter、NvimTree、
Telescope、ToggleTerm、definition、hover、诊断浮窗和格式化。Telescope Normal、file-browser 和
ToggleTerm buffer-local 映射分别为 2/2、4/4 和 5/5。

全部修改性操作只作用于一次性临时文件；最终 `v:errmsg` 和 fatal marker 为空，LSP stderr 的包装基线
见兼容性文档。这个结论只覆盖上述
0.12.3、X11 和 `st` 组合；表中的“活动”仍表示配置会创建映射，不能把同一物理送键结论外推到其他
版本、终端或平台。

## 标签页、窗口和 buffer

| 模式 | 按键 | 行为 | 状态 |
| --- | --- | --- | --- |
| Normal | `,tn` | 编辑一个新标签页 buffer（`:tabedit`） | 活动 |
| Normal | `,tc` | 关闭当前标签页 | 活动 |
| Normal | `,cd` | 将工作目录切换到当前文件目录 | 活动 |
| Normal | `,xo`、`<Space>` | 切换到下一个窗口 | 活动 |
| Normal | `,wh` / `,wj` / `,wk` / `,wl` | 按方向移动窗口焦点 | 活动 |
| Normal | `sh` / `sj` / `sk` / `sl` | 按方向移动窗口焦点，会覆盖以 `s` 开头的部分默认操作 | 活动 |
| Normal | `,x1` | 只保留当前窗口 | 活动 |
| Normal | `,x2`、`ss` | 水平分屏并进入新窗口 | 活动 |
| Normal | `,x3`、`sv` | 垂直分屏并进入新窗口 | 活动 |
| Normal | `<C-Up>` / `<C-Down>` | 增加/减少窗口高度 2 行 | 活动 |
| Normal | `<C-Left>` / `<C-Right>` | 减少/增加窗口宽度 2 列 | 活动 |
| Normal | `<S-j>` / `<S-k>` | 下一个/上一个 buffer | 活动 |
| Normal | `<Tab>` / `<S-Tab>` | Bufferline 下一个/上一个 tab | 活动插件 |

## 基础编辑

| 模式 | 按键 | 行为 |
| --- | --- | --- |
| Insert | `kj` | 返回 Normal mode |
| Normal | `,xs` | 保存当前文件 |
| Normal | `,xm` | 打开命令行并允许继续输入 |
| Normal | `x` | 删除字符到 black-hole register，不覆盖 yank |
| Normal | `<C-d>` | 向后选择并删除一个单词到 black-hole register；覆盖默认半页下滚 |
| Normal | `+` / `-` | 数字递增/递减 |
| Visual | `<` / `>` | 缩进后保持选择 |
| Visual | `<A-j>` / `<A-k>` | 上下移动选中行 |
| Visual | `p` | 替换选择但不覆盖原 yank |
| Visual block | `<A-j>` / `<A-k>` | 上下移动 block |
| Normal/Visual | `,rb` | 打开 substitute 输入；Normal 使用全文件范围 |
| Normal | `,ta` | Alternate Toggler 切换 true/false 等值 |

## 文件树、搜索和专注模式

| 模式 | 按键 | 行为 | 依赖 |
| --- | --- | --- | --- |
| Normal | `,e` | 切换 NvimTree | NvimTree |
| Normal | `,rr` | Telescope `find_files`，包含隐藏文件但尊重 ignore | `telescope` 档位 |
| Normal | `,dd` | Telescope `live_grep` | `telescope` 档位、`rg` |
| Normal | `,bb` | Telescope buffers | `telescope` 档位 |
| Normal | `;t` | Telescope help tags | `telescope` 档位 |
| Normal | `;;` | 恢复上次 Telescope picker | `telescope` 档位 |
| Normal | `;e` | Telescope diagnostics | `telescope` 档位 |
| Normal | `,kk` | Telescope keymaps | `telescope` 档位 |
| Normal | `,xf` | 当前文件目录的 Telescope file browser | `telescope` 档位、file-browser |
| Telescope Normal | `q` | 关闭 picker | Telescope |
| Telescope Normal | `?` | 显示当前 picker 按键 | Telescope |
| Telescope file browser Normal | `N` | 新建 | Telescope file-browser |
| Telescope file browser Normal | `h` | 上级目录 | Telescope file-browser |
| Telescope file browser Normal | `/` | 进入 Insert mode | Telescope file-browser |
| Telescope file browser Insert | `<C-w>` | 删除光标前一个单词 | Telescope file-browser |
| Normal | `,ff` | 切换 ZenMode | ZenMode |

## 终端

| 模式 | 按键 | 行为 |
| --- | --- | --- |
| Normal/Insert | `,xc` | 切换浮动 ToggleTerm |
| Terminal | `<Esc>` | 返回 Terminal-Normal mode（ToggleTerm buffer） |
| Terminal | `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | 离开 terminal 并按方向切换窗口 |

`lua/darkroam/keymaps.lua` 也建立了全局 terminal Ctrl-h/j/k/l 映射；ToggleTerm 的 buffer-local
映射在其 terminal 中提供同一结果。终端 shell 是 `zsh`。

## 注释、surround 和 autopairs

| 模式 | 按键 | 行为 | 依赖 |
| --- | --- | --- | --- |
| Normal | `,ll` | Comment.nvim 当前行注释 toggle | Comment.nvim |
| Normal/Visual | `,l{motion}` / `,l` | Comment.nvim 对 motion/选区执行行注释 | Comment.nvim |
| Normal | `,lO` | 在上方添加注释 | Comment.nvim |
| Normal | `,lA` | 在行尾添加注释 | Comment.nvim |
| Normal | `ys{motion}{char}` | 添加 surround | nvim-surround |
| Normal | `ds{char}` | 删除 surround | nvim-surround |
| Normal | `cs{target}{replacement}` | 修改 surround | nvim-surround |
| Insert | `<M-e>` | Autopairs fast-wrap | nvim-autopairs |

`treesitter` 档位还配置 `af`（function outer）和 `if`（function inner），适用于 Operator-pending 和
Visual mode；其他档位不创建这两个插件映射。

## 补全

| 模式 | 按键 | 行为 |
| --- | --- | --- |
| Insert | `<C-p>` / `<C-n>` | 上一个/下一个补全候选 |
| Insert | `<C-Space>` | 主动补全 |
| Insert | `<C-e>` | 取消补全 |
| Insert | `<CR>` | 确认已选择候选，不自动选择第一项 |
| Insert/Snippet | `<Tab>` | 下一候选、展开/向后跳 snippet、触发补全或 fallback |
| Insert/Snippet | `<S-Tab>` | 上一候选、向前跳 snippet 或 fallback |

## LSP buffer-local 按键

只有 `lsp` 档位且 LSP client 成功 attach 后才存在：

| 模式 | 按键 | 行为 |
| --- | --- | --- |
| Normal | `gD` | declaration |
| Normal | `gd` | definition |
| Normal | `gi` | implementation |
| Normal | `gr` | references |
| Normal | `K` | hover |
| Normal | `,rn` | rename |
| Normal | `,ca` | code action |
| Normal | `,lf` | 通过 Conform 异步格式化，必要时 LSP fallback |
| Normal | `[d` / `]d` | 上一个/下一个诊断 |
| Normal | `,df` | 当前行诊断浮窗 |

## Gitsigns

Gitsigns 当前配置 sign、staged sign 和可选 current-line blame，但仓库没有另行创建 Gitsigns 按键。
Neogit 不属于活动 Git 功能。

Neogit、Markdown Preview、TableMD 和 Lspsaga 的 provider 未声明，仓库不再创建相关失效按键。
恢复这些功能时必须同步本表和 [`../reference/plugins.md`](../reference/plugins.md)。
