![clangd](https://user-images.githubusercontent.com/36493671/152692205-837ec826-54d0-4257-9894-cc1a7ac8a114.svg)

## Configuration:
This is the default config, you can call `require("clangd_extensions").setup()` with no arguments if you don't want to make changes.
Remove `require'lspconfig'.clangd.setup{}` from your config, this will be called by clangd_extensions.nvim. Use the `server` field below to customize `setup{}`.
```lua
require("clangd_extensions").setup {
    server = {
        -- options to pass to nvim-lspconfig
        -- i.e. the arguments to require("lspconfig").clangd.setup({})
    },
    extensions = {
        -- defaults:
        -- Automatically set inlay hints (type hints)
        autoSetHints = true,
        -- Whether to show hover actions inside the hover window
        -- This overrides the default hover handler
        hover_with_actions = true,
        -- These apply to the default ClangdSetInlayHints command
        inlay_hints = {
            -- Only show inlay hints for the current line
            only_current_line = false,
            -- Event which triggers a refersh of the inlay hints.
            -- You can make this "CursorMoved" or "CursorMoved,CursorMovedI" but
            -- not that this may cause  higher CPU usage.
            -- This option is only respected when only_current_line and
            -- autoSetHints both are true.
            only_current_line_autocmd = "CursorHold",
            -- whether to show parameter hints with the inlay hints or not
            show_parameter_hints = true,
            -- prefix for parameter hints
            parameter_hints_prefix = "<- ",
            -- prefix for all the other hints (type, chaining)
            other_hints_prefix = "=> ",
            -- whether to align to the length of the longest line in the file
            max_len_align = false,
            -- padding from the left if max_len_align is true
            max_len_align_padding = 1,
            -- whether to align to the extreme right or not
            right_align = false,
            -- padding from the right if right_align is true
            right_align_padding = 7,
            -- The color of the hints
            highlight = "Comment",
        },
        ast = {
            role_icons = {
                type = "",
                declaration = "",
                expression = "",
                specifier = "",
                statement = "",
                ["template argument"] = "",
            },

            kind_icons = {
                Compound = "",
                Recovery = "",
                TranslationUnit = "",
                PackExpansion = "",
                TemplateTypeParm = "",
                TemplateTemplateParm = "",
                TemplateParamObject = "",
            },

            highlights = {
                detail = "Comment",
            },
        memory_usage = {
            border = "none",
        },
        symbol_info = {
            border = "none",
        },
    },
}
```
## Features:
### [Inlay hints](https://clangd.llvm.org/extensions#inlay-hints)
![image](https://user-images.githubusercontent.com/36493671/152699601-61ad1640-96bf-4082-b553-75d4085c3496.png)
#### Usage
See configuration instructions above
### [View AST](https://clangd.llvm.org/extensions#ast)
You can fold nodes using `zc` and friends - the AST window has `shiftwidth=2` and `foldmethod=indent`.
https://user-images.githubusercontent.com/36493671/152699182-af1db73b-4996-4403-9190-f420f129641a.mp4
### [Completion scores](https://clangd.llvm.org/extensions#code-completion-scores)
Usage: For nvim-cmp
```lua
local cmp = require "cmp"
cmp.setup {
    -- ... rest of your cmp setup ...

    sorting = {
        comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.recently_used,
            require("clangd_extensions.cmp_scores"),
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
        },
    },
}
```
#### Usage
`:ClangdAST` to view the ast with the current line as the range, `:'<,'>ClangdAST` with a visual selection to view the ast with the selected lines as range.
See how ranges are handled at https://clangd.llvm.org/extensions#ast
### [Symbol info](https://clangd.llvm.org/extensions#symbol-info-request)
![image](https://user-images.githubusercontent.com/36493671/152699367-dc928adf-d3ed-4e8e-a9d0-ca573f01c008.png)
#### Usage
`:ClangdSymbolInfo` with the cursor at the desired symbol.
### [Type hierarchy](https://clangd.llvm.org/extensions#type-hierarchy)
![image](https://user-images.githubusercontent.com/36493671/152699475-cc920980-0af9-4eb3-852c-23f487eba2ae.png)
#### Usage
`:ClangdTypeHierarchy` with the cursor over the desired type or a symbol of that type.
### [Memory usage](https://clangd.llvm.org/extensions#memory-usage)
You can fold items using `zc` and friends - the memory usage window has `shiftwidth=2` and `foldmethod=indent`.
![image](https://user-images.githubusercontent.com/36493671/152699322-9e537b1a-8253-45c1-ada3-752effeac39b.png)
#### Usage
`:ClangdMemoryUsage`. Preamble can be large so it is collapsed by default, to expand it use `:ClangdMemoryUsage expand_preamble`

## Implementation status of [extensions](https://clangd.llvm.org/extensions)
 ☑️ Memory usage (implemented)
 ☑️ AST (implemented)
 ☑️ Symbol info request (implemented)
 ☑️ Type hierarchy (implemented)
 ☑️ Inlay hints (implemented)
 ☑️ Switch between source/header (nvim-lspconfig already does this)
 ☑️ File status (see lsp-status.nvim)
 ☑️ Compilation commands (can be specified in lspconfig `init_options`)
 ☑️ Code completion scores (implemented)
 ⬜ Force diagnostics generation (not sure)
## Credits
[simrat39](https://github.com/simrat39) - the code for inlay hints was taken from [rust-tools.nvim](https://github.com/simrat39/rust-tools.nvim) with very minor changes.
