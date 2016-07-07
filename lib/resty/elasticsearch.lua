local cjson = require "cjson"
local http = require "resty.http"
local es_cat = require "resty.es.cat"
local es_utils = require "resty.es.utils" 

local str_find = string.find
local str_sub = string.sub
local math_random = math.random
local make_path = es_utils.make_path

local _M = {
	_VERSION = '0.01'
}


local mt = { __index = _M }


function _M.new(self, hosts)
	if not hosts then
		hosts = {'http://localhost:9200'}
    end

    local es = {
        hosts_len = #hosts, 
        hosts = hosts,
    }
    es.cat = es_cat:new(es)

	return setmetatable(es, mt)
end


function _M._perform_request(self, http_method, url, params, body)
	local temp_index = math_random(self.hosts_len)
	local host = self.hosts[temp_index]
    local http_c = http.new()
    
    url = host .. url
	if params then
        url = url .. ngx.encode_args(params)
	end
    if body then
        body = cjson.encode(body)
    else
        body = ''
    end

	local res, err = http_c:request_uri(url, {method = http_method, body = body})
	if not res then
		return nil, err
	end
    local response_body = res.body
    local temp_index, _, _ = str_find(res.headers['content-type'], ';')
    local mimetype = str_sub(res.headers['content-type'], 1, temp_index - 1)
    if mimetype == 'application/json' then
       response_body = cjson.decode(response_body) 
    elseif mimetype == 'text/plain' then
        -- do nothing
    else 
        return nil, 'Unknown mimetype, unable to deserialize: ' .. mimetype 
    end

    http_c:set_keepalive()
	return res.status, response_body
end


------------------------------------------------------------------------------
-- Get the basic info from the current cluster.
--
------------------------------------------------------------------------------
function _M.info(self, params)
	local status, data = self:_perform_request('GET', '/', params)
	return status, data
end


------------------------------------------------------------------------------
-- Returns True if the cluster is up, False otherwise. 
--
------------------------------------------------------------------------------
function _M.ping(self, params)
	local res, err = self:_perform_request('HEAD', '/', params)
	if not res then
		return false, err
    end
	return true, ''
end


------------------------------------------------------------------------------
-- Execute a search query and get back search hits that match the query. 
--
------------------------------------------------------------------------------
function _M.search(self, s_params)
    if s_params.doc_type and not s_params.index then
        s_params.index = '_all'
    end

    local status, data = self:_perform_request(
        'GET', make_path(s_params.index, s_params.doc_type, '_search'),
        s_params.params, s_params.body
    )

    return status, data
end


------------------------------------------------------------------------------
-- A query that accepts a query template. 
--
------------------------------------------------------------------------------
function _M.search_template(self, s_params)
    local _, data = self:_perform_request(
        'GET',
        make_path(s_params.index, s_params.doc_type, '_search', 'template'),
        s_params.params, s_params.body
    )

    return data
end


function _M.search_shards(self, s_params)
    local _, data = self:_perform_request(
        'GET', make_path(s_params.index, s_params.doc_type, '_search_shards'),
        s_params.params
    )

    return data
end


function _M.explain(self, s_params)
    if not s_params.index then
        return nil, 'the index parameter is a required argument.'
    end
    if not s_params.doc_type then
        return nil, 'the doc_type parameter is a required argument.'
    end
    if not s_params.id then
        return nil, 'the id parameter is a required argument.'
    end

    local status, data = self:_perform_request(
        'GET',
        make_path(s_params.index, s_params.doc_type, s_params.id, '_explain'),
        s_params.params, s_params.body
    )        

    return status, data
end


function _M.delete(self, s_params)
    if not s_params.index then
        return nil, 'the index parameter is a required argument.'
    end
    if not s_params.doc_type then
        return nil, 'the doc_type parameter is a required argument.'
    end
    if not s_params.id then
        return nil, 'the id parameter is a required argument.'
    end

    local status, data = self:_perform_request(
        'DELETE', make_path(index, doc_type, id), s_params.params
    )

    return status, data
end


function _M.count(self, s_params)
    if s_params.doc_type and not s_params.index then
        s_params.index = '_all'
    end

    local status, data = self:_perform_request(
        'GET', make_path(s_params.index, s_params.doc_type, '_count'),
        s_params.params, s_params.body
    )

    return status, data
end


function _M.suggest(self, s_params)
    if not s_params.body then
        return nil, 'the body parameter is a required argument.'
    end

    local status, data = self:_perform_request(
        'POST', make_path(s_params.index, nil, '_suggest'), 
        s_params.params, s_params.body
    )
    
    return status, data
end


return _M
