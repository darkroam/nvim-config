# 插件清单与状态

本文是插件声明、配置入口和生效状态的权威来源。直接声明只允许出现在
`lua/darkroam/plugins.lua`；本文件记录声明与源码钩子的关系，但不代替 Packer 配置。

状态含义：

- **活动**：已声明并有当前运行路径。
- **声明**：已声明，主要使用上游默认行为或作为依赖，没有独立本地配置。
- **部分使用**：已声明，但仓库只消费其部分能力。
- **禁用**：配置文件明确不加载对应插件。
- **遗留未声明**：保留配置或按键，但 `plugins.lua` 没有提供者，当前不能作为可用功能。

## 管理器与基础库

| 插件 | 状态 | 本地入口与职责 |
| --- | --- | --- |
| `wbthomason/packer.nvim` | 活动 | `lua/darkroam/plugins.lua` 自举并声明插件；当前无 pin/lock |
| `nvim-lua/plenary.nvim` | 声明 | Telescope、project.nvim 等插件的共享 Lua 工具库 |
| `nvim-lua/popup.nvim` | 声明 | 历史基础依赖；当前源码没有直接 `require` |

## 编辑与界面

| 插件 | 状态 | 配置文件或行为 |
| --- | --- | --- |
| `windwp/nvim-autopairs` | 活动 | `after/plugin/autopairs.rc.lua`，含 cmp confirm 集成和 `<M-e>` fast-wrap |
| `wellle/targets.vim` | 声明 | 使用上游 text-object 默认行为 |
| `mg979/vim-visual-multi` | 声明 | 使用上游多光标默认行为 |
| `numToStr/Comment.nvim` | 活动 | `after/plugin/comment.rc.lua`，自定义 `,ll`、`,lO`、`,lA` |
| `kylechui/nvim-surround` | 活动 | `after/plugin/surround.rc.lua`，使用 `ys`、`ds`、`cs` 默认映射 |
| `rmagatti/alternate-toggler` | 活动 | `lua/darkroam/keymaps.lua` 提供 `,ta` |
| `nvim-tree/nvim-web-devicons` | 活动 | `after/plugin/web-devicons.rc.lua` |
| `nvim-tree/nvim-tree.lua` | 活动 | `after/plugin/nvim-tree.rc.lua` 与全局 `,e` |
| `akinsho/nvim-bufferline.lua` | 活动 | `after/plugin/bufferline.rc.lua`，tab 模式和 Tab/S-Tab 映射 |
| `akinsho/toggleterm.nvim` | 活动 | `after/plugin/toggleterm.rc.lua`，浮动终端与可选命令 toggle 函数 |
| `folke/zen-mode.nvim` | 活动 | `after/plugin/zen-mode.rc.lua`，`,ff` |
| `lewis6991/impatient.nvim` | 活动 | `lua/darkroam/impatient.lua` 启用 profiling |
| `svrana/neosolarized.nvim` | 活动 | `lua/darkroam/colorscheme.lua` 与 `after/plugin/neosolarized.rc.lua` |
| `tjdevries/colorbuddy.nvim` | 活动依赖 | Neosolarized 声明的依赖，用于诊断 highlight |
| `nvim-lualine/lualine.nvim` | 部分使用 | `after/plugin/lualine.rc.lua`；配置中的 Fugitive extension 没有已声明提供者 |

## 补全、LSP 与格式化

| 插件 | 状态 | 配置文件或行为 |
| --- | --- | --- |
| `hrsh7th/nvim-cmp` | 活动 | `after/plugin/cmp.rc.lua`，插入补全和 Tab/S-Tab 流程 |
| `hrsh7th/cmp-buffer` | 活动 | cmp source `buffer` |
| `hrsh7th/cmp-path` | 活动 | cmp source `path` |
| `hrsh7th/cmp-cmdline` | 部分使用 | 已声明，但没有 `cmp.setup.cmdline()` |
| `hrsh7th/cmp-nvim-lsp` | 活动 | cmp source `nvim_lsp` 和 LSP capability |
| `hrsh7th/cmp-nvim-lua` | 部分使用 | 已声明，但活动 source 列表没有 `nvim_lua` |
| `saadparwaiz1/cmp_luasnip` | 活动 | cmp source `luasnip` |
| `L3MON4D3/LuaSnip` | 活动 | `after/plugin/cmp.rc.lua` 与 `after/plugin/luasnip.rc.lua` |
| `rafamadriz/friendly-snippets` | 活动 | 由 VSCode snippet loader lazy-load |
| `neovim/nvim-lspconfig` | 活动 | `plugin/lspconfig.lua`；当前代码要求 Neovim 0.11 API |
| `williamboman/mason.nvim` | 活动 | `after/plugin/mason.rc.lua` |
| `williamboman/mason-lspconfig.nvim` | 活动 | `after/plugin/mason.rc.lua` 生成 `ensure_installed` |
| `stevearc/conform.nvim` | 活动 | `after/plugin/conform.rc.lua`，按语言开关保存时格式化 |
| `RRethy/vim-illuminate` | 活动 | LSP attach 时调用 `illuminate.on_attach()` |

