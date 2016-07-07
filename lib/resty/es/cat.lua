local _M = {
    _VERSION = '0.01'
}


local mt = { __index = _M }

function _M.new(self, client)
    return setmetatable({client = client}, mt)
end


function _M.aliases(self, c_params)
end


function _M.health(self, ...)
    local status, data = self.client:_perform_request(
        'GET', '/_cat/health', {...}, nil
    )

    return status, data
end


return _M
