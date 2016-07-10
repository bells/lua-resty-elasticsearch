local es_utils = require "resty.es.utils"


local make_path = es_utils.make_path
local deal_params = es_utils.deal_params


local _M = {
    _VERSION = '0.01'
}


local mt = { __index = _M }


function _M.new(self, client)
    return setmetatable({client = client}, mt)
end


function _M.health(self, s_params)
    local basic_params, query_params = deal_params(s_params, 'index')
    local data, err = self.client:_perform_request(
        'GET', 
        make_path('_cluster', 'health', basic_index),
        query_params
    )

    return data, err
end


return _M
