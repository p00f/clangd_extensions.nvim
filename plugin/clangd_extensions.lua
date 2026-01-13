---@module 'clangd_extensions.types'

local specs = { ---@type table<string, Clangd.UserCommand>
    ClangdAST = {
        function(opts)
            require("clangd_extensions.ast").display_ast(opts.line1, opts.line2)
        end,
        { range = true },
    },
    ClangdTypeHierarchy = {
        function() require("clangd_extensions.type_hierarchy").show_hierarchy() end,
        {},
    },
    ClangdSymbolInfo = {
        function() require("clangd_extensions.symbol_info").show_symbol_info() end,
        {},
    },
    ClangdMemoryUsage = {
        function(opts)
            require("clangd_extensions.memory_usage").show_memory_usage(
                opts.args == "expand_preamble"
            )
        end,
        {
            nargs = "?",
            complete = function() return { "expand_preamble" } end,
        },
    },
    ClangdSwitchSourceHeader = {
        function()
            require("clangd_extensions.switch_source_header").switch_source_header()
        end,
        {},
    },
}

for cmd, spec in pairs(specs) do
    vim.api.nvim_create_user_command(cmd, unpack(spec))
end
-- vim: set ts=4 sts=4 sw=4 et ai si sta:
