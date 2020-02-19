--lua table

--local print = print
local tconcat = table.concat
local tinsert = table.insert
local srep = string.rep
local type = type
local pairs = pairs
local tostring = tostring
local next = next
local platform = cc.Application:getInstance():getTargetPlatform()


function print_r(root)
    local cache = {  [root] = "." }
    local function _dump(t,space,name)
        local temp = {}
        for k,v in pairs(t) do
            local key = tostring(k)
            if cache[v] then
                tinsert(temp,"+" .. key .. " {" .. cache[v].."}")
            elseif type(v) == "table" then
                local new_key = name .. "." .. key
                cache[v] = new_key
                tinsert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. srep(" ",#key),new_key))
            else
                tinsert(temp,"+" .. key .. " [" .. tostring(v).."]")
            end
        end
        return tconcat(temp,"\n"..space)
    end
    print("\n", _dump(root, "",""))
end

function print_android(tag, text)
    if cc.PLATFORM_OS_ANDROID == platform then
        local luaj = require "cocos.cocos2d.luaj"
        luaj.callStaticMethod("android.util.Log","d",{tag,text},"(Ljava/lang/String;Ljava/lang/String;)I")
    end
end

function walkTable(t)  
    for k,v in pairs(t) do  
        print("+++",k,v,"+++")  
    end  
end

local function printForAndroid(...)
    local printResult = ""
    --local arg = table.pack({...});
    local arg = {...}
    for i,v in ipairs(arg) do
        printResult = printResult .. tostring(v) .. "\t"
    end
    print_android("LuaPrint", printResult)
end
if cc.PLATFORM_OS_ANDROID == platform then
    print = printForAndroid
end