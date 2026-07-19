# 维护历史

本文件只记录已经完成并验证的重要项目，不复制原始日志或逐 commit 流水账。待办和有恢复条件的暂缓
工作统一见 [`roadmap.md`](roadmap.md)。

## 2026-07-19：Bootstrap 退出取消闭环

- [x] 定界手动中断的根因：Mason `VimLeavePre` terminator 会以失败回调关闭活动 package，旧计数归零后
  仍进入 parser 阶段；`ExitPre` 因退出仍可能被未保存 buffer 取消，不适合作为可靠状态边界。
- [x] 将 `darkroam.bootstrap.setup()` 移到 Lazy 前，只提前注册命令和 `VimLeavePre` guard，不加载插件
  或联网；四档都确认该 guard 是首个退出 autocmd，执行顺序早于随后注册的 Mason terminator。
- [x] 为每次运行建立唯一 active report，将结果发布改为幂等单出口；退出冻结为 `CANCELLED`，保存
  `cancel_reason="vim-leave"` 和 pending 项。Mason refresh/package 与 parser Task 回调失去 active identity
  后立即返回，不能累计错误、进入新阶段或发布第二份摘要。
- [x] `scripts/compat-smoke.lua` 在 0.10.4、0.11.3、0.11.7、0.12.3 中注入延迟假 package，触发退出后
  再补发失败回调；四档均确认单次摘要、pending 计划、`is_running=false`、错误为空且 parser 未启动，
  最终仍通过 25/27/30/32 spec 矩阵和空日志检查。
- [x] 独立 0.12.3 真实 `:qa!` 探针以状态 0 输出一次 `CANCELLED` 且专用日志为空；正常完整数据路径仍
  输出一次 5/5 Mason、3/3 parser 的 `OK`。保留 Mason 自身终止提示边界，`v:dying >= 2` 的严重异常
  退出不冒充可生成 Lua 取消摘要。

## 2026-07-19：C formatter Provider 闭环

- [x] 确认当前机器由用户通过 Mason 手工安装的 `clang-format` 22.1.8 在 Neovim PATH 中可执行；登录
  shell 没有 Mason PATH 不代表 Neovim provider 缺失，并继续明确区分 formatter 与 clangd LSP。
- [x] 将 `clang-format` 纳入 `languages.lua` 驱动的基础 Mason 计划，并登记可执行入口；计划按层次稳定
  生成为 0.10.4 的 2 项、0.11.3/0.11.7 的 4 项、0.12.3 的 5 项加 3 个 parser，Go 关闭时没有外部缺项。
- [x] 将 Conform 从 deprecated `clang_format` alias 迁移到规范名称 `clang-format`，保留
  `lsp_format="fallback"`；不加入仓库级 C 风格，项目没有 `.clang-format` 时沿用 LLVM fallback。
- [x] 从空 Mason data 由 Bootstrap 实际安装 clang-format 并验证 receipt、22.1.8 可执行命令；当前
  完整数据上 0.12.3 得到 5/5 Mason、3/3 parser、`external=0/0` 和 `OK`，全部项目幂等跳过。
- [x] 0.10.4 与 0.12.3 都在首次保存 C buffer 时通过 Conform 得到相同的四行 clang-format 输出，
  formatter inventory 只有规范名称；0.10.4 的成功证明该路径不依赖 LSP，三份专用日志均为空。
- [x] 最终离线矩阵继续得到 25/27/30/32 个活动 spec，四档命令、计划和门槛全部通过。一次重新下载
  全部 Mason/parser 的组合复测因外部下载环境不可用失败，未记录为全量 clean pass；既有 4/3 clean
  基线与本次新增 provider 的独立 clean 安装分别保留其准确验证边界。

## 2026-07-19：显式语言工具链 Bootstrap

- [x] 新增 `lua/darkroam/bootstrap.lua`，在 Lazy setup 后只注册 `:DarkroamBootstrap`；普通启动不加载
  基础档位的 Mason、不刷新 registry、不安装工具或 parser，也不修改系统包和 shell/网络环境配置。
- [x] 命令按 `languages.lua` 和兼容门槛生成稳定计划：0.10.4 为 `stylua`，0.11.3/0.11.7 加入
  `lua-language-server`、`clangd`，0.12.3 再加入 `tree-sitter-cli` 与 `lua`、`c`、`commonlisp` parser；
  Go 保持关闭但映射随语言开关预留。
- [x] 已安装 Mason 项和 parser 幂等跳过；存在缺项时才刷新 registry，并发安装 Mason 项后再构建
  parser。模块拒绝重复并发调用，通过 `plan()`、`is_running()`、`last_report()` 暴露可测试只读状态。
- [x] 最终验证同时检查 Mason package、对应可执行命令和 parser 实际 ABI 加载；摘要区分 `OK`、
  `PARTIAL`、`FAILED`。当前四个 Mason 项和三个 parser 均通过，但独立 `clang-format` 缺失，所以没有
  冒充完整成功，真实结果为 `PARTIAL`。
- [x] 在空 Mason/parser 的隔离 XDG data 中完成首次执行：StyLua 2.5.2、LuaLS 3.18.2-dev、
  clangd 22.1.6、Tree-sitter CLI 0.26.11 和三个 parser 全部安装；三个 parser 均实际加载并解析示例，
  随后复跑时 4/4 Mason、3/3 parser 全部 `skipped`，两次专用日志均为空。
- [x] 系统 Neovim 0.10.4 在同一数据上实际执行时只消费并跳过 StyLua，未触发 LSP/parser；最终离线
  四版本矩阵继续得到 25/27/30/32 个活动 spec，并新增命令存在、启动无报告、Mason 无额外启动加载和
  四档 `plan()` 的断言，全部退出为 0 且专用日志为空。

## 2026-07-18：Neovim 用户级多版本安装

- [x] 从 GitHub release API 核对官方 Linux x86_64 asset，并验证 tarball 大小与 SHA-256：0.11.3 为
  `02b808a3ee8fc30161e07fe3c3edfb24b28bd0295323ac5dbdd8ec7012cac67d`，0.11.7 为
  `38a7c6317f94503841096c00e8fde05ef04b9472fc9d7d62b6e033cecd6f7991`，0.12.3 为
  `c441b547142860bf01bcce39e36cbed185c41112813e15443b16e5237750724d`。
- [x] 将三档完整发布树安装到 `~/.local/opt/neovim/{0.11.3,0.11.7,0.12.3}`，建立
  `current -> 0.12.3`；Downloads 中 0.12.3 现有解压树与官方 tarball 逐文件一致后再移动，原 tarball
  保留为恢复源，系统 `/usr/bin/nvim` 0.10.4 未改动。
- [x] 唯一修改的 shell 配置是 machine-local `~/.config/shell/profile.local`：以存在性检查将
  `current/bin` 放到 PATH 前端并设置 `EDITOR`。没有创建 `~/.local/bin/nvim`；`.zshrc`、`.zprofile`、
  `.bashrc`、`.profile` 和共享 `shell/profile` 的 SHA-256 与修改前逐项相同。
- [x] 干净登录 Zsh 解析到 `current/bin/nvim` 和 0.12.3；三个用户级版本均从各自安装前缀加载 runtime，
  退出码为 0 且专用日志为空。稳定路径四版本离线矩阵再次得到 25/27/30/32 个活动 spec 并全部通过。
- [x] 仓库 Lua 配置和 tracked shell 文件没有本机二进制路径；自动矩阵对旧版使用不可变版本目录，日常
  选择只由 `current` 与未跟踪 `profile.local` 管理。

## 2026-07-18：四版本离线自动兼容矩阵

- [x] 新增 `scripts/check-compat.py`，以重复的 `--case VERSION=NVIM_PATH` 接受显式二进制，并要求
  `--data-home` 中全部 Lazy checkout 存在、HEAD 匹配 lockfile 且没有 tracked 修改；缺失或偏离时在
  Neovim 启动前失败，不自动 restore、联网、安装或 build。
- [x] 新增 `scripts/compat-smoke.lua`，在真实进程内检查版本标签、32 条 lock、活动 spec、集中功能
  门槛、禁用插件 runtimepath、命令和仓库按键，并真实触发 NvimTree、ToggleTerm、ZenMode 以及版本
  允许的 Telescope/file-browser。
- [x] 使用同一套 32/32 锁定 checkout 完成 0.10.4、0.11.3、0.11.7、0.12.3 矩阵；活动 spec 数依次
  为 25、27、30、32，LSP/Telescope/Tree-sitter 状态依次为全关、仅 LSP、LSP+Telescope、全开，
  四档退出码和成功标记均通过，专用 Neovim 日志为空。
- [x] 验证失败判定：声明 0.12.2 但传入 0.12.3 binary 时返回 1，缺失 data home 时在启动前返回 2；
  输出扫描单测确认 `Error detected`、`E5113:`、traceback 和 provider error 均能令检查失败。
- [x] `scripts/check-docs.py` 现在要求两个支持脚本存在且有文档归属；自动 smoke 不冒充首次 restore、
  Mason、真实 LSP、formatter、parser 或 GUI 验证，这些边界继续由安装与兼容性文档维护。

## 2026-07-18：Neovim 0.11 边界实测闭环

- [x] 取得官方 Neovim 0.11.3 和 0.11.7 Linux x86_64 发布包并校验 GitHub release API 提供的
  SHA-256，分别为 `02b808a3ee8fc30161e07fe3c3edfb24b28bd0295323ac5dbdd8ec7012cac67d` 和
  `38a7c6317f94503841096c00e8fde05ef04b9472fc9d7d62b6e033cecd6f7991`；测试配置副本指向
  `8289b0f` 且工作树干净。
- [x] 使用两套独立 HOME 与 XDG data/state/cache 完成首次 Lazy restore：0.11.3 的 27 个 checkout
  和 0.11.7 的 30 个 checkout 全部匹配 lockfile，LuaSnip `jsregexp` build 通过；前者只有 LSP
  档位，后者同时启用 LSP 与 Telescope，两档均完整禁用当前 Tree-sitter 栈。
