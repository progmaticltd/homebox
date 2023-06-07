local dir_requested = is_dir(ngx.var.request_filename)

if ngx.req.get_method() == "MKCOL" and not ngx.re.match(ngx.var.uri, "^.*/$") then

    -- When creating a collection, ensure the path ends with '/'
    local uri = ngx.re.sub(ngx.var.uri, "^(.*?)/?$", "$1/")
    ngx.req.set_uri(uri, true)

elseif dir_requested and not ngx.re.match(ngx.var.uri, "^.*/$") then

    -- URL should end with "/" if directory requested
    local uri = ngx.re.sub(ngx.var.uri, "^(.*?)/?$", "$1/")
    ngx.req.set_uri(uri, true)

end

local dst = ngx.req.get_headers()["Destination"]

if dst then
    -- Remove hostname from destination
    dst = ngx.re.sub(dst, "^(https?://.+?)?(/.*)$", "$2")

    -- Rename the folder Destination does not end with a /,
    -- it is necessary headers-more-nginx-module
    if dir_requested then
        dst = ngx.re.sub(dst, "^(.*?)/?$", "$1/")
    end

    ngx.req.set_header("Destination", dst)
end

-- PROPPATCH no instruction processing PROPFIND.
if ngx.req.get_method() == "PROPPATCH" then
    ngx.req.set_method(ngx.HTTP_PROPFIND)
end
