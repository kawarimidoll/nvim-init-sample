-- share clipboard with OS
vim.opt.clipboard:append('unnamedplus,unnamed')

-- use 2 spaces tab
vim.opt.expandtab = true
vim.opt.shiftround = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2

-- scroll before 3 lines
vim.opt.scrolloff = 3

-- move the cursor to the previous/next line across the first/last character
vim.opt.whichwrap = 'b,s,h,l,<,>,[,],~'

-- improve command line completion
vim.opt.wildmode = { 'longest', 'full' }

-- set window title
vim.opt.title = true

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

-- augroup for this config file
local augroup = vim.api.nvim_create_augroup('init.lua', {})

-- wrapper function to use the internal augroup
local create_autocmd = function(event, opts)
  vim.api.nvim_create_autocmd(event, vim.tbl_extend('force', {
    group = augroup,
  }, opts))
end

-- https://vim-jp.org/vim-users-jp/2011/02/20/Hack-202.html
create_autocmd('BufWritePre', {
  pattern = '*',
  callback = function(event)
    local dir = vim.fs.dirname(event.file)
    local force = vim.v.cmdbang == 1
    if vim.fn.isdirectory(dir) == 0
        and (force or vim.fn.confirm('"' .. dir .. '" does not exist. Create?', "&Yes\n&No") == 1) then
      vim.fn.mkdir(vim.fn.iconv(dir, vim.opt.encoding:get(), vim.opt.termencoding:get()), 'p')
    end
  end
})
