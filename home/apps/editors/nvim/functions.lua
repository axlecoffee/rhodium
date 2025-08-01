local M = {}
local api, fn = vim.api, vim.fn

-- --- System Info ---
-- Dynamic hostname detection
function M.get_hostname()
  local handle = io.popen("hostname")
  if handle then
    local result = handle:read("*a"):gsub("%s+", "")
    handle:close()
    return result
  end
  return "your-hostname"
end

-- --- Dynamic Username Detection ---
function M.get_username()
  return os.getenv("USER") or "your-username"
end

-- --- Spectre ---
function M.spectre_toggle()
  require("spectre").toggle()
end

function M.spectre_open_visual_word()
  require("spectre").open_visual({ select_word = true })
end

function M.spectre_open_visual()
  require("spectre").open_visual()
end

function M.spectre_open_file_search()
  require("spectre").open_file_search({ select_word = true })
end

-- TODO: Pending to order into cats
function M.format_with_conform()
  require("conform").format()
end

function M.find_todos_in_buffer()
  require("telescope").extensions["todo-comments"].todo({ keywords = "FIX,TODO,PERF,TEST" })
end

function M.aerial_symbols()
  require("telescope").extensions.aerial.aerial()
end

function M.trouble_toggle_diagnostics()
  require("trouble").toggle("diagnostics")
end

function M.trouble_toggle_buffer_diagnostics()
  require("trouble").toggle("diagnostics", { filter = { buf = 0 } })
end

function M.trouble_toggle_loclist()
  require("trouble").toggle("loclist")
end

function M.trouble_toggle_references()
  require("trouble").toggle("lsp_references")
end

function M.trouble_toggle_definitions()
  require("trouble").toggle("lsp_definitions")
end

function M.trouble_toggle_implementations()
  require("trouble").toggle("lsp_implementations")
end

function M.trouble_toggle_symbols()
  require("trouble").toggle("symbols")
end

function M.trouble_close()
  require("trouble").close()
end

function M.trouble_next()
  require("trouble").next({ skip_groups = true, jump = true })
end

function M.trouble_prev()
  require("trouble").prev({ skip_groups = true, jump = true })
end

function M.trouble_last()
  require("trouble").last({ skip_groups = true, jump = true })
end

function M.trouble_first()
  require("trouble").first({ skip_groups = true, jump = true })
end

-- --- Terminal Integration ---
-- Open selected file in new terminal session
function M.open_file_in_new_terminal(prompt_bufnr)
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)

  if not selection then
    vim.notify("No file selected", vim.log.levels.WARN, { title = "New Terminal" })
    return
  end

  local file_path = selection.path or selection.filename
  if not file_path then
    vim.notify("Could not determine file path", vim.log.levels.ERROR, { title = "New Terminal" })
    return
  end

  -- Open in new kitty terminal
  local success = vim.fn.system(string.format("kitty -- nvim '%s' &", file_path))

  vim.notify(
    string.format("Opening %s in new terminal", vim.fn.fnamemodify(file_path, ":t")),
    vim.log.levels.INFO,
    { title = "New Terminal" }
  )
end

-- --- Edits ---
-- Replace entire buffer content with clipboard content
function M.replace_buffer_with_clipboard()
  local clipboard_content = vim.fn.getreg("+")

  if clipboard_content == "" then
    vim.notify("Clipboard is empty", vim.log.levels.WARN, { title = "Buffer Switch" })
    return
  end

  -- Get current buffer
  local buf = vim.api.nvim_get_current_buf()

  -- Check if buffer is modifiable
  if not vim.api.nvim_buf_get_option(buf, "modifiable") then
    vim.notify("Buffer is not modifiable", vim.log.levels.ERROR, { title = "Buffer Switch" })
    return
  end

  -- Save current cursor position (optional, for restoration)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  -- Get total line count
  local line_count = vim.api.nvim_buf_line_count(buf)

  -- Replace all buffer content with clipboard content
  -- Split clipboard content into lines
  local lines = vim.split(clipboard_content, "\n", { plain = true })

  -- Replace buffer content
  vim.api.nvim_buf_set_lines(buf, 0, line_count, false, lines)

  -- Move cursor to beginning of buffer
  vim.api.nvim_win_set_cursor(0, { 1, 0 })

  -- Show confirmation message
  local line_count_new = #lines
  vim.notify(
    string.format("Buffer replaced with clipboard content (%d lines)", line_count_new),
    vim.log.levels.INFO,
    { title = "Buffer Switch" }
  )
end

-- Replace visual selection with clipboard content
function M.replace_selection_with_clipboard()
  -- Get clipboard contents
  local clipboard_content = vim.fn.getreg("+")
  if clipboard_content == "" then
    vim.notify("Clipboard is empty", vim.log.levels.WARN, { title = "Selection Replace" })
    return
  end

  -- Get current buffer
  local buf = vim.api.nvim_get_current_buf()

  -- Check if buffer is modifiable
  if not vim.api.nvim_buf_get_option(buf, "modifiable") then
    vim.notify("Buffer is not modifiable", vim.log.levels.ERROR, { title = "Selection Replace" })
    return
  end

  -- Save the visual selection marks before they get lost
  vim.cmd("normal! gv")

  -- Get visual selection range using getpos after reselecting
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_row, start_col = start_pos[2] - 1, start_pos[3] - 1
  local end_row, end_col = end_pos[2] - 1, end_pos[3]

  -- Get the visual mode type
  local mode = vim.fn.visualmode()

  -- Exit visual mode
  vim.cmd("normal! <Esc>")

  -- Split clipboard content into lines
  local lines = vim.split(clipboard_content, "\n", { plain = true })

  if mode == "V" then
    -- Line-wise visual mode - replace entire lines
    vim.api.nvim_buf_set_lines(buf, start_row, end_row + 1, false, lines)
    vim.api.nvim_win_set_cursor(0, { start_row + 1, 0 })
  elseif mode == "v" then
    -- Character-wise visual mode
    if start_row == end_row then
      -- Single line replacement
      local current_line = vim.api.nvim_buf_get_lines(buf, start_row, start_row + 1, false)[1]
      local before = string.sub(current_line, 1, start_col)
      local after = string.sub(current_line, end_col + 1)

      if #lines == 1 then
        -- Single line clipboard content
        local new_line = before .. lines[1] .. after
        vim.api.nvim_buf_set_lines(buf, start_row, start_row + 1, false, { new_line })
        vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col + #lines[1] })
      else
        -- Multi-line clipboard content
        local new_lines = {}
        new_lines[1] = before .. lines[1]
        for i = 2, #lines - 1 do
          table.insert(new_lines, lines[i])
        end
        new_lines[#new_lines + 1] = lines[#lines] .. after
        vim.api.nvim_buf_set_lines(buf, start_row, start_row + 1, false, new_lines)
        vim.api.nvim_win_set_cursor(0, { start_row + #lines, #lines[#lines] })
      end
    else
      -- Multi-line selection replacement
      local first_line = vim.api.nvim_buf_get_lines(buf, start_row, start_row + 1, false)[1]
      local last_line = vim.api.nvim_buf_get_lines(buf, end_row, end_row + 1, false)[1]
      local before = string.sub(first_line, 1, start_col)
      local after = string.sub(last_line, end_col + 1)

      local new_lines = {}
      new_lines[1] = before .. lines[1]
      for i = 2, #lines - 1 do
        table.insert(new_lines, lines[i])
      end
      new_lines[#new_lines + 1] = lines[#lines] .. after

      vim.api.nvim_buf_set_lines(buf, start_row, end_row + 1, false, new_lines)
      vim.api.nvim_win_set_cursor(0, { start_row + #lines, #lines[#lines] })
    end
  elseif mode == "\22" then
    -- Block-wise visual mode
    -- For simplicity, treat as character-wise
    vim.notify("Block mode replaced as character-wise", vim.log.levels.INFO, { title = "Selection Replace" })

    -- Just replace the block with clipboard content
    if #lines == 1 then
      -- Single line clipboard - replace each line in block
      for row = start_row, end_row do
        local current_line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
        local before = string.sub(current_line, 1, start_col)
        local after = string.sub(current_line, end_col + 1)
        local new_line = before .. lines[1] .. after
        vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { new_line })
      end
    else
      -- Multi-line clipboard - insert at block start
      local first_line = vim.api.nvim_buf_get_lines(buf, start_row, start_row + 1, false)[1]
      local before = string.sub(first_line, 1, start_col)
      local last_line = vim.api.nvim_buf_get_lines(buf, end_row, end_row + 1, false)[1]
      local after = string.sub(last_line, end_col + 1)

      local new_lines = {}
      new_lines[1] = before .. lines[1]
      for i = 2, #lines - 1 do
        table.insert(new_lines, lines[i])
      end
      new_lines[#new_lines + 1] = lines[#lines] .. after

      vim.api.nvim_buf_set_lines(buf, start_row, end_row + 1, false, new_lines)
    end
    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
  end

  -- Show confirmation message
  local line_count = #lines
  local replaced_lines = end_row - start_row + 1
  vim.notify(
    string.format("Replaced %d lines with %d lines from clipboard", replaced_lines, line_count),
    vim.log.levels.INFO,
    { title = "Selection Replace" }
  )
end

-- Indents
-- --------------------------------------------------
-- Smart indent function that works in both modes
function M.smart_indent()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    -- Visual mode: indent and keep selection
    vim.cmd("normal! >gv")
  else
    -- Normal mode: indent current line
    vim.cmd("normal! >>")
  end
end

-- Smart outdent function that works in both modes
function M.smart_outdent()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    -- Visual mode: outdent and keep selection
    vim.cmd("normal! <gv")
  else
    -- Normal mode: outdent current line
    vim.cmd("normal! <<")
  end
end

-- -----------------------------------------------------------------------------

-- helper: capture text that is *currently* visually selected
-- FIX: This is completely broken
-- function M.simple_replace()
-- 	-- 1. What are we replacing?
-- 	local visual_active = fn.mode():match("[vV]") -- visual char/line
-- 	local old = (visual_active and fn.getreg("v") ~= "") and fn.getreg("v") -- visual selection
-- 		or fn.expand("<cword>") -- …or word under cursor
-- 	if old == "" then
-- 		vim.notify("Nothing to replace", vim.log.levels.WARN, { title = "Replace" })
-- 		return
-- 	end
-- 	if visual_active then
-- 		api.nvim_feedkeys(api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false) -- leave Visual mode
-- 	end
--
-- 	-- 2. Ask for the new text
-- 	local new = fn.input("Replace '" .. old .. "' with: ", old)
-- 	if new == "" or new == old then
-- 		return
-- 	end
--
-- 	-- 3. Do the substitution (very-nomagic + word boundaries + confirmation)
-- 	local patt = fn.escape(old, "/\\.*$^~[]")
-- 	local repl = fn.escape(new, "/\\&~")
-- 	vim.cmd(("%s/\\V\\<%s\\>/%s/gc"):format("%", patt, repl))
-- end

-- -----------------------------------------------------------------------------

-- Replace visual selection in buffer
function M.replace_visual_selection()
  -- Get the visually selected text
  local vstart = vim.fn.getpos("'<")
  local vend = vim.fn.getpos("'>")

  -- Check if we have a valid visual selection
  if vstart[2] == 0 or vend[2] == 0 then
    vim.notify("No visual selection found", vim.log.levels.WARN, { title = "Replace All" })
    return
  end

  -- Get selected text using getregion (Neovim 0.10+)
  local selected_text
  if vim.fn.has("nvim-0.10") == 1 then
    local lines = vim.fn.getregion(vstart, vend, { type = vim.fn.visualmode() })
    if #lines == 0 then
      vim.notify("No text selected", vim.log.levels.WARN, { title = "Replace All" })
      return
    end
    selected_text = table.concat(lines, "\n")
  else
    -- Fallback for older Neovim versions
    local lines = vim.fn.getline(vstart[2], vend[2])
    if type(lines) == "string" then
      lines = { lines }
    end

    if #lines == 1 then
      selected_text = string.sub(lines[1], vstart[3], vend[3])
    else
      -- Multi-line selection (simplified)
      selected_text = lines[1]:sub(vstart[3])
      for i = 2, #lines - 1 do
        selected_text = selected_text .. "\n" .. lines[i]
      end
      selected_text = selected_text .. "\n" .. lines[#lines]:sub(1, vend[3])
    end
  end

  if selected_text == "" then
    vim.notify("No text selected", vim.log.levels.WARN, { title = "Replace All" })
    return
  end

  local new_text = vim.fn.input("Replace '" .. selected_text .. "' with: ", selected_text)
  if new_text == "" or new_text == selected_text then
    return
  end

  -- Escape for regex (no word boundaries for selections)
  local cmd = string.format("%%s/%s/%s/g", vim.fn.escape(selected_text, "/\\.*$^~[]"), vim.fn.escape(new_text, "/\\&~"))

  vim.cmd(cmd)
  vim.notify(
    string.format("Replaced '%s' with '%s'", selected_text, new_text),
    vim.log.levels.INFO,
    { title = "Replace All" }
  )
end

-- -----------------------------------------------------------------------------

-- Pickers
-- --------------------------------------------------

-- Pick from project root downwards
function M.find_project_root()
  local root_patterns = {
    -- Git
    ".git",
    -- Node.js
    "package.json",
    "node_modules",
    -- Python
    "requirements.txt",
    "pyproject.toml",
    "setup.py",
    ".venv",
    -- Rust
    "Cargo.toml",
    -- Go
    "go.mod",
    -- Java
    "pom.xml",
    "build.gradle",
    -- Generic
    "Makefile",
    "justfile",
    ".project",
    ".root",
    ".projectile",
  }

  local current_dir = vim.fn.expand("%:p:h")
  if current_dir == "" then
    current_dir = vim.fn.getcwd()
  end

  -- Search upwards from current file's directory
  local function find_root(path)
    for _, pattern in ipairs(root_patterns) do
      local full_path = path .. "/" .. pattern
      if vim.fn.isdirectory(full_path) == 1 or vim.fn.filereadable(full_path) == 1 then
        return path
      end
    end

    local parent = vim.fn.fnamemodify(path, ":h")
    if parent == path then
      -- Reached filesystem root
      return nil
    end

    return find_root(parent)
  end

  local project_root = find_root(current_dir)
  return project_root or vim.fn.getcwd() -- Fallback to current working directory
end

-- Find files in project root
function M.find_files_in_project()
  local project_root = M.find_project_root()

  if not project_root then
    vim.notify("Could not find project root", vim.log.levels.WARN, { title = "Project Files" })
    return
  end

  -- Check if Telescope is available
  local telescope_ok, telescope = pcall(require, "telescope.builtin")
  if telescope_ok then
    -- Use Telescope if available
    telescope.find_files({
      cwd = project_root,
      prompt_title = "Project Files (" .. vim.fn.fnamemodify(project_root, ":t") .. ")",
    })
  else
    -- Fallback to built-in file finder
    vim.cmd("cd " .. project_root)
    vim.cmd("edit .")
    vim.notify("Changed directory to project root: " .. project_root, vim.log.levels.INFO, { title = "Project Files" })
  end
end

-- Toggle folds smart
function M.toggle_folds_smart()
  local mode = vim.fn.mode()
  local start_line, end_line

  if mode:match("[vV]") then
    start_line = vim.fn.line("'<")
    end_line = vim.fn.line("'>")
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  else
    start_line = vim.fn.line(".")
    end_line = start_line
  end

  local is_closed = vim.fn.foldclosed(start_line) ~= -1

  for lnum = start_line, end_line do
    vim.cmd((is_closed and lnum .. "foldopen" or lnum .. "foldclose"))
  end
end

-- Find TODOs in project root
function M.find_todos_in_project()
  local project_root = M.find_project_root()

  if not project_root then
    vim.notify("Could not find project root", vim.log.levels.WARN, { title = "Project Files" })
    return
  end

  require("telescope").extensions["todo-comments"].todo({ cwd = project_root, keywords = "FIX,TODO,PERF,TEST" })
end

-- Live grep on current dir
function M.live_grep_args()
  require("telescope").extensions.live_grep_args.live_grep_args()
end

-- Live Grep in project root
function M.live_grep_in_project()
  local project_root = M.find_project_root()

  if not project_root then
    vim.notify("Could not find project root", vim.log.levels.WARN, { title = "Project Files" })
    return
  end

  require("telescope").extensions.live_grep_args.live_grep_args({
    search_dirs = { project_root },
  })
end

-- Smart replace
function M.smart_replace()
  local mode = vim.fn.mode()
  local target
  if mode == "v" then
    local start_pos = vim.fn.getpos("v")
    local end_pos = vim.fn.getpos(".")
    local line = vim.fn.getline(".")
    target = line:sub(math.min(start_pos[3], end_pos[3]), math.max(start_pos[3], end_pos[3]))
  else
    local col = vim.fn.col(".")
    local line = vim.fn.getline(".")
    local char = line:sub(col, col)
    if char:match("[%a%d]") then
      local start = col
      local end_ = col
      while start > 1 and line:sub(start - 1, start - 1):match("[%a%d]") do
        start = start - 1
      end
      while end_ < #line and line:sub(end_ + 1, end_ + 1):match("[%a%d]") do
        end_ = end_ + 1
      end
      target = line:sub(start, end_)
    else
      target = char
    end
  end
  vim.ui.input({ prompt = 'Replace "' .. target .. '" with: ' }, function(input)
    if input then
      vim.cmd("%s/" .. vim.fn.escape(target, "/\\.*$^~[]") .. "/" .. input .. "/g")
    end
  end)
end

-- Get comment string for current buffer
function M.get_comment_string()
  -- Get the comment string from vim's commentstring option
  local commentstring = vim.bo.commentstring

  -- If no commentstring is set, try to determine from filetype
  if commentstring == "" or commentstring == nil then
    local ft = vim.bo.filetype
    local comment_map = {
      lua = "-- %s",
      python = "# %s",
      javascript = "// %s",
      typescript = "// %s",
      c = "// %s",
      cpp = "// %s",
      rust = "// %s",
      go = "// %s",
      java = "// %s",
      sh = "# %s",
      bash = "# %s",
      zsh = "# %s",
      vim = '" %s',
      ruby = "# %s",
      perl = "# %s",
      php = "// %s",
      html = "<!-- %s -->",
      xml = "<!-- %s -->",
      css = "/* %s */",
      sql = "-- %s",
      haskell = "-- %s",
      elixir = "# %s",
      clojure = "; %s",
      lisp = "; %s",
      scheme = "; %s",
      r = "# %s",
      matlab = "% %s",
      tex = "% %s",
      markdown = "<!-- %s -->",
    }
    commentstring = comment_map[ft] or "# %s"
  end

  return commentstring
end

-- Extract comment prefix from commentstring
function M.get_comment_prefix()
  local commentstring = M.get_comment_string()
  -- Extract the part before %s
  local prefix = commentstring:match("^(.-)%s*%%s")
  return prefix or "//"
end

-- Comment Header
-- Comment Header
function M.comment_header()
  local line = vim.api.nvim_get_current_line()
  local comment_prefix = M.get_comment_prefix()

  -- Escape special regex characters in comment prefix
  local escaped_prefix = vim.pesc(comment_prefix)

  -- Get the prefix part (indentation + comment marker)
  local prefix = line:match("^(%s*" .. escaped_prefix .. "%s*)")

  if not prefix then
    vim.notify("No comment found on current line", vim.log.levels.WARN, { title = "Comment Header" })
    return
  end

  -- Get everything after the comment prefix
  local rest = line:sub(#prefix + 1)

  -- Extract content by removing any dashes from beginning and end
  local content = rest:match("^%-*%s*(.-)%s*%-*$")

  if not content or content == "" then
    vim.notify("No content in comment", vim.log.levels.WARN, { title = "Comment Header" })
    return
  end

  -- Clean up any remaining dashes from content edges
  content = content:gsub("^%-*%s*", ""):gsub("%s*%-*$", "")

  -- Check if it's already a properly formatted header (starts and ends with ---)
  if rest:match("^%-%-%-") and rest:match("%-%-%-$") then
    -- It's decorated, convert to normal comment
    vim.api.nvim_set_current_line(prefix .. content)
    vim.notify("Removed header decoration", vim.log.levels.INFO, { title = "Comment Header" })
  else
    -- Convert to title case and add decoration
    local words = {}
    for word in content:gmatch("%S+") do
      local first = word:sub(1, 1):upper()
      local rest_of_word = word:sub(2):lower()
      table.insert(words, first .. rest_of_word)
    end

    local formatted_content = table.concat(words, " ")
    vim.api.nvim_set_current_line(prefix .. "--- " .. formatted_content .. " ---")
    vim.notify("Added header decoration", vim.log.levels.INFO, { title = "Comment Header" })
  end
end

-- Comment Append
function M.comment_append()
  local comment_prefix = M.get_comment_prefix()
  vim.cmd("normal! i" .. comment_prefix .. " ")
  vim.cmd("startinsert!")
end

-- Toggle comments for entire buffer
function M.comment_all()
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_line_count(buf)

  if lines == 0 then
    vim.notify("Buffer is empty", vim.log.levels.WARN, { title = "Comment All" })
    return
  end

  require("Comment.api").toggle.linewise.countwise(1, lines)

  vim.notify("Toggled comments for entire buffer", vim.log.levels.INFO, { title = "Comment All" })
end

-- Language-aware TODO comment insertion
function M.insert_todo_comment(keyword)
  keyword = keyword or "TODO"

  local comment_prefix = M.get_comment_prefix()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()

  -- Get current indentation
  local indent = line:match("^(%s*)")

  -- Create TODO comment with proper format
  local todo_comment = string.format("%s%s %s: ", indent, comment_prefix, keyword)

  -- Insert on current line if empty, otherwise create new line above
  if line:match("^%s*$") then
    vim.api.nvim_set_current_line(todo_comment)
    vim.api.nvim_win_set_cursor(0, { cursor[1], #todo_comment })
  else
    vim.api.nvim_buf_set_lines(0, cursor[1] - 1, cursor[1] - 1, false, { todo_comment })
    vim.api.nvim_win_set_cursor(0, { cursor[1], #todo_comment })
  end

  vim.cmd("startinsert!")
end

-- Create specific TODO comment functions
function M.insert_todo()
  M.insert_todo_comment("TODO")
end

function M.insert_fix()
  M.insert_todo_comment("FIX")
end

function M.insert_hack()
  M.insert_todo_comment("HACK")
end

function M.insert_warn()
  M.insert_todo_comment("WARN")
end

function M.insert_perf()
  M.insert_todo_comment("PERF")
end

function M.insert_note()
  M.insert_todo_comment("NOTE")
end

function M.insert_test()
  M.insert_todo_comment("TEST")
end

-- Insert TODO comment at end of current line
function M.append_todo_comment(keyword)
  keyword = keyword or "TODO"

  local comment_prefix = M.get_comment_prefix()
  local line = vim.api.nvim_get_current_line()

  -- Check if line already has a comment
  local has_comment = line:find(vim.pesc(comment_prefix))

  local todo_text
  if has_comment then
    -- Add TODO after existing comment
    todo_text = string.format(" %s: ", keyword)
  else
    -- Add comment with TODO at end of line
    todo_text = string.format("  %s %s: ", comment_prefix, keyword)
  end

  -- Move to end of line and insert
  vim.cmd("normal! A" .. todo_text)
  vim.cmd("startinsert!")
end

-- Create append functions for each TODO type
function M.append_todo()
  M.append_todo_comment("TODO")
end

function M.append_fix()
  M.append_todo_comment("FIX")
end

function M.append_hack()
  M.append_todo_comment("HACK")
end

function M.append_warn()
  M.append_todo_comment("WARN")
end

function M.append_perf()
  M.append_todo_comment("PERF")
end

function M.append_note()
  M.append_todo_comment("NOTE")
end

function M.append_test()
  M.append_todo_comment("TEST")
end

-- Toggle TODO completion (DONE)
function M.toggle_todo_done()
  local line = vim.api.nvim_get_current_line()
  local comment_prefix = M.get_comment_prefix()

  -- Pattern to match TODO-style comments
  local todo_pattern = "(" .. vim.pesc(comment_prefix) .. "%s*)(%u+)(:)"

  local before, keyword, colon = line:match(todo_pattern)

  if keyword then
    local new_line
    if keyword == "DONE" then
      -- Change DONE back to TODO
      new_line = line:gsub(todo_pattern, "%1TODO%3")
    else
      -- Change any keyword to DONE
      new_line = line:gsub(todo_pattern, "%1DONE%3")
    end
    vim.api.nvim_set_current_line(new_line)
    vim.notify(
      string.format("Toggled: %s → %s", keyword, keyword == "DONE" and "TODO" or "DONE"),
      vim.log.levels.INFO,
      { title = "TODO Toggle" }
    )
  else
    vim.notify("No TODO comment found on current line", vim.log.levels.WARN, { title = "TODO Toggle" })
  end
end

-- List all TODO comments in current buffer
function M.list_buffer_todos()
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local todos = {}

  local keywords = {
    "TODO",
    "FIX",
    "HACK",
    "WARN",
    "PERF",
    "NOTE",
    "TEST",
    "DONE",
    "SEV1",
    "SEV2",
    "SEV3",
    "IMPR",
    "TESTING",
    "PASSED",
    "FAILED",
  }

  for i, line in ipairs(lines) do
    for _, keyword in ipairs(keywords) do
      if line:find("%s" .. keyword .. ":") then
        table.insert(todos, string.format("[%d] %s", i, vim.trim(line)))
      end
    end
  end

  if #todos > 0 then
    vim.notify(table.concat(todos, "\n"), vim.log.levels.INFO, { title = "Buffer TODOs" })
  else
    vim.notify("No TODO comments found in buffer", vim.log.levels.INFO, { title = "Buffer TODOs" })
  end
end

-- Smart Buffer Management
-- --------------------------------------------------
-- Check if a buffer is a real file buffer
function M.is_real_buffer(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end

  local buftype = vim.bo[buf].buftype
  local filetype = vim.bo[buf].filetype
  local bufname = vim.api.nvim_buf_get_name(buf)

  -- Skip special buffer types
  if buftype ~= "" then
    return false
  end

  -- Skip certain filetypes
  local excluded_filetypes = {
    "qf",
    "fugitive",
    "git",
    "help",
    "TelescopePrompt",
    "TelescopeResults",
    "TelescopePreview",
    "terminal",
    "lspinfo",
    "mason",
    "lazy",
    "checkhealth",
  }

  for _, ft in ipairs(excluded_filetypes) do
    if filetype == ft then
      return false
    end
  end

  -- Skip unnamed buffers (but only if they're also unmodified and empty)
  if bufname == "" then
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    if #lines <= 1 and lines[1] == "" and not vim.bo[buf].modified then
      return false
    end
  end

  return true
end

-- Get count of real buffers
function M.get_real_buffer_count()
  local count = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if M.is_real_buffer(buf) then
      count = count + 1
    end
  end
  return count
end

-- Smart close buffer - exits vim if it's the last real buffer
function M.smart_close_buffer()
  local current_buf = vim.api.nvim_get_current_buf()
  local real_buffer_count = M.get_real_buffer_count()

  -- If this is the last real buffer, quit vim
  if real_buffer_count <= 1 then
    -- Check if current buffer is modified
    if vim.bo[current_buf].modified then
      local choice = vim.fn.confirm("Save changes before closing?", "&Yes\n&No\n&Cancel", 1)
      if choice == 1 then
        vim.cmd("write")
        vim.cmd("quit")
      elseif choice == 2 then
        vim.cmd("quit!")
      end
      -- choice == 3 means cancel, do nothing
    else
      vim.cmd("quit")
    end
  else
    -- More than one buffer, just delete current
    vim.cmd("bdelete!")
  end
end

-- Smart save and close - saves then uses smart close
function M.smart_save_and_close()
  local current_buf = vim.api.nvim_get_current_buf()
  local real_buffer_count = M.get_real_buffer_count()

  -- Save current buffer if it's a real file
  if M.is_real_buffer(current_buf) and vim.bo[current_buf].modified then
    vim.cmd("write")
  end

  -- If this is the last real buffer, quit vim
  if real_buffer_count <= 1 then
    vim.cmd("quit")
  else
    vim.cmd("bdelete!")
  end
end

-- Close all other buffers but keep vim open if they're all closed
function M.close_other_buffers()
  local current_buf = vim.api.nvim_get_current_buf()
  local buffers_to_close = {}

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current_buf and M.is_real_buffer(buf) then
      table.insert(buffers_to_close, buf)
    end
  end

  for _, buf in ipairs(buffers_to_close) do
    vim.cmd("bdelete! " .. buf)
  end

  vim.notify(
    string.format("Closed %d other buffers", #buffers_to_close),
    vim.log.levels.INFO,
    { title = "Buffer Management" }
  )
end

-- Diagnostics
-- --------------------------------------------------
-- Toggle native virtual text diagnostics
local virtual_text_enabled = true
function M.toggle_virtual_text()
  virtual_text_enabled = not virtual_text_enabled

  vim.diagnostic.config({
    virtual_text = virtual_text_enabled and {
      source = "if_many",
      prefix = "●",
      spacing = 2,
    } or false,
  })

  vim.notify(
    "Virtual text: " .. (virtual_text_enabled and "enabled" or "disabled"),
    vim.log.levels.INFO,
    { title = "Diagnostics" }
  )
end

-- Show diagnostic popup on current line
function M.show_line_diagnostics()
  vim.diagnostic.open_float(nil, {
    focus = false,
    scope = "line",
    border = "single",
    source = "always",
  })
end

-- Show all buffer diagnostics
function M.show_buffer_diagnostics()
  vim.diagnostic.open_float(nil, {
    focus = true,
    scope = "buffer",
    border = "single",
    source = "always",
  })
end

-- Jump to next/previous diagnostic
function M.goto_next_diagnostic()
  vim.diagnostic.goto_next({ float = { border = "single" } })
end

function M.goto_prev_diagnostic()
  vim.diagnostic.goto_prev({ float = { border = "single" } })
end

-- Cursors
-- --------------------------------------------------
-- Smart pattern selection - prompts for pattern and selects matches
function M.smart_pattern_select()
  local pattern = vim.fn.input("Pattern: ")
  if pattern == "" then
    vim.notify("No pattern entered", vim.log.levels.WARN, { title = "Multicursor" })
    return
  end

  vim.cmd("MCpattern")
  vim.notify(string.format("Selected pattern: %s", pattern), vim.log.levels.INFO, { title = "Multicursor" })
end

-- Create cursors from visual selection with pattern
function M.visual_pattern_select()
  -- Check if we're in visual mode
  local mode = vim.fn.mode()
  if not (mode == "v" or mode == "V" or mode == "\22") then
    vim.notify("Must be in visual mode", vim.log.levels.WARN, { title = "Multicursor" })
    return
  end

  local pattern = vim.fn.input("Pattern within selection: ")
  if pattern == "" then
    vim.notify("No pattern entered", vim.log.levels.WARN, { title = "Multicursor" })
    return
  end

  vim.cmd("MCvisualPattern")
  vim.notify(string.format("Selected pattern in visual: %s", pattern), vim.log.levels.INFO, { title = "Multicursor" })
end

-- Toggle multicursor on word under cursor
function M.toggle_word_cursor()
  local word = vim.fn.expand("<cword>")
  if word == "" then
    vim.notify("No word under cursor", vim.log.levels.WARN, { title = "Multicursor" })
    return
  end

  vim.cmd("MCunderCursor")
  vim.notify(string.format("Multicursor on: %s", word), vim.log.levels.INFO, { title = "Multicursor" })
end

-- Start multicursor on current selection or word
function M.start_multicursor()
  local mode = vim.fn.mode()

  if mode == "v" or mode == "V" or mode == "\22" then
    -- Visual mode - use visual selection
    vim.cmd("MCvisual")
    vim.notify("Multicursor started on visual selection", vim.log.levels.INFO, { title = "Multicursor" })
  else
    -- Normal mode - use word under cursor
    local word = vim.fn.expand("<cword>")
    if word == "" then
      vim.notify("No word under cursor", vim.log.levels.WARN, { title = "Multicursor" })
      return
    end
    vim.cmd("MCstart")
    vim.notify(string.format("Multicursor started on: %s", word), vim.log.levels.INFO, { title = "Multicursor" })
  end
end

-- Clear all multicursors
function M.clear_multicursors()
  vim.cmd("MCclear")
  vim.notify("Multicursors cleared", vim.log.levels.INFO, { title = "Multicursor" })
end

-- Get multicursor status for statusline
function M.get_multicursor_status()
  local ok, hydra = pcall(require, "hydra.statusline")
  if ok and hydra.is_active() then
    return hydra.get_name()
  end
  return ""
end

-- Check if multicursor is active
function M.is_multicursor_active()
  local ok, hydra = pcall(require, "hydra.statusline")
  return ok and hydra.is_active()
end

-- Exposure
-- --------------------------------------------------
-- Make it available both ways
_G.functions = M
package.loaded["functions"] = M

return M
