
#### 字体

- Termux字体文件位置`~/.termux/`



#### 环境变量 > `.bashrc`

```bashrc

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"
export OPENAI_API_KEY="KEY"
```


#### Termux

LUA`pkg install lua-language-server`
telescope`pkg install ripgrep`

---

### 一、项目结构

```
~/.config/nvim/
├── init.lua                     # 入口：按顺序 require 全局模块与各插件配置
├── lazy-lock.json               # lazy.nvim 插件版本锁（已被 .gitignore 忽略）
├── nvim-pack-lock.json          # 原生 vim.pack 锁（已被 .gitignore 忽略）
├── rules/
│   ├── 基础规则/                # 每次新对话自动注入（CodeCompanion 读取）
│   │   ├── 1_基础规则.md
│   │   └── 2_编码守则.mdc
│   └── 规则/                    # 规则库，按需通过 /rules 手动加载
│       ├── FastAPI最佳实践.mdc
│       ├── Go语言规范.mdc
│       └── ...（按技术栈分类的 .mdc 规则集）
└── lua/
    ├── settings.lua             # 原生选项（缩进/行号/撤销文件等）
    ├── keymaps.lua              # 全局键位
    ├── config/lazy.lua          # lazy.nvim 引导 + leader 设置
    ├── plugins/plug_list.lua    # 插件清单（唯一安装入口）
    ├── ai-list.lua              # LLM endpoint / api_key / model 单一数据源
    ├── ai-rules.lua             # 规则组定义示例（当前未被 init.lua 引用）
    ├── lazyvim-zh.lua           # which-key 中文按键说明
    ├── key-help.lua             # <leader>h VIM 速查浮窗
    ├── lualine-config.lua       # 主题 tokyonight-moon + 状态栏
    ├── bufferline-config.lua    # 顶部 buffer 标签
    ├── nvim-tree-config.lua     # 文件树
    ├── treesitter-config.lua    # Treesitter 白名单高亮
    ├── lsp-config.lua           # pyright / lua_ls + 引用高亮
    ├── cmp-config.lua           # nvim-cmp 补全键位与来源
    ├── formatter.lua            # conform.nvim 保存时格式化
    ├── autopairs-config.lua     # 括号自动配对
    ├── atone-config.lua         # 撤销树（左侧面板）
    ├── telescope-config.lua     # 模糊查找
    ├── comment-translate-config.lua  # 注释 / 沉浸式翻译
    ├── codecompanion-config.lua      # AI 对话主体配置
    └── CodeCompanion-help.lua        # 聊天窗口内 @ # / 速查浮窗
```

### 二、启动流程

`init.lua` 的 require 顺序决定加载时机，改动时不要随意调整：

1. `settings` —— 先落地基础 `vim.opt`，避免插件读不到默认值。
2. `keymaps` —— 先设置全局 leader（`<Space>`）与通用映射。
3. `config.lazy` —— 引导 lazy.nvim（缺失时自动 `git clone`），设置
   `mapleader = " "`、`maplocalleader = "\\"`，再 `import = "plugins"`。
4. 依次 require 各插件配置文件：`lazyvim-zh`、`lualine-config`、`nvim-tree-config`、
   `treesitter-config`、`lsp-config`、`formatter`、`bufferline-config`、`key-help`、
   `autopairs-config`、`atone-config`、`telescope-config`、`comment-translate-config`、
   `codecompanion-config`、`CodeCompanion-help`。

注意：

- 这里大部分配置文件是**直接 require 并调用 `setup()`**，所以 `plug_list.lua` 中对应
  条目没有写 `config = function()`；新增插件若沿用这种方式，需保证 lazy.nvim 已完成
  加载，否则会出现 `module not found`。更稳妥的做法是改为插件的 `config` 字段。
- `codecompanion-config.lua` 是例外：整个 `setup` 包在 `User VeryLazy` 自动命令里，
  确保 adapter 依赖的 `ai-list` 与插件本体已就绪。
- `lazyvim-zh.lua` 通过 `VeryLazy` / `LazyLoad` / `LazyFile` 以及 `BufReadPost`、
  `BufEnter`、`WinEnter`、`CursorHold` 反复尝试注入 which-key 描述（1 秒内去重），
  属于兜底重试设计，重复触发是预期行为。

