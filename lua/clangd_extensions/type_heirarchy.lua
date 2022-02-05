local utils = require("clangd_extensions.utils")
local symbol_kind = require("clangd_extensions.symbol_kind")
local fmt = string.format
local api = vim.api
local M = {}

local function format_tree(tree, node, visited, result, padding)
    visited[node.data] = true
    table.insert(result, padding .. fmt(" - %s: %s", node.name, symbol_kind[node.kind]))
    if node.parents then
        if #node.parents > 0 then
            table.insert(result, padding .. "   Parents:")
            for _, parent in pairs(node.parents) do
                if not visited[parent.data] then
                    format_tree(tree, parent, visited, result, padding .. "   ")
                end
            end
        end
    end
    if node.children then
        if #node.children > 0 then
            for _, child in pairs(node.children) do
                table.insert(result, padding .. "   Children:")
                if not visited[child.data] then
                    format_tree(tree, child, visited, result, padding .. "   ")
                end
            end
        end
    end
    return result
end

local function handler(err, TypeHierarchyItem)
    if err then
        return
    else
        local lines = format_tree(TypeHierarchyItem, TypeHierarchyItem, {}, {}, "")
        vim.cmd(fmt([[split %s:\ type\ heirarchy]], TypeHierarchyItem.name))
        api.nvim_buf_set_lines(0, 0, -1, true, lines)
        vim.bo.buftype = "nofile"
        -- api.nvim_buf_set_name(0, TypeHierarchyItem.name .. ": type heirarchy")
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
