local cjson = require "cjson"

local t_insert = table.insert 
local t_concat = table.concat
local str_format = string.format
local select = select


local _M = {
    _VERSION = '0.01'
}


function _M.make_path(...) 
    local t = {}
    local num_args = select('#', ...)
    for i = 1, num_args do
        local arg = select(i, ...)
        if arg ~= nil and arg ~= '' then
            t_insert(t, arg)
        end
    end
    return '/' .. t_concat(t, '/') 
end


local function json_decode(str)
    local json_value = nil
    pcall(function (str) json_value = json.decode(str) end, str)
    return json_value
end


function _M.get_err_str(self, http_response_code, http_response_data)
    return str_format(
        '%s: http response code: %s. and es response error info: %s',
        http_resonse_code, http_response_data
    )
end


function _M.deal_params(s_params, query_params_list)
    if s_params == nil then
        return {}, {}
    end
end


return _M
