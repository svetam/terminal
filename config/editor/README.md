# Editor Configuration (Neovim + tmux)

A minimal, portable terminal editor setup for Ruby on Rails development. Replaces RubyMine's core editor and navigation features.

## Prerequisites

```bash
# Core tools
brew install neovim tmux ripgrep fd

# Nerd Font (for file-type icons in tree, status bar, completions)
brew install --cask font-jetbrains-mono-nerd-font

# Ruby LSP (install globally or per-project via Gemfile)
gem install ruby-lsp
```

After installing the font, set your terminal emulator to use **JetBrainsMono Nerd Font** (or another Nerd Font of your choice).

## Setup

Two symlinks — run from the root of this repository:

```bash
# Neovim config
ln -s "$(pwd)/config/editor/nvim" ~/.config/nvim

# tmux config
mkdir -p ~/.config/tmux
ln -s "$(pwd)/config/editor/tmux/tmux.conf" ~/.config/tmux/tmux.conf
```

## First Run

1. Open `nvim` — **lazy.nvim** auto-installs all plugins on first launch
2. Treesitter parsers auto-install for configured languages
3. Mason auto-installs the Ruby LSP server
4. Restart Neovim after initial setup completes

## Keybinding Cheat Sheet

### General

| Key | Action |
|-----|--------|
| `Space` | Leader key |
| `<leader>w` | Save file |
| `<leader>q` | Quit |
| `<Esc>` | Clear search highlight |
| `<C-h/j/k/l>` | Navigate between splits / tmux panes |

### File Tree (nvim-tree)

| Key | Action |
|-----|--------|
| `<leader>e` | Toggle file tree |
| `<leader>f` | Reveal current file in tree |

### Search (Telescope)

| Key | Action | RubyMine Equivalent |
|-----|--------|---------------------|
| `<leader>p` | Find files | Shift+Cmd+O |
| `<leader>sg` | Live grep (project-wide) | Shift+Cmd+F |
| `<leader>sb` | Search open buffers | — |
| `<leader>sw` | Grep word under cursor | — |
| `<leader>sd` | Search diagnostics | — |
| `<leader>sr` | Resume last search | — |

### LSP (Code Intelligence)

| Key | Action | RubyMine Equivalent |
|-----|--------|---------------------|
| `gd` | Go to definition | Cmd+B |
| `gr` | Find references | Alt+F7 |
| `K` | Hover documentation | Ctrl+Q |
| `<leader>rn` | Rename symbol | Shift+F6 |
| `<leader>ca` | Code actions | Alt+Enter |
| `<leader>d` | Show diagnostic float | — |
| `[d` / `]d` | Previous / next diagnostic | F2 |

### Completion

| Key | Action |
|-----|--------|
| `<Tab>` / `<S-Tab>` | Cycle completions |
| `<CR>` | Confirm selection |
| `<C-Space>` | Trigger completion manually |
| `<C-e>` | Dismiss completion |

### Git

| Key | Action |
|-----|--------|
| `]c` / `[c` | Next / previous git hunk |
| `<leader>gb` | Toggle line blame |
| `<leader>gp` | Preview hunk |
| `<leader>gr` | Reset hunk |

### Buffers

| Key | Action |
|-----|--------|
| `<leader>bn` | Next buffer |
| `<leader>bp` | Previous buffer |
| `<leader>bd` | Delete buffer |

### tmux

| Key | Action |
|-----|--------|
| `Ctrl-a` | Prefix (instead of Ctrl-b) |
| `Prefix + \|` | Split vertically |
| `Prefix + -` | Split horizontally |
| `Prefix + c` | New window |
| `Prefix + r` | Reload tmux config |
| `C-h/j/k/l` | Navigate panes (shared with Neovim) |

## Plugin List

| Plugin | Purpose |
|--------|---------|
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Plugin manager |
| [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) | File tree |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder + grep |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP client |
| [mason.nvim](https://github.com/williamboman/mason.nvim) | LSP auto-installer |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | Autocompletion |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Status bar |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git gutter indicators |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Keybinding popup |
| [catppuccin](https://github.com/catppuccin/nvim) | Color scheme |
| [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) | File-type icons |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | Seamless tmux/nvim navigation |
