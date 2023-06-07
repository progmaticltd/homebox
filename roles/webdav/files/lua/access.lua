local method = ngx.req.get_method()
local file = nil

if (method == "COPY" or method == "MOVE") then

   file = ngx.req.get_headers()["Destination"]

elseif (method == "PUT" or method == "MKCOL") then

   file = ngx.var.uri

end

if (file and ngx.re.match(file, "/\\.[^/]*/?$")) then

   ngx.status = ngx.HTTP_FORBIDDEN
   ngx.exit(ngx.HTTP_FORBIDDEN)

end
