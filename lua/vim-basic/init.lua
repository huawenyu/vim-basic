-- vim-basic: Core options, clipboard, terminal setup, and keymaps
local M = {}

-- Check if a window is a valid code window (not special buffer type)
function M.is_code_win(win)
  if not vim.api.nvim_win_is_valid(win) then return false end
  local buf = vim.api.nvim_win_get_buf(win)
  if vim.bo[buf].buftype ~= "" then return false end
  return true
end

-- Find or create the right code window for opening files
-- Returns { code_win = win_id, created_new = bool }
function M.get_right_code_win()
  local cur_win = vim.api.nvim_get_current_win()

  local code_win
  local wins = vim.api.nvim_tabpage_list_wins(0)
  if #wins == 1 then
    vim.cmd("rightbelow vsplit")
    code_win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(cur_win)
    return { code_win = code_win, created_new = true }
  else
    local right_winnr = vim.fn.winnr("l")
    if right_winnr ~= vim.fn.winnr() then
      local right_win = vim.fn.win_getid(right_winnr)
      if M.is_code_win(right_win) then code_win = right_win end
    end
    if not code_win and M.is_code_win(cur_win) then code_win = cur_win end
    if not code_win then
      vim.cmd("rightbelow vsplit")
      code_win = vim.api.nvim_get_current_win()
      vim.api.nvim_set_current_win(cur_win)
      return { code_win = code_win, created_new = true }
    end
  end
  return { code_win = code_win, created_new = false }
end

