local utils = require("clangd_extensions.utils")
local symbol_kind = require("clangd_extensions.symbol_kind")
local fmt = string.format
local api = vim.api
local M = {}

local function format_tree(node, visited, result, padding)
    visited[node.data] = true
    table.insert(result, padding .. fmt(" • %s: %s", node.name, symbol_kind[node.kind]))

    if node.parents then
        table.insert(result, padding .. "   Parents:")
        for _, parent in pairs(node.parents) do
            if not visited[parent.data] then
                format_tree(parent, visited, result, padding .. "   ")
            end
        end
    end

    if node.children then
        for _, child in pairs(node.children) do
            table.insert(result, padding .. "   Children:")
            if not visited[child.data] then
                format_tree(child, visited, result, padding .. "   ")
            end
        end
    end

    return result
end

local function handler(err, TypeHierarchyItem)
    if err or not TypeHierarchyItem then
        return
    else
        local lines = format_tree(TypeHierarchyItem, {}, {}, "")
        vim.cmd(fmt([[split %s:\ type\ heirarchy]], TypeHierarchyItem.name))
        api.nvim_buf_set_lines(0, 0, -1, true, lines)
        vim.bo.buftype = "nofile"
        vim.bo.modifiable = false
        api.nvim_win_set_option(0, "number", false)
        api.nvim_win_set_option(0, "relativenumber", false)
        api.nvim_win_set_option(0, "spell", false)
        api.nvim_win_set_option(0, "cursorline", false)
    end
end

function M.show_heirarchy()
    utils.request(0, "textDocument/typeHierarchy", {
        textDocument = {
            uri = vim.uri_from_bufnr(0),
        },
        position = {
            line = vim.fn.getcurpos()[2] - 1,
            character = vim.fn.getcurpos()[3] - 1,
        },
        -- TODO make these configurable (config + command args)
        resolve = 3,
        direction = 2,
    }, handler)
end

return M
