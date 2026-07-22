# 维护流程

## 核心原则

- 任何修改先只读分析并提交方案，用户明确确认后才修改 tracked 文件；
- 获批后先更新受影响的权威文档和 roadmap，再修改运行配置；
- 实现后联合验证代码、文档和实际输出，准确无误后才提交；
- 新发现不阻塞获批范围时，只加入 [`roadmap.md`](roadmap.md)，不得顺手扩大实现；
- commit 必须在获批范围内，push 永远需要额外明确授权。

根目录 [`../../AGENTS.md`](../../AGENTS.md) 是自动化代理入口，本文是完整政策来源。

## 文档所有权

| 文档 | 唯一职责 | 不应承担 |
| --- | --- | --- |
| `README.md` | 项目摘要、快速安装入口和文档导航 | 完整矩阵、依赖或插件实现细节 |
| `guide/installation.md` | 从纯净 clone 到验证、恢复和平台边界 | 外部依赖要求级别 |
| `guide/usage.md` | 日常工作流和常见故障 | 内部设计决策历史 |
| `guide/languages.md` | 语言开关、LSP、formatter、parser 和用户命令 | 插件 commit 或系统安装快照 |
| `guide/keymaps.md` | 仓库创建或配置的用户按键 | 上游插件全部默认按键 |
| `reference/architecture.md` | 结构、启动顺序、模块关系和状态边界 | 版本矩阵或机器临时状态 |
| `reference/compatibility.md` | 版本矩阵、功能门槛、降级行为和实测状态 | 插件逐项配置 |
| `reference/dependencies.md` | 外部命令、provider、要求级别和缺失边界 | 语言启用状态 |
| `reference/plugins.md` | 插件声明、配置入口、加载条件和状态 | 外部软件安装步骤 |
| `maintenance/roadmap.md` | 待办和有恢复条件的暂缓工作 | 已完成记录 |
| `maintenance/history.md` | 已完成并验证的重要结论 | 原始日志或逐 commit 流水账 |

除根 `README.md` 和 `AGENTS.md` 外，项目维护文档默认使用中文；命令、路径、代码标识和原始输出保持
原样。

## 强制变更顺序

1. 检查代码、文档、Git 状态和相关运行事实，不修改 tracked 文件；
2. 提交具体方案，覆盖范围、非目标、文档影响、步骤、验证、风险和回退；
3. 获得用户明确批准；
4. 先把权威文档和 roadmap 更新到获批目标状态；
5. 只实施获批代码或配置；
6. 用运行结果校正文档，不保留尚未实现的完成态描述；
7. 运行适用检查，审阅完整 diff 和仓库状态；
8. 只有检查通过或基线失败准确记录后才 commit；未经授权不 push。

文档-only 变更也遵循相同门禁。对这类变更，第 4 步表示先修改相关权威页，再更新 README、历史或
检查器等支持文件。

## 方案模板

每份方案至少回答：

- **现状与证据**：当前行为、版本、Git 状态和可复现事实；
- **目标与范围**：要改变什么、涉及哪些文件和用户行为；
- **非目标**：明确不顺带处理的事项；
- **文档影响**：先更新哪些 owner 文档，哪些不受影响；
- **实施步骤**：文档、代码、状态迁移的顺序；
- **依赖与兼容性**：Neovim 档位、插件锁、外部命令、网络和本机写入；
- **验证矩阵**：静态、headless、真实 buffer、交互或实机检查；
- **风险与失败判定**：如何观察、什么算失败、如何缓解；
- **回退**：文件、commit 和 machine-local 状态如何恢复；
- **提交边界**：是否包含 commit；push 默认不包含。

用户确认前只能只读检查。无法执行的验证必须记录限制和恢复条件，不能直接写成通过。

## 变更关联

- 修改 `lua/darkroam/languages.lua` 时，同步 `guide/languages.md`、依赖、插件和验证；
- 修改 `lua/darkroam/compat.lua` 时，同步 `reference/compatibility.md` 和受影响 plugin spec；
- 修改 `lua/darkroam/lazy.lua`、`lua/darkroam/plugins/*.lua` 或 `lazy-lock.json` 时，同步插件清单、
  兼容性、依赖和用户行为；
- 修改全局、插件或 LSP 按键时，同步 `guide/keymaps.md`，并确认 provider 已声明；
- 修改外部工具或安装行为时，同步依赖清单与安装指南；
- 新增 tracked Lua 文件时，在架构、插件或用户文档中建立明确归属；
- 删除文件时，先迁移所有链接、require、按键、清单和 roadmap 引用。

## 插件更新周期

