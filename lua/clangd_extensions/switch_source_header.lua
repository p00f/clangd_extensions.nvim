local api = vim.api
local nvim_get_current_buf = api.nvim_get_current_buf

---@param err lsp.ResponseError
---@param uri string
    if not uri or uri == "" then
local function handler(err, uri)
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

---@class ClangdSwitchSourceHeader
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
