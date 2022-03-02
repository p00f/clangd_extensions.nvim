local config = require("clangd_extensions.config")

local M = {}

M.hint_aucmd_set_up = false

local commands = [[
if !exists(':ClangdAST')

  function s:memuse_compl(_a,_b,_c)
      return ['expand_preamble']
  endfunction

  command ClangdSetInlayHints lua require('clangd_extensions.inlay_hints').set_inlay_hints()
  command ClangdDisableInlayHints lua require('clangd_extensions.inlay_hints').disable_inlay_hints()
  command ClangdToggleInlayHints lua require('clangd_extensions.inlay_hints').toggle_inlay_hints()
  command -range ClangdAST lua require('clangd_extensions.ast').display_ast(<line1>, <line2>)
  command ClangdTypeHierarchy lua require('clangd_extensions.type_hierarchy').show_hierarchy()
  command ClangdSymbolInfo lua require('clangd_extensions.symbol_info').show_symbol_info()
  command -nargs=? -complete=customlist,s:memuse_compl ClangdMemoryUsage lua require('clangd_extensions.memory_usage').show_memory_usage('<args>' == 'expand_preamble')

endif
]]

function M.setup(opts)
    -- Set up extensions, get lspconfig opts
    config.setup(opts)
    -- Set up autocommands for inlay hints
    local old_func = config.options.server.on_attach
    config.options.server.on_attach = function(client, bufnr)
        if old_func then
            old_func(client, bufnr)
        end
        if config.options.extensions.autoSetHints then
            require("clangd_extensions.inlay_hints").setup_autocmd()
            require("clangd_extensions.inlay_hints").set_inlay_hints()
        end
        vim.cmd(commands)
    end
    -- Call lspconfig setup
    require("lspconfig").clangd.setup(config.options.server)

    -- Set up AST state stuff
    require("clangd_extensions.ast").init()
end

return M
