local M = {}

function M.handler(err, result)
    if err then
        return
    end
    local buf_list = vim.api.nvim_list_bufs()
    for _, bufnr in pairs(buf_list) do
        if result.uri == vim.uri_from_bufnr(bufnr) then
            _G.__CLANGD_FILE_STATUS[bufnr] = result.state
        end
    end
end

return M
