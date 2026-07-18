# 插件清单与状态

本文是插件声明、配置入口、能力档位和生效状态的权威来源。准确版本门槛只在
[`compatibility.md`](compatibility.md) 维护。直接插件 spec 只允许出现在
`lua/darkroam/plugins/*.lua`；lazy.nvim 自身由 `lua/darkroam/lazy.lua` 固定 commit 后 bootstrap。
全部受管插件 commit 记录在 `lazy-lock.json`。

状态含义：

- **活动**：在满足版本门槛时有当前运行路径；
- **依赖**：由其他 spec 显式引用，不单独声明用户能力；
- **默认行为**：加载插件并使用上游默认映射或功能；
- **条件禁用**：当前锁定版本在较旧 Neovim 上不进入 runtimepath；
- **已移除**：本轮确认不再声明、配置或建立相关按键。

## 管理器与共享依赖

| 插件 | 状态与门槛 | 本地入口与职责 |
| --- | --- | --- |
| `folke/lazy.nvim` | 活动；基础档位 | `lua/darkroam/lazy.lua` 固定 manager commit、bootstrap、读取 `lazy-lock.json` 并 import specs |
| `nvim-lua/plenary.nvim` | 依赖；随 Telescope 档位 | `lua/darkroam/plugins/telescope.lua`，供 Telescope 使用 |

不同时保留 Packer 声明。迁移前的 Packer start package 是机器状态，必须备份移出活动 packpath，而不是
作为 Lazy dependency 使用。

## 编辑基础

由 `lua/darkroam/plugins/editor.lua` 负责：

| 插件 | 状态与门槛 | 配置和用户行为 |
| --- | --- | --- |
| `windwp/nvim-autopairs` | 活动；基础档位 | `InsertEnter` 加载、cmp confirm 集成和 Alt-e fast-wrap |
| `wellle/targets.vim` | 默认行为；基础档位 | 使用上游 text-object 映射 |
| `mg979/vim-visual-multi` | 默认行为；基础档位 | 使用上游多光标映射 |
| `numToStr/Comment.nvim` | 活动；基础档位 | `,ll` 当前行 toggle，`,l{motion}` operator，`,lO`/`,lA` extra |
| `kylechui/nvim-surround` | 活动；基础档位 | `ys`、`ds`、`cs` 默认映射 |
| `rmagatti/alternate-toggler` | 活动；基础档位 | `,ta`，映射随 plugin spec 加载 |

Comment.nvim 的 toggler 与 opleader 不再复用同一完整键串，避免 operator 映射被覆盖。

## 界面和终端

由 `lua/darkroam/plugins/ui.lua` 负责：

| 插件 | 状态与门槛 | 配置和用户行为 |
| --- | --- | --- |
| `nvim-tree/nvim-web-devicons` | 活动依赖；基础档位 | 图标默认启用，供文件树、状态栏等消费 |
| `nvim-tree/nvim-tree.lua` | 活动；基础档位 | `,e` 和 `:NvimTree*` 按需加载 |
| `akinsho/nvim-bufferline.lua` | 活动；基础档位 | tab 模式，Tab/Shift-Tab 切换 |
| `akinsho/toggleterm.nvim` | 活动；基础档位 | `,xc` 浮动终端；命名 TermOpen augroup 和 `wincmd` terminal 映射 |
| `folke/zen-mode.nvim` | 活动；基础档位 | `,ff` 按需加载 |
| `svrana/neosolarized.nvim` | 活动；基础档位 | 启动主题、cursor/visual/diagnostic highlight |
| `tjdevries/colorbuddy.nvim` | 依赖；基础档位 | Neosolarized 配置依赖 |
| `nvim-lualine/lualine.nvim` | 活动；基础档位 | mode、branch、diff、诊断、文件、位置；不再请求缺失的 Fugitive extension |

ToggleTerm 仍继承 `vim.o.shell` 的 Zsh。Lazygit、Node、ncdu、htop、Python 自定义 terminal helper 暂时
保留且没有仓库按键；它们只在 ToggleTerm 已加载后存在，外部命令边界见
[`dependencies.md`](dependencies.md)。

## 补全与 snippet

由 `lua/darkroam/plugins/completion.lua` 负责，均属于基础档位：

| 插件 | 状态 | 配置和用户行为 |
| --- | --- | --- |
| `hrsh7th/nvim-cmp` | 活动 | `InsertEnter` 加载，候选、确认和 Tab/S-Tab 流程 |
| `hrsh7th/cmp-buffer` | 活动 source | buffer source |
| `hrsh7th/cmp-path` | 活动 source | path source |
| `hrsh7th/cmp-nvim-lsp` | 活动 source/依赖 | cmp source 与 LSP capabilities |
| `saadparwaiz1/cmp_luasnip` | 活动 source | LuaSnip source |
| `L3MON4D3/LuaSnip` | 活动 | 使用当前 `update_events` 配置，不使用 deprecated `history`；build `jsregexp` 支持 snippet transformation |
| `rafamadriz/friendly-snippets` | 活动依赖 | VSCode snippet loader lazy-load |

## LSP、Mason 与格式化

由 `lua/darkroam/plugins/lsp.lua` 负责：

| 插件 | 状态与门槛 | 配置和用户行为 |
| --- | --- | --- |
| `williamboman/mason.nvim` | 活动；基础档位 | `:Mason` UI 与 PATH；machine-local package manager |
| `williamboman/mason-lspconfig.nvim` | 条件活动；`lsp` 档位 | `:LspInstall`/`:LspUninstall` 时按需加载，生成 `ensure_installed`，`automatic_enable=false` |
| `neovim/nvim-lspconfig` | 条件活动；`lsp` 档位、启动加载 | server definitions、`vim.lsp.config/enable`、LspAttach 映射；不让首个文件错过 FileType attach |
| `stevearc/conform.nvim` | 活动；基础档位 | 显式依赖 Mason 建立 formatter PATH；保存格式化和 `lsp_format="fallback"` |

Mason package 存在不等于 LSP 自动启用。Document highlight 由 Neovim 原生 LSP autocommand 提供，不再
依赖使用 deprecated API 的 Illuminate。StyLua 只作为 formatter；`lua_ls`、`clangd` 和可选 `gopls`
由语言表选择。基础档位不加载当前 nvim-lspconfig 或相应 buffer-local 按键。

## 搜索和文件浏览

由 `lua/darkroam/plugins/telescope.lua` 负责，整组属于 `telescope` 档位：

| 插件 | 状态 | 配置和用户行为 |
| --- | --- | --- |
| `nvim-telescope/telescope.nvim` | 条件活动 | 文件、grep、buffer、帮助、诊断和按键查询 |
| `nvim-telescope/telescope-file-browser.nvim` | 条件活动依赖 | 当前 buffer 目录 file browser |

整组被版本条件禁用时，`,rr`、`,dd`、`,bb`、`;t`、`;;`、`;e`、`,kk`、`,xf` 都不创建。

## Tree-sitter 与 Textobjects

由 `lua/darkroam/plugins/treesitter.lua` 负责，整组属于 `treesitter` 档位：

| 插件 | 状态 | 配置和用户行为 |
| --- | --- | --- |
| `nvim-treesitter/nvim-treesitter` | 条件活动；`main`、`lazy=false` | 新版 setup、内置高亮/缩进、版本专用 parser 目录、parser 命令与 `:TSUpdate` build hook |
| `nvim-treesitter/nvim-treesitter-textobjects` | 条件活动；`main` | 新版独立 setup，显式 `af`/`if` function select 映射 |

普通启动不自动安装 parser；新机器执行 `:DarkroamTSInstall`，由语言表生成 parser 列表，也可直接执行
`:TSInstall lua c commonlisp`。不支持 `treesitter` 的档位不加载当前插件和映射，也不自动切换到旧
`master` 分支。

## Git

| 插件 | 状态与门槛 | 本地入口与职责 |
| --- | --- | --- |
| `lewis6991/gitsigns.nvim` | 活动；基础档位 | `lua/darkroam/plugins/git.lua`，sign、staged sign 和可选 current-line blame |

