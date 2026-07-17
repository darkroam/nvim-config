# 自定义快捷键

Leader 和 LocalLeader 都是逗号 `,`。本文只记录仓库明确创建或配置的按键；Targets、Visual Multi 等
插件的全部上游默认键位不在这里复制。

“活动”表示 provider 已在 `lua/darkroam/plugins.lua` 声明；“遗留”表示映射存在，但 provider
当前缺失。

## 标签页、窗口和 buffer

| 模式 | 按键 | 行为 | 状态 |
| --- | --- | --- | --- |
| Normal | `,tn` | 编辑一个新标签页 buffer（`:tabedit`） | 活动 |
| Normal | `,tc` | 关闭当前标签页 | 活动 |
| Normal | `,cd` | 将工作目录切换到当前文件目录 | 活动 |
| Normal | `,xo`、Space | 切换到下一个窗口 | 活动 |
| Normal | `,wh` / `,wj` / `,wk` / `,wl` | 按方向移动窗口焦点 | 活动 |
| Normal | `sh` / `sj` / `sk` / `sl` | 按方向移动窗口焦点，会覆盖以 `s` 开头的部分默认操作 | 活动 |
| Normal | `,x1` | 只保留当前窗口 | 活动 |
| Normal | `,x2`、`ss` | 水平分屏并进入新窗口 | 活动 |
| Normal | `,x3`、`sv` | 垂直分屏并进入新窗口 | 活动 |
| Normal | Ctrl-Up / Ctrl-Down | 增加/减少窗口高度 2 行 | 活动 |
| Normal | Ctrl-Left / Ctrl-Right | 减少/增加窗口宽度 2 列 | 活动 |
| Normal | Shift-j / Shift-k | 下一个/上一个 buffer | 活动 |
| Normal | Tab / Shift-Tab | Bufferline 下一个/上一个 tab | 活动插件 |

## 基础编辑

| 模式 | 按键 | 行为 |
| --- | --- | --- |
| Insert | `kj` | 返回 Normal mode |
| Normal | `,xs` | 保存当前文件 |
| Normal | `,xm` | 打开命令行并允许继续输入 |
| Normal | `x` | 删除字符到 black-hole register，不覆盖 yank |
| Normal | Ctrl-d | 向后选择并删除一个单词到 black-hole register；覆盖默认半页下滚 |
| Normal | `+` / `-` | 数字递增/递减 |
| Visual | `<` / `>` | 缩进后保持选择 |
| Visual | Alt-j / Alt-k | 上下移动选中行 |
| Visual | `p` | 替换选择但不覆盖原 yank |
| Visual block | Alt-j / Alt-k | 上下移动 block |
| Normal/Visual | `,rb` | 打开 substitute 输入；Normal 使用全文件范围 |
| Normal | `,ta` | Alternate Toggler 切换 true/false 等值 |

## 文件树、搜索和专注模式

| 模式 | 按键 | 行为 | 依赖 |
| --- | --- | --- | --- |
| Normal | `,e` | 切换 NvimTree | NvimTree；LSP buffer 中会被局部诊断映射覆盖 |
| Normal | `,rr` | Telescope `find_files`，包含隐藏文件但尊重 ignore | Telescope |
| Normal | `,dd` | Telescope `live_grep` | Telescope、`rg` |
| Normal | `,bb` | Telescope buffers | Telescope |
| Normal | `;t` | Telescope help tags | Telescope |
| Normal | `;;` | 恢复上次 Telescope picker | Telescope |
| Normal | `;e` | Telescope diagnostics | Telescope |
| Normal | `,kk` | Telescope keymaps | Telescope |
| Normal | `,xf` | 当前文件目录的 Telescope file browser | Telescope file-browser |
| Telescope Normal | `q` | 关闭 picker | Telescope |
| Telescope Normal | `?` | 显示当前 picker 按键 | Telescope |
| Telescope file browser Normal | `N` | 新建 | Telescope file-browser |
| Telescope file browser Normal | `h` | 上级目录 | Telescope file-browser |
| Telescope file browser Normal | `/` | 进入 Insert mode | Telescope file-browser |
| Normal | `,ff` | 切换 ZenMode | ZenMode |

