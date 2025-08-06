local api = vim.api
local nvim_get_current_buf = api.nvim_get_current_buf

---@param err? lsp.ResponseError
---@param uri? string
local function handler(err, uri)
    if err or not uri or (uri == "") then
        vim.api.nvim_echo(
            { { "Corresponding file cannot be determined" } },
            false,
            {}
        )
        return
    end
    local file_name = vim.uri_to_fname(uri)
    vim.api.nvim_cmd({
        cmd = "edit",
        args = { file_name },
    }, {})
end

---@class ClangdExt.SwitchSourceHeader
local M = {}

function M.switch_source_header()
    local bufnr = nvim_get_current_buf()
    require("clangd_extensions.utils").buf_request_method(
        "textDocument/switchSourceHeader",
        {
            uri = vim.uri_from_bufnr(bufnr),
        },
        handler,
        bufnr
    )
end

return M
-- vim: set ts=4 sts=4 sw=4 et ai si sta:
