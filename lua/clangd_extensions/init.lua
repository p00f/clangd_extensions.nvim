local nvim_lsp = require("lspconfig")
local config = require("clangd_extensions.config")
local utils = require("clangd_extensions.utils")

local function setup_lsp()
    nvim_lsp.clangd.setup(config.options.server)
end

local function setup_handlers()
    local lsp_opts = config.options.server
    local custom_handlers = {}

    local file_status = require("clangd_extensions.file_status")
    _G.__CLANGD_FILE_STATUS = {}
    custom_handlers["textDocument/clangd.fileStatus"] = utils.mk_handler(file_status.handler)

    lsp_opts.handlers = vim.tbl_deep_extend("force", custom_handlers, lsp_opts.handlers or {})
end

local M = {}

M.hint_aucmd_set_up = false

function M.setup(opts)
    config.setup(opts)
    if config.options.extensions.autoSetHints and not M.hint_aucmd_set_up then
        require("clangd_extensions.inlay_hints").setup_autocmd()
    end
    setup_handlers()
    setup_lsp()
end

return M
