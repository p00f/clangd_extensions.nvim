local api = vim.api
local nvim_get_current_buf = api.nvim_get_current_buf
local ceil = math.ceil
local utils = require("clangd_extensions.utils")

---@class Clangd.MemoryTreeSpec
---@field _total number
---@field _self number

---@alias Clangd.MemoryTree table<string, Clangd.MemoryTreeSpec>|Clangd.MemoryTreeSpec

---@param lines string[]
local function display(lines)
    utils.validate({ lines = { lines, { "table" } } })

    for k, line in ipairs(lines) do -- Pad lines
        if k ~= 1 then lines[k] = "  " .. line .. "  " end
    end
    local vim_width = api.nvim_get_option_value("columns", { scope = "local" })
    local vim_height = api.nvim_get_option_value("lines", { scope = "local" })
    local height = ceil(vim_height * 0.7 - 4)
    local width = ceil(vim_width * 0.7)
    local row = ceil((vim_height - height) / 2 - 1)
    local col = ceil((vim_width - width) / 2)
    local buf = api.nvim_create_buf(false, true)
    api.nvim_open_win(buf, true, {
        style = "minimal",
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        border = require("clangd_extensions.config").options.memory_usage.border,
    })
    vim.wo.foldmethod = "indent"
    api.nvim_buf_set_lines(buf, 0, -1, true, lines)
    api.nvim_set_option_value("shiftwidth", 2, { buf = buf })
    api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
    api.nvim_set_option_value("modifiable", false, { buf = buf })
    api.nvim_set_option_value("buftype", "nofile", { buf = buf })
    vim.keymap.set("n", "q", ":bd<CR>", {
        noremap = true,
        silent = true,
        buffer = buf,
    })
    vim.keymap.set("n", "<ESC>", ":bd<CR>", {
        noremap = true,
        silent = true,
        buffer = buf,
    })
end

---@param name string
---@return string name
local function format_name(name)
    utils.validate({ name = { name, { "string" } } })

    if name:sub(1, 7) == "file://" then name = vim.uri_to_fname(name) end
    local cwd = vim.fn.getcwd()
    if name:sub(1, cwd:len()) == cwd then name = name:sub(cwd:len() + 2, -1) end
    return name
end

---@param node Clangd.MemoryTree
---@param visited table
---@param result table
---@param padding string
---@param prefix string
---@param expand_preamble boolean
---@return table result
local function format_tree(
    node,
    visited,
    result,
    padding,
    prefix,
    expand_preamble
)
    utils.validate({
        node = { node, { "table" } },
        visited = { visited, { "table" } },
        result = { result, { "table" } },
        padding = { padding, { "string" } },
        prefix = { prefix, { "string" } },
        expand_preamble = { expand_preamble, { "boolean" } },
    })

    if padding == "" then
        table.insert(
            result,
            ("Total: self = %s, total = %s"):format(node._self, node._total)
        )
    end
    visited[prefix] = true
    for child_name, child_node in pairs(node) do
        if
            child_name ~= "_self"
            and child_name ~= "_total"
            and not visited[prefix .. child_name]
        then
            child_name = format_name(child_name)
            table.insert(
                result,
                ("%s%s: self = %s, total = %s"):format(
                    padding,
                    child_name,
                    child_node._self,
                    child_node._total
                )
            )
            if child_name ~= "preamble" or expand_preamble then
                format_tree(
                    child_node,
                    visited,
                    result,
                    padding .. "  ",
                    prefix .. child_name,
                    expand_preamble
                )
            end
        end
    end
    return result
end

---@param err? lsp.ResponseError
---@param result? Clangd.MemoryTree
---@param expand_preamble boolean
local function handler(err, result, expand_preamble)
    utils.validate({
        err = { err, { "table", "nil" }, true },
        result = { result, { "table", "nil" }, true },
        expand_preamble = { expand_preamble, { "boolean" } },
    })

    if err or not result then return end
    display(format_tree(result, {}, { "" }, "", "", expand_preamble))
end

---@class ClangdExt.MemUsage
local M = {}

---@param expand_preamble boolean
function M.show_memory_usage(expand_preamble)
    utils.validate({ expand_preamble = { expand_preamble, { "boolean" } } })

    utils.buf_request_method(
        "$/memoryUsage",
        nil,
        function(err, result) handler(err, result, expand_preamble) end,
        nvim_get_current_buf()
    )
end

return M
-- vim: set ts=4 sts=4 sw=4 et ai si sta:
