---@class ClangdExt.Health
local M = {}

function M.check()
    vim.health.start("Environment")

    if vim.fn.executable("clangd") ~= 1 then
        vim.health.error("`clangd` not found in PATH")
        return
    end
    vim.health.ok("`clangd` found in PATH")

    vim.health.start("Commands Available")
    local commands = {
        "ClangdAST",
        "ClangdMemoryUsage",
        "ClangdSwitchSourceHeader",
        "ClangdSymbolInfo",
        "ClangdTypeHierarchy",
    }
    for _, cmd in ipairs(commands) do
        local msg = ("`%s`"):format(cmd)
        if vim.is_callable(vim.cmd[cmd]) then
            vim.health.ok(msg)
        else
            vim.health.error(msg)
        end
    end
end

return M
-- vim: set ts=4 sts=4 sw=4 et ai si sta:
