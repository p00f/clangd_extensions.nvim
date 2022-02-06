local utils = require("clangd_extensions.utils")
local api = vim.api

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
    })
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

local function handler(err, result)
    if err then
        return
    end
    local disp = { "" }
    table.insert(disp, "Total: " .. result._total)
    table.insert(disp, "  Clangd server: " .. result.clangd_server._total)
    table.insert(disp, "    Background index: " .. result.clangd_server.background_index._total)
    table.insert(disp, "    Dynamic index: " .. result.clangd_server.dynamic_index._total)
    table.insert(disp, "      Main file: " .. result.clangd_server.dynamic_index.main_file._total)
    table.insert(
        disp,
        "        Index: " .. result.clangd_server.dynamic_index.main_file.index._self
    )
    if result.clangd_server.dynamic_index.main_file.slabs then
        table.insert(
            disp,
            "        Slabs: " .. result.clangd_server.dynamic_index.main_file.slabs._total
        )
        for k, v in pairs(result.clangd_server.dynamic_index.main_file.slabs) do
            if k ~= "_self" and k ~= "_total" then
                table.insert(disp, string.format("          %s: %s", vim.uri_to_fname(k), v._total))
                table.insert(disp, string.format("            References: %s", v.references._self))
                table.insert(disp, string.format("            Relations: %s", v.relations._self))
                table.insert(disp, string.format("            Symbols: %s", v.symbols._self))
            end
        end
    end
    table.insert(disp, "      Preamble: " .. result.clangd_server.dynamic_index.preamble._total)
    table.insert(
        disp,
        "        Index: " .. result.clangd_server.dynamic_index.preamble.index._total
    )
    table.insert(
        disp,
        "        Slabs: " .. result.clangd_server.dynamic_index.preamble.slabs._total
    )
    table.insert(disp, "    tuscheduler: " .. result.clangd_server.tuscheduler._total)
    table.insert(
        disp,
        "      Header includer cache: "
            .. result.clangd_server.tuscheduler.header_includer_cache._total
    )
    for k, v in pairs(result.clangd_server.tuscheduler) do
        if k ~= "header_includer_cache" and k ~= "_self" and k ~= "_total" then
            table.insert(disp, string.format("    %s: %s", k, v._total))
            table.insert(disp, string.format("      AST: %s", v.ast._total))
            table.insert(disp, string.format("      Preamble: %s", v.preamble._total))
        end
    end
    display(disp)
end

local M = {}
function M.memory_usage()
    utils.request(0, "$/memoryUsage", nil, handler)
end
return M
