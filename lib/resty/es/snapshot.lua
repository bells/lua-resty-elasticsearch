local es_utils = require "resty.es.utils"

local make_path = es_utils.make_path

local _M = {
    _VERSION = '0.01'
}


local mt = { __index = _M }

function _M.new(self, client)
    return setmetatable({client = client}, mt)
end


function _M.create(self, s_params)
    local data, err = self.client:_perform_request(
        'PUT',
        make_path('_snapshot', s_params.repository, s_params.snapshot),
        s_params.params, s_params.body
    )

    return data, err
end


return _M
