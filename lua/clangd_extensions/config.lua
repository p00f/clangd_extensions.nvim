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
    M.options = vim.tbl_deep_extend("force", {}, M.options, options or {})

    vim.g.clangd_extensions_setup = 1
end

return M
-- vim: set ts=4 sts=4 sw=4 et ai si sta:
