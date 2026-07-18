# 语言能力

本文是语言开关、用户可见能力和安装入口的权威说明。`lua/darkroam/languages.lua` 是代码中的唯一
状态来源；版本门槛优先于语言开关，详见
[`../reference/compatibility.md`](../reference/compatibility.md)。

## 当前语言表

| 语言键 | 状态 | LSP | Formatter | Tree-sitter / filetype |
| --- | --- | --- | --- | --- |
| `lua` | 启用 | `lua_ls` | `stylua` | `lua` |
| `c` | 启用 | `clangd` | `clang_format`，不可用时尝试 LSP fallback | `c` |
| `elisp` | 启用 | 无 | 无 | `commonlisp` 注册到 `lisp`；识别 `.el` 和 `.emacs` |
| `go` | 禁用 | 启用时使用 `gopls` | 启用时使用 `gofmt` | 启用时安装 Go parser family |

“启用”表示配置会在支持该 provider 的版本档位选择相应能力，不表示本机软件包已经安装。Mason、
系统 PATH 和 parser 目录必须分别检查。

## LSP 与 Mason

支持 LSP 的档位使用 `vim.lsp.config()` 和 `vim.lsp.enable()`。当前选择 `lua_ls`、`clangd`，Go 开关
打开后才加入 `gopls`。首次安装执行：

```vim
:LspInstall lua_ls clangd
```

Mason-LSPConfig 的 `automatic_enable=false` 防止扫描 Mason 中的全部软件包并作为 LSP 启动。只有
语言表选中的 server 会 enable；无参数 `:LspInstall` 会按当前 buffer filetype 提示候选，因此纯净安装
使用上面的显式 server 列表。StyLua 不会作为 LSP 启动。

LSP attach 后提供 definition、references、hover、rename、code action、诊断和手动格式化按键，完整
列表见 [`keymaps.md`](keymaps.md)。Neovim 0.12 使用 `:lsp` 和 `:checkhealth vim.lsp` 检查 client。

## 格式化

Conform 根据 filetype 选择 formatter，并以 `lsp_format="fallback"` 作为后备：

- Lua 使用 `stylua`；LuaLS 的 formatting capability 被关闭，避免重复格式化；
- C 使用 `clang_format`，但 `clangd` 不提供独立的 `clang-format` 命令；
- Go 只有在语言开关启用后使用 `gofmt`；
- Elisp 当前没有 formatter。

首次可通过 Mason 安装 StyLua：

```vim
:MasonInstall stylua
:ConformInfo
```

保存时会触发 Conform。`:ConformInfo` 显示 formatter 不可用时，应检查 provider，而不是仅检查配置表。

## Tree-sitter

支持当前 Tree-sitter 档位时，执行：

```vim
:MasonInstall tree-sitter-cli
:DarkroamTSInstall
```

命令按语言表安装 `lua`、`c` 和 `commonlisp`；Go parser family 当前不安装。打开对应 filetype 后由
Neovim 内置 `vim.treesitter.start()` 启动高亮，`commonlisp` 显式注册到 `lisp`。parser 安装位置和
纯净恢复步骤见 [`installation.md`](installation.md)。

## 修改语言开关

不能通过只安装一个工具来改变仓库语言状态。新增、关闭或修改语言时，需要先提出方案并同步：

1. `lua/darkroam/languages.lua`；
2. `lua/darkroam/plugins/lsp.lua` 的 server 和 formatter；
3. `lua/darkroam/plugins/treesitter.lua` 的 parser 和 filetype；
4. 本文、依赖清单、插件清单和相关按键；
5. 对应语言 buffer 的 LSP、格式化和 parser 验证。

## 常见判断错误

- Mason package 目录存在，不等于 server 已成功 attach；
- 登录 shell 找不到命令，不等于 Neovim 中 Mason PATH 一定不可用；
- `clangd` 与 `clang-format` 是两个不同命令；
- 语言开关启用但版本门槛禁用 provider，是主动降级而不是开关失效；
- parser 下载成功但无法加载时，还要检查 Neovim 版本、ABI 和实际 runtimepath。
