-- cache init.lua
vim.loader.enable()

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

require('bool_fn')
require('user_command')

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
    if not vim.bool_fn.isdirectory(dir)
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
  return vim.bool_fn.wildmenumode() and '<c-n>' or '<down>'
end, { expr = true, desc = 'Select next' })
vim.keymap.set('c', '<c-p>', function()
  return vim.bool_fn.wildmenumode() and '<c-p>' or '<up>'
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

-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
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
  add('vim-jp/vimdoc-ja')
  -- Prefer Japanese as the help language
  vim.opt.helplang:prepend('ja')
end)

now(function()
  require('mini.statusline').setup()
  vim.opt.laststatus = 3
  vim.opt.cmdheight = 0
end)

now(function()
  require('mini.misc').setup()
  MiniMisc.setup_restore_cursor()

  -- Zoom command
  vim.api.nvim_create_user_command('Zoom', function()
    MiniMisc.zoom(0, {})
  end, { desc = 'Zoom current buffer' })
  -- Zoom keymap
  vim.keymap.set('n', '<space>z', function()
    MiniMisc.zoom(0, {})
  end, { desc = 'Zoom current buffer' })
end)

now(function()
  require('mini.notify').setup()
  vim.notify = require('mini.notify').make_notify({
    ERROR = { duration = 10000 }
  })
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
  require('mini.sessions').setup()

  vim.api.nvim_create_user_command('SessionWrite', function(arg)
    vim.cmd('%argdelete')
    MiniSessions.write(arg.args ~= '' and arg.args or nil)
  end, { desc = 'Write session', nargs = '?' })
  vim.api.nvim_create_user_command('SessionDelete', function()
    MiniSessions.select('delete')
  end, { desc = 'Delete session' })
  vim.api.nvim_create_user_command('SessionLoad', function()
    MiniSessions.select('read')
  end, { desc = 'Load session' })
  vim.api.nvim_create_user_command('SessionEscape', function()
    vim.v.this_session = ''
  end, { desc = 'Load session' })
end)

now(function()
  require('mini.starter').setup()
end)

later(function()
  require('mini.pairs').setup()
end)

later(function()
  require('mini.surround').setup()

  create_autocmd('FileType', {
    pattern = 'javascript,typescript,javascriptreact,typescriptreact',
    callback = function()
      vim.b.minisurround_config = {
        custom_surroundings = {
          s = {
            input = { '${().-()}' },
            output = { left = '${', right = '}' },
          },
        },
      }
    end
  })
end)

later(function()
  local gen_ai_spec = require('mini.extra').gen_ai_spec
  require('mini.ai').setup({
    custom_textobjects = {
      B = gen_ai_spec.buffer(),
      D = gen_ai_spec.diagnostic(),
      I = gen_ai_spec.indent(),
      L = gen_ai_spec.line(),
      N = gen_ai_spec.number(),
      J = { { '()%d%d%d%d%-%d%d%-%d%d()', '()%d%d%d%d%/%d%d%/%d%d()' } }
    },
  })

  create_autocmd('FileType', {
    pattern = 'javascript,typescript,javascriptreact,typescriptreact',
    callback = function()
      vim.b.miniai_config = {
        custom_textobjects = {
          s = { '${().-()}' },
        },
      }
    end
  })
end)

later(function()
  local function mode_nx(keys)
    return { mode = 'n', keys = keys }, { mode = 'x', keys = keys }
  end
  local clue = require('mini.clue')
  clue.setup({
    triggers = {
      -- Leader triggers
      mode_nx('<Leader>'),

      -- Built-in completion
      { mode = 'i', keys = '<c-x>' },

      -- `g` key
      mode_nx('g'),

      -- Marks
      mode_nx("'"),
      mode_nx('`'),

      -- Registers
      mode_nx('"'),
      { mode = 'i', keys = '<c-r>' },
      { mode = 'c', keys = '<c-r>' },

      -- Window commands
      { mode = 'n', keys = '<c-w>' },

      -- bracketed commands
      { mode = 'n', keys = '[' },
      { mode = 'n', keys = ']' },

      -- `z` key
      mode_nx('z'),

      -- surround
      mode_nx('s'),

      -- text object
      { mode = 'x', keys = 'i' },
      { mode = 'x', keys = 'a' },
      { mode = 'o', keys = 'i' },
      { mode = 'o', keys = 'a' },

      -- option toggle
      { mode = 'n', keys = 'm' },
    },

    clues = {
      -- Enhance this by adding descriptions for <Leader> mapping groups
      clue.gen_clues.builtin_completion(),
      clue.gen_clues.g(),
      clue.gen_clues.marks(),
      clue.gen_clues.registers({ show_contents = true }),
      clue.gen_clues.windows({ submode_resize = true, submode_move = true }),
      clue.gen_clues.z(),
      { mode = 'n', keys = 'mm', desc = '+mini.map' },
    },
  })
end)

