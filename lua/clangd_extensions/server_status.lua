local config = require("clangd_extensions.config")
local inlay = require("clangd_extensions.inlay_hints")

local M = {}

function M.handler(_, result)
    if result.quiescent and config.options.extensions.autoSetHints and not M.ran_once then
        inlay.set_inlay_hints()
        require("clangd_extensions.inlay_hints").setup_autocmd()
        M.ran_once = true
    end
end

return M
