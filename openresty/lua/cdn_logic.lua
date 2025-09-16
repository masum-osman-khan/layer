local memcached = require "resty.memcached"
local cjson = require "cjson"

local function get_location_from_ip(ip)
    if string.match(ip, "^10%.") or string.match(ip, "^192%.168%.") or string.match(ip, "^172%.16") then
        return "local"
    elseif string.match(ip, "^185%.") then 
        return "europe"
    else 
        return "global"
    end
end

local function get_device_type(user_agent)
    if string.match(user_agent, "Mobile") or string.match(user_agent, "Android") then
        return "mobile"
    elseif string.match(user_agent, "iPad") then
        return "tablet"
    else
        return "desktop"
    end
end

local mc, err = memcached: new()
if not mc then
    ngx.log(ngx.ERR, "failed to instantiate memcached: ", err)
    return ngx.exit(500)
end
mc:set_timeout(1000)

local ok, err = mc:connect("memcached_cache", 11211)
if not ok then
    ngx.log(ngx.ERR, "failed to connect to memcached: ", err)
    return ngx.exit(500)
end

local ip_address = ngx.var.remote_addr
local user_agent = ngx.req.get_header()["User-Agent"]

local location = get_location_from_ip(ip_address)
local device = get_device_type(user_agent)

ngx.log(ngx.INFO, "User IP: ", ip_address, ", Location: ", location, ", Device: ", device)

local cache_key = ngx.var.uri .. ":" .. location .. ":" .. device


local content, flags, err = mc:get(cache_key)
if err then
    ngx.log(ngx.ERR, "memcached get error: ", err)
elseif content then
    ngx.log(ngx.INFO, "Cache hit for key: ", cache_key)

    local decoded_content = cjson.decode(content)
    if device == "mobile" then
        decoded_content.message = "This is a mobile-optimized version of the content."
    end

    ngx.header["Content-Type"] = "application/json"
    ngx.say(cjson.encode(decoded_content))
    return ngx.exit(200)
end

ngx.log(ngx.INFO, "Cache miss for key: ", cache_key, ". Proceeding to backend.")

local res = ngx.location.capture(ngx.var.uri)
local backend_body = res.body

if res.status = 200 then
    local ok, err = mc.set(cache_key, backend_body, 3600)
    if not ok then
        ngx.log(ngx.ERR, "failed to set cache key: ", err)
    else
        ngx.log(ngx.INFO, "Successfully cached key: ", cache_key)
    end
end

ngx.header["Content-Type"] = "application/json"
ngx.say(backend_body)
mc:close()