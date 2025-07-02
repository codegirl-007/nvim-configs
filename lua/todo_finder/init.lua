local M = {}

function M.setup()
  vim.api.nvim_create_user_command('TodoList', function()
    require('todo_finder.telescope').show()
  end, {})
end

return M
