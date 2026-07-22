# 安装与恢复

本文给出从纯净 clone 到可检查编辑环境的顺序。Linux 是当前经过验证的主路径；Windows 0.12 已有
原生部署步骤和平台 shell 方案，但尚未取得本仓库的 Windows 实机完整验证，因此不能把设计兼容写成
已通过。macOS 只记录配置中确实存在的目录及剪贴板差异。版本支持范围见
[`../reference/compatibility.md`](../reference/compatibility.md)，外部命令见
[`../reference/dependencies.md`](../reference/dependencies.md)。

## 安装边界

仓库只包含配置和 `lazy-lock.json`。以下内容由本机管理，不进入 Git：

- `stdpath("data")` 下的 lazy.nvim、插件、Mason 软件包和 Tree-sitter parser；
- `stdpath("state")` 与 `stdpath("cache")` 下的日志、shada、undo、swap 和缓存；
- 系统命令、字体、剪贴板 provider、凭据和项目历史。

普通启动可以 bootstrap Lazy 并恢复插件，但不会自动安装 Mason 工具或首次所需 parser，也不会修改
系统包。

## 1. 检查前置条件

至少确认 Neovim 和 Git 可用。Unix 还要确认 Zsh；Windows 还要确认 PowerShell：

```sh
nvim --version
git --version
zsh --version        # Unix
pwsh --version       # Windows，或使用 powershell
```

完整功能还需要网络、TLS 证书、`curl`、`tar`、`make`、C compiler，以及按功能选择的 `rg`、
`fd`/`fdfind`、剪贴板 provider 和 Nerd Font。Windows 还要把 Git for Windows 的 `bin/sh.exe` 加入
PATH；现代 Windows 通常自带 `curl.exe` 和 `tar.exe`。准确要求级别以依赖清单为准。

### Windows 前置工具（PowerShell）

下面使用 Scoop 管理用户级工具；已有 Neovim 时只安装缺少项目：

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
Invoke-RestMethod https://get.scoop.sh | Invoke-Expression
scoop install git pwsh ripgrep fd make gcc 7zip
```

LuaSnip 的 Windows `jsregexp` build 还需要 Git `sh.exe`。Scoop Git 通常位于：

```powershell
$gitBin = "$HOME\scoop\apps\git\current\bin"
$env:Path += ";$gitBin"
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$gitBin*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$gitBin", "User")
}
```

重新打开 PowerShell 后检查：

```powershell
Get-Command nvim,git,rg,fd,make,gcc,sh,curl.exe,tar.exe
Get-Command pwsh,powershell -ErrorAction SilentlyContinue
git config --global core.longpaths true
```

Windows 终端应选择 Nerd Font；字体影响图标显示，不影响 Neovim 启动。

### 推荐的用户级多版本布局

Linux 官方 tarball 不覆盖系统软件包，按版本解压到用户目录，并用一个 `current` symlink 选择日常版本：

```text
~/.local/opt/neovim/
├── 0.11.3/
├── 0.11.7/
├── 0.12.3/
└── current -> 0.12.3
```

0.11.3 和 0.11.7 保留给兼容矩阵显式调用，不进入默认 PATH。当前机器只在未跟踪的
`~/.config/shell/profile.local` 选择 Neovim，不建立 `~/.local/bin/nvim`，也不修改共享 profile、Zsh
或 Bash 配置：

```sh
nvim_bin_dir="$HOME/.local/opt/neovim/current/bin"
if [ -x "$nvim_bin_dir/nvim" ]; then
    case ":$PATH:" in
        *:"$nvim_bin_dir":*) ;;
        *) PATH="$nvim_bin_dir:$PATH" ;;
    esac
    export PATH
    export EDITOR="$nvim_bin_dir/nvim"
