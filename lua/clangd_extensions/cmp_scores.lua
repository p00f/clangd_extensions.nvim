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
