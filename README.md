![clangd](https://user-images.githubusercontent.com/36493671/152692205-837ec826-54d0-4257-9894-cc1a7ac8a114.svg)

## Features:
### [Inlay hints](https://clangd.llvm.org/extensions#inlay-hints)
![image](https://user-images.githubusercontent.com/36493671/152699601-61ad1640-96bf-4082-b553-75d4085c3496.png)
### [Memory usage](https://clangd.llvm.org/extensions#memory-usage)
![image](https://user-images.githubusercontent.com/36493671/152699322-9e537b1a-8253-45c1-ada3-752effeac39b.png)
### [View AST](https://clangd.llvm.org/extensions#ast)
https://user-images.githubusercontent.com/36493671/152699182-af1db73b-4996-4403-9190-f420f129641a.mp4
### [Symbol info](https://clangd.llvm.org/extensions#symbol-info-request)
![image](https://user-images.githubusercontent.com/36493671/152699367-dc928adf-d3ed-4e8e-a9d0-ca573f01c008.png)
### [Type heirarchy](https://clangd.llvm.org/extensions#type-hierarchy)
![image](https://user-images.githubusercontent.com/36493671/152699475-cc920980-0af9-4eb3-852c-23f487eba2ae.png)

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
