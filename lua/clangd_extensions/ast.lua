local list_contains = vim.list_contains
local api = vim.api
local conf = require("clangd_extensions.config").options.ast

local nvim_get_current_buf = api.nvim_get_current_buf
local augroup = api.nvim_create_augroup
local autocmd = api.nvim_create_autocmd

---@class ClangdExt.AST
local M = {}

--- node_pos[source_buf][ast_buf][linenum] = { start = start, end = end }
--- position of node in `source_buf` corresponding to line no. `linenum` in `ast_buf`
M.node_pos = {}

--- detail_pos[ast_buf][linenum] = { start = start, end = end }
--- position of `detail` in line no. `linenum` of `ast_buf`
M.detail_pos = {}

M.nsid = vim.api.nvim_create_namespace("clangd_extensions")

---@param source_buf integer
---@param ast_buf integer
local function setup_hl_autocmd(source_buf, ast_buf)
    local group = augroup("ClangdExtensions", {})
    autocmd("CursorMoved", {
        group = group,
        buffer = ast_buf,
        callback = function() M.update_highlight(source_buf, ast_buf) end,
    })
    autocmd("BufLeave", {
        group = group,
        buffer = ast_buf,
        callback = function() M.clear_highlight(source_buf) end,
    })
end

---@param role string
---@param kind string
---@return string|"   "
local function icon_prefix(role, kind)
    if conf.kind_icons[kind] then return conf.kind_icons[kind] .. "  " end

    if conf.role_icons[role] then return conf.role_icons[role] .. "  " end

    return "   "
end

---@param role string
---@param kind string
---@param detail? string
---@return string
---@return table|nil
local function describe(role, kind, detail)
    local icon = icon_prefix(role, kind)
    local detailpos = nil
    local role_dismiss = {
        "expression",
        "statement",
        "declaration",
        "template name",
    }

    local str = kind

    if not list_contains(role_dismiss, role) then
        str = ("%s %s"):format(str, role)
    end

    local str_len = str:len()
    local icon_len = vim.fn.strlen(icon)

    if detail then
        detailpos = {
            start = str_len + icon_len + 1,
            ["end"] = str_len + icon_len + detail:len() + 1,
        }
        str = ("%s %s"):format(str, detail)
    end

    return (icon .. str), detailpos
end

---@param node Clangd.ASTNode
---@param visited table
---@param result table
---@param padding string
---@param hl_bufs table
---@return table result
local function walk_tree(node, visited, result, padding, hl_bufs)
    visited[node] = true
    local str, detpos = describe(node.role, node.kind, node.detail)
    table.insert(result, padding .. str)

    local len = padding:len()
    local result_len = #result

    if node.detail and detpos then
        M.detail_pos[hl_bufs.ast_buf][result_len] = {
            start = len + detpos.start,
            ["end"] = len + detpos["end"],
        }
    end

    if node.range then
        M.node_pos[hl_bufs.source_buf][hl_bufs.ast_buf][result_len] = {
            start = { node.range.start.line, node.range.start.character },
            ["end"] = { node.range["end"].line, node.range["end"].character },
        }
    end

    if node.children then
        for _, child in ipairs(node.children) do
            if not visited[child] then
                walk_tree(child, visited, result, padding .. "  ", hl_bufs)
            end
        end
    end

    return result
end

---@param ast_buf integer
local function highlight_detail(ast_buf)
    for linenum, range in pairs(M.detail_pos[ast_buf]) do
        vim.highlight.range(
            ast_buf,
            M.nsid,
            conf.highlights.detail,
            { linenum - 1, range.start },
            { linenum - 1, range["end"] },
            {
                regtype = "v",
                inclusive = false,
                priority = 110,
            }
        )
    end
end

---@param err? lsp.ResponseError
---@param ASTNode? Clangd.ASTNode
local function handler(err, ASTNode)
    if err or not ASTNode then return end

    local source_buf = nvim_get_current_buf()
    vim.cmd.vsplit(("%s: AST"):format(ASTNode.detail))
    local ast_buf = nvim_get_current_buf()
    api.nvim_set_option_value("filetype", "ClangdAST", { buf = ast_buf })

    if not M.node_pos[source_buf] then M.node_pos[source_buf] = {} end

    M.node_pos[source_buf][ast_buf] = {}
    M.detail_pos[ast_buf] = {}

    local lines = walk_tree(
        ASTNode,
        {},
        {},
        "",
        { source_buf = source_buf, ast_buf = ast_buf }
    )
    api.nvim_buf_set_lines(ast_buf, 0, -1, true, lines)
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    vim.bo.modifiable = false
    vim.bo.shiftwidth = 2
    vim.wo.foldmethod = "indent"
    api.nvim_set_option_value("number", false, { scope = "local" })
    api.nvim_set_option_value("relativenumber", false, { scope = "local" })
    api.nvim_set_option_value("spell", false, { scope = "local" })
    api.nvim_set_option_value("cursorline", false, { scope = "local" })
    setup_hl_autocmd(source_buf, ast_buf)
    highlight_detail(ast_buf)
end

---@param source_buf integer
function M.clear_highlight(source_buf)
    api.nvim_buf_clear_namespace(source_buf, M.nsid, 0, -1)
end

---@param source_buf integer
---@param ast_buf integer
function M.update_highlight(source_buf, ast_buf)
    M.clear_highlight(source_buf)

    if nvim_get_current_buf() ~= ast_buf then return end

    local curline = vim.fn.getcurpos()[2]
    local curline_ranges = M.node_pos[source_buf][ast_buf][curline]
    if not curline_ranges then return end

    vim.highlight.range(
        source_buf,
        M.nsid,
        "Search",
        curline_ranges.start,
        curline_ranges["end"],
        {
            regtype = "v",
            inclusive = false,
            priority = 110,
        }
    )
end

---@param line1 integer
---@param line2 integer
function M.display_ast(line1, line2)
    local bufnr = nvim_get_current_buf()

    require("clangd_extensions.utils").buf_request_method("textDocument/ast", {
        textDocument = { uri = vim.uri_from_bufnr(bufnr) },
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
    }, handler, bufnr)
end

return M
-- vim: set ts=4 sts=4 sw=4 et ai si sta:
