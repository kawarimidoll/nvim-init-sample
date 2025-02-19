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

vim.keymap.set({ 'n', 'x' }, 'x', '"_d', { desc = 'delete using blackhole register' })
vim.keymap.set('n', 'X', '"_D', { desc = 'delete using blackhole register' })
vim.keymap.set('o', 'x', 'd', { desc = 'delete using blackhole register' })

vim.keymap.set('n', 'p', 'p`]', { desc = 'paste and move the cursor to the end the pasted region' })
vim.keymap.set('n', 'P', 'P`]', { desc = 'paste and move the cursor to the end the pasted region' })

vim.keymap.set('x', 'p', 'P', { desc = 'paste without change register' })
vim.keymap.set('x', 'P', 'p', { desc = 'paste with change register' })

vim.keymap.set('c', '<c-n>', function()
  return vim.fn.wildmenumode() == 1 and '<c-n>' or '<down>'
end, { expr = true, desc = 'Select next' })
vim.keymap.set('c', '<c-p>', function()
  return vim.fn.wildmenumode() == 1 and '<c-p>' or '<up>'
end, { expr = true, desc = 'Select previous' })
vim.keymap.set('c', '<c-b>', '<left>', { desc = 'Emacs like left' })
vim.keymap.set('c', '<c-f>', '<right>', { desc = 'Emacs like right' })
vim.keymap.set('c', '<c-a>', '<home>', { desc = 'Emacs like home' })
vim.keymap.set('c', '<c-e>', '<end>', { desc = 'Emacs like end' })
vim.keymap.set('c', '<c-h>', '<bs>', { desc = 'Emacs like bs', remap = true })
vim.keymap.set('c', '<c-d>', '<del>', { desc = 'Emacs like del' })

vim.keymap.set('n', '<space>w', '<cmd>write<cr>', { desc = 'write' })
vim.keymap.set({ 'n', 'x' }, 'so', ':source<cr>', { silent = true, desc = 'Source current script' })

-- https://zenn.dev/vim_jp/articles/2024-10-07-vim-insert-uppercase
vim.keymap.set('i', '<c-l>', function()
  local col = vim.fn.getpos('.')[3]
  local substring = vim.fn.getline('.'):sub(1, col - 1)
  local result = vim.fn.matchstr(substring, [[\v<(\k(<)@!)*$]])
  return '<c-w>' .. result:upper()
end, { expr = true, desc = 'Capitalize word before cursor' })

vim.keymap.set('n', 'q:', '<nop>', { desc = 'disable cmdwin' })

vim.cmd.cnoreabbrev('qw wq')
vim.cmd.cnoreabbrev('lup lua<space>=')
