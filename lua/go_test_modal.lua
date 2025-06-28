local M = {}

function M.run_go_test()
  local buf = vim.api.nvim_create_buf(false, true)

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
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

  vim.api.nvim_buf_set_name(buf, 'Go Test Output')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'go')
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})

  vim.keymap.set('n', '<Esc>', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, silent = true })

  vim.keymap.set('n', '<CR>', function()
    local line = vim.api.nvim_get_current_line()
    local file, lnum = string.match(line, '([%w%p_%-/]+%.go):(%d+):')
    if file and lnum then
      vim.api.nvim_win_close(win, true) -- close modal first
      vim.cmd('edit ' .. file)
      vim.api.nvim_win_set_cursor(0, { tonumber(lnum), 0 })
    end
  end, { buffer = buf, silent = true, nowait = true })

  vim.fn.jobstart({ 'go', 'test', '-v', './...' }, {
    stdout_buffered = false,
    on_stdout = function(_, data, _)
      if not data then
        return
      end

      for _, line in ipairs(data) do
        if line ~= '' and not line:match '^%?%s+[%w%p]+%s+%[no test files%]$' then
          local display_line = line

          if line:match '^%-%-%- PASS:' then
            display_line = '✅ ' .. line
          elseif line:match '^%-%-%- FAIL:' then
            display_line = '❌ ' .. line
          end

          vim.api.nvim_buf_set_lines(buf, -1, -1, false, { display_line })
        end
      end
    end,
    on_stderr = function(_, data, _)
      if data then
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
      end
    end,
    on_exit = function(_, _)
      vim.api.nvim_buf_set_lines(buf, -1, -1, false, { '=== Test Complete ===' })
    end,
  })
end

return M
