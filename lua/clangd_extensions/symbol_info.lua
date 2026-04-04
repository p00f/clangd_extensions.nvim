local api = vim.api
local nvim_get_current_buf = api.nvim_get_current_buf
local utils = require("clangd_extensions.utils")

---@class ClangdExt.SymbolInfo
local M = {}

---@param err? lsp.ResponseError
---@param result? Clangd.SymbolDetails[]
local function handler(err, result)
    utils.validate({
        err = { err, { "table", "nil" }, true },
        result = { result, { "table", "nil" }, true },
    })

    if err or not result or not result[1] then return end

    local name_str = ("name: %s"):format(result[1].name)
    local container_str = ("container: %s"):format(result[1].containerName)

    local buf, win = vim.lsp.util.open_floating_preview(
        { name_str, container_str },
        "",
        {
            height = 2,
            width = math.max(name_str:len(), container_str:len()),
            focusable = false,
            focus = false,
            border = require("clangd_extensions.config").options.symbol_info.border,
        }
    )

    vim.keymap.set("n", "q", function()
        pcall(api.nvim_buf_delete, buf, { force = true })
        pcall(api.nvim_win_close, win, true)
    end, { buffer = buf })
end

function M.show_symbol_info()
    local bufnr = nvim_get_current_buf()

    utils.buf_request_method("textDocument/symbolInfo", {
        textDocument = {
            uri = vim.uri_from_bufnr(bufnr),
        },
        position = {
            line = vim.fn.getcurpos()[2] - 1,
            character = vim.fn.getcurpos()[3] - 1,
        },
    }, handler, bufnr)
end

return M
-- vim: set ts=4 sts=4 sw=4 et ai si sta:
