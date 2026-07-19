# Roadmap

本文只保存尚未完成的工作。`[ ]` 表示待办；暂缓项必须给出恢复条件。优先级描述风险，不代表自动
授权，任何实现仍需按 [`workflow.md`](workflow.md) 单独提交方案并获得确认。

## P2：维护体验

- [ ] 定界独立临时 Lua 文件或 Telescope preview 启动 LuaLS 时的 workspace root：本轮实机提示它扫描
  到同属临时父目录、与当前文件无关的 Mason fixture，并因 500 KB 门槛跳过其中 659 KB 的 meta 文件。
  先在隔离最小目录复现并记录 resolved root/workspace folders；确认是测试布局、上游 fallback 还是
  仓库 root 配置后，再另行提交是否限制 root 的方案。

## 暂缓

当前没有经确认后主动暂缓的项目。以后加入本节的项目必须记录原方案、暂缓原因、可验证的恢复条件、
恢复前需要重新确认的范围和临时安全状态；满足条件后也不会自动开工。

已完成工作只进入 [`history.md`](history.md)，不在本文保留勾选项。
