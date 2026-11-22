
#### 字体

- Termux字体文件位置`~/.termux/`



#### 环境变量 > `.bashrc`

```bashrc
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"
export ZHIPU_API_KEY=""
export DEEPSEEK_API_KEY=""
```


#### Termux

- LUA`pkg install lua-language-server`
- telescope`pkg install ripgrep`
- ```bash

extra-keys = [\
    [\
        {key: '=', popup: '=='}, \
        {key: '+', popup: '+='}, \
        {key: '-', popup: '->'}, \
        {key: '*', popup: '*='}, \
        {key: '/', popup: 'BACKSLASH'}, \
        {key: '$', popup: '&'}, \
        'UP', \
        'DOWN' \
    ], \
    [ \
        'TAB', \
        {key: '(', popup: ')'}, \
        {key: '[', popup: ']'}, \
        {key: '{', popup: '}'}, \
        {key: "'", popup: '"'}, \
        {key: '_', popup: '|'}, \
        'LEFT', \
        'RIGHT' \
    ], \
    [ \
        'ESC', \
        'CTRL', \
        {key: ':', popup: ';'}, \
        {key: '#', popup: '.'}, \
        {key: '!', popup: '?'}, \
        {key: '<', popup: '^'}, \
        {key: ',', popup: '`'}, \
        {key: '>', popup: {key: KEYBOARD, display: '键盘'}} \
    ] \
]



# shortcut.create-session = ctrl + …

# shortcut.next-session = ctrl + _

# shortcut.previous-session = ctrl + ~


```

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

