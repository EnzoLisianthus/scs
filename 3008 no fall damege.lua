local a = getrawmetatable(game)
local b = a.__namecall
setreadonly(a, false)
a.__namecall = newcclosure(function(name, ...)
       local muhammed = {...}
       if getnamecallmethod() == "FireServer" and tostring(name) == "RemoteEvent" and type(unpack(muhammed[1])) == "number" then
           muhammed[1] = 0
           muhammed[2] = true
           muhammed[3] = false
           muhammed[4] = nil
           muhammed[5] = 0
           muhammed[6] = 0
       end
       return b(name, unpack(muhammed))
   end)