//
// Hook
//

// Ready
if (!linvChar) then
    hook.Add("InitPostEntity", "plyDataSaver:InitPostEntity", function()
        plyDataSaver.sendNet("clientReady")
    end)
end