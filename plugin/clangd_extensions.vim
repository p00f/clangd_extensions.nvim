function s:memuse_compl(_a,_b,_c)
    return ['expand_preamble']
endfunction

command ClangdSetInlayHints lua require('clangd_extensions.inlay_hints').set_inlay_hints()
command ClangdDisableInlayHints lua require('clangd_extensions.inlay_hints').disable_inlay_hints()
command ClangdToggleInlayHints lua require('clangd_extensions.inlay_hints').toggle_inlay_hints()
command -range ClangdAST lua require('clangd_extensions.ast').display_ast(<line1>, <line2>)
command ClangdTypeHeirarchy lua require('clangd_extensions.type_heirarchy').show_heirarchy()
command ClangdSymbolInfo lua require('clangd_extensions.symbol_info').show_symbol_info()
command -nargs=? -complete=customlist,s:memuse_compl ClangdMemoryUsage lua require('clangd_extensions.memory_usage').show_memory_usage('<args>' == 'expand_preamble')
