# Implementation status of [extensions](https://clangd.llvm.org/extensions)
 - [x] Memory usage
 - [ ] AST
 - [x] Symbol info request (implemented)
 - [x] Type hierarchy (implemented)
 - [x] Inlay hints (implemented)
 - [x] Switch between source/header (nvim-lspconfig already does this)
 - [x] File status (see lsp-status.nvim)
 - [x] Compilation commands (can be specified in lspconfig `init_options`)

 I'm not if the below are even possible:
 - [ ] Force diagnostics generation (look into this)
 - [ ] Code completion scores (look into this)
 - [ ] Diagnostic categories
 - [ ] Inline fixes for diagnostics
