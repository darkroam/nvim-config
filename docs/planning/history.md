# 维护历史

本文件只记录已经完成并验证的项目。活动和挂起工作分别见 [`todo.md`](todo.md) 与
[`suspended.md`](suspended.md)。

## 2026-07-17：Neovim shell 迁移至 Zsh

- [x] 确认 `/usr/bin/zsh` 5.9 可用、Fish 不存在，并经方案确认后先更新架构、依赖和用户文档。
- [x] 将 `lua/darkroam/options.lua` 的固定 shell 从 `fish` 改为 `zsh`；ToggleTerm 继续通过
  `vim.o.shell` 继承，无需建立第二个 shell 决策点。
- [x] 隔离环境加载 options 后确认 `shell=zsh`、命令可执行，并通过该 shell 得到 `zsh-ok`；39 个
  Lua 文件解析和文档一致性检查通过。
- [x] 完整配置启动输出确认 `configured shell: zsh`，且没有 Fish 相关错误；既有 Neovim 0.10/0.11
  兼容错误保持不变，继续由活动 TODO 跟踪。

## 2026-07-17：文档与治理基线

- [x] 全量盘点 41 个原 tracked 文件、39 个 Lua 文件、启动顺序、语言开关、Packer 声明、插件 hook、
  自定义按键、外部命令和当前机器运行基线。
- [x] 参考 home dotfiles 文档的 `project / planning / user` 分层，为独立 Neovim 仓库建立对应架构。
- [x] 将 README 重写为兼容性、安装、启动关系和文档导航入口，不再保留过时 NullLS 安装说明。
- [x] 建立架构、依赖、插件、维护政策、审计、TODO、挂起、历史、用户指南和快捷键权威边界。
- [x] 建立 `AGENTS.md` 的“方案确认—文档先行—实现—验证—提交”强制流程。
- [x] 建立 `scripts/check-docs.py`，关联必需文档、内部链接、tracked Lua、Packer 声明和语言状态。
- [x] 文档检查、检查器 Python 编译、39 个 Lua 文件解析和 staged whitespace 检查通过；真实配置
  headless 启动的既有 0.10/0.11 错误与审计记录一致，未被误记为成功。
- [x] 当前运行缺陷没有被文档工作静默修复；Neovim 0.10/0.11 冲突、插件无锁、遗留 provider、
  固定 `fish` 和 autocommand 风险均保留为活动 TODO。

## 2026-06-25：近期代码整理

- [x] `eb0d224`：以 Conform 替换 NullLS，并按语言开关选择 formatter。
- [x] `531df31`：加入统一语言开关、Emacs Lisp filetype 和按开关生成的 LSP/Mason/Tree-sitter 状态。
- [x] `921a29c`：移除缺失的 Tree-sitter commentstring hook。
- [x] `bfffaeb`：精简 Lua/Go 配置和大量旧插件配置，但留下若干禁用/遗留文件与按键待审查。

## 2022-2024：配置形成

- [x] 2022 年完成从 Vimscript 到 Lua、Packer、LSP/cmp、Tree-sitter、Telescope、Git、终端和 UI 插件
  的主要配置。
- [x] 2022 年加入 Markdown table、surround、Prettier 等当时的插件路径；其中部分 provider 后来从
  声明中移除，但配置或按键仍保留。
- [x] 2024 年更新配置，随后在 2026 年进行集中精简。
