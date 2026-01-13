---@class ClangdExt.Utils
local M = {}

---Dynamic `vim.validate()` wrapper. Covers both legacy and newer implementations
---@param T table<string, vim.validate.Spec|ValidateSpec>
function M.validate(T)
    if vim.fn.has("nvim-0.11") ~= 1 then
        ---Filter table to fit legacy standard
        ---@cast T table<string, vim.validate.Spec>
        for name, spec in pairs(T) do
            while #spec > 3 do
                table.remove(spec, #spec)
            end

            T[name] = spec
        end

        vim.validate(T)
        return
    end

    ---Filter table to fit non-legacy standard
    ---@cast T table<string, ValidateSpec>
    for name, spec in pairs(T) do
        while #spec > 4 do
            table.remove(spec, #spec)
        end

        T[name] = spec
    end

    for name, spec in pairs(T) do
        table.insert(spec, 1, name)
        vim.validate(unpack(spec))
    end
end

---@param method vim.lsp.protocol.Method|string
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

    local clients = vim.lsp.get_clients({ bufnr = bufnr, method = method })
    for _, client in ipairs(clients) do
        client:request(method, params, handler, bufnr)
    end
end

return M
-- vim: set ts=4 sts=4 sw=4 et ai si sta:
