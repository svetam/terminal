local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  group = augroup("trim_whitespace", { clear = true }),
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- Return to last edit position on file open
autocmd("BufReadPost", {
  group = augroup("last_position", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-resize splits on window resize
autocmd("VimResized", {
  group = augroup("resize_splits", { clear = true }),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Smart :q / :q! behavior:
--   In editor: close file, show empty buffer, focus tree
--   In tree: exit nvim entirely
-- This also keeps a blank editor pane so the tree never goes fullscreen.
function _G.smart_close()
  local ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })

  if ft == "NvimTree" then
    vim.cmd("qa!")
    return
  end

  -- Count listed non-tree buffers
  local listed_bufs = vim.tbl_filter(function(b)
    return vim.api.nvim_buf_is_loaded(b)
      and vim.api.nvim_get_option_value("buflisted", { buf = b })
      and vim.api.nvim_get_option_value("filetype", { buf = b }) ~= "NvimTree"
  end, vim.api.nvim_list_bufs())

  local current_buf = vim.api.nvim_get_current_buf()

  if #listed_bufs <= 1 then
    vim.cmd("enew")
    vim.api.nvim_set_option_value("buflisted", false, { buf = vim.api.nvim_get_current_buf() })
  else
    vim.cmd("bprevious")
    if vim.api.nvim_buf_is_valid(current_buf) then
      vim.api.nvim_buf_delete(current_buf, { force = true })
    end
  end

  -- Focus tree
  local wins = vim.api.nvim_tabpage_list_wins(0)
  for _, w in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(w)
    if vim.api.nvim_get_option_value("filetype", { buf = buf }) == "NvimTree" then
      vim.api.nvim_set_current_win(w)
      return
    end
  end
end

-- When the last editor window closes, keep a blank pane so tree doesn't go fullscreen.
-- If tree is also gone, let nvim exit normally.
autocmd("WinClosed", {
  group = augroup("keep_editor_pane", { clear = true }),
  nested = true,
  callback = function()
    vim.schedule(function()
      local wins = vim.api.nvim_tabpage_list_wins(0)
      local has_tree = false
      local has_editor = false
      for _, w in ipairs(wins) do
        if vim.api.nvim_win_is_valid(w) then
          local buf = vim.api.nvim_win_get_buf(w)
          local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
          if ft == "NvimTree" then
            has_tree = true
          else
            has_editor = true
          end
        end
      end
      -- Tree is alone: create blank editor pane and focus tree
      if has_tree and not has_editor then
        vim.cmd("botright vnew")
        require("nvim-tree.api").tree.resize({ width = 35 })
        vim.cmd("wincmd h")
      end
    end)
  end,
})
