local es_utils = require "resty.es.utils"

local make_path = es_utils.make_path

local _M = {
    _VERSION = '0.01'
}


local mt = { __index = _M }

function _M.new(self, client)
    return setmetatable({client = client}, mt)
end


function _M.info(self, s_params)
    local data, err = self.client:_perform_request(
        'GET', 
        make_path('_nodes', s_params.node_id, s_params.metric),
        s_params.params
    )

    return data, err
end


return _M
