local M = {}

local help_buf = nil
local help_win = nil

local help_text = [[
 ╔══════════════════════════════════════════════════════════════════╗
 ║                      KEYBINDING CHEAT SHEET                     ║
 ║                Press q, <Esc>, or <F1> to close                 ║
 ╠══════════════════════════════════════════════════════════════════╣
 ║                                                                 ║
 ║  RUBYMINE SHORTCUTS (Ctrl replaces Cmd)                         ║
 ║  ─────────────────────────────────────────────────────────────── ║
 ║  Ctrl+Shift+O     Find files            ≡ Shift+Cmd+O          ║
 ║  Ctrl+Shift+F     Live grep (project)   ≡ Shift+Cmd+F          ║
 ║  Ctrl+1           Toggle file tree      ≡ Cmd+1                ║
 ║  F2               Reveal file in tree   ≡ Cmd+F1               ║
 ║  Ctrl+B           Go to definition      ≡ Cmd+B                ║
 ║  Alt+F7           Find references       ≡ Alt+F7               ║
 ║  Shift+F6         Rename symbol         ≡ Shift+F6             ║
 ║  Alt+Enter        Code actions          ≡ Alt+Enter            ║
 ║  Ctrl+S           Save file             ≡ Cmd+S                ║
 ║                                                                 ║
 ║  NEOVIM-NATIVE (learn these over time)                          ║
 ║  ─────────────────────────────────────────────────────────────── ║
 ║  Space p          Find files                                    ║
 ║  Space sg         Live grep (project)                           ║
 ║  Space e          Toggle file tree                              ║
 ║  Space f          Reveal file in tree                           ║
 ║  Space sw         Grep word under cursor                        ║
 ║  Space sb         Search open buffers                           ║
 ║  Space sr         Resume last search                            ║
 ║  gd               Go to definition                              ║
 ║  gr               Find references                               ║
 ║  K                Hover documentation                           ║
 ║  Space rn         Rename symbol                                 ║
 ║  Space ca         Code actions                                  ║
 ║  Space d          Show diagnostic float                         ║
 ║  [d / ]d          Prev / next diagnostic                        ║
 ║                                                                 ║
 ║  COMPLETION                                                     ║
 ║  ─────────────────────────────────────────────────────────────── ║
 ║  Tab / Shift+Tab  Cycle completions                             ║
 ║  Enter            Confirm selection                             ║
 ║  Ctrl+Space       Trigger completion manually                   ║
 ║  Ctrl+E           Dismiss completion                            ║
 ║                                                                 ║
 ║  NAVIGATION                                                     ║
 ║  ─────────────────────────────────────────────────────────────── ║
 ║  Ctrl+H/J/K/L    Move between splits / tmux panes              ║
 ║  Space bn/bp/bd   Next / prev / delete buffer                   ║
 ║  Space w          Save file                                     ║
 ║  Space q          Smart quit                                    ║
 ║                                                                 ║
 ║  GIT                                                            ║
 ║  ─────────────────────────────────────────────────────────────── ║
 ║  ]c / [c          Next / prev git hunk                          ║
 ║  Space gb         Toggle line blame                             ║
 ║  Space gp         Preview hunk                                  ║
 ║                                                                 ║
 ║  TMUX (prefix = Ctrl+A)                                         ║
 ║  ─────────────────────────────────────────────────────────────── ║
 ║  Prefix + |       Split vertically                              ║
 ║  Prefix + -       Split horizontally                            ║
 ║  Prefix + c       New window                                    ║
 ║  Prefix + r       Reload tmux config                            ║
 ║                                                                 ║
 ║  Space ? / F1     This help screen                              ║
 ║  Space (wait)     Which-key popup (all bindings)                ║
 ║                                                                 ║
 ╚══════════════════════════════════════════════════════════════════╝
]]

function M.toggle()
  -- Close if already open
  if help_win and vim.api.nvim_win_is_valid(help_win) then
    vim.api.nvim_win_close(help_win, true)
    help_win = nil
    help_buf = nil
    return
  end

  -- Create buffer
  help_buf = vim.api.nvim_create_buf(false, true)
  local lines = vim.split(help_text, "\n")
  vim.api.nvim_buf_set_lines(help_buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = help_buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = help_buf })

  -- Calculate window size
  local width = 70
  local height = #lines
  local ui = vim.api.nvim_list_uis()[1]
  local row = math.floor((ui.height - height) / 2)
  local col = math.floor((ui.width - width) / 2)

  -- Create floating window
  help_win = vim.api.nvim_open_win(help_buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "none",
  })

  -- Close on q, Esc, or F1
  local close = function()
    if help_win and vim.api.nvim_win_is_valid(help_win) then
      vim.api.nvim_win_close(help_win, true)
    end
    help_win = nil
    help_buf = nil
  end
  vim.keymap.set("n", "q", close, { buffer = help_buf, nowait = true })
  vim.keymap.set("n", "<Esc>", close, { buffer = help_buf, nowait = true })
  vim.keymap.set("n", "<F1>", close, { buffer = help_buf, nowait = true })
end

return M
