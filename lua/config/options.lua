local o = vim.opt

-- Indentation
o.expandtab    = true
o.shiftwidth   = 4
o.softtabstop  = 4
o.tabstop      = 4
o.autoindent   = true

-- Line numbers
o.number         = true
o.relativenumber = true

-- Search
o.hlsearch   = true
o.incsearch  = true
o.smartcase  = true
o.ignorecase = true

-- UI
o.showmatch  = true
o.wildmenu   = true
o.cursorline = true
o.lazyredraw = true
o.showcmd    = true
o.showmode   = false
o.laststatus = 2
o.signcolumn = "yes"

-- Wrapping
o.wrap      = true
o.linebreak = true
o.list      = false

-- Timing
o.updatetime = 750

-- Splits
o.splitbelow = true
o.splitright = true

-- Misc
o.conceallevel = 0
o.belloff      = "all"      -- replaces noerrorbells / visualbell / t_vb=

-- Colors (replaces csapprox)
o.termguicolors = true

-- Undo
o.undofile = true           -- persistent undo; dirs live in stdpath (~/.local/state/nvim)

-- Folds (99 = open all folds by default; later commits use ufo)
o.foldlevelstart = 99

-- Tags
o.tags = "./tags;/"
