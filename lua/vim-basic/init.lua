-- vim-basic: Core options, clipboard, terminal setup, and keymaps
local M = {}

function M.setup()
  vim.opt.modeline = true
  -- Optimize text wrapping and formatting for CJK (Chinese, Japanese, Korean) languages
  vim.opt.formatoptions:append({ m = true, B = true })

  -- Modern file format detection (removes obsolete Pre-OSX Mac format)
  vim.opt.fileformats = { 'unix', 'dos' }

  -- Clipboard / Yank (use only unnamedplus to avoid wayland primary selection issues)
  vim.opt.clipboard:prepend("unnamedplus")



  local function url_encode(str)
    return (str:gsub("[^%w%-%.%_%~]", function(c)
      return string.format("%%%02X", string.byte(c))
    end))
  end

  local function detect_link()
    local function find_path_greedy(input)
      if not input or input == "" then return nil, nil end
      local parts = vim.split(input, "/")
      for i = #parts, 1, -1 do
        local candidate = table.concat(parts, "/", 1, i)
        local path_part, line_part = candidate:match("([^:]+):(%d+)$")
        if path_part then
          local abs_path = vim.fn.fnamemodify(path_part, ":p")
          if vim.fn.filereadable(abs_path) == 1 then
            return abs_path, line_part
          end
        end
        local abs_path = vim.fn.fnamemodify(candidate, ":p")
        if vim.fn.filereadable(abs_path) == 1 then
          return abs_path, nil
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
    valid_file, line_num = find_path_greedy(cfile)

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
    if link then
      vim.notify("Detected: " .. link.value, vim.log.levels.INFO)
    else
      vim.notify("No link detected", vim.log.levels.WARN)
    end
  end, { silent = true, desc = "[misc] Detect link under cursor *" })

  vim.keymap.set("x", "<leader>gf", function()
    local link = detect_link()
    if link then
      vim.notify("Detected: " .. link.value, vim.log.levels.INFO)
    else
      vim.notify("No link detected", vim.log.levels.WARN)
    end
  end, { silent = true, desc = "(tool) Detect link" })

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
