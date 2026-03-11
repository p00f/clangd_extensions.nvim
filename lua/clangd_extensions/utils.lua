---@module 'clangd_extensions.types'

---@class ClangdExt.Utils
local M = {}

---Dynamic `vim.validate()` wrapper. Covers both legacy and newer implementations
---@param T table<string, any>
function M.validate(T)
    local has_011 = vim.fn.has("nvim-0.11") == 1
    for name, spec in pairs(T) do
        if not has_011 and #spec == 4 then
            table.remove(spec, #spec)
        end
        T[name] = spec
    end

    if has_011 then
        for name, spec in pairs(T) do
            table.insert(spec, 1, name)
            vim.validate(unpack(spec)) ---@diagnostic disable-line:param-type-not-match
        end
    else
        vim.validate(T) ---@diagnostic disable-line:param-type-not-match
    end
end

---@param method vim.lsp.protocol.Method|Clangd.Method
---@param params table|nil
---@param handler lsp.Handler|fun(...: any): any
---@param bufnr integer
function M.buf_request_method(method, params, handler, bufnr)
    M.validate({
        method = { method, { "string" } },
        params = { params, { "table", "nil" }, true },
        handler = { handler, { "function" } },
        bufnr = { bufnr, { "number" } },
    })

    local clients = vim.lsp.get_clients({ bufnr = bufnr, method = method }) ---@diagnostic disable-line: param-type-mismatch
    for _, client in ipairs(clients) do
        client:request(method, params, handler, bufnr) ---@diagnostic disable-line: param-type-mismatch
    end
end

return M
-- vim: set ts=4 sts=4 sw=4 et ai si sta:
