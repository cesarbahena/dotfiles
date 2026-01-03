local M = {}

-- Default keymapper
function M.map(spec)
  local which_key = try {
    require,
    'which-key',
    catch = function() return nil end,
    or_else = require 'utils.fallback_keymapper',
  }
  which_key.add(spec)
end

return M