Neogit、git.nvim 和 Fugitive 不属于活动能力，也不再保留仓库配置或失效按键。

## 本轮已移除

| 插件或路径 | 结论 |
| --- | --- |
| `wbthomason/packer.nvim` | manager 已停止维护，以固定版本 lazy.nvim 和 lockfile 取代 |
| `nvim-lua/popup.nvim` | 当前 Telescope 不再需要，仓库无直接消费 |
| `lewis6991/impatient.nvim` | Neovim 0.10+ 使用内置 `vim.loader.enable()` |
| `hrsh7th/cmp-cmdline` | 已声明但未配置 cmdline source，删除而非保留无效声明 |
| `hrsh7th/cmp-nvim-lua` | 未进入活动 source，LuaLS 已提供 Lua workspace completion |
| `RRethy/vim-illuminate` | 当前锁定版本在 0.12 调用 deprecated `client.supports_method`；以原生 LSP document highlight 取代 |
| `ahmedkhalf/project.nvim` | 无仓库 projects 按键，且 history `uv.fs_event` 使 headless 退出挂起；删除后使用 `,cd` 显式切换目录 |
| Lspsaga、git.nvim、lsp-colors、lspkind、Neogit、Prettier、Tokyonight | provider 未声明；删除遗留 runtime 配置 |
| Colorizer、Orgmode、ts-autotag | 原文件已禁用且 provider 未声明；删除空壳配置 |
| Markdown table、Markdown Preview、Neogit 全局按键 | provider 缺失；删除按键，不制造未知命令 |

恢复任何已移除 provider 都是新的插件和用户行为变更，必须重新提案。

迁移删除的旧源码路径如下；它们的活动职责已经分别进入上面的 Lazy spec，或按“本轮已移除”结论
终止：

- `lua/darkroam/plugins.lua`
- `lua/darkroam/colorscheme.lua`
- `lua/darkroam/impatient.lua`
- `plugin/lspconfig.lua`
- `plugin/lspsaga.rc.lua`
- `after/plugin/autopairs.rc.lua`
- `after/plugin/bufferline.rc.lua`
- `after/plugin/cmp.rc.lua`
- `after/plugin/colorizer.rc.lua`
- `after/plugin/comment.rc.lua`
- `after/plugin/conform.rc.lua`
- `after/plugin/git.rc.lua`
- `after/plugin/gitsigns.rc.lua`
- `after/plugin/lsp-colors.rc.lua`
- `after/plugin/lspkind.rc.lua`
- `after/plugin/lualine.rc.lua`
- `after/plugin/luasnip.rc.lua`
- `after/plugin/mason.rc.lua`
- `after/plugin/neogit.rc.lua`
- `after/plugin/neosolarized.rc.lua`
- `after/plugin/nvim-tree.rc.lua`
- `after/plugin/orgmode.rc.lua`
- `after/plugin/prettier.rc.lua`
- `after/plugin/project.rc.lua`
- `after/plugin/surround.rc.lua`
- `after/plugin/telescope.rc.lua`
- `after/plugin/toggleterm.rc.lua`
- `after/plugin/tokyonight.rc.lua`
- `after/plugin/treesitter.rc.lua`
- `after/plugin/ts-autotag.rc.lua`
- `after/plugin/web-devicons.rc.lua`
- `after/plugin/zen-mode.rc.lua`

## 配置覆盖与维护规则

活动 spec 文件必须全部在本文件有归属：

- `lua/darkroam/plugins/editor.lua`
- `lua/darkroam/plugins/ui.lua`
- `lua/darkroam/plugins/completion.lua`
- `lua/darkroam/plugins/lsp.lua`
- `lua/darkroam/plugins/telescope.lua`
- `lua/darkroam/plugins/treesitter.lua`
- `lua/darkroam/plugins/git.lua`

新增、删除或替换插件时，先更新本文件和依赖/用户文档，再修改 spec。插件更新必须提交
`lazy-lock.json` 的可审计 diff，并重新验证所有可取得的 Neovim 档位。不得依靠 data 目录中的旧插件
缓存掩盖缺失声明、错误 dependency 或错误版本门槛。
