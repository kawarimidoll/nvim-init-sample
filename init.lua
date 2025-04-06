-- share clipboard with OS
vim.opt.clipboard:append('unnamedplus,unnamed')

-- use 2-spaces indent
vim.opt.expandtab = true
vim.opt.shiftround = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2

-- scroll offset as 3 lines
vim.opt.scrolloff = 3

-- move the cursor to the previous/next line across the first/last character
vim.opt.whichwrap = 'b,s,h,l,<,>,[,],~'

vim.api.nvim_create_user_command(
  'InitLua',
  function()
    vim.cmd.edit(vim.fn.stdpath('config') .. '/init.lua')
  end,
  { desc = 'Open init.lua' }
)

-- augroup for this config file
local augroup = vim.api.nvim_create_augroup('init.lua', {})

-- wrapper function to use internal augroup
local function create_autocmd(event, opts)
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
  end,
  desc = 'Auto mkdir to save file'
})

vim.keymap.set('n', 'p', 'p`]', { desc = 'Paste and move the end' })
vim.keymap.set('n', 'P', 'P`]', { desc = 'Paste and move the end' })

vim.keymap.set('x', 'p', 'P', { desc = 'Paste without change register' })
vim.keymap.set('x', 'P', 'p', { desc = 'Paste with change register' })

vim.keymap.set({ 'n', 'x' }, 'x', '"_d', { desc = 'Delete into blackhole' })
vim.keymap.set('n', 'X', '"_D', { desc = 'Delete into blackhole' })
vim.keymap.set('o', 'x', 'd', { desc = 'Delete using x' })

vim.keymap.set('c', '<c-b>', '<left>', { desc = 'Emacs like left' })
vim.keymap.set('c', '<c-f>', '<right>', { desc = 'Emacs like right' })
vim.keymap.set('c', '<c-a>', '<home>', { desc = 'Emacs like home' })
vim.keymap.set('c', '<c-e>', '<end>', { desc = 'Emacs like end' })
vim.keymap.set('c', '<c-h>', '<bs>', { desc = 'Emacs like bs' })
vim.keymap.set('c', '<c-d>', '<del>', { desc = 'Emacs like del' })

vim.keymap.set('n', '<space>;', '@:', { desc = 'Re-run the last command' })

vim.keymap.set('n', '<space>w', '<cmd>write<cr>', { desc = 'Write' })

vim.keymap.set({ 'n', 'x' }, 'so', ':source<cr>', { silent = true, desc = 'Source current script' })

vim.keymap.set('c', '<c-n>', function()
  return vim.fn.wildmenumode() == 1 and '<c-n>' or '<down>'
end, { expr = true, desc = 'Select next' })
vim.keymap.set('c', '<c-p>', function()
  return vim.fn.wildmenumode() == 1 and '<c-p>' or '<up>'
end, { expr = true, desc = 'Select previous' })

vim.keymap.set('n', '<space>q', function()
  if not pcall(vim.cmd.tabclose) then
    vim.cmd.quit()
  end
end, { desc = 'Quit current tab or window' })

vim.keymap.set('n', 'q:', '<nop>', { desc = 'Disable cmdwin' })

-- abbreviation only for ex-command
local function abbrev_excmd(lhs, rhs, opts)
  vim.keymap.set('ca', lhs, function()
    return vim.fn.getcmdtype() == ':' and rhs or lhs
  end, vim.tbl_extend('force', { expr = true }, opts))
end

abbrev_excmd('qw', 'wq', { desc = 'fix typo' })
abbrev_excmd('lup', 'lua =', { desc = 'lua print' })

-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.uv.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    'git', 'clone', '--filter=blob:none',
    'https://github.com/echasnovski/mini.nvim', mini_path
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps' (customize to your liking)
require('mini.deps').setup({ path = { package = path_package } })

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

now(function()
  require('mini.icons').setup()
end)

now(function()
  require('mini.basics').setup({
    options = {
      extra_ui = true,
    },
    mappings = {
      option_toggle_prefix = 'm',
    },
  })
end)

later(function()
  add('https://github.com/vim-jp/vimdoc-ja')
  -- Prefer Japanese as the help language
  vim.opt.helplang:prepend('ja')
end)

now(function()
  require('mini.statusline').setup()
  vim.opt.laststatus = 3
  vim.opt.cmdheight = 0

  -- ref: https://github.com/Shougo/shougo-s-github/blob/2f1c9acacd3a341a1fa40823761d9593266c65d4/vim/rc/vimrc#L47-L49
  create_autocmd({ 'RecordingEnter', 'CmdlineEnter' }, {
    pattern = '*',
    callback = function()
      vim.opt.cmdheight = 1
    end,
  })
  create_autocmd('RecordingLeave', {
    pattern = '*',
    callback = function()
      vim.opt.cmdheight = 0
    end,
  })
  create_autocmd('CmdlineLeave', {
    pattern = '*',
    callback = function()
      if vim.fn.reg_recording() == '' then
        vim.opt.cmdheight = 0
      end
    end,
  })
end)

now(function()
  require('mini.misc').setup()

  MiniMisc.setup_restore_cursor()

  vim.api.nvim_create_user_command('Zoom', function()
    MiniMisc.zoom(0, {})
  end, { desc = 'Zoom current buffer' })
  vim.keymap.set('n', 'mz', '<cmd>Zoom<cr>', { desc = 'Zoom current buffer' })
end)

now(function()
  require('mini.notify').setup()

  vim.notify = require('mini.notify').make_notify({})

  vim.api.nvim_create_user_command('NotifyHistory', function()
    MiniNotify.show_history()
  end, { desc = 'Show notify history' })
end)

now(function()
  local base16 = require('mini.base16')
  local zenn_palette = base16.mini_palette(
    '#0a2a2a', -- background
    '#edf2f6', -- foreground
    75         -- accent chroma
  )
  base16.setup({ palette = zenn_palette })

  -- overwrite highlight WinSeparator
  vim.api.nvim_set_hl(0, 'WinSeparator', { link = 'Comment' })
  -- call autocmd ColorScheme manually
  vim.api.nvim_exec_autocmds('ColorScheme', {})
end)

later(function()
  local hipatterns = require('mini.hipatterns')
  local hi_words = require('mini.extra').gen_highlighter.words
  hipatterns.setup({
    highlighters = {
      -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
      fixme = hi_words({ 'FIXME', 'Fixme', 'fixme' }, 'MiniHipatternsFixme'),
      hack = hi_words({ 'HACK', 'Hack', 'hack' }, 'MiniHipatternsHack'),
      todo = hi_words({ 'TODO', 'Todo', 'todo' }, 'MiniHipatternsTodo'),
      note = hi_words({ 'NOTE', 'Note', 'note' }, 'MiniHipatternsNote'),
      -- Highlight hex color strings (`#rrggbb`) using that color
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end)

later(function()
  require('mini.cursorword').setup()
end)

later(function()
  require('mini.indentscope').setup()
end)

later(function()
  require('mini.trailspace').setup()

  vim.api.nvim_create_user_command(
    'Trim',
    function()
      MiniTrailspace.trim()
      MiniTrailspace.trim_last_lines()
    end,
    { desc = 'Trim trailing space and last blank lines' }
  )
end)

now(function()
  require('mini.starter').setup()
end)