### 三、插件清单

插件统一在 `lua/plugins/plug_list.lua` 中声明，版本由 `lazy-lock.json` 锁定。

| 插件 | 作用 | 配置文件 | 加载条件 |
| --- | --- | --- | --- |
| `folke/which-key.nvim` | 按键提示，配合中文描述 | `lazyvim-zh.lua` | `priority = 10000` |
| `folke/tokyonight.nvim` | 主题 `tokyonight-moon` | `lualine-config.lua` | 默认 |
| `nvim-lualine/lualine.nvim` | 状态栏 | `lualine-config.lua` | 默认 |
| `nvim-tree/nvim-tree.lua` | 文件树，宽 40，打开文件后自动关闭 | `nvim-tree-config.lua` | 默认 |
| `nvim-tree/nvim-web-devicons` | 文件图标 | — | 依赖 |
| `nvim-treesitter/nvim-treesitter` | 语法高亮（main 分支） | `treesitter-config.lua` | `build = :TSUpdate` |
| `HiPhish/rainbow-delimiters.nvim` | 括号彩虹配色 | 无独立配置 | 默认 |
| `XXiaoA/atone.nvim` | 撤销树，左侧面板宽 0.9 | `atone-config.lua` | 默认 |
| `mason-org/mason.nvim` | LSP / 工具安装器 | `opts = {}` | 默认 |
| `mason-org/mason-lspconfig.nvim` | Mason 与 lspconfig 桥接 | `opts = {}` | `ft = lua/python/css/html` |
| `neovim/nvim-lspconfig` | LSP 客户端配置 | `lsp-config.lua` | 依赖 |
| `hrsh7th/nvim-cmp` | 补全引擎 | `cmp-config.lua` | `ft = lua/python/css/html` |
| `hrsh7th/cmp-nvim-lsp` / `cmp-buffer` / `cmp-path` | 补全来源 | `cmp-config.lua` | 依赖 |
| `stevearc/conform.nvim` | 保存时格式化 | `formatter.lua` | `ft = lua/python/css/html` |
| `windwp/nvim-autopairs` | 括号自动配对 | `autopairs-config.lua` | `event = InsertEnter` |
| `akinsho/bufferline.nvim` | 顶部 buffer 标签栏 | `bufferline-config.lua` | 默认 |
| `lewis6991/gitsigns.nvim` | 变更标记 | 无独立配置 | 默认 |
| `nvim-telescope/telescope.nvim` | 模糊查找 | `telescope-config.lua` | 默认 |
| `nvim-telescope/telescope-fzf-native.nvim` | 加速 fzf 排序 | — | `build = make` |
| `noir4y/comment-translate.nvim` | 注释 / 沉浸式翻译 | `comment-translate-config.lua` | 默认 |
| `olimorris/codecompanion.nvim` | AI 对话、内联编辑 | `codecompanion-config.lua` | 默认 |

`yianwillis/vimcdoc`（中文帮助）在 `plug_list.lua` 中已注释，但 `nvim-pack-lock.json`
仍保留其记录；重新启用时需确认帮助文件已生成（`:helptags`）。

### 四、键位总表

