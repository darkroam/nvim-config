# Roadmap

本文只保存尚未完成的工作。`[ ]` 表示待办；暂缓项必须给出恢复条件。优先级描述风险，不代表自动
授权，任何实现仍需按 [`workflow.md`](workflow.md) 单独提交方案并获得确认。

## P0：兼容性验证

- [ ] 决定下载目录中 0.12.3 二进制的稳定安装位置；配置不得硬编码本机路径。

## P1：安装与工具链

- [ ] 为已确认方向另提实现方案：增加用户显式调用的 `:DarkroamBootstrap`，按 `languages.lua`
  安装 Mason 工具和 parser、验证结果并输出摘要；不得在启动时自动联网或调用系统包管理器。
- [ ] 补齐 C 格式化 provider 或调整 C 的 Conform 行为；区分 Mason `clangd` 和独立
  `clang-format`，未安装前不能把实际 C 格式化记为通过。
- [ ] 在升级到 clangd 23 或更新 nvim-lspconfig 前，处理其将移除的旧 `offsetEncoding` 扩展：当前
  锁定 nvim-lspconfig 会声明该能力，clangd 22.1.6 记录弃用提示但 initialize、hover 和 shutdown
  均通过；后续方案必须验证标准 `positionEncodings` 协商，而不是只过滤 server stderr。

## P1：编辑行为

- [ ] 核对 `formatoptions` 追加 `r` 后又移除 `cro` 的真实目标，更新注释并以 buffer 行为验证。
- [ ] 评估 buffer-local LSP `<leader>e` 覆盖全局 NvimTree `<leader>e` 是否符合预期。
- [ ] 审查 ToggleTerm 中没有仓库按键的 Lazygit、Node、ncdu、htop、Python helper，确认保留、改为
  user command、增加按键或删除，并处理 `python` 与 `python3` 命令差异。

## P2：维护体验

- [ ] 建立一致的 Lua 格式化基线，消除历史 UTF-8 BOM 和风格差异；无 formatter 时不得声称全库
  格式化通过。
- [ ] 为 lazy.nvim manager commit 和 `lazy-lock.json` 制定受控更新周期；每次更新包含兼容矩阵
  验证，不能把 `:Lazy update` 当作日常无审查操作。
- [ ] 在正常 GUI/终端会话检查 clipboard、图标字体、NvimTree、Telescope、ToggleTerm 和文档中的
  活动按键；headless 结果不能替代完整交互体验。

## 暂缓

当前没有经确认后主动暂缓的项目。以后加入本节的项目必须记录原方案、暂缓原因、可验证的恢复条件、
恢复前需要重新确认的范围和临时安全状态；满足条件后也不会自动开工。

已完成工作只进入 [`history.md`](history.md)，不在本文保留勾选项。
