---@module "cmp"

---Non-legacy validation spec (>=v0.11)
---@class ValidateSpec
---@field [1] any
---@field [2] vim.validate.Validator
---@field [3]? boolean
---@field [4]? string

---@class lsp.Position
---@field line number
---@field character number

---Non-legacy validation spec (>=v0.11)
---@class ValidateSpec
---@field [1] any
---@field [2] vim.validate.Validator
---@field [3]? boolean
---@field [4]? string

---@class Clangd.ASTNode
---@field role string
---@field kind string
---@field detail? string
---@field arcana? string
---@field range? lsp.Range
---@field children? Clangd.ASTNode[]

---@class Clangd.SymbolDetails
---@field name string
---@field containerName string
---@field usr string
---@field id string?

---@class Clangd.TypeHierarchyItem
---@field name string
---@field detail? string
---@field kind lsp.SymbolKind
---@field deprecated? boolean
---@field uri string
---@field range lsp.Range
---@field selectionRange lsp.Range
---@field parents? Clangd.TypeHierarchyItem[]
---@field children? Clangd.TypeHierarchyItem[]
---@field data? any

---@class Clangd.UserCommand
---@field [1] string|fun(opts?: vim.api.keyset.create_user_command.command_args)
---@field [2] vim.api.keyset.user_command

---@class cmp.Entry
---@field public id integer
---@field public cache cmp.Cache
---@field public match_cache cmp.Cache
---@field public score integer
---@field public exact boolean
---@field public matches table
---@field public context cmp.Context
---@field public source cmp.Source
---@field public source_offset integer
---@field public source_insert_range lsp.Range
---@field public source_replace_range lsp.Range
---@field public completion_item lsp.CompletionItem
---@field public item_defaults? lsp.internal.CompletionItemDefaults
---@field public resolved_completion_item lsp.CompletionItem|nil
---@field public resolved_callbacks fun()[]
---@field public resolving boolean
---@field public confirmed boolean
---@field public insert_range lsp.Range
---@field public replace_range lsp.Range
---@field public offset integer
---@field public word string
---@field public filter_text string
---@field private match_view_args_ret {input:string, word:string, option:cmp.MatchingConfig, matches:table[]}
