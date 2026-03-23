local map = vim.keymap.set

-- Save / Quit
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save file (Ctrl+S)" })

-- Smart quit: uses smart_close() from autocmds.lua
-- Editor: closes file, shows empty buffer, focuses tree
-- Tree: exits nvim
map("n", "<leader>q", function() smart_close() end, { desc = "Smart quit" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Window navigation (Alt + arrow keys AND Ctrl + hjkl)
map("n", "<A-Left>", "<C-w>h", { desc = "Move to left window" })
map("n", "<A-Down>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<A-Up>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<A-Right>", "<C-w>l", { desc = "Move to right window" })
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize windows with Ctrl+Arrow
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Move lines up/down in visual mode
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })

-- Keep cursor centered when searching
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Better indenting (stay in visual mode)
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Split management
map("n", "<leader>v", "<cmd>vsplit<cr>", { desc = "Vertical split" })
map("n", "<leader>h", "<cmd>split<cr>", { desc = "Horizontal split" })

-- Buffer navigation
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- ============================================================
-- RubyMine-compatible keybindings (Ctrl replaces Cmd)
-- Mirrors RubyMine shortcuts so muscle memory transfers.
-- ============================================================
-- Ctrl+Shift+O and Ctrl+Shift+F are registered in plugins/telescope.lua
-- so they go through the tree-aware wrapper (avoids 50-50 split issue)
-- Cmd+1 → Ctrl+1  (toggle project tree)
map("n", "<C-1>", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file tree (Ctrl+1)" })
-- Cmd+F1 → Ctrl+Shift+1  (reveal current file in tree)
-- Note: Ctrl+Shift+1 may not work in all terminals; F2 as fallback
map("n", "<F2>", "<cmd>NvimTreeFindFile<cr>", { desc = "Reveal in tree (F2)" })
-- Cmd+B → Ctrl+B  (go to definition) — gd also works
map("n", "<C-b>", vim.lsp.buf.definition, { desc = "Go to definition (Ctrl+B)" })
-- Alt+F7 → Alt+F7  (find usages / references) — gr also works
map("n", "<A-F7>", vim.lsp.buf.references, { desc = "Find references (Alt+F7)" })
-- Shift+F6 → Shift+F6  (rename) — same as RubyMine
map("n", "<S-F6>", vim.lsp.buf.rename, { desc = "Rename symbol (Shift+F6)" })
-- Alt+Enter → Alt+Enter  (code actions / quick fix)
map("n", "<A-CR>", vim.lsp.buf.code_action, { desc = "Code actions (Alt+Enter)" })
-- Navigate back/forward: use built-in Ctrl+O / Ctrl+I
-- (Alt+Arrow is used for window navigation)

-- Help/cheat sheet
map("n", "<leader>?", "<cmd>lua require('core.help').toggle()<cr>", { desc = "Keybinding cheat sheet" })
map("n", "<F1>", "<cmd>lua require('core.help').toggle()<cr>", { desc = "Keybinding cheat sheet" })
