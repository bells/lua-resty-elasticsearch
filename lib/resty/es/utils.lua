local t_insert = table.insert 
local t_concat = table.concat

local _M = {
    _VERSION = '0.01'
}


function _M.make_path(index, doc_type, ...) 
    local t = {...}
    if doc_type then
        t_insert(t, 1, doc_type)
    end
    if index then
        t_insert(t, 1, index)
    end
    return '/' .. t_concat(t, '/') 
end


return _M
