local api = vim.api
local nvim_get_current_buf = api.nvim_get_current_buf
local fmt = string.format
local ceil = math.ceil

local function display(lines)
    for k, line in pairs(lines) do -- Pad lines
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

local function format_name(name)
    if name:sub(1, 7) == "file://" then name = vim.uri_to_fname(name) end
    local cwd = vim.fn.getcwd()
    if name:sub(1, string.len(cwd)) == cwd then
        name = name:sub(string.len(cwd) + 2, -1)
    end
    return name
end

local function format_tree(
    node,
    visited,
    result,
    padding,
    prefix,
    expand_preamble
)
    if padding == "" then
        table.insert(
            result,
            fmt("Total: self = %s, total = %s", node._self, node._total)
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
                padding
                    .. fmt(
                        "%s: self = %s, total = %s",
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

local function handler(err, result, expand_preamble)
    if err then return end
    display(format_tree(result, {}, { "" }, "", "", expand_preamble))
end

local M = {}

function M.show_memory_usage(expand_preamble)
    require("clangd_extensions.utils").buf_request_method(
        "$/memoryUsage",
        nil,
        function(err, result) handler(err, result, expand_preamble) end,
        nvim_get_current_buf()
    )
end

return M