## 终端

| 模式 | 按键 | 行为 |
| --- | --- | --- |
| Normal/Insert | `,xc` | 切换浮动 ToggleTerm |
| Terminal | Esc | 返回 Terminal-Normal mode（ToggleTerm buffer） |
| Terminal | Ctrl-h / Ctrl-j / Ctrl-k / Ctrl-l | 离开 terminal 并按方向切换窗口 |

`lua/darkroam/keymaps.lua` 也建立了全局 terminal Ctrl-h/j/k/l 映射；ToggleTerm 的 buffer-local
映射在其 terminal 中提供同一结果。终端 shell 是 `zsh`。

## 注释、surround 和 autopairs

| 模式 | 按键 | 行为 | 依赖 |
| --- | --- | --- | --- |
| Normal/Operator | `,ll` | Comment.nvim 行注释 toggle/operator leader | Comment.nvim |
| Normal | `,lO` | 在上方添加注释 | Comment.nvim |
| Normal | `,lA` | 在行尾添加注释 | Comment.nvim |
| Normal | `ys{motion}{char}` | 添加 surround | nvim-surround |
| Normal | `ds{char}` | 删除 surround | nvim-surround |
| Normal | `cs{target}{replacement}` | 修改 surround | nvim-surround |
| Insert | Alt-e | Autopairs fast-wrap | nvim-autopairs |

Tree-sitter textobjects 还配置了 `af`（function outer）和 `if`（function inner）。

## 补全

| 模式 | 按键 | 行为 |
| --- | --- | --- |
| Insert | Ctrl-p / Ctrl-n | 上一个/下一个补全候选 |
| Insert | Ctrl-Space | 主动补全 |
| Insert | Ctrl-e | 取消补全 |
| Insert | Enter | 确认已选择候选，不自动选择第一项 |
| Insert/Snippet | Tab | 下一候选、展开/向后跳 snippet、触发补全或 fallback |
| Insert/Snippet | Shift-Tab | 上一候选、向前跳 snippet 或 fallback |

## LSP buffer-local 按键

只有 LSP client 成功 attach 后才存在：

| 模式 | 按键 | 行为 |
| --- | --- | --- |
| Normal | `gD` | declaration |
| Normal | `gd` | definition |
| Normal | `gi` | implementation |
| Normal | `gr` | references |
| Normal | `K` | hover |
| Normal | `,rn` | rename |
| Normal | `,ca` | code action |
| Normal | `,lf` | 异步 LSP format |
| Normal | `[d` / `]d` | 上一个/下一个诊断 |
| Normal | `,e` | 当前行诊断浮窗；覆盖同 buffer 的全局 NvimTree `,e` |

## Gitsigns

Gitsigns 当前配置 sign、staged sign 和可选 current-line blame，但仓库没有另行创建 Gitsigns 按键。
Neogit 不属于活动 Git 功能。

## 当前遗留不可用按键

这些映射仍由 `lua/darkroam/keymaps.lua` 创建，但 provider 没有声明：

| 按键 | 原目标 | 当前状态 |
| --- | --- | --- |
| `,gg` | `:Neogit` | 遗留，不可用 |
| `,tf` | format Markdown table | 遗留，不可用 |
| `,tl` / `,th` / `,td` | 在右/左插列、删列 | 遗留，不可用 |
| `,tj` / `,tk` | 在下/上插行 | 遗留，不可用 |
| `,tq` / `,tw` / `,te` | 表格列左/中/右对齐 | 遗留，不可用 |
| `,md` | `:MarkdownPreviewToggle` | 遗留，不可用 |

Lspsaga 配置文件中的 `K`、`gd`、`gp`、`gl`、`gr`、`gc`、Ctrl-j、Ctrl-k 不会创建，因为
Lspsaga 模块未声明且 `pcall(require, "lspsaga")` 立即返回。

未来恢复或删除 provider 时，必须同步本表和
[`../project/plugins.md`](../project/plugins.md)。
