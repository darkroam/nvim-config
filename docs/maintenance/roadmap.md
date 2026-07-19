# Roadmap

本文只保存尚未完成的工作。`[ ]` 表示待办；暂缓项必须给出恢复条件。优先级描述风险，不代表自动
授权，任何实现仍需按 [`workflow.md`](workflow.md) 单独提交方案并获得确认。

## P1：编辑行为

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
