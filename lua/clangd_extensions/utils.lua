local M = {}
-- from mfussenegger/nvim-lsp-compl@29a81f3
function M.request(bufnr, method, params, handler)
    return vim.lsp.buf_request(bufnr, method, params, M.mk_handler(handler))
end

function M.mk_handler(fn)
    return function(...)
        local config_or_client_id = select(4, ...)
        local is_new = type(config_or_client_id) ~= "number"
        if is_new then
            fn(...)
        else
            local err = select(1, ...)
            local method = select(2, ...)
            local result = select(3, ...)
            local client_id = select(4, ...)
            local bufnr = select(5, ...)
            local config = select(6, ...)
            fn(err, result, { method = method, client_id = client_id, bufnr = bufnr }, config)
        end
    end
end

return M
