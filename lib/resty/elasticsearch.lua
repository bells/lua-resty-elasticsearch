local http = require "resty.http"
local cjson = require "cjson"

local string = string

local _M = {
	_VERSION = '0.01'
}


local mt = { __index = _M }

local function _make_path(index, doc_type, ...) 
    local prefix
    if index ~= nil and doc_type ~= nil then
        prefix = string.format('%s/%s', index, doc_type)
    elseif index ~= nil and doc_type == nil then
        prefix = index
    elseif index == nil and doc_type ~= nil then
        prefix = '_all/' .. doc_type
    end
    local suffix = table.concat({...}, '/')
    return string.format('/%s/%s', prefix, suffix)
end


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

	return setmetatable(
        {http_clients_len = #http_clients, http_clients = http_clients},
        mt
    )
end


function _M._perform_request(self, http_method, url, params, body)
	local temp_index = math.random(self.http_clients_len)
	local http_client = self.http_clients[temp_index]
    
    ngx.log(ngx.ERR, '****************: url: ', url)	
	if params then
        url = string.format('%s?%s', url, ngx.encode_args(params))
	end
    if body then
        body = cjson.encode(body)
    else
        body = ''
    end

	local res, err = http_client:request{
        path = url, method = http_method, body = body}
	if not res then
		return nil, err
	end
    local response_body = ''
    if res.has_body then
       response_body = res:read_body() 
    end

	return res.stauts, cjson.decode(response_body)
end


function _M.info(self, params)
	_, data = self:_perform_request('GET', '/', params)
	return data
end


function _M.ping(self, params)
	local res, err = self:_perform_request('HEAD', '/', params)
	if not res then
		return false
    end
	return true
end


function _M.search(self, s_params)
    local _, data = self:_perform_request(
        'GET', _make_path(s_params.index, s_params.doc_type, '_search'),
        s_params.params, s_params.body
    )

    return data
end


function _M.search_template(self, s_params)
    local _, data = self:_perform_request(
        'GET', _make_path(s_params.index, s_params.doc_type, '_search', 'template'),
        s_params.params, s_params.body
    )

    return data
end

return _M
