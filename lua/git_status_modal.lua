local M = {}

function M.open()
  local buf = vim.api.nvim_create_buf(false, true)

  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.6)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  })

  vim.api.nvim_buf_set_name(buf, 'Git Status')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'diff')
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})

  local file_paths = {}

  vim.keymap.set('n', '<Esc>', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, silent = true })

  vim.keymap.set('n', '<CR>', function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line_num = cursor[1]
    local path = file_paths[line_num]
    if path and path ~= '' then
      vim.api.nvim_win_close(win, true)
      vim.cmd('edit ' .. vim.fn.fnameescape(path))
    end
  end, { buffer = buf, silent = true })

  -- Add git add functionality
  vim.keymap.set('n', 'a', function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line_num = cursor[1]
    local path = file_paths[line_num]
    if path and path ~= '' then
      vim.fn.system({'git', 'add', path})
      vim.notify('Added: ' .. path, vim.log.levels.INFO)
      -- Refresh the modal
      vim.api.nvim_win_close(win, true)
      M.open()
    end
  end, { buffer = buf, silent = true, desc = 'Git add file' })

  -- Add help text
  vim.keymap.set('n', '?', function()
    vim.notify('Git Status Modal:\n<CR> - Open file\na - Git add file\n<Esc> - Close', vim.log.levels.INFO)
  end, { buffer = buf, silent = true, desc = 'Show help' })

  vim.fn.jobstart({ 'git', 'status', '--short' }, {
    stdout_buffered = true,
    on_stdout = function(_, data, _)
      if data then
        local decorated = {}
        for _, line in ipairs(data) do
          if line ~= '' then
            local icon = ''
            if line:match '^%s*M' then
              icon = '🟡'
            elseif line:match '^%s*A' then
              icon = '🟢'
            elseif line:match '^%s*D' then
              icon = '🔴'
            elseif line:match '^%?%?' then
              icon = '🌀'
            end

            table.insert(decorated, icon .. ' ' .. line)
            local path = line:match '^%s*[%?MAD]+%s+(.+)$'
            table.insert(file_paths, path or '')
          end
        end
        if #decorated == 0 then
          decorated = { 'No changes detected' }
        end
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, decorated)
      end
    end,
    on_stderr = function(_, data, _)
      if data and #data > 0 then
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { 'Error: Not a git repository or git not found' })
      end
    end,
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, { '', '=== Git Status Complete (Press ? for help) ===' })
      end
    end,
  })
end

return M