## 搜索、项目、语法和 Git

| 插件 | 状态 | 配置文件或行为 |
| --- | --- | --- |
| `nvim-telescope/telescope.nvim` | 活动 | `after/plugin/telescope.rc.lua`，文件、grep、buffer、帮助、诊断和按键查询 |
| `nvim-telescope/telescope-file-browser.nvim` | 活动 | 同一配置加载 `file_browser` extension |
| `ahmedkhalf/project.nvim` | 活动 | `after/plugin/project.rc.lua`，pattern root 和 projects extension |
| `nvim-treesitter/nvim-treesitter` | 活动 | `after/plugin/treesitter.rc.lua`，parser 集合由语言开关生成 |
| `nvim-treesitter/nvim-treesitter-textobjects` | 活动 | Tree-sitter `af`/`if` function text object |
| `lewis6991/gitsigns.nvim` | 活动 | `after/plugin/gitsigns.rc.lua`，sign 和 blame 配置 |

## 禁用与遗留配置

这些文件仍会被 Neovim 解析，但不代表对应功能可用：

| 文件或按键来源 | 状态 | 原提供者或结论 |
| --- | --- | --- |
| `after/plugin/colorizer.rc.lua` | 禁用 | `norcalli/nvim-colorizer.lua` 未声明；文件明确说明 deprecated API |
| `after/plugin/orgmode.rc.lua` | 禁用 | `nvim-orgmode/orgmode` 未声明；文件明确避免启动时 parser 编译 |
| `after/plugin/ts-autotag.rc.lua` | 禁用 | `windwp/nvim-ts-autotag` 未声明；注释中的语言范围已过时，后续需清理 |
| `plugin/lspsaga.rc.lua` | 遗留未声明 | 历史提供者 `glepnir/lspsaga.nvim`；`pcall` 失败后不创建映射 |
| `after/plugin/git.rc.lua` | 遗留未声明 | 历史候选 `dinhhuy258/git.nvim` 从未处于当前声明 |
| `after/plugin/lsp-colors.rc.lua` | 遗留未声明 | 没有当前 provider |
| `after/plugin/lspkind.rc.lua` | 遗留未声明 | 历史 provider `onsails/lspkind-nvim` 未声明 |
| `after/plugin/neogit.rc.lua` | 遗留未声明 | 历史 provider `TimUntersberger/neogit` 未声明 |
| `after/plugin/prettier.rc.lua` | 遗留未声明 | 历史 provider `MunifTanjim/prettier.nvim` 未声明；当前格式化由 Conform 负责 |
| `after/plugin/tokyonight.rc.lua` | 遗留未声明 | `folke/tokyonight.nvim` 未声明；仅设置全局变量，不启用主题 |
| `lua/darkroam/keymaps.lua` 的 `,gg` | 遗留未声明 | 调用不存在的 `:Neogit` |
| `lua/darkroam/keymaps.lua` 的 `,tf` 等表格映射 | 遗留未声明 | 历史 provider `allen-mack/nvim-table-md` 未声明 |
| `lua/darkroam/keymaps.lua` 的 `,md` | 遗留未声明 | 历史 provider `iamcco/markdown-preview.nvim` 未声明 |
| `after/plugin/lualine.rc.lua` 的 `fugitive` extension | 遗留未声明 | `vim-fugitive` 未声明 |

上述项目必须经单独方案决定删除、恢复 provider 或增加缺失保护；文档建立本身不替用户作选择。

## 配置覆盖清单

为了避免小型 hook 在重构时失去归属，以下 tracked plugin 配置都必须继续出现在本文：

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

## 维护规则

- 新增、删除或替换插件时，先更新本文件的状态和依赖边界，再改 `plugins.lua`。
- 有配置文件但无声明的项目必须明确标为禁用或遗留，不能依靠本机旧插件缓存伪装为仓库能力。
- 已声明但未消费的 source、extension 或基础库应定期审查；删除前仍需确认上游间接依赖。
- 插件更新必须与 Neovim 最低版本和锁定策略一起验证，不能只以 `:PackerSync` 完成作为成功。
- 插件相关用户行为同步更新 [`../user/usage-zh.md`](../user/usage-zh.md) 和
  [`../user/keybindings-zh.md`](../user/keybindings-zh.md)。
