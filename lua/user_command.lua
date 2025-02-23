vim.api.nvim_create_user_command(
  'InitLua',
  function()
    vim.cmd.edit(vim.fn.stdpath('config') .. '/init.lua')
  end,
  { desc = 'Open init.lua' }
)

vim.api.nvim_create_user_command(
  'CopyLastCmd',
  function()
    vim.fn.setreg('*', vim.fn.getreg(':'))
    -- unless vim.opt.clipboard has unnamed
    -- vim.fn.setreg('', vim.fn.getreg(':'))
  end,
  { desc = 'Copy last used command' }
)
