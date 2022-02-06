local defcmd = vim.api.nvim_add_user_command
defcmd("ClangdSetInlayHints", function()
    require("clangd_extensions.inlay_hints").set_inlay_hints()
end, {})

defcmd("ClangdDisableInlayHints", function()
    require("clangd_extensions.inlay_hints").disable_inlay_hints()
end, {})

defcmd("ClangdToggleInlayHints", function()
    require("clangd_extensions.inlay_hints").toggle_inlay_hints()
end, {})

defcmd("ClangdAST", function(args)
    require("clangd_extensions.ast").display_ast(args.line1, args.line2)
end, { range = true })

defcmd("ClangdTypeHeirarchy", function()
    require("clangd_extensions.type_heirarchy").show_heirarchy()
end, {})

defcmd("ClangdSymbolInfo", function()
    require("clangd_extensions.symbol_info").show_symbol_info()
end, {})

defcmd("ClangdMemoryUsage", function(args)
    require("clangd_extensions.memory_usage").show_memory_usage(
        args.args == "expand_preamble" and true or false
    )
end, {
    nargs = "?",
    complete = function()
        return { "expand_preamble" }
    end,
})