插件和 manager 使用季度审查窗口：每年 1、4、7、10 月最多发起一轮；窗口可以跳过，不会自动运行，
也不构成修改或联网授权。安全问题、目标 Neovim 升级、上游兼容故障或已确认 bug 可以单独提出紧急
方案，但仍遵循完整确认门禁。日常启动的 Lazy checker 保持关闭，安装恢复只使用 `:Lazy restore`。

每轮更新先在旧 lock 上确认工作树干净、文档/Lua 检查和当前兼容矩阵基线，再提交列出目标 manager
commit、插件名单、预期 branch、相关 upstream 变更、网络步骤、文档影响和专项验证的方案。获批后使用
独立 worktree 或 clone，以及隔离的 `HOME`、XDG config/data/state/cache/runtime；日常 data 不能作为
生成或验收新 lock 的环境。

manager 与普通插件分阶段处理：

1. manager 阶段先审阅准确 commit range，只选择一个完整 commit；同步修改 `lazy.lua` 的
   `lazy_commit` 和 `lazy-lock.json` 的 `lazy.nvim` 条目，两者不一致即失败。该阶段单独验证并形成可回退
   commit，不用无范围 `:Lazy update` 顺带更新其他插件；
2. 普通插件按 UI/editor、completion/LSP/Mason/formatter、search、Tree-sitter 等功能组拆批。只对方案
   中明确列出的名字执行 `:Lazy update [plugins]`，每批审阅 lock diff；出现未列出的插件、branch 变化、
   意外删除/新增或运行配置需求时停止并重新确认；
3. 用新 lock 在隔离 data 执行 `:Lazy restore`，检查 Lazy task/build、lockfile 声明的全部 checkout
   （当前 32 个）的 HEAD 和 tracked clean 状态，再运行四版本矩阵。manager、build hook 或门槛变化
   至少补做 0.12.3 完整路径和 0.10.4 基础路径的 clean restore；受影响的 LSP、formatter、parser、
   搜索或 UI 还要做真实专项验证。

退出码为零但输出或日志含 Neovim/provider 错误、checkout 与 lock 不符、build 失败、旧版门槛回归、
专项行为失败或文档无法准确描述时均不得接受新版本。回退时恢复该批之前的 Git commit，并在受影响的
隔离或日常 data 执行 `:Lazy restore` 回到旧 lock；不要手工 checkout 若干目录制造混合状态。每批只在
全部检查通过后提交，push 仍需额外授权。

## 验证标准

每次变更至少执行：

```sh
python3 scripts/check-docs.py
python3 scripts/check-lua-format.py
git diff --check
git status --short
```

检查器验证文档结构和链接、Lua 所有权、Lazy 声明与 lockfile、兼容门槛、语言状态、可静态识别的
自定义按键、roadmap/history 职责、可移植路径和根 `.gitattributes` 的 LF 合同。

Lua 格式检查只消费 Git 跟踪文件和根 `.stylua.toml`，同时验证 BOM、CRLF、末尾换行、StyLua 格式与
AST 等价性。找不到 formatter 时退出 2，必须记录“StyLua 不可用，格式未验证”，不能因为编码预检或
其他命令成功就声称全库格式通过。更新 StyLua 后若产生新 diff，先审阅规则和 formatter 版本再改代码。

代码变更还要执行受影响的 Lua 和 Neovim 检查。Headless Neovim 可能打印错误后返回零，因此必须捕获
并审阅标准输出和标准错误中的 `Error detected`、`E...`、traceback 和 provider error。网络、GUI、
硬件或交互限制应准确写为“未验证”或“环境受限”。

修改兼容门槛、Lazy spec、manager commit 或 `lazy-lock.json` 时，在拥有目标二进制与完整预恢复 data
的环境运行 `scripts/check-compat.py`。该脚本只做离线 smoke，不替代首次 restore、Mason、LSP、parser
或 GUI 验证；缺失的矩阵 case 必须在提交说明和兼容性文档中明确保留为未验证。

## Git 与仓库卫生

- 开始和结束都检查 `git status --short --branch`，保留用户已有改动；
- 根 `.gitattributes` 必须保持 `* text=auto eol=lf`，让 tracked 文本在 Linux、macOS 和 Windows 的
  working tree 中统一使用 LF；新增确实要求 CRLF 的文件类型时只能添加明确的扩展名 override；
- 行尾策略变更后检查 `git check-attr text eol -- lazy-lock.json` 与 `git ls-files --eol`；不得在未审阅
  全部结果时执行或提交无范围的 `git add --renormalize .`；
- 不提交日志、shada、session、缓存、插件、Mason 包、parser、构建产物或凭据；
- 提交前审阅完整 diff，只 stage 获批范围；
- 一个 commit 形成一个可独立解释和回退的检查点；
- 不重写历史、不 force push，也不自动 push。

活动方向和暂缓条件见 [`roadmap.md`](roadmap.md)，已经验证的重大结果见
[`history.md`](history.md)。
