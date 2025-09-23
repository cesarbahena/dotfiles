return {
  {
    'echasnovski/mini.surround',
    opts = {
      respect_selection_type = false,
      silent = true,
      mappings = {
        add = 'r',
        delete = 'rd',
        find = 'rc',
        find_left = 'rp',
        highlight = 'rv',
        replace = 'rs',
        suffix_last = 'e',
        update_n_lines = 'r+',
      },
      custom_surroundings = {
        k = {
          input = {
            { '%b()', '%b[]', '%b{}', '%b<>' },
            '^.().*().$',
          },
          output = { left = '(', right = ')' },
        },
        K = {
          input = {
            { '%b{}', '%b[]', '%b()', '%b<>' },
            '^.().*().$',
          },
          output = { left = '{ ', right = ' }' },
        },
        q = {
          output = { left = "'", right = "'" },
        },
        Q = {
          input = {
            { [[%b'']], [[%b""]], [[%b""]] },
            '^.().*().$',
          },
          output = { left = [["]], right = [["]] },
        },
        D = {
          input = { '%[%[().-()%]%]', '^..().*()..$' },
          output = { left = '[[', right = ']]' },
        },
        ['$'] = {
          input = { '%$%{().-()%}', '^..().*()..$' },
          output = { left = '${', right = '}' },
        },
      },
    },
  },
}