- [x] 两档都由 Mason 成功安装 `lua-language-server` 3.18.2-dev 和 `clangd` 22.1.6；真实 Lua/C
  buffer 只有预期 client attach，并通过 project root、buffer-local `gd`、hover、LuaLS formatting
  禁用和优雅 shutdown 检查。
- [x] 0.11.3 与 0.11.7 均通过 NvimTree、ToggleTerm、ZenMode 和 Zsh 真实触发；0.11.7 还通过
  Telescope 与 file-browser 真实触发，0.11.3 则确认相关 spec、checkout、命令和按键全部缺席。
- [x] 最终沙箱外门控和 LSP 探针退出码均为 0，专用 Neovim 日志为空。clangd 22.1.6 对锁定
  nvim-lspconfig 的旧 `offsetEncoding` 扩展记录弃用提示但不影响当前请求；clangd 23 前的标准能力
  迁移已进入 roadmap，没有在本轮静默修改运行配置。

## 2026-07-18：LuaLS 沙箱超时定界

- [x] 在受限沙箱中用 LuaLS 3.18.2 运行无 `workspace.library` 的最小 LSP 探针；Neovim 成功发送
  initialize，server 回复 `$/hello`，但内部 worker 在 20 秒内没有处理 initialize，排除 runtime
  library 扫描和仓库配置作为超时前提。
- [x] 同一个 Mason package、workspace 和最小探针在沙箱外 59 ms 完成 initialize，确认超时来自
  当前执行沙箱的进程、线程或 IPC 限制，不需要修改 LSP 启动命令。
- [x] 沙箱外加载本仓库真实配置，LuaLS 在 55 ms 内自动 attach；root、当前 runtime library 入口、
  buffer-local `gd`、关闭 server formatting 和实际 hover 请求均通过。
- [x] Neovim 专用日志为空，LSP 日志没有错误或 warning；保留当前 `workspace.library` 和 plugin spec，
  仅校正文档与验证方法，并从 roadmap 移除该定界项。

## 2026-07-18：发布后纯净 clone 验证

- [x] 从 GitHub `main` 全新 clone，确认远端与测试工作树都指向修复提交
  `03ea5995b9d0ce843bdf0e0171fbc7047edbf000`，且 clone 工作树保持干净。
- [x] 使用独立 `HOME` 和 XDG config/data/state/cache 验证 Neovim 0.12.3：首次 Lazy restore
  为 0 task error，manager 与受管插件 32/32 checkout 匹配 lockfile，Tree-sitter 与 LuaSnip build
  通过；Mason 四个工具和 `lua`、`c`、`commonlisp` parser 安装完成。
- [x] C buffer 的 clangd attach、Lua buffer 的 StyLua 和 parser、Elisp 的 commonlisp parser，以及
  NvimTree、ToggleTerm、ZenMode、Telescope、file-browser 的真实命令触发路径通过；独立
  `clang-format` 仍保持缺失。
- [x] Neovim 0.10.4 使用另一套 clean data 完成 0 task error restore；LSP、Telescope、Tree-sitter
  的 spec、checkout、命令和仓库按键保持缺席，NvimTree、ToggleTerm、ZenMode 和 Zsh 路径通过。
- [x] LuaLS 当时仅确认 package、配置和自动启动，180 秒内未完成 initialize，未冒充通过；后续已由
  本页上方的沙箱外验证闭环。GUI/终端交互仍未由 headless 测试替代，继续由 roadmap 跟踪。

## 2026-07-18：Tree-sitter 首次安装修复

- [x] 将直接执行 `vim.cmd.TSUpdate()` 的自定义 build 函数改为上游推荐的
  `build = ":TSUpdate"`；Lazy 在执行冒号命令前加载 plugin 和 config，首次恢复不再遇到命令注册
  顺序错误。
- [x] 使用全新隔离 XDG data/state/cache 验证 Neovim 0.12.3 首次 `:Lazy! restore`：全部 Lazy task
  为 0 error，32/32 checkout 匹配 lockfile，Tree-sitter build 和 LuaSnip `jsregexp` build 通过。
- [x] 在同一隔离环境由 Mason 安装四个声明工具并构建 `lua`、`c`、`commonlisp` parser；C 的 clangd
  attach、Lua StyLua、C/Lua/Elisp parser 和 NvimTree、ToggleTerm、ZenMode、Telescope 实际命令触发
  均通过，独立 `clang-format` 仍按文档保持缺失。
- [x] Neovim 0.10.4 使用另一套 clean data 完成 0 error restore；LSP、Telescope、Tree-sitter 的
  spec、checkout、命令和按键缺席，NvimTree、ToggleTerm、ZenMode 与 Zsh 基础路径可用。
- [x] LuaLS package、root、配置和自动启动已确认，但 180 秒内未完成 initialize；该阶段没有冒充
  通过，后续由本页上方的沙箱内外对照验证完成定界。

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