fi
unset nvim_bin_dir
```

条件判断使 `current` 缺失时保留共享 profile 原有的 `EDITOR=nvim` 和系统 PATH 回退。安装新版本时先放入
新的不可变版本目录并验证，再原子切换 `current`；不要用仓库 Lua 配置或版本控制内的 shell 文件硬编码
本机安装路径。

当前机器已按此布局安装官方 0.11.3、0.11.7 和 0.12.3，`current` 指向 0.12.3；Downloads 中原有
0.12.3 解压目录已经移动，官方 tarball 继续作为恢复源保留。稳定路径已重跑四版本自动矩阵，三个用户级
版本均从各自目录加载 runtime，专用日志为空。已有登录会话不会自动获得新的环境；重新登录或执行
`. ~/.config/shell/profile.local` 后再使用 `command -v nvim`、`nvim --version` 和 `$EDITOR` 核对。

## 2. 备份旧状态

已有配置或运行状态时，先移到自行命名的备份目录。需要考虑的标准位置是：

```text
~/.config/nvim
~/.local/share/nvim
~/.local/state/nvim
~/.cache/nvim
```

不要只替换配置后继续复用旧 Packer start tree；它会绕过 Lazy 的版本条件。备份比直接删除更容易
回退，确认新环境稳定后再处理备份。

Windows 默认路径为 `%LOCALAPPDATA%\nvim`、`%LOCALAPPDATA%\nvim-data` 和
`%TEMP%\nvim-data`；Neovim 0.12 的 `stdpath()` 是最终权威。PowerShell 备份示例：

```powershell
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$targets = @(
    "$env:LOCALAPPDATA\nvim",
    "$env:LOCALAPPDATA\nvim-data",
    "$env:TEMP\nvim-data"
)
foreach ($target in $targets) {
    if (Test-Path $target) { Move-Item $target "${target}.backup-$stamp" }
}
```

## 3. Clone 并恢复插件

```sh
git clone https://github.com/darkroam/nvim-config ~/.config/nvim
nvim
```

Windows 使用：

```powershell
git clone https://github.com/darkroam/nvim-config `
    "$env:LOCALAPPDATA\nvim"
