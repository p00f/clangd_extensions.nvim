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
