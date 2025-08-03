local M = {}

function M.buf_request_method(method, params, handler, bufnr)
    local clients = vim.lsp.get_clients({ bufnr = bufnr, method = method })
    for _, client in pairs(clients) do
        client:request(method, params, handler, bufnr)
    end
end

return M
