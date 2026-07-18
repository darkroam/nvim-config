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
| 0.12.3 | 完整 | 启用 | 启用 | `main` 新 API 与 Textobjects | 当前工作树已通过隔离首次 Lazy、Mason、parser、插件触发、C/Elisp 和 StyLua 验证；LuaLS initialize、发布后 clone 和 GUI 仍未完成 |
| 0.11.7+ | 降级 | 启用 | 启用 | 当前栈禁用 | 设计目标，尚未取得对应二进制实测 |
| 0.11.3-0.11.6 | 降级 | 启用 | 禁用 | 当前栈禁用 | 设计目标，尚未取得对应二进制实测 |
| 0.11.0-0.11.2 | 基础 | 禁用 | 禁用 | 当前栈禁用 | 设计目标，尚未取得对应二进制实测 |
| 0.10.x | 基础 | 禁用 | 禁用 | 当前栈禁用 | 0.10.4 已完成启动和基础插件验证 |

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

Tree-sitter 已使用 Lazy 标准冒号 build，隔离首次恢复的 32/32 checkout、LuaSnip build 和全部 Lazy
task 均通过。相同环境还确认 Mason 四个工具、三个 parser、C/Elisp buffer 和活动插件命令；LuaLS
虽自动启动但 180 秒内未完成 initialize，因此完整档位仍保留该未验证项。0.10.4 的独立 clean data
restore 为 0 task error，LSP、Telescope 和 Tree-sitter spec、checkout、命令与按键均保持缺席。

## 共享状态边界

0.12 parser 安装到 `stdpath("data")/treesitter-0.12`。较旧档位还会从 runtimepath 移除公共
`stdpath("data")/site`，避免读取 ABI 不兼容的 parser 或旧 Packer start package。一个 lockfile
无法同时锁定同一插件的 `main` 和 `master`；如需为旧版恢复完整 Tree-sitter，必须另行设计独立 data
root、lockfile 和验证矩阵。

Mason 软件包、parser、系统命令和插件 checkout 都是机器状态，不属于兼容性承诺。安装与验证步骤见
[`../guide/installation.md`](../guide/installation.md)，当前语言意图见
[`../guide/languages.md`](../guide/languages.md)。

## 变更规则

修改版本门槛时，先更新本文和 `lua/darkroam/compat.lua`，再更新受影响的 plugin spec、用户行为和
验证计划。0.11 在取得对应二进制并检查完整输出前，必须继续标为“设计目标、未实测”。验证不能只看
Neovim 退出码；输出中的 `Error detected`、`E...`、traceback 或 provider error 都表示未通过。
