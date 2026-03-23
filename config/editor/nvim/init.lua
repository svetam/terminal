-- Leader key must be set before plugins load
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable netrw before plugins load (nvim-tree replaces it)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Core configuration
require("core.options")

-- Bootstrap lazy.nvim and load plugins
require("plugins")

-- Keymaps and autocommands after plugins
require("core.keymaps")
require("core.autocmds")
