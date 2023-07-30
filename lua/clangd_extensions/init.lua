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
        vim.api.nvim_create_user_command('ClangdSetInlayHints', function()
            require("clangd_extensions.inlay_hints").set_inlay_hints()
        end, { nargs = 0 })
        vim.api.nvim_create_user_command('ClangdDisableInlayHints', function()
            require("clangd_extensions.inlay_hints").disable_inlay_hints()
        end, { nargs = 0 })
        vim.api.nvim_create_user_command('ClangdToggleInlayHints', function()
            require("clangd_extensions.inlay_hints").toggle_inlay_hints()
        end, { nargs = 0 })
        vim.api.nvim_create_user_command('ClangdAST', function(opts)
            require("clangd_extensions.ast").display_ast(opts.line1, opts.line2)
        end, { range = true, nargs = 0 })
        vim.api.nvim_create_user_command('ClangdTypeHierarchy', function()
            require("clangd_extensions.type_hierarchy").show_hierarchy()
        end, { nargs = 0 })
        vim.api.nvim_create_user_command('ClangdSymbolInfo', function()
            require("clangd_extensions.symbol_info").show_symbol_info()
        end, { nargs = 0 })
        vim.api.nvim_create_user_command(
            'ClangdMemoryUsage',
            function(opts)
                require("clangd_extensions.memory_usage").show_memory_usage(opts.args == 'expand_preamble')
            end,
            {
                nargs = '?',
                complete = function(_, _, _)
                    return { 'expand_preamble' }
                end
            }
        )
    end
end

return M
