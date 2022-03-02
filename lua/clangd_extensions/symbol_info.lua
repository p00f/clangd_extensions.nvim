local config = require("clangd_extensions.config")

local function handler(err, result)
    if err or (#result == 0) then
        return
    end
    local name_str = string.format("name: %s", result[1].name)
    local container_str = string.format("container: %s", result[1].containerName)
    vim.lsp.util.open_floating_preview({ name_str, container_str }, "", {
        height = 2,
        width = math.max(string.len(name_str), string.len(container_str)),
        focusable = false,
        focus = false,
        border = config.options.extensions.symbol_info.border,
    })
end

local M = {}

function M.show_symbol_info()
    vim.lsp.buf_request(0, "textDocument/symbolInfo", {
        textDocument = {
            uri = vim.uri_from_bufnr(0),
        },
        position = {
            line = vim.fn.getcurpos()[2] - 1,
            character = vim.fn.getcurpos()[3] - 1,
        },
    }, handler)
end

return M
