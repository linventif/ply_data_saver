//
// Hook
//

// Ready
hook.Add("InitPostEntity", "plyDataSaver:InitPostEntity", function()
    if (!linvChar) then
        plyDataSaver.sendNet("clientReady")
    end
end)