---@class ClangdExt.Health
local M = {}

function M.check()
    vim.health.start("Environment")

    if vim.fn.executable("clangd") ~= 1 then
        vim.health.error("`clangd` not found in PATH")
        return
    end
    vim.health.ok("`clangd` found in PATH")
end

return M
-- vim: set ts=4 sts=4 sw=4 et ai si sta:
