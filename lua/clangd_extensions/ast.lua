local utils = require("clangd_extensions.utils")
local M = {}

local function handler(err, ASTNode)
    if err then
        return
    else
        --TODO: do the actual thing with ASTNode instead
        print(vim.inspect(ASTNode))
    end
end

function M.display_ast(line1, line2)
    utils.request(0, "textDocument/ast", {
        textDocument = { uri = vim.uri_from_bufnr(0) },
        range = {
            start = {
                line = line1 - 1,
                character = 0,
            },
            ["end"] = {
                line = line2,
                character = 0,
            },
        },
    }, handler)
end

return M
