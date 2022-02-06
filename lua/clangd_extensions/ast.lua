local utils = require("clangd_extensions.utils")
local fmt = string.format
local api = vim.api
local M = {}

local function icon_prefix(role)
    local tbl = {
        type = "",
        declaration = "",
        expression = "",
        specifier = "",
        statement = "",
        ["template argument"] = "",
    }
    if tbl[role] then
        return tbl[role] .. "  "
    else
        return "   "
    end
end

local function describe(role, kind, detail)
    local str = ""
    str = str .. kind
    if
        not (
            role == "expression"
            or role == "statement"
            or role == "declaration"
            or role == "template name"
        )
    then
        str = str .. " " .. role
    end
    if detail then
        str = str .. " " .. detail
    end
    return icon_prefix(role) .. str
end

local function format_tree(node, visited, result, padding)
    visited[node] = true
    table.insert(result, padding .. describe(node.role, node.kind, node.detail))

    if node.children then
        for _, child in pairs(node.children) do
            if not visited[child] then
                format_tree(child, visited, result, padding .. "  ")
            end
        end
    end

    return result
end

local function handler(err, ASTNode)
    if err or not ASTNode then
        return
    else
        local lines = format_tree(ASTNode, {}, {}, "")
        vim.cmd(fmt([[vsplit %s:\ AST]], ASTNode.detail))
        api.nvim_buf_set_lines(0, 0, -1, true, lines)
        vim.bo.buftype = "nofile"
        vim.bo.modifiable = false
        api.nvim_win_set_option(0, "number", false)
        api.nvim_win_set_option(0, "relativenumber", false)
        api.nvim_win_set_option(0, "spell", false)
        api.nvim_win_set_option(0, "cursorline", false)
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
