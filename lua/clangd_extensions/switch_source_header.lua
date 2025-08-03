local api = vim.api
local nvim_get_current_buf = api.nvim_get_current_buf

local function handler(_err, uri)
    if not uri or uri == "" then
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
