# Termux 开发环境搭建（Android + Neovim）

把原先的 `111.txt` 手工清单整理为**可分步执行、每步可校验**的说明文档。
不提供一键脚本的原因：换源路径与 Termux 版本强相关、`pkg upgrade` 可能中途交互、SSH 密钥与 API Key 需要人工确认，脚本化后出错点反而更难定位。

**执行原则**：一次只粘贴一个代码块 → 跑完看「验证」→ 异常查「报错处理」→ 再进入下一块。

**顺序设计理由**

1. 先给存储权限：后续从 `~/storage/downloads` 取文件、备份配置都要它
2. 先换源再 `update`：官方源在国内易超时，先换省时间
3. 先 `upgrade` 再 `install`：避免旧依赖版本导致解析冲突
4. Git 身份放在 clone 之前：否则提交会出现 `empty ident` 报错
5. 环境变量用 `>>` 追加前先 `grep` 查重：避免重复写
6. SSH 与 LSP 放最后：不阻塞主流程，且依赖前面装好的 `git` / `node`

---

## 0. 前置条件

**意图**：确认版本，否则换源路径会写错（这是原清单最大的隐患）。

```bash
termux-info | head -5
echo $PREFIX
```

- 必须是 **F-Droid 或 GitHub Releases** 的 Termux（≥ 0.118）。Play Store 版本已停更，仓库地址和路径都不同
- `$PREFIX` 应为 `/data/data/com.termux/files/usr`

**报错处理**

| 现象 | 处理 |
|---|---|
| `termux-info: command not found` | `pkg install -y termux-tools` |
| 版本 < 0.118 | 卸载后从 F-Droid 重装，不要继续下面的换源步骤 |

---

## 1. 授予存储权限

**意图**：Termux 的 `~` 是应用私有目录，读写 `/storage/emulated/0`（下载目录、共享盘）需要单独授权。

```bash
termux-setup-storage
```

**验证**

```bash
ls ~/storage
```

应看到 `dcim downloads movies music pictures shared` 等软链接。

**报错处理**

- 没有弹窗 → 系统设置 → 应用 → Termux → 权限 → 文件与媒体 → 允许
- `~/storage` 不存在 → 重新执行；仍失败则 `pkg install -y termux-tools` 后重试
- 无法访问 `Android/data` → Android 11+ 系统限制，非脚本问题

---

## 2. 更换 APT 镜像源

**意图**：官方源 `packages-cf.termux.dev` 在国内延迟高，`pkg upgrade` 常卡住。

**推荐做法（最稳，自动匹配仓库名）**

```bash
termux-change-repo
# Mirror group → China → TUNA（清华）→ OK
```

**手动做法**（先备份，再按版本选一种）

```bash
cp $PREFIX/etc/apt/sources.list $PREFIX/etc/apt/sources.list.bak
cat $PREFIX/etc/apt/sources.list
```

- 新版（源里是 `packages-cf.termux.dev/apt/termux-main`）：

```bash
sed -i 's@^deb https://packages-cf.termux.dev/apt/@deb https://mirrors.tuna.tsinghua.edu.cn/termux/apt/@' $PREFIX/etc/apt/sources.list
```

- 旧版（源里是 `termux-packages-24`），即 `111.txt` 的写法：

```bash
sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list
```

**验证**

```bash
pkg update
```

无 404、无长时间无响应即可。

**报错处理**

| 现象 | 处理 |
|---|---|
| `404 Not Found` | 路径与版本不匹配 → `cp sources.list.bak sources.list` 后改用 `termux-change-repo` |
| `Hash Sum mismatch` | `pkg clean && pkg update` |
| `NO_PUBKEY` / GPG 错误 | `pkg install -y --reinstall termux-keyring` |
| `mirror sync in progress` | 镜像正在同步，等 1~5 分钟重试 |
| 反复超时 | 换 `BFSU` / `USTC` 源，或改回官方源 |

---

## 3. 更新与安装基础工具

**意图**：先整体升级，再一次性装齐编辑器与检索工具，减少多次拉元数据。

```bash
pkg update -y && pkg upgrade -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold
```

```bash
pkg install -y git python nodejs neovim ripgrep lazygit stylua lua-language-server openssh
```

- `ripgrep` → Telescope 的 `live_grep`
- `lua-language-server` → `lua_ls`，装系统包比 Mason 编译更省事
- `stylua` → Lua 格式化
- `openssh` → 提供 `ssh-keygen`（未预装时的兜底）

**关于 `x11-repo`（原清单中无用途）**

```bash
pkg install -y x11-repo   # 仅在需要 GUI 应用时安装
```

它只是新增 X11 仓库，本流程里的命令行工具都不需要；提前装会让 `pkg upgrade` 多解析一批包。

**验证**

```bash
for c in git python node nvim rg lazygit stylua ssh-keygen; do printf '%-12s %s\n' "$c" "$(command -v $c || echo MISSING)"; done
```

**报错处理**

| 现象 | 处理 |
|---|---|
| 卡在 `*** config file` 交互 | 用上面的 `--force-confdef --force-confold` 参数 |
| `Unable to locate package` | 先 `pkg update`；再 `pkg search <名字>` 确认包名 |
| `dpkg: error processing` 依赖冲突 | `pkg install -f`，仍失败则 `apt full-upgrade` |
| `No space left on device` | `df -h $PREFIX`；清理 `pkg clean`、`~/.cache` |
| `killed`（内存不足） | 关闭后台应用后重试单个包 |

---

## 4. 配置 Git 身份

**意图**：提交需要合法的 `user.name` / `user.email`，缺失会直接拒绝提交（原清单里 `user.email` 被换行截断，会触发此错）。

```bash
git config --global user.name "your-name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
```

**验证**

```bash
git config --global --list
```

**报错处理**

- `fatal: not a valid email address` → 邮箱缺引号或含空格，用引号包裹
- `fatal: empty ident name` → `user.name` 未设置或为空
- 填错 → `git config --global --unset user.email` 后重设

---

## 5. 部署 Neovim 配置

**意图**：把 dotfiles 拉进 `~/.config/nvim`（私有目录，不受共享存储权限影响），由 `lazy.nvim` 首次启动时自动装插件。

```bash
mkdir -p ~/.config
[ -d ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.bak.$(date +%s)
git clone https://github.com/KUVBBH/nvim.git ~/.config/nvim
```

首次启动（联网，需数分钟）：

```bash
nvim
```

**验证**

```bash
nvim --headless "+Lazy! sync" +qa && echo PLUGINS_OK
nvim +"checkhealth"   # 交互界面看 lsp / treesitter 是否 OK
```

**报错处理**

| 现象 | 处理 |
|---|---|
| `module 'lazy' not found` / 引导失败 | `rm -rf ~/.local/share/nvim/lazy/lazy.nvim` 再开 nvim（原清单这步就是干这个，但**要在失败之后**做，而不是必做项） |
| 插件树彻底混乱 | `rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim` 后重开 |
| `Failed to connect to github.com port 443` | `pkg install -y openssh` 无效；需换网络/代理，或 `git config --global url."https://ghfast.top/https://github.com/".insteadOf "https://github.com/"` 后重试 |
| treesitter 解析器编译失败 | `pkg install -y clang make`，再 `:TSUpdate` |
| `rg: command not found` | 回到第 3 步装 `ripgrep` |
| 状态栏/图标乱码 | 装 Nerd Font 到 `~/.termux/font.ttf` 后 `termux-reload-settings` |

---

## 6. 配置环境变量与 API Key

**意图**：AI 插件从环境变量读密钥，避免写进 `init.lua` 被 git 提交。

```bash
grep -n 'API_KEY\|mason/bin' ~/.bashrc || true
```

```bash
cat >> ~/.bashrc <<'EOF'
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"
export ZHIPU_API_KEY=""
export DEEPSEEK_API_KEY=""
EOF
source ~/.bashrc
```

**验证**

```bash
echo "$DEEPSEEK_API_KEY"; echo "$PATH" | tr ':' '\n' | grep mason
```

或新开一个 Termux 会话再 `echo $ZHIPU_API_KEY`。

**报错处理**

- `source: not found` → 当前是 `sh`/`dash`，执行 `bash -lc 'source ~/.bashrc'`
- 新终端读不到 → 检查 `.bash_profile` / `.profile` 里是否有提前 `return`
- 变量重复 → `grep -n API_KEY ~/.bashrc` 后手工删多余行（`>>` 不具备幂等性）
- 明文密钥风险 → `chmod 600 ~/.bashrc`，切勿把 `.bashrc` 提交到公开仓库

---

## 7. 生成 SSH 密钥并绑定 GitHub

