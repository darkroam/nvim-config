# 安装与恢复

本文给出从纯净 clone 到可检查编辑环境的顺序。Linux 是当前经过验证的主路径；macOS 和 Windows
只记录配置中确实存在的目录及剪贴板差异，不宣称拥有完整验证矩阵。版本支持范围见
[`../reference/compatibility.md`](../reference/compatibility.md)，外部命令见
[`../reference/dependencies.md`](../reference/dependencies.md)。

## 安装边界

仓库只包含配置和 `lazy-lock.json`。以下内容由本机管理，不进入 Git：

- `stdpath("data")` 下的 lazy.nvim、插件、Mason 软件包和 Tree-sitter parser；
- `stdpath("state")` 与 `stdpath("cache")` 下的日志、shada、undo、swap 和缓存；
- 系统命令、字体、剪贴板 provider、凭据和项目历史。

普通启动可以 bootstrap Lazy 并恢复插件，但不会自动安装 Mason 工具或首次所需 parser，也不会修改
系统包。

## 1. 检查前置条件

至少确认 Neovim、Git 和 Zsh 可用：

```sh
nvim --version
git --version
zsh --version
```

完整功能还需要网络、TLS 证书、`curl`、`tar`、`make`、C compiler，以及按功能选择的 `rg`、
`fd`/`fdfind`、剪贴板 provider 和 Nerd Font。准确要求级别以依赖清单为准。

## 2. 备份旧状态

已有配置或运行状态时，先移到自行命名的备份目录。需要考虑的标准位置是：

```text
~/.config/nvim
~/.local/share/nvim
~/.local/state/nvim
~/.cache/nvim
```

不要只替换配置后继续复用旧 Packer start tree；它会绕过 Lazy 的版本条件。备份比直接删除更容易
回退，确认新环境稳定后再处理备份。

## 3. Clone 并恢复插件

```sh
git clone https://github.com/darkroam/nvim-config ~/.config/nvim
nvim
```

首次启动依次执行：

1. clone `lua/darkroam/lazy.lua` 中固定 commit 的 lazy.nvim；
2. 读取 `lua/darkroam/plugins/*.lua`；
3. 按 `lazy-lock.json` 下载并 checkout 受管插件；
4. 执行首次 build hook，例如 LuaSnip 的 `make install_jsregexp`。

截至 2026-07-18，隔离 XDG 的 0.12.3 纯净安装在第 4 步存在已确认缺陷：
`nvim-treesitter` 的 build hook 在插件脚本注册命令前调用 `:TSUpdate`，因此 `:Lazy! restore` 输出
`Command not found: TSUpdate`。该命令仍可能以退出码 0 结束，且 32 个 checkout 可以全部与
`lazy-lock.json` 匹配，但这次安装仍应判为失败。第二次启动会注册 `:TSUpdate`，不能据此把首次恢复
追记为通过；修复和完整复测由 roadmap 跟踪。

完成后检查：

```vim
:Lazy
:Lazy restore
:checkhealth lazy
```

不要把 `:Lazy update` 当作安装修复命令；它会改变锁文件目标，必须走受控更新和兼容性验证。

## 4. 安装语言工具

当前没有统一的 `:DarkroamBootstrap` 命令。首次准备已启用语言时，显式执行：

```vim
:LspInstall lua_ls clangd
:MasonInstall stylua tree-sitter-cli
```

显式参数使纯净安装不依赖当前 buffer filetype 的交互候选。Mason-LSPConfig 的 `ensure_installed` 也由
`languages.lua` 生成 `lua_ls` 和 `clangd`，用于保持配置意图一致。StyLua 是 formatter，不是 LSP；
`tree-sitter-cli` 用于构建当前 Tree-sitter `main` parser。

当前 C formatter 配置名是 `clang_format`，但 `clangd` 软件包不等于 `clang-format` 命令。纯净环境在
没有独立 provider 时只能使用可用的 LSP fallback；补齐 provider 仍是 roadmap 项，不能记作已完成。

## 5. 安装 parser

在支持当前 Tree-sitter 档位的 Neovim 上执行：

```vim
:DarkroamTSInstall
```

当前首次恢复缺陷发生后，第二次启动可提供此命令作为手工恢复入口，但这不等于纯净安装链路已经
修复。需要可重复安装时，应等待 build hook 修复并重新执行隔离验证。

该命令根据 `languages.lua` 安装当前选择的 parser。也可显式执行：

```vim
:TSInstall lua c commonlisp
```

parser 写入 `stdpath("data")/treesitter-0.12`。插件升级后使用 `:TSUpdate`；较旧 Neovim 不加载当前
Tree-sitter 栈，也不应尝试用该命令绕过版本门槛。

## 6. 验证安装

至少检查：

```vim
:checkhealth
:Lazy
:Mason
:ConformInfo
:checkhealth vim.lsp
```

再分别打开 Lua、C 和 Emacs Lisp 文件，确认实际 LSP attach、formatter 可用性、parser 高亮和按键。
Neovim 0.12 使用内置 `:lsp` 查看 client。命令存在、目录存在或退出码为零都不能单独证明功能通过；
还要检查完整输出中的错误。

## 故障恢复

- Lazy bootstrap 失败：检查 Git、网络和 TLS；保留完整错误，不要手工放入未知 commit 的插件目录。
- Lazy 恢复输出 `Command not found: TSUpdate`：这是当前已知的首次 build 顺序缺陷，不是成功提示；
  不要仅凭退出码 0 或第二次启动正常而忽略。
- 旧版出现 Telescope/LSP/Tree-sitter 最低版本错误：检查是否仍有 Packer start package 绕过条件加载。
- shell 或 ToggleTerm 失败：使用 `:set shell?` 和 `command -v zsh` 核对。
- 系统 PATH 找不到 Mason 工具：以 `:Mason` 和 `:ConformInfo` 为准，同时确认 server 是否真正启动。

回退时成套恢复旧配置和与其匹配的 data 备份，不要把旧 Packer tree 与当前 Lazy 配置混用。

## 其他平台

macOS 和 Linux 使用 `~/.config/nvim`；Windows 通常使用 `$env:LOCALAPPDATA\nvim`。仓库分别保留
`lua/darkroam/macos.lua` 和 `lua/darkroam/windows.lua` 的剪贴板设置，但当前完整安装验证只覆盖 Linux。