now(function()
  add({
    source = 'neovim/nvim-lspconfig',
    depends = { 'williamboman/mason.nvim' },
  })

  ---@diagnostic disable-next-line: missing-fields
  require('mason').setup({
    ui = {
      icons = {
        package_installed = '✓',
        package_pending = '➜',
        package_uninstalled = '✗'
      }
    }
  })

  -- https://eiji.page/blog/neovim-diagnostic-config/
  vim.diagnostic.config({
    virtual_text = {
      format = function(diagnostic)
        return string.format("%s (%s: %s)", diagnostic.message, diagnostic.source, diagnostic.code)
      end,
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "⛔",
        [vim.diagnostic.severity.WARN] = "⚠️",
        [vim.diagnostic.severity.INFO] = "ℹ️",
        [vim.diagnostic.severity.HINT] = "💡",
      },
    },
  })

  -- :h lsp-attach
  create_autocmd('LspAttach', {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then
        return
      end

      if client:supports_method('textDocument/formatting') then
        -- Format the current buffer on save
        create_autocmd('BufWritePre', {
          buffer = args.buf,
          callback = function()
            vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
          end,
        })
      end
    end,
  })

  require('lsp.lua_ls')
end)

later(function()
  add('liangxianzhe/floating-input.nvim')
end)

later(function()
  require('mini.completion').setup()
  vim.opt.completeopt:append('fuzzy')

  -- helper function
  local imap_expr = function(lhs, rhs)
    vim.keymap.set('i', lhs, rhs, { expr = true })
  end

  -- define keycodes
  local keys = {
    cn = vim.keycode('<c-n>'),
    cp = vim.keycode('<c-p>'),
    ct = vim.keycode('<c-t>'),
    cd = vim.keycode('<c-d>'),
    cr = vim.keycode('<cr>'),
    cy = vim.keycode('<c-y>'),
  }

  -- choose by <tab>/<s-tab>
  imap_expr('<tab>', function()
    -- popup is visible -> next item
    -- popup is NOT visible -> add indent
    return vim.bool_fn.pumvisible() and keys.cn or keys.ct
  end)
  imap_expr('<s-tab>', function()
    -- popup is visible -> previous item
    -- popup is NOT visible -> remove indent
    return vim.bool_fn.pumvisible() and keys.cp or keys.cd
  end)
  -- select by <cr>
  imap_expr('<cr>', function()
    if not vim.bool_fn.pumvisible() then
      -- popup is NOT visible -> insert newline
      -- return keys.cr
      return require('mini.pairs').cr() -- for `mini.pairs` users
    end
    local item_selected = vim.fn.complete_info()['selected'] ~= -1
    if item_selected then
      -- popup is visible and item is selected -> select item
      return keys.cy
    end
    -- popup is visible but item is NOT selected -> hide popup and insert newline
    return keys.cy .. keys.cr
  end)
end)

later(function()
  require('mini.tabline').setup()
end)

later(function()
  require('mini.bufremove').setup()

  vim.api.nvim_create_user_command(
    'Bufdelete',
    function()
      MiniBufremove.delete()
    end,
    { desc = 'Remove buffer' }
  )
end)

later(function()
  require('mini.files').setup()

  vim.api.nvim_create_user_command(
    'Files',
    function()
      MiniFiles.open()
    end,
    { desc = 'Open file exproler' }
  )
end)

later(function()
  require('mini.visits').setup()
end)

later(function()
  require('mini.pick').setup()

  vim.ui.select = MiniPick.ui_select

  vim.keymap.set('n', '<space>f', function()
    MiniPick.builtin.files({ tool = 'git' })
  end, { desc = 'mini.pick.files' })

  vim.keymap.set('n', '<space>b', function()
    MiniPick.builtin.buffers(
      { include_current = false },
      {
        mappings = {
          wipeout = {
            char = '<c-d>',
            func = function()
              vim.api.nvim_buf_delete(MiniPick.get_picker_matches().current.bufnr, {})
            end
          }
        }
      }
    )
  end, { desc = 'mini.pick.buffers' })

  vim.keymap.set('n', '<space>h', function()
    require('mini.extra').pickers.visit_paths()
  end, { desc = 'mini.extra.visit_paths' })

  vim.keymap.set('c', 'h', function()
    if vim.fn.getcmdtype() .. vim.fn.getcmdline() == ':h' then
      return '<c-u>Pick help<cr>'
    end
    return 'h'
  end, { expr = true, desc = 'mini.pick.help' })
end)

later(function()
  require('mini.diff').setup()
end)

later(function()
  require('mini.git').setup()

  vim.keymap.set({ 'n', 'x' }, '<space>gs', MiniGit.show_at_cursor, { desc = 'Show at cursor' })
end)

later(function()
  require('mini.operators').setup({
    exchange = { prefix = 'g/' },
    replace = { prefix = 'R' },
  })

  vim.keymap.set('n', 'RR', 'R', { desc = 'Replace mode' })
end)

later(function()
  require('mini.jump').setup({
    delay = {
      idle_stop = 10,
    },
  })
end)

later(function()
  require('mini.jump2d').setup()
end)

later(function()
  local animate = require('mini.animate')
  animate.setup({
    cursor = {
      -- Animate for 100 milliseconds with linear easing
      timing = animate.gen_timing.linear({ duration = 100, unit = 'total' }),

      -- Animate with shortest line for any cursor move
      path = animate.gen_path.line({
        predicate = function() return true end,
      }),
    },
    scroll = {
      -- Animate for 150 milliseconds with linear easing
      timing = animate.gen_timing.linear({ duration = 150, unit = 'total' }),
    },
  })
end)

later(function()
  require('mini.bracketed').setup()
end)

later(
  function()
    require('mini.splitjoin').setup({
      mappings = {
        toggle = 'gS',
        split = 'ss',
        join = 'sj',
      },
    })
  end
)

later(function()
  require('mini.move').setup()
end)

later(function()
  require('mini.align').setup()
end)

later(function()
  local map = require('mini.map')
  map.setup({
    integrations = {
      map.gen_integration.builtin_search(),
      map.gen_integration.diff(),
      map.gen_integration.diagnostic(),
    },
    symbols = {
      scroll_line = '▶',
    }
  })
  vim.keymap.set('n', 'mmf', MiniMap.toggle_focus, { desc = 'MiniMap.toggle_focus' })
  vim.keymap.set('n', 'mms', MiniMap.toggle_side, { desc = 'MiniMap.toggle_side' })
  vim.keymap.set('n', 'mmt', MiniMap.toggle, { desc = 'MiniMap.toggle' })
end)

later(function()
  vim.treesitter.start = (function(wrapped)
    return function(bufnr, lang)
      lang = lang or vim.fn.getbufvar(bufnr or '', '&filetype')
      pcall(wrapped, bufnr, lang)
    end
  end)(vim.treesitter.start)

  add({
    source = 'nvim-treesitter/nvim-treesitter',
    depends = { 'JoosepAlviste/nvim-ts-context-commentstring' },
    hooks = {
      post_checkout = function()
        vim.cmd.TSUpdate()
      end
    },
  })
  ---@diagnostic disable-next-line: missing-fields
  require('nvim-treesitter.configs').setup({
    -- add auto-install languages
    ensure_installed = { 'lua', 'vim', 'tsx' },
    highlight = { enable = true },
  })

  local ctx_cms = require('ts_context_commentstring')
  ctx_cms.setup({ enable_autocmd = false })
  require('mini.comment').setup({
    options = {
      custom_commentstring = function()
        return ctx_cms.calculate_commentstring() or vim.bo.commentstring
      end,
    },
  })
end)

later(function()
  vim.keymap.set('n', '?', '<cmd>silent vimgrep//gj%|copen<cr>',
    { desc = 'Populate latest search result to quickfix list' })

  -- use rg for external-grep
  vim.opt.grepprg =
  [[rg --vimgrep --trim --hidden --glob=!.git --glob='!*.lock' --glob='!*-lock.json']]
  vim.opt.grepformat = '%f:%l:%c:%m'

  -- original: `:NewGrep` in :help grep
  vim.api.nvim_create_user_command('Grep', function(arg)
    local fargs = vim.fn.join(arg.fargs, ' ')
    local args = {
      'silent',
      'grep!',
      (arg.bang and '--fixed-strings --' or ''),
      [[']] .. string.gsub(fargs, [[']], [['\'']]) .. [[']],
    }
    vim.cmd.execute(vim.fn.string(table.concat(args, ' ')))
    local size = vim.fn.getqflist({ size = true }).size
    if size > 0 then
      vim.cmd.copen()
    else
      vim.notify('no matches found', vim.log.levels.WARN)
      vim.cmd.cclose()
    end
  end, { nargs = '+', bang = true, desc = 'Enhounced grep' })

  vim.keymap.set('n', '<space>/', ':Grep ', { desc = 'Grep' })
  vim.keymap.set('n', '<space>?', ':Grep <c-r><c-w>', { desc = 'Grep current word' })
end)

later(function()
  add({ source = 'stevearc/quicker.nvim' })
  local quicker = require('quicker')
  vim.keymap.set('n', 'mq', quicker.toggle, { desc = 'Toggle quickfix' })
  quicker.setup({
    keys = {
      { '>', quicker.expand,   desc = 'Expand quickfix content' },
      { '<', quicker.collapse, desc = 'Collapse quickfix content' },
    },
  })
end)

now(function()
  local default_rtp = vim.opt.runtimepath:get()
  vim.opt.runtimepath:remove(vim.env.VIMRUNTIME)
  vim.cmd.source(vim.env.VIMRUNTIME .. '/filetype.lua')
  create_autocmd("SourcePre", {
    pattern = "*/plugin/*",
    once = true,
    callback = function()
      vim.opt.runtimepath = default_rtp
    end
  })
end)
