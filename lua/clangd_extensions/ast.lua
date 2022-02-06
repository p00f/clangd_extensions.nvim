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

local function format_tree(node, visited, result, padding, hl_bufs)
    visited[node] = true
    table.insert(result, padding .. describe(node.role, node.kind, node.detail))

    if node.range then
        table.insert(__CLANGD_SOURCE_AST_BUFS[hl_bufs.source_buf][hl_bufs.ast_buf], {
            start = { node["range"]["start"]["line"], node["range"]["start"]["character"] },
            ["end"] = { node["range"]["end"]["line"], node["range"]["end"]["character"] },
        })
    end

    if node.children then
        for _, child in pairs(node.children) do
            if not visited[child] then
                format_tree(child, visited, result, padding .. "  ", hl_bufs)
            end
        end
    end

    return result
end

function M.clear_highlight(source_buf)
    api.nvim_buf_clear_namespace(source_buf, __CLANGD_NSID, 0, -1)
end

local function setup_hl_autocmd(source_buf, ast_buf)
    vim.cmd(string.format(
        [[
    augroup ClangdExtensions
    autocmd CursorMoved <buffer=%s> lua require("clangd_extensions.ast").update_highlight(%s,%s)
    autocmd BufLeave <buffer=%s>   lua require("clangd_extensions.ast").clear_highlight(%s)
    ]],
        ast_buf,
        source_buf,
        ast_buf,
        ast_buf,
        source_buf
    ))
end

function M.update_highlight(source_buf, ast_buf)
    M.clear_highlight(source_buf)
    if api.nvim_get_current_buf() ~= ast_buf then
        return
    end
    local curline = vim.fn.getcurpos()[2]
    local curline_ranges = __CLANGD_SOURCE_AST_BUFS[source_buf][ast_buf][curline]
    vim.highlight.range(
        source_buf,
        __CLANGD_NSID,
        "Search",
        curline_ranges.start,
        curline_ranges["end"],
        "v",
        false,
        110
    )
end

local function handler(err, ASTNode)
    if err or not ASTNode then
        return
    else
        local source_buf = api.nvim_get_current_buf()
        vim.cmd(fmt([[vsplit %s:\ AST]], ASTNode.detail))
        local ast_buf = api.nvim_get_current_buf()
        if not __CLANGD_SOURCE_AST_BUFS[source_buf] then
            __CLANGD_SOURCE_AST_BUFS[source_buf] = {}
        end
        __CLANGD_SOURCE_AST_BUFS[source_buf][ast_buf] = {}

        local lines = format_tree(
            ASTNode,
            {},
            {},
            "",
            { source_buf = source_buf, ast_buf = ast_buf }
        )
        api.nvim_buf_set_lines(0, 0, -1, true, lines)
        vim.bo.buftype = "nofile"
        vim.bo.modifiable = false
        api.nvim_win_set_option(0, "number", false)
        api.nvim_win_set_option(0, "relativenumber", false)
        api.nvim_win_set_option(0, "spell", false)
        api.nvim_win_set_option(0, "cursorline", false)
        setup_hl_autocmd(source_buf, ast_buf)
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
