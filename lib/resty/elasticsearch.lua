local http = require "resty.http"
local cjson = require "cjson"

local string = string

local _M = {
	_VERSION = '0.01'
}


local mt = { __index = _M }


function _M.new(self, hosts)
	if not hosts then
		hosts = {{'localhost', 9200}}
    end
    http_clients = {}
    for _, v in pairs(hosts) do
	    local http_client = http.new()
        http_client:set_timeout(500)
        http_client:connect(v[1], v[2])
        table.insert(http_clients, http_client)
    end

	return setmetatable({http_clients_len = #http_clients, http_clients = http_clients}, mt)
end


function _M._perform_request(self, http_method, url, params, body)
	local temp_index = math.random(self.http_clients_len)
	local http_client = self.http_clients[temp_index]
	
	if params then
        url = string.format('%s?%s', url, ngx.encode_args(params))
	end
	local res, err = http_client:request{path = url, method = http_method, body = body}
	if not res then
		return nil, err
	end
    local body = ''
    if res.has_body then
       body = res:read_body() 
    end
	return res.stauts, cjson.decode(body)
end


function _M._make_path(self, ...) 
    local path = table.concat({...}, '/')
    ngx.log(ngx.ERR, '...........path: ', path)
    return '/' .. path
end


function _M.info(self, params)
	_, data = self:_perform_request('GET', '/', params, nil)
	return data
end


function _M.ping(self, params)
	local res, err = self:_perform_request('HEAD', '/', params, nil)
	if not res then
		return false
    end
	return true
end


function _M.search(self, index, doc_type, params, body)
    if doc_type and not index then
        index = '_all'
    end
    local _, data = self:_perform_request('GET', self:_make_path(index, doc_type, '_search'), params, cjson.encode(body))
    return data
end


return _M
