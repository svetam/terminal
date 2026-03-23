return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
  },
  lazy = false,
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    -- Helper: ensure we're not in the nvim-tree window before opening telescope
    local function focus_editor_window()
      local current_buf = vim.api.nvim_get_current_buf()
      local ft = vim.api.nvim_get_option_value("filetype", { buf = current_buf })
      if ft == "NvimTree" then
        vim.cmd("wincmd l")
        -- If still in tree (no other window), create a split
        local new_ft = vim.api.nvim_get_option_value("filetype", { buf = vim.api.nvim_get_current_buf() })
        if new_ft == "NvimTree" then
          vim.cmd("vsplit | enew")
          -- Restore tree width so it doesn't stay 50-50
          require("nvim-tree.api").tree.resize({ width = 35 })
        end
      end
    end

    -- Wrap telescope builtins to always open from editor window
    local builtin = require("telescope.builtin")
    local function find_files() focus_editor_window() builtin.find_files() end
    local function live_grep() focus_editor_window() builtin.live_grep() end
    local function buffers() focus_editor_window() builtin.buffers() end
    local function help_tags() focus_editor_window() builtin.help_tags() end
    local function grep_string() focus_editor_window() builtin.grep_string() end
    local function diagnostics() focus_editor_window() builtin.diagnostics() end
    local function resume() focus_editor_window() builtin.resume() end

    -- Neovim-native keymaps
    vim.keymap.set("n", "<leader>p", find_files, { desc = "Find files" })
    vim.keymap.set("n", "<leader>sg", live_grep, { desc = "Live grep (project)" })
    vim.keymap.set("n", "<leader>sb", buffers, { desc = "Search buffers" })
    vim.keymap.set("n", "<leader>sh", help_tags, { desc = "Search help" })
    vim.keymap.set("n", "<leader>sw", grep_string, { desc = "Grep word under cursor" })
    vim.keymap.set("n", "<leader>sd", diagnostics, { desc = "Search diagnostics" })
    vim.keymap.set("n", "<leader>sr", resume, { desc = "Resume last search" })

    -- Search in current file (Telescope fuzzy find replaces Vim's /)
    local function buf_search() focus_editor_window() builtin.current_buffer_fuzzy_find() end
    vim.keymap.set("n", "/", buf_search, { desc = "Search in current file" })
    vim.keymap.set("n", "<C-f>", buf_search, { desc = "Search in file (Ctrl+F)" })

    -- Search & replace in current file (pre-fills command, live preview via inccommand)
    -- Ctrl+Shift+H mirrors RubyMine's Ctrl+Shift+R (replace in file)
    vim.keymap.set("n", "<C-S-h>", ":%s/", { desc = "Search & replace (Ctrl+Shift+H)" })

    -- RubyMine-compatible keymaps (same wrappers, Ctrl replaces Cmd)
    vim.keymap.set("n", "<C-S-o>", find_files, { desc = "Find files (Ctrl+Shift+O)" })
    vim.keymap.set("n", "<C-S-f>", live_grep, { desc = "Live grep (Ctrl+Shift+F)" })

    -- Show line numbers in Telescope preview pane
    vim.api.nvim_create_autocmd("User", {
      pattern = "TelescopePreviewerLoaded",
      callback = function()
        vim.wo.number = true
      end,
    })

    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            -- Scroll preview: Ctrl+D/U (half page), Ctrl+Down/Up (line by line)
            ["<C-d>"] = actions.preview_scrolling_down,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-Down>"] = actions.preview_scrolling_down,
            ["<C-Up>"] = actions.preview_scrolling_up,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<Esc>"] = actions.close,
          },
          n = {
            ["<Esc>"] = actions.close,
          },
        },
        preview = {
          treesitter = true,
        },
        file_ignore_patterns = {
          "node_modules",
          ".git/",
          "vendor/bundle",
          "tmp/",
          "log/",
        },
        path_display = { "truncate" },
        layout_config = {
          horizontal = {
            preview_width = 0.55,
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true,
        },
      },
    })

    telescope.load_extension("fzf")
  end,
}
