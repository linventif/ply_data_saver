//
// Network
//

// Variables
local netName = "plyDataSaver"
local netTable = {
    ["clientReady"] = 0
}

// Send
function plyDataSaver.sendNet(id, args)
    net.Start(netName)
    net.WriteUInt(netTable[id], 8)
    net.WriteString(util.TableToJSON(args || {}))
    net.SendToServer()
end