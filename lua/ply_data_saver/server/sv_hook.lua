//
// Hook
//

hook.Add("PlayerDisconnected", "plyDataSaver:SavePlayerData", function(ply)
    plyDataSaver.savePlyData(ply)
end)

hook.Add("ShutDown", "plyDataSaver:SaveAllPlayerData", function()
    for _, ply in ipairs(player.GetAll()) do
        plyDataSaver.savePlyData(ply)
    end
end)

hook.Add("PlayerLoadout", "plyDataSaver:loadPlyData", function(ply)
    if (ply.plyDataSaverLoaded) then return end
    plyDataSaver.loadPlyData(ply)
    ply.plyDataSaverLoaded = true
end)