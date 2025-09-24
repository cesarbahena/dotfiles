local M = {}

function M.cache(self)
  local harpoon = require 'harpoon'
  self.marks = harpoon:list().items
  self.current_file_path = vim.fn.expand '%:p:.'

  -- Calculate total length for compact mode decision
  local total_length = 0
  for _, item in ipairs(self.marks) do
    local filename = vim.fn.fnamemodify(item.value, ':t'):gsub('%..*', '')
    total_length = total_length + #filename + 4 -- +4 for " -t " or " --"
  end

  self.use_compact = total_length > (vim.o.columns * 0.4) or #self.marks > 4

  -- Pre-calculate the display text
  if #self.marks == 0 then
    self.display_text = ''
  elseif self.use_compact then
    -- Compact mode: -Abc (capital for current, lowercase for others)
    local letters = {}
    for _, item in ipairs(self.marks) do
      local first_letter = vim.fn.fnamemodify(item.value, ':t'):sub(1, 1)
      if item.value == self.current_file_path then
        table.insert(letters, first_letter:upper()) -- Capital for current
      else
        table.insert(letters, first_letter:lower()) -- Lowercase for others
      end
    end
    self.display_text = ' -' .. table.concat(letters, '')
  else
    -- Full mode: -t filename --filename
    local result = {}
    for _, item in ipairs(self.marks) do
      local filename = vim.fn.fnamemodify(item.value, ':t'):gsub('%..*', '')
      if item.value == self.current_file_path then
        table.insert(result, ' -t ' .. filename) -- Active: -t filename
      else
        table.insert(result, ' --' .. filename) -- Inactive: --filename
      end
    end
    self.display_text = table.concat(result, '')
  end
end

function M.marks()
  local harpoon = require 'harpoon'
  local marks = harpoon:list().items
  local current_file_path = vim.fn.expand '%:p:.'

  if #marks == 0 then return '' end

  local total_length = 0
  for _, item in ipairs(marks) do
    local filename = vim.fn.fnamemodify(item.value, ':t'):gsub('%..*', '')
    total_length = total_length + #filename + 4
  end

  local use_compact = total_length > (vim.o.columns * 0.4) or #marks > 4

  if use_compact then
    local letters = {}
    for _, item in ipairs(marks) do
      local first_letter = vim.fn.fnamemodify(item.value, ':t'):sub(1, 1)
      if item.value == current_file_path then
        table.insert(letters, first_letter:upper())
      else
        table.insert(letters, first_letter:lower())
      end
    end
    return ' -' .. table.concat(letters, '')
  else
    local result = {}
    for _, item in ipairs(marks) do
      local filename = vim.fn.fnamemodify(item.value, ':t'):gsub('%..*', '')
      if item.value == current_file_path then
        table.insert(result, ' -t ' .. filename)
      else
        table.insert(result, ' --' .. filename)
      end
    end
    return table.concat(result, '')
  end
end

return M

