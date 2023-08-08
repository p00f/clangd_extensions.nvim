local create_command = vim.api.nvim_create_user_command

create_command('ClangdSetInlayHints', function()
    require("clangd_extensions.inlay_hints").set_inlay_hints()
end, {})

create_command('ClangdDisableInlayHints', function()
    require("clangd_extensions.inlay_hints").disable_inlay_hints()
end, {})

create_command('ClangdToggleInlayHints', function()
    require("clangd_extensions.inlay_hints").toggle_inlay_hints()
end, {})

create_command('ClangdAST', function(opts)
    require("clangd_extensions.ast").display_ast(opts.line1, opts.line2)
end, { range = true })

create_command('ClangdTypeHierarchy', function()
    require("clangd_extensions.type_hierarchy").show_hierarchy()
end, {})

create_command('ClangdSymbolInfo', function()
    require("clangd_extensions.symbol_info").show_symbol_info()
end, {})

create_command(
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
