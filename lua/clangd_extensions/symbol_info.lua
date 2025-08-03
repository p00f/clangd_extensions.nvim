local fmt = string.format
local len = string.len
local api = vim.api
local nvim_get_current_buf = api.nvim_get_current_buf

local function handler(err, result)
    if err or (#result == 0) then return end
    local name_str = fmt("name: %s", result[1].name)
    local container_str = fmt("container: %s", result[1].containerName)

    vim.lsp.util.open_floating_preview({ name_str, container_str }, "", {
        height = 2,
        width = math.max(len(name_str), len(container_str)),
        focusable = false,
        focus = false,
        border = require("clangd_extensions.config").options.symbol_info.border,
    })
end

local M = {}

function M.show_symbol_info()
    local bufnr = nvim_get_current_buf()

    require("clangd_extensions.utils").buf_request_method(
        "textDocument/symbolInfo",
        {
            textDocument = {
                uri = vim.uri_from_bufnr(bufnr),
            },
            position = {
                line = vim.fn.getcurpos()[2] - 1,
                character = vim.fn.getcurpos()[3] - 1,
            },
        },
        handler,
        bufnr
    )
end

return M
