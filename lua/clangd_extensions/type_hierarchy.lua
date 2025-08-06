local symbol_kind = require("clangd_extensions.symbol_kind")
local fmt = string.format
local api = vim.api
local nvim_get_current_buf = api.nvim_get_current_buf
local type_hierarchy_augroup =
    api.nvim_create_augroup("ClangdTypeHierarchy", {})

---@class ClangdTypeHierarchy
local M = {}
M.type_to_location = {}
M.offset_encoding = {}

---@param node any
---@param visited table|unknown
---@param result table|unknown
---@param padding string
---@param type_to_location unknown
---@return table|unknown result
local function format_tree(node, visited, result, padding, type_to_location)
    visited[node.data] = true
    table.insert(
        result,
        padding .. fmt(" • %s: %s", node.name, symbol_kind[node.kind])
    )

    type_to_location[node.name] = { uri = node.uri, range = node.range }

    if node.parents and #node.parents > 0 then
        table.insert(result, padding .. "   Parents:")
        for _, parent in pairs(node.parents) do
            if not visited[parent.data] then
                format_tree(
                    parent,
                    visited,
                    result,
                    padding .. "   ",
                    type_to_location
                )
            end
        end
    end

    if node.children and #node.children > 0 then
        table.insert(result, padding .. "   Children:")
        for _, child in pairs(node.children) do
            if not visited[child.data] then
                format_tree(
                    child,
                    visited,
                    result,
                    padding .. "   ",
                    type_to_location
                )
            end
        end
    end

    return result
end

---@type lsp.Handler
local function handler(err, TypeHierarchyItem, ctx)
    if err or not TypeHierarchyItem then return end

    local client_id = ctx.client_id
    -- Save old state
    local source_win = api.nvim_get_current_win()

    -- Init
    M.offset_encoding[client_id] =
        vim.lsp.get_clients({ id = client_id })[1].offset_encoding
    vim.cmd.split(fmt("%s: type hierarchy", TypeHierarchyItem.name))
    local bufnr = nvim_get_current_buf()
    M.type_to_location[bufnr] = {}

    -- Set content
    local lines = format_tree(
        TypeHierarchyItem,
        {},
        {},
        "",
        M.type_to_location[bufnr]
    )
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

            vim.lsp.util.show_document(
                location,
                M.offset_encoding[client_id],
                { focus = true }
            )
        end
    end, {
        buffer = bufnr,
        desc = "go to definition of type under cursor",
    })

    -- Clear `type_to_location` for this buffer when it is wiped out
    api.nvim_create_autocmd("BufWipeOut", {
        buffer = bufnr,
        group = type_hierarchy_augroup,
        callback = function() M.type_to_location[bufnr] = nil end,
    })
end

function M.show_hierarchy()
    local bufnr = nvim_get_current_buf()

    require("clangd_extensions.utils").buf_request_method(
        "textDocument/typeHierarchy",
        {
            textDocument = {
                uri = vim.uri_from_bufnr(bufnr),
            },
            position = {
                line = vim.fn.getcurpos()[2] - 1,
                character = vim.fn.getcurpos()[3] - 1,
            },
            -- TODO: make these configurable (config + command args)
            resolve = 3,
            direction = 2,
        },
        handler,
        bufnr
    )
end

return M
