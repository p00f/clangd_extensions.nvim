local fmt = string.format
local api = vim.api
local conf = require("clangd_extensions.config").options.extensions.ast

local M = {}

local function setup_hl_autocmd(source_buf, ast_buf)
    vim.cmd(string.format(
        [[
    augroup ClangdExtensions
    autocmd CursorMoved <buffer=%s> lua require("clangd_extensions.ast").update_highlight(%s,%s)
    autocmd BufLeave <buffer=%s> lua require("clangd_extensions.ast").clear_highlight(%s)
    augroup END
    ]],
        ast_buf,
        source_buf,
        ast_buf,
        ast_buf,
        source_buf
    ))
end

local function icon_prefix(role, kind)
    if conf.kind_icons[kind] then
        return conf.kind_icons[kind] .. "  "
    elseif conf.role_icons[role] then
        return conf.role_icons[role] .. "  "
    else
        return "   "
    end
end

local function describe(role, kind, detail)
    local str = ""
    local icon = icon_prefix(role, kind)
    local detailpos = nil
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
        detailpos = {
            start = string.len(str) + (icon == "   " and 0 or 2) + 4,
            ["end"] = string.len(str) + string.len(detail) + 6,
        }
        str = str .. " " .. detail
    end
    return (icon .. str), detailpos
end

local function walk_tree(node, visited, result, padding, hl_bufs)
    visited[node] = true
    local str, detpos = describe(node.role, node.kind, node.detail)
    table.insert(result, padding .. str)

    if node.detail and detpos then
        M.detail_pos[hl_bufs.ast_buf][#result] = {
            start = string.len(padding) + detpos.start,
            ["end"] = string.len(padding) + detpos["end"],
        }
    end

    if node.range then
        M.node_pos[hl_bufs.source_buf][hl_bufs.ast_buf][#result] = {
            start = { node.range.start.line, node.range.start.character },
            ["end"] = { node.range["end"].line, node.range["end"].character },
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

local function highlight_detail(ast_buf)
    for linenum, range in pairs(M.detail_pos[ast_buf]) do
        vim.highlight.range(
            ast_buf,
            M.nsid,
            conf.highlights.detail,
            { linenum - 1, range.start },
            { linenum - 1, range["end"] },
            "v",
            false,
            110
        )
    end
end

local function handler(err, ASTNode)
    if err or not ASTNode then
        return
    else
        local source_buf = api.nvim_get_current_buf()
        vim.cmd(fmt([[vsplit %s:\ AST]], ASTNode.detail))
        local ast_buf = api.nvim_get_current_buf()
        if not M.node_pos[source_buf] then
            M.node_pos[source_buf] = {}
        end
        M.node_pos[source_buf][ast_buf] = {}
        M.detail_pos[ast_buf] = {}

        local lines = walk_tree(ASTNode, {}, {}, "", { source_buf = source_buf, ast_buf = ast_buf })
        api.nvim_buf_set_lines(ast_buf, 0, -1, true, lines)
        vim.bo.buftype = "nofile"
        vim.bo.bufhidden = "wipe"
        vim.bo.modifiable = false
        vim.bo.shiftwidth = 2
        vim.wo.foldmethod = "indent"
        api.nvim_win_set_option(0, "number", false)
        api.nvim_win_set_option(0, "relativenumber", false)
        api.nvim_win_set_option(0, "spell", false)
        api.nvim_win_set_option(0, "cursorline", false)
        setup_hl_autocmd(source_buf, ast_buf)
        highlight_detail(ast_buf)
    end
end

function M.init()
    --- node_pos[source_buf][ast_buf][linenum] = { start = start, end = end }
    --- position of node in `source_buf` corresponding to line no. `linenum` in `ast_buf`
    M.node_pos = {}
    --- detail_pos[ast_buf][linenum] = { start = start, end = end }
    --- position of `detail` in line no. `linenum` of `ast_buf`
    M.detail_pos = {}
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
    local curline_ranges = M.node_pos[source_buf][ast_buf][curline]
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
    vim.lsp.buf_request(0, "textDocument/ast", {
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
