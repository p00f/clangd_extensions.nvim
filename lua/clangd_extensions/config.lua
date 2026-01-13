local utils = require("clangd_extensions.utils")

---@class ClangdExt.Config
local M = {}

---@class ClangdExt.Opts
M.options = {
    ast = {
        role_icons = {
            type = "🄣",
            declaration = "🄓",
            expression = "🄔",
            statement = ";",
            specifier = "🄢",
            ["template argument"] = "🆃",
        },

        kind_icons = {
            Compound = "🄲",
            Recovery = "🅁",
            TranslationUnit = "🅄",
            PackExpansion = "🄿",
            TemplateTypeParm = "🅃",
            TemplateTemplateParm = "🅃",
            TemplateParamObject = "🅃",
        },

        highlights = {
            detail = "Comment",
        },
    },

    memory_usage = {
        border = "none",
    },

    symbol_info = {
        border = "none",
    },
}

---@param options? ClangdExt.Opts
function M.setup(options)
    utils.validate({ options = { options, { "table", "nil" }, true } })

    M.options = vim.tbl_deep_extend("force", {}, M.options, options or {})
end

return M
-- vim: set ts=4 sts=4 sw=4 et ai si sta:
