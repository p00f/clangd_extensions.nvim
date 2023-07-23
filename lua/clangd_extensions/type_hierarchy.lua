-- vim: set ft=lua ts=4 sw=0 tw=0:

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
        vim.cmd(fmt([[split %s:\ type\ hierarchy]], TypeHierarchyItem.name))
        local bufnr = vim.api.nvim_get_current_buf()
        -- retrieve offset_encoding for later use
        M.offset_encoding = vim.lsp.get_client_by_id(ctx.client_id).offset_encoding
        type_pos_mappings[bufnr] = {}
        local lines = format_tree(TypeHierarchyItem, {}, {}, "", type_pos_mappings[bufnr])
        vim.bo.modifiable = true
        api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
        vim.bo.modifiable = false
        vim.bo.filetype = "ClangdTypeHierarchy"
        vim.bo.buftype = "nofile"
        vim.bo.bufhidden = "hide"
        vim.bo.buflisted = true
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

local type_hierarchy_group = vim.api.nvim_create_augroup("ClangdTypeHierarchy", {
    clear = true
})

local function setup_type_hierarchy_buffer(bufnr)
    vim.cmd([[
    syntax clear
    syntax match ClangdTypeName "\( \{2,\}• \)\@<=\w\+\(:\)\@="
    ]])
    vim.api.nvim_set_hl(0, "ClangdTypeName", {link = "Underlined"})
    vim.keymap.set("n", "gd", function ()
        local word = vim.fn.expand("<cWORD>")
        word = string.gsub(word, ":$", "")
        local location = type_pos_mappings[bufnr][word]
        if location ~= nil then
            vim.lsp.util.jump_to_location(location, M.offset_encoding)
        end
    end, { buffer = bufnr, desc = "go to definition of cursor" })
end

-- setup when buffer is first created
vim.api.nvim_create_autocmd("FileType", {
    group = type_hierarchy_group,
    pattern = "ClangdTypeHierarchy",
    callback = function ()
        local bufnr = vim.api.nvim_get_current_buf()
        setup_type_hierarchy_buffer(bufnr)
    end
})

-- setup when the hidden/deleted buffer is loaded
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    group = type_hierarchy_group,
    pattern = "*",
    callback = function ()
        local bufnr = vim.api.nvim_get_current_buf()
        -- below doesn't work when buffer is deleted and then opened
        -- if vim.bo[bufnr].filetype ~= "ClangdTypeHierarchy" then
        --     return
        -- end
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if not vim.endswith(bufname, ": type hierarchy") then
            return
        end
        setup_type_hierarchy_buffer(bufnr)
    end
})

vim.api.nvim_create_autocmd("BufWipeout", {
    group = type_hierarchy_group,
    pattern = "ClangdTypeHierarchy",
    callback = function ()
       local bufnr = vim.api.nvim_get_current_buf()
       type_pos_mappings[bufnr] = nil
    end
})


return M
