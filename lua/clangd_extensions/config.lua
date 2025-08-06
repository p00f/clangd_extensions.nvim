---@class ClangdConfig
local M = {}

---@class ClangdOpts
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

---@param options? table|ClangdOpts
function M.setup(options)
    M.options = vim.tbl_deep_extend("force", {}, M.options, options or {})
end

return M
