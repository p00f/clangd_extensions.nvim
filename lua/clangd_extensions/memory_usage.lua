local api = vim.api
local nvim_get_current_buf = api.nvim_get_current_buf
local ceil = math.ceil
local utils = require("clangd_extensions.utils")

---@class Clangd.MemoryTreeSpec
---@field _total number
---@field _self number

---@alias Clangd.MemoryTree table<string, Clangd.MemoryTreeSpec>|Clangd.MemoryTreeSpec

---@class ClangdExt.MemUsage
---@field window? { buf: integer, win: integer }
local M = {}

function M.close_window()
    pcall(api.nvim_buf_delete, M.window.buf, { force = true })
    pcall(api.nvim_win_close, M.window.win, true)

    M.window = nil
end

---@param lines string[]
local function display(lines)
    utils.validate({ lines = { lines, { "table" } } })

    if M.window then M.close_window() end

    for k, line in ipairs(lines) do -- Pad lines
        if k ~= 1 then lines[k] = "  " .. line .. "  " end
    end

    local buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_lines(buf, 0, -1, true, lines)

    local height = ceil(vim.o.lines * 0.7 - 4)
    local width = ceil(vim.o.columns * 0.7)
    local row = ceil((vim.o.lines - height) / 2 - 1)
    local col = ceil((vim.o.columns - width) / 2)
    local win = api.nvim_open_win(buf, true, {
        style = "minimal",
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        border = require("clangd_extensions.config").options.memory_usage.border,
    })
    api.nvim_set_option_value("foldmethod", "indent", { win = win })
    api.nvim_set_option_value("shiftwidth", 2, { buf = buf })
    api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
    api.nvim_set_option_value("modifiable", false, { buf = buf })
    api.nvim_set_option_value("buftype", "nofile", { buf = buf })
    vim.keymap.set("n", "q", M.close_window, { buffer = buf })
    vim.keymap.set("n", "<Esc>", M.close_window, { buffer = buf })

    M.window = { buf = buf, win = win }
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
---@param visited table<string, boolean>
---@param result string[]
---@param padding string
---@param prefix string
---@param expand_preamble boolean
---@return string[] result
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
