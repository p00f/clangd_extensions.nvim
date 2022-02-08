local utils = require("clangd_extensions.utils")
local fmt = string.format
local api = vim.api

local M = {}

local function setup_hl_autocmd(source_buf, ast_buf)
    vim.cmd(string.format(
        [[
    augroup ClangdExtensions
    autocmd CursorMoved <buffer=%s> lua require("clangd_extensions.ast").update_highlight(%s,%s)
    autocmd BufLeave <buffer=%s>   lua require("clangd_extensions.ast").clear_highlight(%s)
    augroup END
    ]],
        ast_buf,
        source_buf,
        ast_buf,
        ast_buf,
        source_buf
    ))
end

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

local function walk_tree(node, visited, result, padding, hl_bufs)
    visited[node] = true
    table.insert(result, padding .. describe(node.role, node.kind, node.detail))

    if node.range then
        M.map[hl_bufs.source_buf][hl_bufs.ast_buf][#result] = {
            start = { node["range"]["start"]["line"], node["range"]["start"]["character"] },
            ["end"] = { node["range"]["end"]["line"], node["range"]["end"]["character"] },
        }
    end

    if node.children then
        for _, child in pairs(node.children) do
            if not visited[child] then
                walk_tree(child, visited, result, padding .. "  ", hl_bufs)
            end
        end
    end

    return result
end

local function handler(err, ASTNode)
    if err or not ASTNode then
        return
    else
        local source_buf = api.nvim_get_current_buf()
        vim.cmd(fmt([[vsplit %s:\ AST]], ASTNode.detail))
        local ast_buf = api.nvim_get_current_buf()
        if not M.map[source_buf] then
            M.map[source_buf] = {}
        end
        M.map[source_buf][ast_buf] = {}

        local lines = walk_tree(ASTNode, {}, {}, "", { source_buf = source_buf, ast_buf = ast_buf })
        api.nvim_buf_set_lines(ast_buf, 0, -1, true, lines)
        vim.bo.buftype = "nofile"
        vim.bo.modifiable = false
        api.nvim_win_set_option(ast_buf, "number", false)
        api.nvim_win_set_option(ast_buf, "relativenumber", false)
        api.nvim_win_set_option(ast_buf, "spell", false)
        api.nvim_win_set_option(ast_buf, "cursorline", false)
        vim.cmd(string.format(
            [[
        augroup ClangdWin
        autocmd QuitPre <buffer=%s> bwipeout
        augroup END
        ]],
            ast_buf
        ))
        setup_hl_autocmd(source_buf, ast_buf)
    end
end

function M.init()
    M.map = {}
    M.nsid = vim.api.nvim_create_namespace("clangd_extensions")
end

function M.clear_highlight(source_buf)
    api.nvim_buf_clear_namespace(source_buf, M.nsid, 0, -1)
end

function M.update_highlight(source_buf, ast_buf)
    M.clear_highlight(source_buf)
    if api.nvim_get_current_buf() ~= ast_buf then
        return
    end
    local curline = vim.fn.getcurpos()[2]
    local curline_ranges = M.map[source_buf][ast_buf][curline]
    if curline_ranges then
        vim.highlight.range(
            source_buf,
            M.nsid,
            "Search",
            curline_ranges.start,
            curline_ranges["end"],
            "v",
            false,
            110
        )
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
