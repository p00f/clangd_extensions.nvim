local api = vim.api
local fmt = string.format
local config = require("clangd_extensions.config")

local function display(lines)
    for k, line in pairs(lines) do -- Pad lines
        if k ~= 1 then
            lines[k] = "  " .. line .. "  "
        end
    end
    local vim_width = api.nvim_get_option("columns")
    local vim_height = api.nvim_get_option("lines")
    local height = math.ceil(vim_height * 0.7 - 4)
    local width = math.ceil(vim_width * 0.7)
    local row = math.ceil((vim_height - height) / 2 - 1)
    local col = math.ceil((vim_width - width) / 2)
    local buf = api.nvim_create_buf(false, true)
    api.nvim_open_win(buf, true, {
        style = "minimal",
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        border = config.options.extensions.memory_usage.border,
    })
    vim.bo.shiftwidth = 2
    vim.wo.foldmethod = "indent"
    api.nvim_buf_set_lines(buf, 0, -1, true, lines)
    api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    api.nvim_buf_set_option(buf, "modifiable", false)
    api.nvim_buf_set_option(buf, "buftype", "nofile")
    api.nvim_buf_set_keymap(buf, "n", "q", ":bd<CR>", {
        noremap = true,
        silent = true,
    })
    api.nvim_buf_set_keymap(buf, "n", "<ESC>", ":bd<CR>", {
        noremap = true,
        silent = true,
    })
end

local function format_name(name)
    if name:sub(1, 7) == "file://" then
        name = vim.uri_to_fname(name)
    end
    local cwd = vim.fn.getcwd()
    if name:sub(1, string.len(cwd)) == cwd then
        name = name:sub(string.len(cwd) + 2, -1)
    end
    return name
end

local function format_tree(node, visited, result, padding, prefix, expand_preamble)
    if padding == "" then
        table.insert(result, fmt("Total: self = %s, total = %s", node._self, node._total))
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
    if err then
        return
    end
    display(format_tree(result, {}, { "" }, "", "", expand_preamble))
end

local M = {}

function M.show_memory_usage(expand_preamble)
    vim.lsp.buf_request(0, "$/memoryUsage", nil, function(err, result)
        handler(err, result, expand_preamble)
    end)
end

return M
