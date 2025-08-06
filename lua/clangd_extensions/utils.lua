---@class ClangdExt.Utils
local M = {}

---@param method vim.lsp.protocol.Method|string
---@param params table|nil
---@param handler lsp.Handler|fun(...: any): any
---@param bufnr integer
function M.buf_request_method(method, params, handler, bufnr)
    local clients = vim.lsp.get_clients({ bufnr = bufnr, method = method })
    for _, client in ipairs(clients) do
        client:request(method, params, handler, bufnr)
    end
end

return M
-- vim: set ts=4 sts=4 sw=4 et ai si sta:
