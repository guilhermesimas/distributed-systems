--- Serializa
-- @param #table t table with parameters
-- @return #string in the form '{parameter1, parameter2, ...}'
M={}

function M.marshall(t)
    local s = '{'
    for i,v in ipairs(t) do
        if     (type(v) == "string") then s = s.."'"..v.."'"
        elseif (type(v) == "number") then s = s..v
        end

        if i ~= #t then s = s..',' end
    end
    return s..'}'
end

--- Desserializa
-- @param #string s encoded parameter list
-- @return #string table as array with parameters in order
function M.unmarshall(s)
    return load(s)()
end

-- name: function name
-- args: table with parameters
-- ret : string in the form 'return{`name`={args}}
function M.marshall_call(name, args)
    return 'return{'..name..'='..M.marshall(args)..'}'
end

-- in : string with encoded call
-- out: function name, table with parameters
function M.unmarshall_call(s)
    for call,params in pairs(M.unmarshall(s)) do
        return call, params
    end
end

function M.marshall_ret(t)
    return 'return'..M.marshall(t)
end

function M.unmarshall_ret(s)
    return M.unmarshall(s)
end

return M
