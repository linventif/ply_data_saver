//
// Network
//

// Variables
local netName = "plyDataSaver"
local netTable = {
    [0] = "clientReady"
}

// Add Network Strings
util.AddNetworkString(netName)

// Receive
net.Receive(netName, function(len, ply)
    local id = net.ReadUInt(8)
    local data = util.JSONToTable(net.ReadString())
    if (plyDataSaver["net"][netTable[id]]) then plyDataSaver["net"][netTable[id]](ply, data) end
end)