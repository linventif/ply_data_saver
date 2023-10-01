//
// Hook
//

// Ready
hook.Add("InitPostEntity", "plyDataSaver:InitPostEntity", function()
    plyDataSaver.sendNet("clientReady")
end)