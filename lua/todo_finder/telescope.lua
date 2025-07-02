-- ~/.config/nvim/lua/todo_finder/telescope.lua

local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local previewers = require 'telescope.previewers'
local Path = require 'plenary.path'

local M = {}

local function parse_todo_lines(lines)
  local entries = {}
  for _, line in ipairs(lines) do
    local filename, lnum, text = line:match '([^:]+):(%d+):(.*)'
    if filename and lnum then
      table.insert(entries, {
        display = string.format('%s:%s: %s', filename, lnum, text),
        ordinal = filename .. text,
        filename = filename,
        lnum = tonumber(lnum),
        text = text,
      })
    end
  end
  return entries
end

local function get_custom_previewer()
  return previewers.new_buffer_previewer {
    define_preview = function(self, entry)
      local file = Path:new(entry.value.filename)
      if not file:exists() then
        return
      end

      local lines = file:readlines()
      local lnum = entry.value.lnum

      local start = math.max(lnum - 5, 1)
      local finish = math.min(lnum + 5, #lines)
      local preview_lines = {}

      for i = start, finish do
        table.insert(preview_lines, lines[i])
      end

      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_lines)
      vim.api.nvim_buf_add_highlight(self.state.bufnr, -1, 'Search', lnum - start, 0, -1)
    end,
  }
end

function M.show()
  local rg_cmd = {
    'rg',
    '--no-heading',
    '--with-filename',
    '--line-number',
    '--color',
    'never',
    [[(?i)^\s*(//|#|--|/\*+)\s*.*\b(TODO|FIXME|BUG|HACK)\b]],
  }

  local lines = vim.fn.systemlist(rg_cmd)
  if vim.v.shell_error ~= 0 or #lines == 0 then
    vim.notify('No TODOs found.', vim.log.levels.INFO)
    return
  end

  local results = parse_todo_lines(lines)

  pickers
    .new({}, {
      prompt_title = "Things You'll Never Do",
      finder = finders.new_table {
        results = results,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.display,
            ordinal = entry.ordinal,
          }
        end,
      },
      sorter = conf.generic_sorter {},
      previewer = get_custom_previewer(),
      attach_mappings = function(_, map)
        actions.select_default:replace(function()
          actions.close()
          local entry = action_state.get_selected_entry().value
          vim.cmd('edit ' .. entry.filename)
          vim.fn.cursor(entry.lnum, 1)
        end)
        return true
      end,
    })
    :find()
end

return M
