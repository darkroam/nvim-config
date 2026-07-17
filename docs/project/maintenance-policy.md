# 维护策略

## 核心原则

- 本仓库的任何修改都必须先只读分析并提交方案，得到用户明确确认后才修改 tracked 文件。
- 确认后先更新权威文档和 planning 状态，再实施运行代码或配置。
- 实现完成后先验证代码与文档的完整性、一致性和准确性，再提交 Git commit。
- 未经明确授权不 push，不把“允许 commit”扩展解释为“允许发布远端”。
- 新发现如果不阻塞已确认范围，只记录到 `planning/todo.md`，不得顺手扩大实现。

根目录 [`../../AGENTS.md`](../../AGENTS.md) 是自动化代理的执行入口；本文是完整政策来源。

## 文档权威关系

| 文档 | 唯一职责 | 不应承担 |
| --- | --- | --- |
| `README.md` | 项目摘要、兼容性警告、安装入口和导航 | 完整依赖或逐插件实现细节 |
| `project/architecture.md` | 结构、加载顺序、所有权、运行关系和设计边界 | 某台机器的临时安装状态 |
| `project/dependencies.md` | 外部命令、provider、要求级别和缺失边界 | 插件配置逐项状态 |
| `project/plugins.md` | 插件声明、配置 hook、活动/禁用/遗留状态 | 外部软件包安装清单 |
| `user/usage-zh.md` | 自洽的安装、日常使用和故障处理 | 维护者内部决策历史 |
| `user/keybindings-zh.md` | 仓库自定义按键及当前可用性 | 上游插件全部默认按键 |
| `planning/repository-audit.md` | 有日期和基线 commit 的检查事实 | 永久架构保证 |
| `planning/todo.md` | 仍需行动的活动工作 | 已完成记录或无恢复条件的愿望 |
| `planning/suspended.md` | 有明确恢复条件的延期工作 | 普通活动缺陷 |
| `planning/history.md` | 已完成且验证过的结论 | 尚未完成的计划 |

除根 `README.md` 和 `AGENTS.md` 外，仓库维护文档默认使用中文；命令名、路径、代码标识和原始输出
保持原样。

## 方案门禁

每份方案至少说明：

1. 当前行为和可复现证据；
2. 目标、范围和非目标；
3. 先修改哪些权威文档；
4. 实现步骤及文件边界；
5. 依赖、兼容性和数据/状态影响；
6. 静态、headless、交互或实机验证矩阵；
7. 风险、失败判定和回退方式；
8. 是否包含 commit，以及绝不默认包含的 push。

可复用骨架见 [`../planning/change-template.md`](../planning/change-template.md)。用户确认前只能进行
只读检查；诊断工具意外生成的日志或缓存必须立即移除并确认工作树恢复原状。

## 文档先行规则

方案获批后按以下顺序工作：

1. 更新架构、依赖、插件、用户行为或 planning 中实际受影响的权威文档。
2. 运行文档检查，确保“将要实现的目标状态”内部自洽。
3. 实施已批准代码；不得为了匹配文档而暗中加入方案外行为。
4. 以运行结果校正文档，使最终文档只描述实际验证后的状态。
5. 将完成项从 TODO/计划迁到 history，挂起项必须附恢复条件。

单纯修正文档也需要方案确认，但不需要伪造代码改动。紧急修复若没有用户给出的特殊授权，也不绕过
本流程。

## 变更关联规则

- 修改 `lua/darkroam/languages.lua` 时，同步架构、依赖、用户指南以及 LSP/Mason/Conform/
  Tree-sitter 消费关系。
- 修改 `lua/darkroam/plugins.lua` 时，同步 `project/plugins.md`、依赖和用户可见功能。
- 修改 `lua/darkroam/keymaps.lua` 或插件按键时，同步 `user/keybindings-zh.md`，并确认 provider
  确实已声明。
- 修改最低 Neovim 版本、Packer/锁定策略或外部工具时，同步 README 和依赖文档。
- 新增 tracked Lua 文件时，必须在架构、插件清单或用户文档中建立明确归属。
- 删除文件时，先删除或迁移所有内部链接、按键、require、插件清单和 planning 引用。

## 验证标准

每次文档修改至少执行：

```sh
python3 scripts/check-docs.py
git diff --check
git status --short
```

`scripts/check-docs.py` 验证：

- 必需文档及 README 导航是否完整；
- Markdown 内部链接是否指向现存文件；
- 每个 tracked Lua 文件是否在权威文档中有归属；
- Packer 直接声明是否全部出现在插件清单；
- `languages.lua` 与架构、依赖、用户指南的启用/禁用表是否一致；
- TODO、suspended、history 是否保持各自状态职责；
- 文档是否意外写入本机绝对 home 路径。

代码变更还应执行受影响的 Lua/Neovim 检查。Headless Neovim 的退出码不能单独作为结论：必须捕获并
审阅标准输出和标准错误中的 `Error detected`、`E...`、traceback 和 provider 错误。受沙箱、网络、
GUI 或交互条件限制的项目应准确写为“未验证”或“环境受限”，不能伪造通过。

文档架构可以在准确记录既有 runtime failure 的前提下独立提交；涉及相应运行路径的后续行为修改，
不得引入新错误，并必须按获批方案处理相关基线问题。

## Git 与仓库卫生

- 开始和结束都检查 `git status --short --branch`，保存并尊重用户已有改动。
- 不提交 `.nvimlog`、shada、session、缓存、插件、Mason 包、parser、构建产物或凭据。
- 提交前运行 `git diff --check` 并审阅完整 diff；只 stage 本次获批范围。
- 一个 commit 应形成可独立解释和验证的检查点，message 明确范围。
- 不重写历史、不 force push，也不自动 push。

## 当前已记录但未决的方向

Packer 是否迁移、插件如何锁定、Neovim 版本如何落地，以及遗留插件配置是否删除，都尚未在本次
文档工作中替用户决定。它们是
[`../planning/todo.md`](../planning/todo.md) 的独立提案对象。
