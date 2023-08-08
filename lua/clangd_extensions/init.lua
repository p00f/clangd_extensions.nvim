local M = {}

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
    end

    return config.options.server
end

return M