function M.setup()
  vim.opt.modeline = true
  -- Optimize text wrapping and formatting for CJK (Chinese, Japanese, Korean) languages
  vim.opt.formatoptions:append({ m = true, B = true })

  -- Modern file format detection (removes obsolete Pre-OSX Mac format)
  vim.opt.fileformats = { 'unix', 'dos' }

  -- Clipboard / Yank (use only unnamedplus to avoid wayland primary selection issues)
  vim.opt.clipboard = "unnamedplus"
  if vim.env.SSH_TTY then
    vim.g.clipboard = "osc52"
  end


  local function url_encode(str)
    return (str:gsub("[^%w%-%.%_%~]", function(c)
      return string.format("%%%02X", string.byte(c))
    end))
  end

  local function detect_link()
    local function find_path_greedy(input)
      if not input or input == "" then return nil, nil end

      -- Extract trailing :linenum if present (e.g., "file.conf:400" or "file.conf:400: extra text")
      local line_num = input:match(":(%d+):?.*$")
      local path_input = line_num and input:gsub(":" .. line_num .. ":?.*$", "") or input

      local parts = vim.split(path_input, "/")
      for i = #parts, 1, -1 do
        local candidate = table.concat(parts, "/", 1, i)
        local abs_path = vim.fn.fnamemodify(candidate, ":p")
        if vim.fn.filereadable(abs_path) == 1 then
          return abs_path, line_num
        end
      end

      -- Fallback: try just filename without path
      local filename = path_input:match("([^/]+)$")
      if filename then
        local abs_path = vim.fn.fnamemodify(filename, ":p")
        if vim.fn.filereadable(abs_path) == 1 then
          return abs_path, line_num
        end
      end

      return nil, nil
    end

    local line_text = vim.api.nvim_get_current_line()
    -- URL check
    local url = line_text:match("https?://[%w%-_%.%?%.:/%+=&]+")
    if url then
      return { type = "url", value = url }
    end

    -- File search
    local valid_file, line_num = nil, nil
    local cfile = vim.fn.expand("<cfile>")
    -- Extract line num from line in case cfile missed it (vim stops cfile at colon)
    local line_num_from_line = line_text:match(":(%d+)")
    local cfile_with_line = line_num_from_line and (cfile .. ":" .. line_num_from_line) or cfile
    valid_file, line_num = find_path_greedy(cfile_with_line)

    if not valid_file then
      -- Extract filename from line (everything before the first :)
      local filename_from_line = line_text:match("^([^:]+)")
      if filename_from_line then
        local with_line = line_num_from_line and (filename_from_line .. ":" .. line_num_from_line) or filename_from_line
        valid_file, line_num = find_path_greedy(with_line)
      end
    end

    if not valid_file then
      for word in line_text:gmatch("[%g]+") do
        valid_file, line_num = find_path_greedy(word)
        if valid_file then break end
      end
    end

    if valid_file then
      local jump = line_num and (":" .. line_num) or ""
      return { type = "file", value = valid_file .. jump }
    end

    -- Fallback: Search (for markdown/vim files)
    local ft = vim.bo.filetype
    if ft == "markdown" or ft == "vim" then
      local words = vim.fn.expand("<cword>")
      if words ~= "" then
        local search_url = "https://google.com" .. url_encode(words)
        return { type = "url", value = search_url }
      end
    end

    return nil
  end

  local function open_detected_link()
    local link = detect_link()
    if not link then
      vim.notify("No link detected under cursor", vim.log.levels.WARN)
      return
    end

    if link.type == "url" then
      if vim.fn.exists(":FloatermNew") == 2 then
        vim.cmd("FloatermNew w3m " .. vim.fn.fnameescape(link.value))
      else
        local opener = vim.fn.has("mac") == 1 and "open" or "xdg-open"
        vim.fn.jobstart({ opener, link.value }, { detach = true })
      end
    elseif link.type == "file" then
      vim.cmd("edit " .. vim.fn.fnameescape(link.value))
    end
  end

  -- Terminal setup
  vim.api.nvim_create_augroup("terminal_setup", { clear = true })
  vim.api.nvim_create_autocmd("TermOpen", {
    group = "terminal_setup",
    callback = function()
      vim.keymap.set("n", "<LeftRelease>", "<LeftRelease>i", { buffer = true })
      vim.cmd("startinsert")
    end,
  })
  vim.api.nvim_create_autocmd("TermOpen", {
    group = "terminal_setup",
    callback = function()
      vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { buffer = true })
    end,
  })
  vim.api.nvim_create_autocmd("FileType", {
    group = "terminal_setup",
    pattern = "fzf",
    callback = function()
      vim.cmd("tunmap <Esc><Esc>")
    end,
  })

  -- Yank from cursor to end of line
  vim.keymap.set('n', 'Y', 'y$', { desc = "Yank to end of line" })

  -- Copy text to tmpfile
  vim.keymap.set('v', '<leader>yy', function()
    vim.cmd('call utils#GetSelected("v", "/tmp/vim.yank")')
  end, { silent = true, desc = "Copy text to tmpfile" })

  vim.keymap.set('n', '<leader>yy', function()
    vim.cmd('call vimuxscript#Copy()')
  end, { silent = true, desc = "Copy text to tmpfile" })

  -- Paste text from tmpfile
  vim.keymap.set('n', '<leader>yp', function()
    vim.cmd('r! cat /tmp/vim.yank')
  end, { silent = true, desc = "Paste text from tmpfile" })

  -- vim search with visual selection
  vim.keymap.set('v', '//', function()
    vim.fn.execute('y')
    vim.cmd(':vim /\\<' .. vim.fn.getreg('"') .. '\\C/gj %')
  end, { desc = "[find] Search visual selection *" })

  -- Link detection: <leader>gf to preview/detect, ;gf to open with w3m
  vim.keymap.set("n", "gf", function()
    vim.cmd("call utils#GotoFileWithLineNum(0)")
  end, { desc = "[file] Open file under cursor *" })

  vim.keymap.set("n", "<leader>gf", function()
    local link = detect_link()
    if not link then
      return
    end
    if link.type ~= "file" then
      return
    end

    local path, line_num = link.value:match("(.+):(%d+)$")
    if path then
      path = vim.fn.fnamemodify(path, ":p")
    else
      path = vim.fn.fnamemodify(link.value, ":p")
      line_num = nil
    end

    local cur_win = vim.api.nvim_get_current_win()
    local result = M.get_right_code_win()
    local code_win = result.code_win

    vim.api.nvim_win_call(code_win, function()
      vim.cmd("edit " .. vim.fn.fnameescape(path))
      if line_num then
        local lnum = tonumber(line_num)
        local bufnr = vim.api.nvim_get_current_buf()
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        if lnum > 0 and lnum <= line_count then
          vim.api.nvim_win_set_cursor(0, { lnum, 0 })
          vim.cmd("normal! zz")
          local ns_id = vim.api.nvim_create_namespace("flash")
          vim.api.nvim_buf_set_extmark(0, ns_id, lnum - 1, 0, {
            end_line = lnum,
            hl_group = "Search",
          })
          vim.fn.timer_start(300, function()
            vim.api.nvim_buf_clear_namespace(0, ns_id, lnum - 1, lnum)
          end)
        end
      end
    end)

    vim.api.nvim_set_current_win(cur_win)
  end, { silent = true, desc = "[misc] Open link in right code win *" })

  vim.keymap.set("x", "<leader>gf", function()
    local link = detect_link()
    if not link then
      vim.notify("No link detected", vim.log.levels.WARN)
      return
    end
    if link.type ~= "file" then
      vim.notify("Not a file link: " .. link.value, vim.log.levels.WARN)
      return
    end

    local path, line_num = link.value:match("(.+):(%d+)$")
    if path then
      path = vim.fn.fnamemodify(path, ":p")
    else
      path = vim.fn.fnamemodify(link.value, ":p")
      line_num = nil
    end

    local cur_win = vim.api.nvim_get_current_win()
    local result = M.get_right_code_win()
    local code_win = result.code_win

    vim.api.nvim_win_call(code_win, function()
      vim.cmd("edit " .. vim.fn.fnameescape(path))
      if line_num then
        local lnum = tonumber(line_num)
        local bufnr = vim.api.nvim_get_current_buf()
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        if lnum > 0 and lnum <= line_count then
          vim.api.nvim_win_set_cursor(0, { lnum, 0 })
          vim.cmd("normal! zz")
          local ns_id = vim.api.nvim_create_namespace("flash")
          vim.api.nvim_buf_set_extmark(0, ns_id, lnum - 1, 0, {
            end_line = lnum,
            hl_group = "Search",
          })
          vim.fn.timer_start(300, function()
            vim.api.nvim_buf_clear_namespace(0, ns_id, lnum - 1, lnum)
          end)
        end
      end
    end)

    vim.api.nvim_set_current_win(cur_win)
  end, { silent = true, desc = "(tool) Open link in right code win" })

  vim.keymap.set("n", ";gf", function()
    open_detected_link()
  end, { silent = true, desc = "[misc] Open link with w3m *" })

  -- Cleanup toolbox
  vim.keymap.set({ "n", "x" }, "<leader>ct", function()
    local mode = vim.api.nvim_get_mode().mode
    if mode:match("[vV\22]") then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
      vim.schedule(function()
        vim.cmd([[silent! '<,'>s/\s\+$//e]])
        print("Selection: Trailing whitespace cleared")
      end)
    else
      local save_cursor = vim.fn.getpos(".")
      vim.cmd([[silent! %s/\s\+$//e]])
      vim.fn.setpos(".", save_cursor)
      print("File: Trailing whitespace cleared")
    end
  end, { desc = "[misc] Clear trailing whitespace *" })

  vim.keymap.set({ "n", "x" }, "<leader>ci", function()
    local mode = vim.api.nvim_get_mode().mode
    if mode:match("[vV\22]") then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
      vim.schedule(function() vim.cmd("normal! gv=") end)
    else
      local save_cursor = vim.fn.getpos(".")
      vim.cmd("normal! gg=G")
      vim.fn.setpos(".", save_cursor)
    end
  end, { desc = "Fix indentation" })

  vim.keymap.set({ "n", "x" }, "<leader>cm", function()
    local mode = vim.api.nvim_get_mode().mode
    if mode:match("[vV\22]") then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
      vim.schedule(function() vim.cmd([[silent! '<,'>s/\r//g]]) end)
    else
      vim.cmd([[silent! %s/\r//g]])
    end
  end, { desc = "[misc] Remove ^M (Windows line endings) *" })

  vim.keymap.set({ "n", "x" }, "<leader>cn", function()
    local mode = vim.api.nvim_get_mode().mode
    local range = mode:match("[vV\22]") and "'<,'>" or "%"
    if mode:match("[vV\22]") then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
      vim.schedule(function() vim.cmd(string.format([[silent! %ss/\n\{3,}/\r\r/e]], range)) end)
    else
      vim.cmd([[silent! %s/\n\{3,}/\r\r/e]])
    end
  end, { desc = "[misc] Collapse blank lines *" })
end

return M