nvim
```

仓库根 `.gitattributes` 固定 tracked 文本的 working-tree 行尾为 LF。该规则在 clone 时覆盖 Windows
常见的 `core.autocrlf=true`，无需为了本仓库修改全局 Git 配置；Lazy 后续以 LF 重写
`lazy-lock.json` 时，也不应再出现 `LF will be replaced by CRLF` 警告。可在仓库中验证实际属性：

```powershell
git check-attr text eol -- lazy-lock.json
git ls-files --eol
```

`lazy-lock.json` 应报告 `text: auto` 与 `eol: lf`，其 working-tree 标记应为 `w/lf`。如果仍有行尾
警告，先确认 clone 已包含 `.gitattributes`，不要用 `git add --renormalize .` 制造无关的全库改写，
也不要把警告误认为插件 commit 已变化；先用 `git diff -- lazy-lock.json` 检查真实内容。

首次启动依次执行：

1. clone `lua/darkroam/lazy.lua` 中固定 commit 的 lazy.nvim；
2. 读取 `lua/darkroam/plugins/*.lua`；
3. 按 `lazy-lock.json` 下载并 checkout 受管插件；
4. 执行首次 build hook，例如 LuaSnip 的 `make install_jsregexp`。

Tree-sitter 首次 build 使用上游推荐的 `build = ":TSUpdate"`。Lazy 处理冒号命令时会先加载插件
和配置，再执行已注册的命令；这取代了曾在命令注册前直接调用 `vim.cmd.TSUpdate()` 的自定义函数。
2026-07-18 修复 `03ea599` 发布到 GitHub `main` 后，从远端全新 clone，并使用独立 `HOME` 与
XDG data/state/cache 复测。Neovim 0.12.3 的首次 restore 确认全部 Lazy task 为 0 error、32/32 checkout
匹配 lockfile，Tree-sitter build 正常输出 `All parsers are up-to-date`。另一套 clean data 上的
Neovim 0.10.4 restore 同样为 0 task error，且按兼容策略不恢复 LSP、Telescope 和 Tree-sitter。
官方 Neovim 0.11.3 和 0.11.7 发布包也分别使用独立 XDG 环境完成 restore；前者 27/27 checkout，
后者 30/30 checkout，均匹配 lockfile 且 LuaSnip build 成功。0.11.3 不恢复 Telescope 和 Tree-sitter，
0.11.7 恢复 Telescope 但仍不恢复 Tree-sitter，与兼容矩阵一致。

完成后检查：

```vim
:Lazy
:Lazy restore
:checkhealth lazy
```

Windows 额外检查 `:set shell?`、`:set shellcmdflag?`，应看到 `pwsh` 或 `powershell`，且参数包含
`-Command`，不能是 `cmd.exe` 的 `/s /c`。`:Lazy` 输出必须确认 LuaSnip 的 `make install_jsregexp`
没有失败；Git `sh.exe` 不在 PATH 是该 build 的常见原因。

不要把 `:Lazy update` 当作安装修复命令；它会改变锁文件目标，必须走受控更新和兼容性验证。
季度与紧急更新的授权、隔离 XDG、拆批、验收和回退规则只在
[`../maintenance/workflow.md`](../maintenance/workflow.md#插件更新周期) 维护。普通安装和故障恢复不得
借更新命令绕过 lock。

## 4. 安装语言工具

插件恢复完成后，显式执行统一安装命令：

```vim
:DarkroamBootstrap
```

该命令只在用户调用后按 `languages.lua` 和当前 Neovim 档位生成计划，不在普通启动时联网。它会跳过
已安装项目；仅在 Mason 项缺失时刷新 registry 并安装，Mason 阶段完成后才在支持档位构建 parser，
最后重新验证 Mason package 及其可执行命令、parser 实际加载和不能由仓库安装的外部命令。命令不会
运行 Lazy restore、系统包管理器或修改 shell/网络环境配置，同一时刻也只允许一个 bootstrap 任务。

版本降级计划如下：

| Neovim | Mason 项 | Parser |
| --- | --- | --- |
| 0.10.x、0.11.0-0.11.2 | `stylua`、`clang-format` | 禁用 |
| 0.11.3+ | 上述两项及 `lua-language-server`、`clangd` | 禁用 |
| 0.12+ | 上述四项及 `tree-sitter-cli` | `lua`、`c`、`commonlisp` |

表中的范围仍受兼容性文档记录的目标版本约束，不表示任意未来 patch 已实测。Go 开关启用后，LSP 档位
还会加入 `gopls`，Tree-sitter 档位加入 Go parser family；系统 Go 工具链中的 `gofmt` 只检查不安装。
旧的 `:LspInstall`、`:MasonInstall` 和 `:DarkroamTSInstall` 仍作为手工诊断入口保留，但纯净安装优先使用
统一命令。

结束时输出一行 `DARKROAM_BOOTSTRAP` 摘要：`OK` 表示托管项和外部要求均满足，`PARTIAL` 表示托管项
成功但外部命令缺失，`FAILED` 表示 Mason/parser 安装或最终验证失败，`CANCELLED` 表示 Neovim 已进入
退出流程。退出 guard 会在 Mason terminator 前冻结 active report；随后到达的失败回调不得累计错误、
启动 parser 或重复发布摘要。Mason 仍可能输出自己的安装终止提示。可用
`require("darkroam.bootstrap").last_report()` 读取最近一次结构化报告；没有运行过时返回 `nil`。

0.10.4、0.11.3、0.11.7 和 0.12.3 均已用延迟假 package 验证取消路径：退出时 pending 项保留、失败回调
不进入 parser、`is_running()` 恢复 false 且只输出一次 `CANCELLED`。0.12.3 的真实 `:qa!` 探针退出码为
0、专用日志为空；同一最终代码的正常完整数据复跑仍只输出一次 `OK`。

0.12.3 先前已在空 Mason/parser 的隔离 data 中通过统一命令安装 `lua-language-server`、`clangd`、
`stylua`、`tree-sitter-cli` 和三个 parser；本次又从空 Mason data 实际安装新增的 `clang-format`
22.1.8，并在完整数据上确认 5/5 Mason、3/3 parser 全部跳过且结果为 `OK`。一次重新下载全部项目的
组合复测因外部下载环境不可用而没有完成，未冒充新的全量 clean pass；既有 4/3 clean 基线和新增
provider 的独立 clean 安装均保留准确边界。0.10.4 已实际使用 `clang-format` 完成保存格式化，没有
触发 LSP 或 parser。0.11.3 和 0.11.7 也分别确认 Mason 可安装 `lua-language-server` 3.18.2-dev 与
`clangd` 22.1.6。两档的 Lua 和 C buffer 都只有预期 server attach，并通过项目 root、buffer-local
`gd` 与 hover 请求检查；LuaLS formatting 保持关闭。受限沙箱中，lua-language-server 虽启动并回复
`$/hello`，但内部 worker
无法处理 initialize；即使移除 `workspace.library`，20 秒最小探针仍复现，说明不是 runtime library
扫描导致。使用同一 Mason package 在沙箱外复测时，最小探针 59 ms 完成 initialize；加载本仓库真实
配置后 55 ms 完成自动 attach，root、当前 runtime library 入口、buffer-local `gd`、禁用 LuaLS
formatting 和实际 hover 请求均通过。判断安装结果时应区分配置失败与执行环境限制。

当前锁定的 nvim-lspconfig 仍在 clangd 默认配置中声明兼容旧客户端的 `offsetEncoding` 扩展。仓库在
发送 clangd initialize 请求前删除该字段，只发送 Neovim 提供的标准
`general.positionEncodings`。clangd 22.1.6 返回标准 `capabilities.positionEncoding="utf-8"`，Neovim
client 最终使用 `utf-8`；该 server 版本还返回同值的旧 response 字段，但未来移除不会影响核心处理的
标准结果。仓库不改写其他 clangd capability、命令或 hook，也不通过过滤 stderr 隐藏问题。升级 clangd
或 nvim-lspconfig 时仍须复测 initialize payload、协商结果和多字节位置，不能仅凭请求成功判断兼容。

C formatter 使用 Conform 的规范名称 `clang-format`，由同名 Mason package 提供；`clangd` 仍是不同的
LSP 软件包，不能互相替代。当前机器由用户手工安装的 `clang-format` 22.1.8 已在 Neovim 的 Mason PATH
中实际可用；纳入统一命令后，纯净环境不再需要单独执行 `:MasonInstall clang-format`。项目存在
`.clang-format` 时由工具自动读取；没有项目配置时沿用上游 LLVM fallback，仓库不注入全局 C 风格。

## 5. 安装 parser

`:DarkroamBootstrap` 已包含支持档位的 parser 安装。需要单独重试 parser 时执行：

```vim
:DarkroamTSInstall
```

如果首次 Lazy 恢复输出 Tree-sitter build 错误，不要用第二次启动存在此命令来代替纯净安装验证。

该命令根据 `languages.lua` 安装当前选择的 parser。也可显式执行：

```vim
:TSInstall lua c commonlisp
```

parser 写入 `stdpath("data")/treesitter-0.12`。插件升级后使用 `:TSUpdate`；较旧 Neovim 不加载当前
Tree-sitter 栈，也不应尝试用该命令绕过版本门槛。

## 6. 验证安装

至少检查：

```vim
:checkhealth
:Lazy
:Mason
:ConformInfo
:checkhealth vim.lsp
```

再分别打开 Lua、C 和 Emacs Lisp 文件，确认实际 LSP attach、formatter 可用性、parser 高亮和按键。
Neovim 0.12 使用内置 `:lsp` 查看 client。命令存在、目录存在或退出码为零都不能单独证明功能通过；
还要检查完整输出中的错误。

Windows 还应执行 `:echo has("win32")`、`:lsp`，打开 Lua/C/Emacs Lisp 文件检查 client、formatter 和
parser；用 `:!Write-Output ok`、`:ToggleTerm`、`Get-Clipboard` 和 `"+yy` 验证 PowerShell、终端和
原生剪贴板。Telescope 的 `,rr`/`,dd` 需要 `fd`/`rg` 在 Neovim PATH 中可见。`check-compat.py` 当前是
POSIX/XDG 维护脚本，不能替代 Windows 原生验收。

### 离线兼容性 smoke

维护版本门槛或插件锁时，可复用已经完整恢复的 Lazy data 对多个二进制运行自动 smoke。命令不负责
下载二进制或插件；`--data-home` 必须包含 `nvim/lazy` 下与当前 `lazy-lock.json` 一致的全部 checkout：

```sh
python3 scripts/check-compat.py \
  --data-home ~/.local/share \
  --case 0.10.4=/usr/bin/nvim \
  --case 0.11.3=~/.local/opt/neovim/0.11.3/bin/nvim \
  --case 0.11.7=~/.local/opt/neovim/0.11.7/bin/nvim \
  --case 0.12.3=~/.local/opt/neovim/0.12.3/bin/nvim
```

驱动器为每个 case 创建临时 HOME 与 XDG wrapper，阻止验证阶段通过 Git HTTPS 补下载，并检查实际
版本、进程输出、成功标记和专用 Neovim 日志。checkout 缺失、commit 不匹配、声明版本不符、非零
退出、`Error detected`、`E[0-9]{3,}:`、traceback、provider error 或非空内部日志都会返回失败。
成功只代表启动、版本门槛和基础插件触发；Mason、真实 LSP、formatter、parser 与 GUI 仍按上文步骤
单独验证。

当前脚本已使用完整的 32 个锁定 checkout 对 0.10.4、0.11.3、0.11.7 和 0.12.3 跑通同一条命令；
活动 spec 数分别为 25、27、30 和 32。版本标签冒充会返回 1，缺失 data 会在启动前返回 2，因此不能
用错误二进制或空插件目录制造假通过。

## 故障恢复

- Lazy bootstrap 失败：检查 Git、网络和 TLS；保留完整错误，不要手工放入未知 commit 的插件目录。
- Lazy 恢复输出 `Command not found: TSUpdate`：说明首次 build 顺序修复没有生效，必须判为失败；
  不要仅凭退出码 0 或第二次启动正常而忽略。
- 旧版出现 Telescope/LSP/Tree-sitter 最低版本错误：检查是否仍有 Packer start package 绕过条件加载。
- shell 或 ToggleTerm 失败：使用 `:set shell?` 和 `:set shellcmdflag?` 核对；Unix 执行
  `command -v zsh`，Windows 执行 `Get-Command pwsh,powershell`，且 Windows 参数必须使用 `-Command`，
  不能保留 `cmd.exe` 的 `/s /c`。
- 系统 PATH 找不到 Mason 工具：以 `:Mason` 和 `:ConformInfo` 为准，同时确认 server 是否真正启动。
- clangd 日志出现 `offsetEncoding capability is a deprecated clangd extension`：说明 initialize 前的
  capability 清理没有生效，应检查最终发送参数和 nvim-lspconfig 配置合并；不要过滤 stderr 或把退出码
  0 当作通过。
- 自动 smoke 在启动前报告 checkout 缺失或 commit 不符：先在受控联网步骤完成 `:Lazy restore`，再
  重新离线运行；验证脚本本身不会改变插件版本或补下载。

回退时成套恢复旧配置和与其匹配的 data 备份，不要把旧 Packer tree 与当前 Lazy 配置混用。

## 其他平台

macOS 和 Linux 使用 `~/.config/nvim`；Windows 通常使用 `$env:LOCALAPPDATA\nvim`。仓库分别保留
`lua/darkroam/macos.lua` 和 `lua/darkroam/windows.lua` 的剪贴板设置。Linux 的完整安装和交互验证已完成；
Windows 仍须按本页清单完成目标机器实测后，才能更新兼容性文档的验证状态。
