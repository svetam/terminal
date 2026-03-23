return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = false,
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
    { "<leader>f", "<cmd>NvimTreeFindFile<cr>", desc = "Reveal file in tree" },
  },
  config = function()
    local api = require("nvim-tree.api")

    local function on_attach(bufnr)
      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      -- Apply all default mappings first
      api.config.mappings.default_on_attach(bufnr)

      -- Right arrow: expand directory or preview file (keep focus in tree)
      vim.keymap.set("n", "<Right>", function()
        local node = api.tree.get_node_under_cursor()
        if not node or node.name == ".." then return end
        if node.type == "directory" then
          api.node.open.edit()
        elseif node.type == "file" then
          -- Find existing editor window (or create one)
          local tree_win = vim.api.nvim_get_current_win()
          local editor_win = nil
          for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local buf = vim.api.nvim_win_get_buf(w)
            local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
            if ft ~= "NvimTree" then
              editor_win = w
              break
            end
          end
          if not editor_win then
            vim.cmd("vsplit")
            editor_win = vim.api.nvim_get_current_win()
            api.tree.resize({ width = 35 })
          end
          -- Open file in editor window, then return focus to tree
          vim.api.nvim_set_current_win(editor_win)
          vim.cmd("edit " .. vim.fn.fnameescape(node.absolute_path))
          vim.api.nvim_set_current_win(tree_win)
        end
      end, opts("Expand / Preview"))

      -- Left arrow: collapse directory (no-op on root to stay in project)
      vim.keymap.set("n", "<Left>", function()
        local node = api.tree.get_node_under_cursor()
        if not node or node.name == ".." then return end
        api.node.navigate.parent_close()
      end, opts("Collapse / Parent"))

      -- Search files and jump to them in the tree (not open in editor)
      vim.keymap.set("n", "/", function()
        require("telescope.builtin").find_files({
          attach_mappings = function(_, map_key)
            local action_state = require("telescope.actions.state")
            local actions = require("telescope.actions")
            map_key("i", "<CR>", function(prompt_bufnr)
              local entry = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              if entry then
                api.tree.find_file(entry.path)
              end
            end)
            return true
          end,
        })
      end, opts("Find file in tree"))

      -- Enter: open file and focus it in editor
      vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
    end

    require("nvim-tree").setup({
      on_attach = on_attach,
      view = {
        width = 35,
        side = "left",
      },
      renderer = {
        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
        },
        indent_markers = {
          enable = true,
        },
      },
      filters = {
        dotfiles = false,
        custom = { "^.git$" },
      },
      git = {
        enable = true,
        ignore = false,
      },
      actions = {
        open_file = {
          quit_on_open = false,
          resize_window = true,
          window_picker = {
            enable = true,
            picker = function()
              -- Always open in a non-tree window; create one if needed
              local wins = vim.api.nvim_tabpage_list_wins(0)
              for _, win in ipairs(wins) do
                local buf = vim.api.nvim_win_get_buf(win)
                local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                if ft ~= "NvimTree" then
                  return win
                end
              end
              -- No non-tree window found: create a split and fix tree width
              vim.cmd("vsplit")
              local new_win = vim.api.nvim_get_current_win()
              -- Restore tree width (prevents 50-50 split)
              vim.schedule(function()
                require("nvim-tree.api").tree.resize({ width = 35 })
              end)
              return new_win
            end,
          },
        },
      },
      update_focused_file = {
        enable = true,
      },
    })

    -- Ensure a blank editor pane exists alongside the tree on startup.
    -- nvim-tree's own hijack_directories handles opening the tree when `nvim .` is used.
    -- This just adds the editor pane so the tree is never fullscreen.
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        vim.defer_fn(function()
          local wins = vim.api.nvim_tabpage_list_wins(0)
          local has_tree = false
          local has_editor = false
          for _, w in ipairs(wins) do
            local buf = vim.api.nvim_win_get_buf(w)
            local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
            if ft == "NvimTree" then
              has_tree = true
            else
              has_editor = true
            end
          end
          if has_tree and not has_editor then
            vim.cmd("botright vnew")
            require("nvim-tree.api").tree.resize({ width = 35 })
            -- Focus the tree, not the blank pane
            vim.cmd("wincmd h")
          end
        end, 50)
      end,
    })
  end,
}
