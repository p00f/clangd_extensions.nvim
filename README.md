![clangd](https://user-images.githubusercontent.com/36493671/152692205-837ec826-54d0-4257-9894-cc1a7ac8a114.svg)
## Implementation status of [extensions](https://clangd.llvm.org/extensions)
 - [x] Memory usage (implemented)
 - [x] AST (implemented)
 - [x] Symbol info request (implemented)
 - [x] Type hierarchy (implemented)
 - [x] Inlay hints (implemented)
 - [x] Switch between source/header (nvim-lspconfig already does this)
 - [x] File status (see lsp-status.nvim)
 - [x] Compilation commands (can be specified in lspconfig `init_options`)

 I'm not sure if the below are in scope or even possible:
 - [ ] Force diagnostics generation (look into this)
 - [ ] Code completion scores (look into this)
 - [ ] Diagnostic categories
 - [ ] Inline fixes for diagnostics
