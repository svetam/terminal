local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Indentation (Ruby standard: 2 spaces)
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true

-- Mouse support (touchpad scrolling)
opt.mouse = "a"

-- System clipboard
opt.clipboard = "unnamedplus"

-- Scroll context
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Persistent undo
opt.undofile = true

-- No swap files
opt.swapfile = false
opt.backup = false

-- Appearance
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.wrap = false

-- Splits open in natural direction
opt.splitbelow = true
opt.splitright = true

-- Faster completion experience
opt.updatetime = 250
opt.timeoutlen = 300

-- Allow hidden buffers
opt.hidden = true

-- Show substitution preview
opt.inccommand = "split"

-- Minimal command line height
opt.cmdheight = 1

-- Show filename at the top of each split (winbar)
opt.winbar = "%=%m %f"

-- Set terminal tab title to "project_dir - nvim"
opt.title = true
opt.titlestring = "%{fnamemodify(getcwd(), ':t')} - nvim"
