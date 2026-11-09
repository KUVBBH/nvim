require("nvim-tree").setup({
  -- 视图
  view = {
    -- 稍微加宽一点，方便看长文件名
    width = 40,
    -- 显示相对行号，方便快速跳转
    relativenumber = true, 
  },
  
  -- 渲染
  renderer = {
    -- 图标
    -- icons = { show = { file = false, folder = false, git = false } },
    -- 合并空文件夹
    group_empty = true,
    -- 开启缩进参考线
    indent_markers = { enable = true },
    -- 高亮 Git 状态
    highlight_git = true,
  },
  
  -- 过滤
  filters = {
    -- 建议改为 false，显示隐藏文件（如 .env, .gitignore），按大写 'H' 可以随时切换
    dotfiles = false,
    -- 隐藏被 git 忽略的文件
    git_ignored = true,
  },
  
  -- Git 集成
  git = {
    enable = true,
  },
  
  -- 打开文件后的行为
  actions = {
    open_file = {
      -- 在小屏幕上很实用：打开文件后自动关闭文件树
      quit_on_open = true,
    },
  },
  
})
