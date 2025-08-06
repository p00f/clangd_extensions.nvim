---@class ClangdUtils
local M = {}

---@param method vim.lsp.protocol.Method
---@param params table|nil
---@param handler lsp.Handler
---@param bufnr integer
function M.buf_request_method(method, params, handler, bufnr)
    local clients = vim.lsp.get_clients({ bufnr = bufnr, method = method })
    for _, client in pairs(clients) do
        client:request(method, params, handler, bufnr)
    end
end

return M
