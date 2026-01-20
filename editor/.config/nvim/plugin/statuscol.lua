local function resolve_hl(buf, lnum, is_current)
  local placed = vim.fn.sign_getplaced(buf, { group = "*", lnum = lnum })[1]
  for _, s in ipairs(placed and placed.signs or {}) do
    if s.name:match("^Dap") then
      return "BashBlue"
    end
  end

  local diags = vim.diagnostic.get(buf, { lnum = lnum - 1 })
  for _, d in ipairs(diags) do
    if d.severity == vim.diagnostic.severity.ERROR then
      return "BashRed"
    elseif d.severity == vim.diagnostic.severity.WARN then
      return "BashYellow"
    end
  end

  return is_current and "BashGreen" or "BashGray"
end

require("statuscol").setup({
  setopt = true,
  segments = {
    {
      text = {
        function(args)
          local hl = resolve_hl(args.buf, args.lnum, args.relnum == 0)

          if args.relnum == 0 then
            return "%#" .. hl .. "# $ %*"
          end

          return "%#" .. hl .. "#"
            .. string.format("%2d", args.relnum)
            .. " %*"
        end,
      },
    },
  },
})
