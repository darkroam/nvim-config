# 当前待办

这里只保留活动工作。每项都必须先形成独立方案并获得确认；优先级描述风险，不代表自动授权实施。

## P0：启动与可复现性

- [ ] 决定并实施 Neovim 基线：升级实际运行环境到 0.11+，或另行设计兼容 0.10 的 API 与插件版本；
  必须同时验证 LSP、Telescope、Mason-LSPConfig 和完整 startup output。
- [ ] 选择插件可复现策略：评估继续 Packer 并 pin commit、生成可审计 snapshot，或迁移到有锁文件的
  manager；方案必须包含 bootstrap、回退、离线行为和旧插件目录迁移。
- [ ] 在兼容版本上建立可靠 headless 检查，使 startup error 能产生非零验证结果，而不是只依赖
  Neovim 默认 exit status。

## P1：声明与运行一致性

- [ ] 逐项决定遗留 provider：Lspsaga、git.nvim、lsp-colors、lspkind、Neogit、Prettier、Tokyonight、
  Colorizer、Orgmode、ts-autotag；删除、恢复或继续禁用都需同步插件清单和用户行为。
- [ ] 处理无 provider 快捷键：`,gg`、Markdown table 系列和 `,md`；不得继续让可见按键静默调用
  不存在的命令。
- [ ] 审查 `cmp-cmdline`、`cmp-nvim-lua`、`popup.nvim` 和 Lualine `fugitive` extension，确认是启用、
  删除还是作为明确依赖保留。
- [ ] 决定 `fish` 是正式核心依赖还是应改为可移植 shell；当前机器缺少 `fish`，修改前必须确认用户
  的终端工作流偏好。
- [ ] 补齐 C 格式化 provider 或调整 Conform fallback 设计；区分 Mason `clangd` 和独立
  `clang-format`。

## P1：配置安全与维护性

- [ ] 用命名 augroup 和 Lua API 重构全局 `autocmd!`、`autocmd! TermOpen`，验证不会清除 builtin、
  插件或其他用户事件。
- [ ] 核对 `formatoptions` 追加 `r` 后又移除 `cro` 的真实目标，更新注释并以 buffer 行为验证。
- [ ] 评估 `impatient.nvim` 及每次启动 profiling 是否仍需要，结合启动时间和上游维护状态决定。
- [ ] 建立一致的 Lua 格式化基线，处理 UTF-8 BOM 和 Gitsigns 风格差异；不能在无 formatter 时声称
  全库格式化通过。

## P2：验证和用户体验

- [ ] 在 Neovim 0.11+ 的正常用户会话验证 Packer bootstrap、Mason、Tree-sitter、LSP、Conform、
  Telescope、NvimTree、ToggleTerm、clipboard 和所有文档中的活动按键。
- [ ] 为关键配置增加最小自动检查或 CI，并避免联网安装成为每次静态检查的前提。
- [ ] 评估 buffer-local LSP `<leader>e` 覆盖全局 NvimTree `<leader>e` 是否符合预期。
- [ ] 审查 ToggleTerm 中未绑定的 Lazygit、Node、ncdu、htop、Python toggle 函数，确认保留、加按键或
  删除；同时处理 `python` 与 `python3` 命令差异。

有明确恢复条件、但当前不处于活动状态的项目见 [`suspended.md`](suspended.md)，已完成工作见
[`history.md`](history.md)。