leader 为 `<Space>`，localleader 为 `\`。

#### 4.1 全局键位（`lua/keymaps.lua`）

| 键位 | 模式 | 功能 |
| --- | --- | --- |
| `<leader><leader>` | n | 保存 |
| `<leader>q` | n | 保存并退出 |
| `<leader>!` | n | 强制退出 |
| `<leader>N` | n | 取消搜索高亮 |
| `J` / `K` | v | 选中块向下 / 向上移动并保持选中 |
| `<leader><right>` / `<leader><left>` | n | 下一个 / 上一个 buffer |
| `<leader>b` | n | 关闭当前 buffer |
| `<leader>h` | n | 打开 VIM 速查浮窗（`key-help.lua`） |

#### 4.2 文件与搜索

| 键位 | 功能 |
| --- | --- |
| `<leader>n` | 打开文件树（`:NvimTreeOpen`） |
| `<leader>ff` | 查找文件 |
| `<leader>fg` | 实时全文搜索（依赖 `ripgrep`） |
| `<leader>fb` | 查看缓冲区列表 |
| `<leader>fh` | 帮助标签搜索 |

#### 4.3 编辑、运行与翻译

| 键位 | 模式 | 功能 |
| --- | --- | --- |
| `<leader>f` | n / v | conform 格式化（异步，LSP 兜底） |
| `<leader>(` | n | 开 / 关 autopairs |
| `<leader>u` | n | 撤销树 `Atone toggle` |
| `<leader>R` | n（仅 Python buffer） | 保存后执行 `!python <file>` |
| `<leader>tr` | v | 翻译并替换选中注释 |
| `<leader>tt` | n | 行内沉浸式翻译开关 |

#### 4.4 LSP

| 键位 | 功能 |
| --- | --- |
| `gd` | 跳转定义 |
| `gD` | 跳转声明 |
| `gr` | 查找引用 |
| `<leader>rn` | 重命名符号 |

光标停留（`CursorHold` / `CursorHoldI`）自动高亮引用，移动后清除；高亮样式为
`#b4f9f8` 背景 + 黑色加粗字（写引用额外加下划线），并在 `ColorScheme` 事件后重新应用。

#### 4.5 补全（`lua/cmp-config.lua`）

| 键位 | 功能 |
| --- | --- |
| `<CR>` | 仅在显式选中条目时确认，否则换行 |
| `<Tab>` | 菜单可见时向下选择，否则正常缩进 |
| `<S-Tab>` | 菜单可见时向上选择 |

补全来源：`nvim_lsp`、`buffer`、`path`。

#### 4.6 AI 对话（`lua/codecompanion-config.lua`）

| 键位 | 模式 | 功能 |
| --- | --- | --- |
| `<leader>ac` | n / v | 打开 / 关闭聊天窗口（保留历史） |
| `<leader>ai` | n / v | 内联生成 / 原地修改 |
| `<leader>aa` | n / v | Actions 菜单（提示词库） |
| `<leader>av` | v | 对选中代码提问 |

聊天缓冲区（`filetype=codecompanion`）内的附加键位：

| 键位 | 功能 |
| --- | --- |
| `<leader>@` | `@` 工具速查浮窗（含说明与示例） |
| `<leader>#` | `#` 上下文变量速查浮窗 |
| `<leader>/` | `/` 斜杠命令速查浮窗 |

浮窗内 `q` / `<Esc>` 关闭，`j` `k` `<C-d>` `<C-u>` 滚动，底部预览窗随光标实时更新。

### 五、LSP / Mason

`lua/lsp-config.lua` 使用 Neovim 0.11+ 的原生 `vim.lsp.config` / `vim.lsp.enable`：

- 全局兜底：`vim.lsp.config("*", { root_markers = { ".git" } })`。
- `pyright`：`cmd = { "pyright-langserver", "--stdio" }`，项目标记
  `pyrightconfig.json` / `pyproject.toml` / `setup.py`，诊断模式 `openFilesOnly`，
  开启 `autoSearchPaths` 与 `useLibraryCodeForTypes`。
- `lua_ls`：`cmd = { "lua-language-server" }`，项目标记 `.luarc.json` / `.luarc.lua`。
- 统一启用：`vim.lsp.enable({ "pyright", "lua_ls" })`。

依赖说明：

- `pyright-langserver` 由 Mason 安装，需确保 `~/.local/share/nvim/mason/bin` 在 `PATH` 中。
- `lua-language-server` 由 Termux 包管理器安装，因此 `cmd` 使用命令名而非绝对路径。
- 新增语言三步走：`vim.lsp.config("<server>", {...})` → `vim.lsp.enable(...)` →
  在 `plug_list.lua` 中 `mason-lspconfig.nvim`、`nvim-cmp`、`conform.nvim` 的 `ft` 列表补文件类型。

### 六、格式化（conform.nvim）

`lua/formatter.lua`：

- `python` → `black`，`lua` → `stylua`（其他语言可在 `formatters_by_ft` 追加）。
- `format_on_save` 开启，`timeout_ms = 500`，失败或超时回退到 LSP 格式化。
- `notify_on_error = true`，格式化报错会弹出通知。

`black` 与 `stylua` 需自行安装并置于 `PATH`；未安装时保存不会阻塞编辑，只是不产生格式化结果。

### 七、Treesitter

`lua/treesitter-config.lua` 采用**白名单**策略，只对下列文件类型启动高亮：

```
lua, python, html, css, markdown, markdown_inline, bash
```

流程：`require("nvim-treesitter").install(langs)` 安装解析器（main 分支 API），
再通过 `FileType` 自动命令对命中白名单的 buffer 执行 `vim.treesitter.start`。
新增语言只需在 `supported_languages` 表里加一项，重启后解析器自动安装。

### 八、AI 集成

#### 8.1 配置数据源

所有 API 参数集中在 `lua/ai-list.lua`：

| 用途 | key | endpoint | 默认模型 | 环境变量 |
| --- | --- | --- | --- | --- |
| CodeCompanion | `codecompanion.deepseek` | `https://api.deepseek.com` | `deepseek-v4-flash` | `DEEPSEEK_API_KEY` |
| CodeCompanion | `codecompanion.zhipu` | `https://open.bigmodel.cn/api/paas/v4` | `glm-4-flash` | `ZHIPU_API_KEY` |
| 注释翻译 | `comment.zhipu` | `https://open.bigmodel.cn/api/paas/v4/chat/completions` | `glm-4-flash` | `ZHIPU_API_KEY` |

切换模型只改 `codecompanion-config.lua` 顶部一行：

```lua
local MODEL = "deepseek" -- 改为 "zhipu" 即切换智谱
```

因此 `.bashrc` 中实际需要 `DEEPSEEK_API_KEY` 与 `ZHIPU_API_KEY`；上面示例里的
`OPENAI_API_KEY` 在当前配置中未被读取（`openai` adapter 仍处于注释状态）。

#### 8.2 规则注入

`interactions.chat.opts.system_prompt` 是一个函数，运行时：

1. 扫描 `stdpath("config")/rules/基础规则/**/*.md*`；
2. 按文件名排序，拼接为 `--- 文件名 ---` 分段；
3. 追加 `Environment` 段落（OS、Neovim 版本、日期、CWD、项目根、adapter、语言）；
4. 与默认 system prompt 合并返回。

目录为空时 `vim.notify` 警告并回退默认提示词；加载成功会提示文件数量。
所以 `rules/基础规则/` 下的任何 `.md` / `.mdc` 都会成为全局常驻指令，
不要把与项目无关的大文件放进去，否则每次对话都要付出 token 成本。

`rules/规则/` 是规则库，不自动注入，需在聊天中用 `/rules` 手动挑选。

#### 8.3 可用工具与命令

- `@` 工具：`read_file`、`edit_file`、`overwrite_file`、`create_file`、`delete_file`、
  `grep_search`、`file_search`、`run_command`、`get_changed_files`、`get_diagnostics`、
  `search_help`、`web_search`、`fetch_webpage`、`memory`、`ask_questions`；
  工具组：`@{agent}`（全部授权）、`@{files}`（仅文件操作）。
- `#` 上下文：`#{buffer}`、`#{buffers}`、`#{selection}`、`#{viewport}`、
  `#{diagnostics}`、`#{quickfix}`、`#{terminal}`、`#{diff}`、`#{code_review}`、`#{messages}`。
- `/` 命令：`/buffer`、`/file`、`/fetch`、`/symbols`、`/tools`、`/rules`、
  `/compact`、`/fork`、`/save`、`/resume`、`/rename`、`/share`、`/mode`、`/mcp`、
  `/commit`、`/explain`。
- 自定义提示词库：`中文解释代码`、`中文修复代码`（`modes = { "v" }`，自动提交），
  可在 `<leader>aa` 菜单中调用。
- 内置聊天键位：`<C-s>` / `<CR>` 发送，`ga` 接受、`gr` 拒绝、`gv` 查看 diff、
  `gs` 切换 system prompt、`gp` 固定缓冲区、`gw` 监视缓冲区、`gx` 清空、`q` 取消请求。

#### 8.4 可选扩展

配置中已写好的注释块，按需启用：

- MCP：安装 `ravitemer/mcphub.nvim` 后打开 `extensions.mcphub`。
- 会话历史：安装 `ravitemer/codecompanion-history.nvim` 后打开 `extensions.history`。
- ACP 本地 Agent（`claude_code`、`codex`、`gemini_cli` 等）与 `openai` / `anthropic` /
  `gemini` / `ollama` adapter 模板均在注释中，取消注释即可使用。

### 九、UI 与浮窗实现

- `lua/key-help.lua`：`<leader>h` 打开 VIM 速查表，宽度固定 65，高度为屏幕 90%；
  用 `strdisplaywidth` + `pad_str` 对齐中英文混排，左侧键位、右侧说明，中间以 `│` 分隔。
- `lua/CodeCompanion-help.lua`：数据与渲染分离（`data_tools` / `data_context` /
  `data_commands`），共用 `show_cheatsheet(title, groups)`；主窗高度为屏幕 50%
  （上限为行数 + 2），底部再开预览窗显示 `note` 与示例。
- 两者均使用 `nvim_open_win` + `relative = "editor"` + `style = "minimal"` +
  `border = "rounded"`，buffer 设置 `bufhidden = "wipe"`，关闭即销毁。
- `lua/lazyvim-zh.lua` 通过 `which-key.add()` 批量注入中文描述，缓存已被用户覆盖的
  键位与图标，避免全量重建。

### 十、基础选项（`lua/settings.lua`）

- 禁用自动注释续行：`formatoptions` 移除 `c` `r` `o`。
- 持久化撤销：`undofile = true`，`undodir = ~/.data/nvim/undo`（目录需存在）。
- 行号 `number` + `relativenumber`，`cursorline = true`，`signcolumn = "yes"`。
- 缩进：`tabstop` / `shiftwidth` / `softtabstop = 2`，`expandtab`，`autoindent`。
- 折行：`wrap = true`、`linebreak = true`、`breakindent = true`。
- 真彩色：`termguicolors = true`；搜索高亮 `hlsearch = true`。

注意该文件中 `wrap` 被赋值两次（先 `false` 后 `true`），最终生效为 `true`。

### 十一、常见扩展操作

| 目标 | 改动位置 |
| --- | --- |
| 安装新插件 | `lua/plugins/plug_list.lua` 追加条目 |
| 新语言高亮 | `lua/treesitter-config.lua` 的 `supported_languages` |
| 新语言 LSP | `lua/lsp-config.lua` 的 `vim.lsp.config` + `vim.lsp.enable`，并补 `plug_list.lua` 的 `ft` |
| 新语言格式化器 | `lua/formatter.lua` 的 `formatters_by_ft` |
| 新全局键位 | `lua/keymaps.lua` |
| 新 AI 服务商 | `lua/ai-list.lua` 增配置 + `codecompanion-config.lua` 的 `adapters.http` 增函数 + 改 `MODEL` |
| 常驻 AI 规则 | `rules/基础规则/` 下新增 `.md` |
| 主题更换 | `lua/lualine-config.lua` 的 `colorscheme` 与 `lualine.options.theme` |

### 十二、故障排查

- 插件状态：`:Lazy`；整体健康检查：`:checkhealth`。
- LSP 未启动：`:Mason` 确认已安装，`:checkhealth lsp` 检查 `cmd` 是否可执行，
  并确认 `PATH` 含 `mason/bin`。
- 格式化无效果：确认 `black` / `stylua` 在 `PATH`，且 conform 已加载
  （`:ConformInfo` 查看可用格式化器）。
- Treesitter 报错：`:TSUpdate` 重装解析器；白名单外的文件类型本就不会高亮。
- AI 无响应：检查 `ai-list.lua` 中 endpoint 与环境变量是否为空，
  日志位于 `~/.local/state/nvim/codecompanion.log`（`log_level = "WARN"`，
  排查时临时改为 `"DEBUG"`）。
- 规则未生效：确认文件位于 `rules/基础规则/` 且扩展名为 `.md` / `.mdc`，
  聊天时会弹出「已加载 N 个规则文件」通知。
- `lazy-lock.json` / `nvim-pack-lock.json` 被 `.gitignore` 忽略，迁移机器时需手动拷贝
  才能还原完全一致的插件版本。
