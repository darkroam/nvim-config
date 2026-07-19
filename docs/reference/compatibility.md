# 兼容性与支持范围

本文是 Neovim 版本档位、功能门槛、降级行为和实测状态的唯一权威来源。README、安装指南、插件清单
和用户指南只引用本文，不各自维护兼容矩阵。

## 支持策略

仓库使用一个配置和一个 `lazy-lock.json`：

- Neovim 0.12.3 是完整功能主路径；
- Neovim 0.10/0.11 以正常启动和基础编辑为目标；
- 锁定插件要求更新 Neovim 时，通过 `lua/darkroam/compat.lua` 和 Lazy `cond` 主动禁用对应功能；
- 旧版不自动切换到另一插件分支、另一 commit 或未记录的本机插件；
- “设计兼容”与“已在对应二进制实测”必须分开记录。

## 版本矩阵

| Neovim | 档位 | LSP | Telescope | Tree-sitter | 验证状态 |
| --- | --- | --- | --- | --- | --- |
| 0.12.3 | 完整 | 启用 | 启用 | `main` 新 API 与 Textobjects | GitHub `main` 的发布后 clone 已通过隔离首次 Lazy、Mason、parser、插件触发、LuaLS、C/Elisp 和 StyLua 验证；Bootstrap 的既有 4/3 clean 基线、新增 clang-format 独立 clean 安装和当前完整 5/3 幂等验证通过；GUI 仍未完成 |
| 0.11.7+ | 降级 | 启用 | 启用 | 当前栈禁用 | 0.11.7 已通过隔离首次 Lazy、Mason、LSP、Telescope、基础插件和禁用边界实测；更高 0.11 patch 未逐一实测 |
| 0.11.3-0.11.6 | 降级 | 启用 | 禁用 | 当前栈禁用 | 下界 0.11.3 已通过隔离首次 Lazy、Mason、LSP、基础插件和禁用边界实测；0.11.4-0.11.6 未逐一实测 |
| 0.11.0-0.11.2 | 基础 | 禁用 | 禁用 | 当前栈禁用 | 设计目标，尚未取得对应二进制实测 |
| 0.10.x | 基础 | 禁用 | 禁用 | 当前栈禁用 | 0.10.4 已完成启动、基础插件和基础 formatter 的实际执行验证 |

“禁用”表示对应插件不进入 runtimepath、配置不执行、仓库为该插件声明的按键不创建。它不表示 data
目录中一定没有旧 checkout；判断活动能力必须同时检查版本、Lazy spec 和 runtimepath。

## 功能门槛

下表必须与 `lua/darkroam/compat.lua` 的 `minimum` 表一致：

| 功能键 | 最低 Neovim | 低版本行为 |
| --- | --- | --- |
| `lsp` | `0.11.3` | 不加载 nvim-lspconfig、Mason-LSPConfig 和 LSP buffer-local 按键 |
| `telescope` | `0.11.7` | 不加载 Telescope、file-browser 和对应按键 |
| `treesitter` | `0.12.0` | 不加载当前 `main` 插件、Textobjects、parser 配置及 `af`/`if` |

门槛针对仓库当前锁定的插件 commit，不是对上游未来版本的永久承诺。更新 `lazy-lock.json` 后必须重新
检查每个可取得档位，不能仅凭旧结论继续声称兼容。

## Bootstrap 降级矩阵

`:DarkroamBootstrap` 本身在所有支持档位存在；命令只按当前版本启用的 provider 生成计划：

| Neovim 档位 | Mason 项 | Parser |
| --- | --- | --- |
| 基础（0.10.x、0.11.0-0.11.2） | 启用语言的基础 formatter；当前为 `stylua`、`clang-format` | 禁用 |
| LSP（0.11.3+） | 上述项目及启用语言的 server；当前为 `lua-language-server`、`clangd` | 禁用 |
| Tree-sitter（0.12+） | 上述项目及 `tree-sitter-cli` | 启用语言的 parser；当前为 `lua`、`c`、`commonlisp` |

这里的“禁用”意味着不把项目放入计划，而不是尝试加载旧插件 API。C formatter 在所有档位由 Mason
管理，不依赖 LSP 门槛；启用 Go 后的 `gofmt` 仍作为外部 formatter 独立检查。命令不会扩大版本支持
承诺，也不会在普通启动时访问网络。

四档都使用核心 `VimLeavePre` API，在 Lazy/Mason setup 前注册同一个退出 guard。活动任务退出时报告
`CANCELLED`；Mason refresh、package 和 Tree-sitter Task 回调只在原 report 仍 active 时继续。选择
`VimLeavePre` 而不是 `ExitPre`，因为后者触发后退出仍可能被未保存 buffer 取消。`v:dying >= 2` 时该
事件不会触发，因此严重异常退出不属于取消摘要承诺。

Tree-sitter 已使用 Lazy 标准冒号 build。发布修复 `03ea599` 后，从 GitHub `main` 全新 clone 的隔离
首次恢复确认 32/32 checkout、LuaSnip build 和全部 Lazy task 均通过；相同环境还确认 Mason 四个
工具、三个 parser、C/Elisp buffer 和活动插件命令。LuaLS 虽自动启动但 180 秒内未完成 initialize，
后续已定界为受限沙箱无法驱动其内部 worker：无 library 的最小探针仍超时，而同一 package 在沙箱外
59 ms 完成最小 initialize，真实配置 55 ms 完成 attach 并通过 hover。由此 LuaLS 在 0.12.3 完整档位
记为已验证，GUI/终端交互仍保持未验证。0.10.4 使用另一套 clean data restore 为 0 task error，LSP、
Telescope 和 Tree-sitter spec、checkout、命令与按键均保持缺席，基础插件真实命令和 Zsh 路径通过。

0.11 下界使用官方 0.11.3 和 0.11.7 Linux x86_64 发布包、指向 `8289b0f` 的干净配置副本以及各自
隔离的 XDG data/state/cache 实测。0.11.3 的 27 个 checkout 与 lockfile 一致，LSP 启用而 Telescope
和 Tree-sitter 完全缺席；0.11.7 的 30 个 checkout 与 lockfile 一致，LSP 与 Telescope 启用而
Tree-sitter 完全缺席。两档的 LuaSnip build、Mason `lua-language-server` 3.18.2-dev 与 `clangd`
22.1.6 安装、NvimTree/ToggleTerm/ZenMode、Zsh、LuaLS 和 clangd 实际 attach 均通过；LuaLS 与 clangd
还验证了项目 root、buffer-local `gd` 和 hover，LuaLS formatting 保持关闭。专用 Neovim 日志为空。
锁定的 nvim-lspconfig 仍声明旧 `offsetEncoding` 扩展；仓库已在 initialize 前从实际 payload 删除
该字段，保留 Neovim 0.11.3+ 的标准 `general.positionEncodings`。0.11.3、0.11.7、0.12.3 均与 clangd
22.1.6 协商出标准 `positionEncoding="utf-8"`，client 使用 `utf-8`；含中文前缀的 definition 返回
UTF-8 byte column 24，hover、root、buffer-local `gd` 和状态 0 shutdown 通过，三份 LSP 日志均没有旧
capability 弃用提示。clangd 22.1.6 仍返回同值的旧 response 字段，但核心标准结果已独立验证。

## 共享状态边界

0.12 parser 安装到 `stdpath("data")/treesitter-0.12`。较旧档位还会从 runtimepath 移除公共
`stdpath("data")/site`，避免读取 ABI 不兼容的 parser 或旧 Packer start package。一个 lockfile
无法同时锁定同一插件的 `main` 和 `master`；如需为旧版恢复完整 Tree-sitter，必须另行设计独立 data
root、lockfile 和验证矩阵。

Mason 软件包、parser、系统命令和插件 checkout 都是机器状态，不属于兼容性承诺。安装与验证步骤见
[`../guide/installation.md`](../guide/installation.md)，当前语言意图见
[`../guide/languages.md`](../guide/languages.md)。

## 自动矩阵边界

仓库提供 `scripts/check-compat.py` 与进程内 `scripts/compat-smoke.lua`，用于对显式传入的二进制运行
离线 smoke。当前目标矩阵是 0.10.4、0.11.3、0.11.7 和 0.12.3；脚本会核对调用者声明版本与实际
`vim.version()`，不能用另一 patch 的结果替代。测试使用调用者预先恢复的完整 Lazy data，启动前
要求全部 32 个 checkout 与 lockfile 一致，因此不会为缺失插件联网或自动修复。

自动矩阵覆盖启动输出、专用 Neovim 日志、集中功能门槛、活动 Lazy spec、runtimepath、命令、自定义
按键以及 NvimTree、ToggleTerm、ZenMode 和版本允许的 Telescope 真实触发。它不安装 Mason 工具或
parser，也不启动真实 LSP、不验证 parser ABI 和 GUI；它只检查 `:DarkroamBootstrap` 在全部档位注册
且 `plan()` 与降级矩阵一致；确定性延迟 package 还用于检查四档退出后的单次 `CANCELLED`、pending
项目和禁止 parser 阶段。这些运行结论仍以本页版本矩阵中的独立实测记录为准。

2026-07-18 使用同一套 32/32 lockfile checkout 首次运行完整自动矩阵：0.10.4、0.11.3、0.11.7 和
0.12.3 分别得到 25、27、30 和 32 个活动 spec，三项功能状态依次为全部关闭、仅 LSP、LSP 加
Telescope、三项全部开启。四个进程均返回 0、输出唯一成功标记且专用 Neovim 日志为空；完整 data 中
保留禁用插件 checkout 没有令其进入旧版 runtimepath。自动矩阵由此记为已验证，但不扩大上文真实
LSP、Mason、parser 或 GUI 的结论。

2026-07-19 加入 bootstrap 后重跑相同四档矩阵，活动 spec 数和功能门槛保持不变；新增检查确认命令
在四档都存在、启动时没有报告或额外 Mason 加载，并且计划依次为 1/0、3/0、3/0、4/3 个 Mason/parser
项目。0.12.3 另在空 Mason/parser data 中完成 4/4 工具与 3/3 parser 首次安装、可执行命令和 ABI 加载
验证，再完成幂等复跑；0.10.4 实际执行只检查并跳过 StyLua。所有对应专用日志为空。

同日将 clang-format 纳入基础 Mason 计划后，最终矩阵的 Mason/parser 数更新为 2/0、4/0、4/0、5/3，
四档仍保持 25/27/30/32 个活动 spec 并全部通过。空 Mason data 已由 Bootstrap 实际安装 clang-format
22.1.8；当前完整数据的 0.12.3 Bootstrap 为 5/5、3/3、无外部缺项并返回 `OK`。0.10.4 和 0.12.3
均通过首次保存的真实 C 格式化，使用规范 formatter 名 `clang-format`，对应专用日志为空。一次重新
下载全部项目的组合复测因外部下载环境不可用失败，因此没有替代既有 4/3 clean 基线或冒充新的全量
clean pass。

同日加入退出 guard 后，四档矩阵都以延迟假 package 启动真实 Bootstrap，再触发 `VimLeavePre` 并补发
终止失败回调；每档只发布一次 `CANCELLED`，pending 计划准确、错误列表为空、parser 安装未启动且最终
兼容成功 marker 与专用日志通过。独立 0.12.3 `:qa!` 进程也以状态 0 输出单次取消摘要、日志为空；正常
完整数据复跑仍为 5/5、3/3、`OK`，证明 guard 没有改写完成结果。

## 变更规则

修改版本门槛时，先更新本文和 `lua/darkroam/compat.lua`，再更新受影响的 plugin spec、用户行为和
验证计划。表中只有明确列出的 patch 版本可以标为实测；同一范围内未逐一取得的 patch 仍不能借用
边界版本结果。验证不能只看 Neovim 退出码；输出中的 `Error detected`、`E...`、traceback 或 provider
error 都表示未通过。语言 server 自身日志里的已知提示也必须检查、解释并跟踪，不能静默忽略。
修改 `compat.lua`、Lazy spec 或 `lazy-lock.json` 时，除文档合同检查外还应对所有可取得的目标二进制
运行自动矩阵；缺少某一二进制或完整 data 时必须明确记录未运行，不能把其他 case 的成功外推过去。
