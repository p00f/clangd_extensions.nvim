---@module 'cmp'

---@param entry1 cmp.Entry
---@param entry2 cmp.Entry
---@return boolean
return function(entry1, entry2)
    local diff
    if entry1.completion_item.score and entry2.completion_item.score then
        diff = (entry2.completion_item.score * entry2.score)
            - (entry1.completion_item.score * entry1.score)
    else
        diff = entry2.score - entry1.score
    end
    return (diff < 0)
end
-- vim: set ts=4 sts=4 sw=4 et ai si sta:
