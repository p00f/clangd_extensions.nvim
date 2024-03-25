local function handler(_err, uri)
    if not uri or uri == "" then
        vim.api.nvim_echo({ { "Corresponding file cannot be determined" } }, false, {})
        return
    end
    local file_name = vim.uri_to_fname(uri)
    vim.api.nvim_cmd({
        cmd = "edit",
        args = { file_name },
    }, {})
end

return {
    switch_source_header = function()
        vim.lsp.buf_request(0, "textDocument/switchSourceHeader", {
            uri = vim.uri_from_bufnr(0),
        }, handler)
    end,
}
