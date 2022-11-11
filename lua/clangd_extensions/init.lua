local M = {}

M.hint_aucmd_set_up = false

function M.setup(opts)
    local lsp_config = M.prepare(opts)

    -- Call lspconfig setup
    require("lspconfig").clangd.setup(lsp_config)
end

function M.prepare(opts)
    local config = require("clangd_extensions.config")

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
        M.setup_comands()
    end

    -- Set up AST state stuff
    require("clangd_extensions.ast").init()

    return config.options.server
end

function M.setup_comands()
    -- nvim_get_commands would work here, but we don't need _all_ the commands, just an existence check
    if vim.fn.exists(':ClangdAST') == 0 then
        local inlay_hints = require('clangd_extensions.inlay_hints')
        local ast = require('clangd_extensions.ast')
        local type_hierarchy = require('clangd_extensions.type_hierarchy')
        local symbol_info = require('clangd_extensions.symbol_info')
        local memory_usage = require('clangd_extensions.memory_usage')

        vim.api.nvim_create_user_command('ClangdSetInlayHints', inlay_hints.set_inlay_hints, { nargs = 0 })
        vim.api.nvim_create_user_command('ClangdDisableInlayHints', inlay_hints.disable_inlay_hints, { nargs = 0 })
        vim.api.nvim_create_user_command('ClangdToggleInlayHints', inlay_hints.toggle_inlay_hints, { nargs = 0 })
        vim.api.nvim_create_user_command('ClangAST', function(opts) ast.display_ast(opts.line1, opts.line2) end, { range = true, nargs = 0 })
        vim.api.nvim_create_user_command('ClangdTypeHierarchy', type_hierarchy.show_hierarchy, { nargs = 0 })
        vim.api.nvim_create_user_command('ClangdSymbolInfo', symbol_info.show_symbol_info, { nargs = 0 })
        vim.api.nvim_create_user_command(
            'ClangdMemoryUsage',
            function(opts)
                memory_usage.show_memory_usage(opts.args == 'expand_preamble')
            end,
            {
                nargs = '?',
                complete = function(_,_,_)
                    return {'expand_preamble'}
                end
            }
        )
    end
end

return M
