local symbol_kind = require("clangd_extensions.symbol_kind")
local fmt = string.format
local api = vim.api
local M = {}

local function format_tree(node, visited, result, padding)
    visited[node.data] = true
    table.insert(result, padding .. fmt(" • %s: %s", node.name, symbol_kind[node.kind]))

    if node.parents then
        if #node.parents > 0 then
            table.insert(result, padding .. "   Parents:")
            for _, parent in pairs(node.parents) do
                if not visited[parent.data] then
                    format_tree(parent, visited, result, padding .. "   ")
                end
            end
        end
    end

    if node.children then
        if #node.children > 0 then
            table.insert(result, padding .. "   Children:")
            for _, child in pairs(node.children) do
                if not visited[child.data] then
                    format_tree(child, visited, result, padding .. "   ")
                end
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
        vim.cmd(fmt([[split %s:\ type\ hierarchy]], TypeHierarchyItem.name))
        local bufnr = vim.api.nvim_get_current_buf()
        api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
        vim.bo.buftype = "nofile"
        vim.bo.modifiable = false
        vim.bo.bufhidden = "wipe"
        api.nvim_win_set_option(0, "number", false)
        api.nvim_win_set_option(0, "relativenumber", false)
        api.nvim_win_set_option(0, "spell", false)
        api.nvim_win_set_option(0, "cursorline", false)
    end
end

function M.show_hierarchy()
    vim.lsp.buf_request(0, "textDocument/typeHierarchy", {
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
