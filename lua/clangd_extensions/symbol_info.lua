local utils = require("clangd_extensions.utils")

local function handler(err, result)
    if err then
        return
    end
    local name_str = string.format("name: %s", result[1].name)
    local container_str = string.format("container: %s", result[1].containerName)
    local width = math.max(string.len(name_str), string.len(container_str))
    local params = vim.lsp.util.make_floating_popup_options(width, 2, { focusable = false })
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, 1, true, { name_str, container_str })
    vim.api.nvim_open_win(buf, false, params)
end
local M = {}

function M.show_symbol_info()
    utils.request(0, "textDocument/symbolInfo", {
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
