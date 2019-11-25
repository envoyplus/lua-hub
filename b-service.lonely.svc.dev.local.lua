
local function url_decode(str)
    return str:gsub("%%(%x%x)", function(hex)
        return string_char(tonumber(hex, 16))
    end)
end
local function decode_pairs(str, decoder)
	local p =string.find(str,"?")
	local all_query = string.sub(str,p+1)
	 print("all : ",all_query,"\r\n")
    local query_pairs = {}
    for pair in all_query:gmatch "[^&]+" do
        local k, v = pair:match "^([^=]*)=?(.*)"
        query_pairs[decoder(k)] = decoder(v)
		   print(decoder(k),"-->",decoder(v),"\r\n")
    end

    return query_pairs
end


function envoy_on_request(request_handle)
  request_handle:logInfo("进来了")
  path = request_handle:headers():get(":path")
  request_handle:logInfo(path)
  request_handle:headers():add("mama", "99")
--
    local mytable = decode_pairs(path, url_decode)
    local version = mytable["version"]
    local userid = mytable["userid"]
    local gray_array = {100, 200}
    if( version ~= nil )
    then
        request_handle:logInfo("已经存在了"..version)
    else

        for key,value in ipairs(gray_array)
        do
            if( userid==tostring(value) )
            then
               path = path..'&version=v2'
               request_handle:headers():replace(":path", path)
               request_handle:logInfo("我加了参数"..path)
            end
           print(key, value)
        end

    end
--
end

function envoy_on_response(response_handle)

--   response_handle:headers():add("response_body_size", response_handle:body():length())
  response_handle:headers():add("X-Envoy-Ingress", os.getenv("HOSTNAME"))
  response_handle:logInfo("envoy_on_response 来过")
end
