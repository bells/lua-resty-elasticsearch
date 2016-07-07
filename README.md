# lua-resty-elasticsearch

ElasticSearch client for for [OpenResty](http://openresty.org/) / [ngx_lua](https://github.com/openresty/lua-nginx-module).

# Requirements

[lua-resty-http](https://github.com/pintsized/lua-resty-http)

# API

* [new](#new)
* [ping](#ping)
* [info](#info)
* [search](#search)

## Synopsis

``` lua
lua_package_path "/path/to/lua-resty-http,lua-resty-elasticsearch/lib/?.lua;;";

server {
    location /test_es {
        content_by_lua '
            local cjson = require "cjson"
            local elasticsearch = require "resty.elasticsearch"
            es = elasticsearch:new({"http://172.18.5.64:9200"})

            local status, data = es:info()
            ngx.say(cjson.encode(data))
            ngx.say("---------------------------")
            local body = {query={match_all={}}}
            local status, data = es:search({doc_type="products"})
            ngx.say(cjson.encode(data))
            ngx.say("---------------------------")
            local status, data = es.cat:health()
            ngx.say(data)
        ';
    }
}
```

## new

`syntax: es = elasticsearch:new()`

Creates the elasticsearch object. 

## ping

`syntax: ok, err = es:ping()`

Returns True if the cluster is up, False otherwise. 

## info

`syntax: status, data = es:info()`

Get the basic info from the current cluster. 

## search

`syntax: status, data = es:search{index="index", doc_type="user", body={query={match_all={}}}}`

Execute a search query and get back search hits that match the query. 

# Copyright and License

This module is licensed under the 2-clause BSD license.

Copyright (c) 2015-2016, by bells <bellszhu@gmail.com>

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
