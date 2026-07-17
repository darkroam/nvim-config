# 当前待办

这里只保留活动工作。每项都必须先形成独立方案并获得确认；优先级描述风险，不代表自动授权实施。

## P0：兼容性验证

- [ ] 取得 Neovim 0.11.3 和 0.11.7 二进制，分别验证 LSP-only 与 LSP+Telescope 档位；在此之前
  `architecture.md` 和用户指南必须保持“设计目标、未实测”的表述。
- [ ] 为 0.10.4、0.11.3、0.11.7 和 0.12.3 建立离线优先的自动验证或 CI，确保 startup output 中的
  `Error detected`、`E...` 和 traceback 能使检查失败，而不是只依赖 Neovim exit status。
- [ ] 决定 `~/Downloads` 中 0.12.3 二进制的稳定安装位置；配置不得硬编码本机下载目录。

## P1：工具链与行为

- [ ] 补齐 C 格式化 provider 或调整 C 的 Conform 行为；区分 Mason `clangd` 和独立
  `clang-format`，未安装前不能把实际 C 格式化记为通过。
- [ ] 核对 `formatoptions` 追加 `r` 后又移除 `cro` 的真实目标，更新注释并以 buffer 行为验证。
- [ ] 评估 buffer-local LSP `<leader>e` 覆盖全局 NvimTree `<leader>e` 是否符合预期。
- [ ] 审查 ToggleTerm 中没有仓库按键的 Lazygit、Node、ncdu、htop、Python helper，确认保留、改为
  user command、增加按键或删除；同时处理 `python` 与 `python3` 命令差异。

## P2：维护体验

- [ ] 建立一致的 Lua 格式化基线，消除历史 UTF-8 BOM 和风格差异；无 formatter 时不得声称全库
  格式化通过。
- [ ] 为 lazy.nvim manager commit 和 `lazy-lock.json` 制定受控更新周期；每次更新必须包含兼容矩阵
  验证，不能把 `:Lazy update` 当作日常无审查操作。
- [ ] 在正常 GUI/终端会话检查 clipboard、图标字体、NvimTree、Telescope、ToggleTerm 和所有文档中的
  活动按键；headless 结果不能替代完整交互体验。

有明确恢复条件、但当前不处于活动状态的项目见 [`suspended.md`](suspended.md)，已完成工作见
[`history.md`](history.md)。
