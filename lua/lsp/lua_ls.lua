local lua_opts = {}
lua_opts.on_init = function(client)
  if client.workspace_folders then
    local path = client.workspace_folders[1].name
    if vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc') then
      return
    end
  end
  client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
    runtime = { version = 'LuaJIT' },
    workspace = {
      checkThirdParty = 'Disable',
      library = vim.list_extend(vim.api.nvim_get_runtime_file('lua', true), {
        '${3rd}/luv/library',
        '${3rd}/busted/library',
        '${3rd}/luassert/library',
      }),
    }
  })
end
lua_opts.settings = { Lua = {} }
require('lspconfig').lua_ls.setup(lua_opts)
