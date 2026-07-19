# 语言能力

本文是语言开关、用户可见能力和安装入口的权威说明。`lua/darkroam/languages.lua` 是代码中的唯一
状态来源；版本门槛优先于语言开关，详见
[`../reference/compatibility.md`](../reference/compatibility.md)。

## 当前语言表

| 语言键 | 状态 | LSP | Formatter | Tree-sitter / filetype |
| --- | --- | --- | --- | --- |
| `lua` | 启用 | `lua_ls` | `stylua` | `lua` |
| `c` | 启用 | `clangd` | `clang-format`，不可用时尝试 LSP fallback | `c` |
| `elisp` | 启用 | 无 | 无 | `commonlisp` 注册到 `lisp`；识别 `.el` 和 `.emacs` |
| `go` | 禁用 | 启用时使用 `gopls` | 启用时使用 `gofmt` | 启用时安装 Go parser family |

“启用”表示配置会在支持该 provider 的版本档位选择相应能力，不表示本机软件包已经安装。Mason、
系统 PATH 和 parser 目录必须分别检查。

## LSP 与 Mason

支持 LSP 的档位使用 `vim.lsp.config()` 和 `vim.lsp.enable()`。当前选择 `lua_ls`、`clangd`，Go 开关
打开后才加入 `gopls`。首次安装统一执行：

```vim
:DarkroamBootstrap
```

Mason-LSPConfig 的 `automatic_enable=false` 防止扫描 Mason 中的全部软件包并作为 LSP 启动。只有
语言表选中的 server 会 enable；无参数 `:LspInstall` 会按当前 buffer filetype 提示候选，因此纯净安装
不依赖它选择 server。统一命令在支持 LSP 的档位安装选中 server，在基础档位只处理仍可用的 formatter。
StyLua 不会作为 LSP 启动。

clangd initialize 只发送标准 `general.positionEncodings`，不会发送 nvim-lspconfig 默认配置中兼容旧
客户端的 `offsetEncoding` 扩展。clangd 22.1.6 返回标准 `positionEncoding="utf-8"`，client 实际使用
`utf-8`；该版本同时返回的同值旧 response 字段不属于客户端发送能力，clangd 23 移除它后核心仍使用
标准结果。升级 clangd 或 nvim-lspconfig 时必须用含多字节文本的 C buffer 复测位置，而不是隐藏弃用日志。

LSP attach 后提供 definition、references、hover、rename、code action、诊断和手动格式化按键，完整
列表见 [`keymaps.md`](keymaps.md)。Neovim 0.12 使用 `:lsp` 和 `:checkhealth vim.lsp` 检查 client。

### LuaLS workspace root 边界

Neovim 0.12.3 实际消费锁定 nvim-lspconfig 的新版 `lsp/lua_ls.lua`：先按 `.emmyrc.json` 或
`.luarc*`，再按 StyLua/Selene 配置，最后按 `.git` 搜索祖先 root；仓库只叠加 settings 和
capabilities，没有覆盖 `root_dir`。Neovim 找到 marker 后把该目录同时用于 `root_dir` 和
workspace folders。Telescope scratch preview 是 `nofile` buffer，而核心 LSP enable callback 不会为
这类 buffer 启动 client。

2026-07-20 使用 Neovim 0.12.3 和真实 LuaLS 3.18.2-dev 完成三类隔离样本：

- 普通 `/tmp` 文件受宿主空 `/tmp/.git` 影响，marker root、client root 和 workspace folder 都准确为
  `/tmp`；
- 更近的 `.stylua.toml` 将三者收敛到该临时项目目录，没有继承更远的 `/tmp/.git`；
- 无祖先 marker 的 `/var/tmp` 文件以 `root_dir=nil`、空 workspace folders 的单文件状态初始化，
  不是 attach 失败。

三个 client 都完成 initialize 和优雅停止，messages 与核心日志为空，LSP 日志各只有启动行。单独的
Telescope 样本选中真实 Lua 文件后，layout state 指向的 preview 含文件内容但保持 `buftype=nofile`，
preview 和全局 client 数都为零。由此 2026-07-19 的 size-limit 提示已定界为交互探针先把普通
`test.c` buffer 改成 `lua`，再由异常宽的空 `/tmp/.git` marker 将 workspace 扩到 `/tmp`；它不是
Telescope preview attach，也不是仓库日常 root 配置缺陷，因此不增加 `lua_ls.root_dir` override。

## 格式化

Conform 根据 filetype 选择 formatter，并以 `lsp_format="fallback"` 作为后备：

- Lua 使用 `stylua`；LuaLS 的 formatting capability 被关闭，避免重复格式化；
- C 使用规范 formatter 名 `clang-format`，由同名 Mason package 提供；`clangd` 只负责 LSP；
- Go 只有在语言开关启用后使用 `gofmt`；
- Elisp 当前没有 formatter。

本仓库内的 Lua 由根目录 `.stylua.toml` 统一定义 LuaJIT syntax、Unix 换行、Tab 缩进、120 列和引号等
规则，Conform 格式化仓库文件时会读取同一配置。维护检查使用 `python3 scripts/check-lua-format.py`，只
检查 Git 跟踪的 Lua 文件，并同时拒绝 BOM、CRLF 和缺失末尾换行；找不到 StyLua 时结果是未验证失败，
不能写成全库格式化通过。

统一命令通过 Mason 安装 StyLua 和 clang-format；也可单独诊断：

```vim
:MasonInstall stylua clang-format
:ConformInfo
```

保存时会触发 Conform。`:ConformInfo` 显示 formatter 不可用时，应检查 provider，而不是仅检查配置表。

## Tree-sitter

支持当前 Tree-sitter 档位时，统一命令先安装 `tree-sitter-cli`，再安装选中的 parser。也可单独诊断：

```vim
:MasonInstall tree-sitter-cli
:DarkroamTSInstall
```

命令按语言表安装 `lua`、`c` 和 `commonlisp`；Go parser family 当前不安装。打开对应 filetype 后由
Neovim 内置 `vim.treesitter.start()` 启动高亮，`commonlisp` 显式注册到 `lisp`。parser 安装位置和
纯净恢复步骤见 [`installation.md`](installation.md)。

## Bootstrap 结果

`:DarkroamBootstrap` 在所有支持档位注册，但版本门槛优先于语言开关：基础档位计划 StyLua 和
clang-format，0.11.3+ 再计划选中的 LSP，0.12+ 再计划 Tree-sitter CLI 和 parser。已安装托管项会跳过，
不会为了验证而刷新 registry。启用 Go 后，不能由 Mason/parser 阶段补齐的 `gofmt` 仍作为外部命令
检查；缺失时结果为 `PARTIAL`，不会把 LSP fallback 记作独立 formatter。

Neovim 在任务运行中退出时，结果为 `CANCELLED`，`last_report()` 记录 `cancel_reason="vim-leave"` 和
尚未完成的 Mason/parser/外部项目。该状态不是安装失败；再次启动后由用户重新执行命令，已成功安装的
项目会按幂等规则跳过。严重异常退出导致 `VimLeavePre` 不执行时，不能保证生成取消摘要。

## 修改语言开关

不能通过只安装一个工具来改变仓库语言状态。新增、关闭或修改语言时，需要先提出方案并同步：

1. `lua/darkroam/languages.lua`；
2. `lua/darkroam/plugins/lsp.lua` 的 server 和 formatter；
3. `lua/darkroam/plugins/treesitter.lua` 的 parser 和 filetype；
4. `lua/darkroam/bootstrap.lua` 的安装和外部命令映射；
5. 本文、依赖清单、插件清单和相关按键；
6. 对应语言 buffer 的 bootstrap 计划、LSP、格式化和 parser 验证。

## 常见判断错误

- Mason package 目录存在，不等于 server 已成功 attach；
- 登录 shell 找不到命令，不等于 Neovim 中 Mason PATH 一定不可用；
- `clangd` 与 `clang-format` 是两个不同命令；
- 语言开关启用但版本门槛禁用 provider，是主动降级而不是开关失效；
- parser 下载成功但无法加载时，还要检查 Neovim 版本、ABI 和实际 runtimepath。
