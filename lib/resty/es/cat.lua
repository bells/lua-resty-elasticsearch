local es_utils = require "resty.es.utils"


local deal_params = es_utils.deal_params


local _M = {
    _VERSION = '0.01'
}


local mt = { __index = _M }

function _M.new(self, client)
    return setmetatable({client = client}, mt)
end


function _M.aliases(self, c_params)
end


function _M.health(self, s_params)
    local _, query_params = deal_params(s_params)
    local data, err = self.client:_perform_request(
        'GET', '/_cat/health', query_params
    )

    return data, err
end


return _M
