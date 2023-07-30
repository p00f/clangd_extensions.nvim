local symbol_kind = require("clangd_extensions.symbol_kind")
local fmt = string.format
local api = vim.api
local type_hierarchy_augroup = api.nvim_create_augroup("ClangdTypeHierarchy", {})

local M = {}
M.type_to_location = {}
M.offset_encoding = {}

local function format_tree(node, visited, result, padding, type_to_location)
    visited[node.data] = true
    table.insert(result, padding .. fmt(" • %s: %s", node.name, symbol_kind[node.kind]))

    type_to_location[node.name] = { uri = node.uri, range = node.range }

    if node.parents then
        if #node.parents > 0 then
            table.insert(result, padding .. "   Parents:")
            for _, parent in pairs(node.parents) do
                if not visited[parent.data] then
                    format_tree(parent, visited, result, padding .. "   ", type_to_location)
                end
            end
        end
    end

    if node.children then
        if #node.children > 0 then
            table.insert(result, padding .. "   Children:")
            for _, child in pairs(node.children) do
                if not visited[child.data] then
                    format_tree(child, visited, result, padding .. "   ", type_to_location)
                end
            end
        end
    end

    return result
end


local function handler(err, TypeHierarchyItem, ctx)
    if err or not TypeHierarchyItem then
        return
    else
        -- Save old state
        local source_win = api.nvim_get_current_win()

        -- Init
        M.offset_encoding[ctx.client_id] = vim.lsp.get_client_by_id(ctx.client_id).offset_encoding
        vim.cmd.split(fmt("%s: type hierarchy", TypeHierarchyItem.name))
        local bufnr = vim.api.nvim_get_current_buf()
        M.type_to_location[bufnr] = {}

        -- Set content
        local lines = format_tree(TypeHierarchyItem, {}, {}, "", M.type_to_location[bufnr])
        api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)

        -- Set options
        vim.bo.modifiable = false
        vim.bo.filetype = "ClangdTypeHierarchy"
        vim.bo.buftype = "nofile"
        vim.bo.bufhidden = "wipe"
        vim.bo.buflisted = true
        api.nvim_set_option_value("number", false, { scope = "local" })
        api.nvim_set_option_value("relativenumber", false, { scope = "local" })
        api.nvim_set_option_value("spell", false, { scope = "local" })
        api.nvim_set_option_value("cursorline", false, { scope = "local" })
        local winbar = api.nvim_get_option_value("winbar", {})
        local numlines = winbar == "" and #lines or #lines + 1
        local winheight = math.min(numlines, 15)
        api.nvim_win_set_height(0, winheight)

        -- Set highlights
        vim.cmd([[
        syntax clear
        syntax match ClangdTypeName "\( \{2,\}• \)\@<=\w\+\(:\)\@="
        ]])
        vim.api.nvim_set_hl(0, "ClangdTypeName", { link = "Underlined" })

        -- Set keymap
        vim.keymap.set("n", "gd", function()
            local word = vim.fn.expand("<cWORD>")
            word = string.gsub(word, ":$", "")
            local location = M.type_to_location[bufnr][word]
            if location ~= nil then
                api.nvim_set_current_win(source_win)
                vim.lsp.util.jump_to_location(location, M.offset_encoding[ctx.client_id])
            end
        end, { buffer = bufnr, desc = "go to definition of type under cursor" })

        -- Clear `type_to_location` for this buffer when it is wiped out
        api.nvim_create_autocmd("BufWipeOut", {
            buffer = bufnr,
            group = type_hierarchy_augroup,
            callback = function()
                M.type_to_location[bufnr] = nil
            end
        })
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
