local symbol_kind = require("clangd_extensions.symbol_kind")
local fmt = string.format
local api = vim.api
local M = {}

local function format_tree(node, visited, result, padding, type_pos_mapping)
    visited[node.data] = true
    table.insert(result, padding .. fmt(" • %s: %s", node.name, symbol_kind[node.kind]))

    type_pos_mapping[node.name] = { uri = node.uri, range = node.range }

    if node.parents then
        if #node.parents > 0 then
            table.insert(result, padding .. "   Parents:")
            for _, parent in pairs(node.parents) do
                if not visited[parent.data] then
                    format_tree(parent, visited, result, padding .. "   ", type_pos_mapping)
                end
            end
        end
    end

    if node.children then
        if #node.children > 0 then
            table.insert(result, padding .. "   Children:")
            for _, child in pairs(node.children) do
                if not visited[child.data] then
                    format_tree(child, visited, result, padding .. "   ", type_pos_mapping)
                end
            end
        end
    end

    return result
end

_G.type_pos_mappings = {}

local function handler(err, TypeHierarchyItem, ctx)
    if err or not TypeHierarchyItem then
        return
    else
        local oldwin = api.nvim_get_current_win()
        vim.cmd(fmt([[split %s:\ type\ hierarchy]], TypeHierarchyItem.name))
        local bufnr = vim.api.nvim_get_current_buf()
        -- retrieve offset_encoding for later use
        M.offset_encoding = vim.lsp.get_client_by_id(ctx.client_id).offset_encoding
        type_pos_mappings[bufnr] = {}
        local lines = format_tree(TypeHierarchyItem, {}, {}, "", type_pos_mappings[bufnr])
        api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
        vim.bo.modifiable = false
        vim.bo.filetype = "ClangdTypeHierarchy"
        vim.bo.buftype = "nofile"
        vim.bo.bufhidden = "wipe"
        vim.bo.buflisted = true
        api.nvim_win_set_option(0, "number", false)
        api.nvim_win_set_option(0, "relativenumber", false)
        api.nvim_win_set_option(0, "spell", false)
        api.nvim_win_set_option(0, "cursorline", false)

        vim.cmd([[
        syntax clear
        syntax match ClangdTypeName "\( \{2,\}• \)\@<=\w\+\(:\)\@="
        ]])
        vim.api.nvim_set_hl(0, "ClangdTypeName", { link = "Underlined" })
        vim.keymap.set("n", "gd", function()
            local word = vim.fn.expand("<cWORD>")
            word = string.gsub(word, ":$", "")
            local location = type_pos_mappings[bufnr][word]
            if location ~= nil then
                api.nvim_set_current_win(oldwin)
                vim.lsp.util.jump_to_location(location, M.offset_encoding)
            end
        end, { buffer = bufnr, desc = "go to definition of cursor" })
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
