local M = {}

local namespace = vim.api.nvim_create_namespace 'semgrep'
local Job = require 'plenary.job'

function M.run_semgrep()
  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)

  Job:new({
    command = 'semgrep',
    args = { '--quiet', '--json', '--config=smell.yaml', filepath },
    on_exit = function(j)
      local output = table.concat(j:result(), '\n')
      local ok, decoded = pcall(vim.json.decode, output)
      if not ok or not decoded.results then
        return
      end

      local diagnostics = {}
      for _, result in ipairs(decoded.results) do
        if result.path == filepath then
          local msg = result.extra.message or 'Code smell'
          local start = result.start
          local finish = result['end']
          table.insert(diagnostics, {
            lnum = start.line - 1,
            col = start.col - 1,
            end_lnum = finish.line - 1,
            end_col = finish.col - 1,
            severity = vim.diagnostic.severity.WARN,
            message = msg,
            source = 'semgrep',
          })
        end
      end

      vim.schedule(function()
        vim.diagnostic.set(namespace, bufnr, diagnostics, {})
      end)
    end,
  }):start()
end

return M