**意图**：以 SSH 方式免密 `push`（`ssh-keygen` 默认交互会让人以为卡死，故显式指定路径与空口令）。

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
ssh-keygen -t ed25519 -C "termux@android" -f ~/.ssh/id_ed25519 -N ""
cat ~/.ssh/id_ed25519.pub
```

复制输出，粘贴到 GitHub → Settings → SSH and GPG keys → New SSH key。

**验证**

```bash
ssh -T git@github.com
```

出现 `Hi <user>! You've successfully authenticated` 即成功（退出码 1 属正常）。

**报错处理**

| 现象 | 处理 |
|---|---|
| `ssh-keygen: command not found` | `pkg install -y openssh` |
| 停在 `Enter passphrase` | 直接回车两次；或按上面的 `-N ""` 免口令 |
| `Permission denied (publickey)` | `ssh -vT git@github.com` 看实际使用的 key；`ssh-add ~/.ssh/id_ed25519` |
| `Host key verification failed` | `ssh-keyscan github.com >> ~/.ssh/known_hosts` |
| 22 端口被屏蔽 | `~/.ssh/config` 写 `Host github.com` / `HostName ssh.github.com` / `Port 443` |
| `bad permissions` 警告 | `chmod 600 ~/.ssh/id_ed25519` |

---

## 8. 安装 LSP 与格式化工具

**意图**：补齐 Python 侧（`black` 格式化、`basedpyright` 类型检查）。`basedpyright` 优先走 Mason，因为第 6 步已把 `mason/bin` 加入 PATH。

```vim
:MasonInstall basedpyright
```

npm 全局安装的兜底方案（装到 `$PREFIX/bin`，同在 PATH 内）：

```bash
npm install -g basedpyright
python -m pip install --upgrade black
```

**验证**

```bash
basedpyright --version
black --version
```

**报错处理**

| 现象 | 处理 |
|---|---|
| `npm WARN EBADENGINE` | 仅警告，可忽略 |
| npm `EACCES` | `npm config get prefix` 应为 `$PREFIX`；否则 `npm config set prefix $PREFIX` |
| `pip: command not found` | 用 `python -m pip` |
| `externally-managed-environment` | 建虚拟环境：`python -m venv ~/.venv && source ~/.venv/bin/activate` |
| nvim 找不到 `black` | `:echo exepath('black')`，为空则把所在目录加入 `.bashrc` 的 PATH |

---

## 9. 整体自检

```bash
termux-info | head -3
for c in git nvim rg lazygit stylua node python ssh-keygen black basedpyright; do
  printf '%-14s %s\n' "$c" "$(command -v $c || echo MISSING)"
done
ssh -T git@github.com 2>&1 | head -1
git -C ~/.config/nvim remote -v
```

全部有路径、`ssh -T` 返回 `Hi ...`，即环境可用。

---

## 附：相对 `111.txt` 的准确性修正

| 原写法 | 问题 | 本文档 |
|---|---|---|
| `git config --global user.email` 后换行跟邮箱 | 邮箱成为独立命令，报 `command not found` 且邮箱未设置 | 合并为单行并加引号 |
| `sed` 换源只匹配 `termux-packages-24` | 新版 Termux 源是 `apt/termux-main`，替换后 404 | 先 `cat` 判断版本，或直接用 `termux-change-repo` |
| 无备份即 `sed -i` | 写错只能重装 Termux | `cp sources.list{,.bak}` |
| `pkg upgrade -y` | 可能停在 conffile 交互提示 | 追加 `--force-confdef --force-confold` |
| `echo ... >> ~/.bashrc` | 重复执行产生重复行 | 先 `grep` 查重 |
| `source ~/.bashrc` | 仅在交互式 bash 生效；写进脚本对当前进程无效 | 在交互 shell 执行，或新开会话 |
| `ssh-keygen -t ed25519 -C "GitHub"` | 交互提问路径/口令，易误判为卡死 | `-f ... -N ""` |
| 无条件 `rm -rf ~/.local/share/nvim/lazy/lazy.nvim` | 首次安装前删除无意义 | 仅在 `lazy` 引导失败后执行 |
| `pkg install x11-repo` | 与后续包无依赖关系 | 标为可选 |
| `pkg install ripgrep` 顺序靠后 | 装完 nvim 才发现 Telescope 不能用 | 与工具同批安装，并加自检 |
| 无校验步骤 | 哪步失败不清楚 | 每节附「验证」与「报错处理」 |
