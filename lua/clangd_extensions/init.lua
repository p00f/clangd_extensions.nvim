local config = require("clangd_extensions.config")

local M = {}

M.hint_aucmd_set_up = false

function M.setup(opts)
    -- Set up extensions, get lspconfig opts
    config.setup(opts)
    -- Set up autocommands for inlay hints
    if config.options.extensions.autoSetHints and not M.hint_aucmd_set_up then
        local old_func = config.options.server.on_attach
        config.options.server.on_attach = function(client, bufnr)
            old_func(client, bufnr)
            require("clangd_extensions.inlay_hints").setup_autocmd()
            require("clangd_extensions.inlay_hints").set_inlay_hints()
            M.hint_aucmd_set_up = true
        end
    end
    -- Call lspconfig setup
    require("lspconfig").clangd.setup(config.options.server)

    __CLANGD_SOURCE_AST_BUFS = {}
    __CLANGD_NSID = vim.api.nvim_create_namespace("clangd_extensions")
end

return M
