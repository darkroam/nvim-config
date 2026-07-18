# 维护历史

本文件只记录已经完成并验证的重要项目，不复制原始日志或逐 commit 流水账。待办和有恢复条件的暂缓
工作统一见 [`roadmap.md`](roadmap.md)。

## 2026-07-18：纯净安装失败定界

- [x] 使用独立 `HOME` 和 XDG config/data/state/cache，从 GitHub `main` 重新 clone，确认测试对象为
  `a44507c0d8735f23651d04bc23db797ee8d90c85` 且 clone 工作树干净。
- [x] Neovim 0.12.3 首次 `:Lazy! restore` 完成 lazy.nvim bootstrap；manager 与 31 个受管插件共
  32/32 checkout 匹配 `lazy-lock.json`，LuaSnip 的 `jsregexp` 原生模块构建成功。
- [x] 完整输出同时确认 `nvim-treesitter` build 报
  `Command not found: TSUpdate`；第二次启动时 `:TSUpdate` 和 `:TSInstall` 均已注册，故根因是首次
  build 与 plugin 命令注册的顺序，而不是锁文件缺失。
- [x] 一次代理 TLS fetch 中断没有改变最终 checkout，但配置错误已经使纯净安装失败；按获批边界
  停止 Mason、parser、语言 buffer 和 0.10.4 后续验证，修复与完整复测继续由 roadmap 跟踪。

## 2026-07-18：个人配置文档重组

- [x] 对比 rafi/vim-config、jdhao/nvim-config、brainfucksec/neovim-lua、ayamir/nvimdots 和
  ThePrimeagen/init.lua，按确认选择采用面向未来自己和自动化代理的分层任务式文档。
- [x] 将文档重组为 `guide / reference / maintenance`，新增纯净安装、语言能力和单一兼容矩阵入口；
  README 保持简短导航，全部项目文档继续随 Git clone 离线可用。
- [x] 将 TODO 与暂缓状态合并到 roadmap，将方案模板合入 workflow；审计中的当前事实迁入权威文档，
  不再长期保存原始审计流水。
- [x] 更新 `scripts/check-docs.py`，在原有链接、Lua 所有权和 Lazy lock 检查上增加兼容门槛、单一语言
  表、静态自定义按键、维护状态和旧路径检查。
- [x] 文档合同和 whitespace 检查通过；隔离 state/cache/log 的 0.12.3 与 0.10.4 headless 启动输出
  分别确认完整能力开启和三项版本门槛关闭，没有 Neovim 配置错误。
- [x] 纯净 clone 全流程和 `:DarkroamBootstrap` 实现没有混入本次文档变更，继续由 roadmap 跟踪。

## 2026-07-17：Lazy、Neovim 0.12 与旧版降级兼容

- [x] 经方案确认，以 Neovim 0.12.3 为完整功能主路径，建立 `compat.lua` 的 LSP 0.11.3、Telescope
  0.11.7、Tree-sitter 0.12.0 集中门槛；0.11 保持未实测标记。
- [x] 将停止维护且无锁的 Packer 迁移为 lazy.nvim 11.17.5；manager 与 31 个受管 plugin commit 共 32 条
  写入 `lazy-lock.json`，文档检查器验证声明、inventory、lock 和 bootstrap commit 一致。
- [x] 将全部活动配置迁到 7 个 Lazy spec；插件命令、按键、依赖和 `cond` 同处声明，旧版不再执行
  `plugin/`/`after/plugin/` 的不兼容路径。实际 Packer tree 已移到
  `~/.local/share/nvim/packer-backup-20260717`，保留回滚副本。
- [x] 修正 Mason-LSPConfig 的 `automatic_enable=false`，只在显式 `:LspInstall` 时刷新 registry；0.12.3
  实测 Lua buffer 只有 `lua_ls` attach，C buffer 只有 `clangd` attach，StyLua 不再成为 LSP。
- [x] 以命名 `LspAttach`/highlight augroup 和原生 document highlight 取代 Illuminate deprecated API；
  Conform 的 StyLua 格式化和 C 的 clangd fallback 均通过实际 buffer 验证。
- [x] 按 nvim-treesitter `main` 新 API 配置启动、高亮和缩进，单独初始化 Textobjects；parser 隔离到
  `treesitter-0.12`，安装并通过 health 检查 `lua`、`c`、`commonlisp`，`af`/`if` 与 Elisp
  `lisp -> commonlisp` 映射实测生效。
- [x] Lazy 与 Telescope health 通过；0.12.3 的主题、基础 plugin 配置、锁定 checkout 和插件命令检查
  通过。0.10.4 实测正常启动并可打开/格式化 Lua，系统 parser runtime 保留且不读取 0.12 ABI；
  LSP/Telescope/Tree-sitter plugin 命令及仓库按键缺席，而 NvimTree、Conform、cmp、Comment、surround、
  ToggleTerm、Lualine 和 Zsh 路径可加载。
- [x] 删除 Packer、impatient、popup、未消费 cmp source、Illuminate、project.nvim、全部无 provider 配置
  和 Neogit/Markdown/TableMD 失效按键；修正 Comment、LuaSnip、Conform、ToggleTerm、Lualine 与
  autocommand 的已确认问题。

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
- [x] 当时发现的运行缺陷没有被文档工作静默修复；后续 Lazy、Zsh 和兼容性修改均通过独立方案完成，
  其余事项继续由 roadmap 跟踪。

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
