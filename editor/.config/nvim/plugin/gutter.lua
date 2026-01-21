require('statuscol').setup {
  setopt = true,
  segments = {
    {
      text = {
        function(args)
          local hl = require('hl_groups').get_lnr_color(args.buf, args.lnum, args.relnum == 0)

          if args.relnum == 0 then
            return '%#' .. hl .. '# $ %*'
          end

          return '%#' .. hl .. '#' .. string.format('%2d', args.relnum) .. ' %*'
        end,
      },
    },
  },
}
