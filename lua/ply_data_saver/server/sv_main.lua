//
// Function
//

//
// Getter
//

// Create Table plyDataSaver(steamID64, statistic, weapon, variable, position, aparence, other)
function plyDataSaver.GetStatistic(ply)
    return {
        ["frags"] = ply:Frags(),
        ["deaths"] = ply:Deaths()
    }
end

function plyDataSaver.GetWeapon(ply)
    local rtn = {}

    local weapons = ply:GetWeapons()
    for _, weapon in pairs(weapons) do
        local weaponName = weapon:GetClass()
        local ammo = weapon:Clip1()
        local ammoMax = weapon:GetMaxClip1()
        local ammo2 = weapon:Clip2()
        local ammo2Max = weapon:GetMaxClip2()
        local ammoReserve = ply:GetAmmoCount(weapon:GetPrimaryAmmoType())
        local ammoReserve2 = ply:GetAmmoCount(weapon:GetSecondaryAmmoType())

        if (ammoMax == -1) then continue end
        if (plyDataSaver.Config.blacklistWeapon[weaponName]) then continue end

        rtn[weaponName] = {
            ["ammo"] = ammo,
            ["ammoMax"] = ammoMax,
            ["ammo2"] = ammo2,
            ["ammo2Max"] = ammo2Max,
            ["ammoReserve"] = ammoReserve,
            ["ammoReserve2"] = ammoReserve2
        }
    end

    return rtn
end

function plyDataSaver.GetVariable(ply)
    return {
        ["health"] = ply:Health(),
        ["health_max"] = ply:GetMaxHealth(),
        ["armor"] = ply:Armor(),
        ["armor_max"] = ply:GetMaxArmor(),
        ["food"] = ply:GetNWInt("Energy") || 0,
        ["ammo"] = ply:GetAmmo(),
        ["team"] = ply:Team(),
        ["name"] = ply:GetName()
    }
end

function plyDataSaver.GetPosition(ply)
    return {
        ["pos"] = ply:GetPos(),
        ["ang"] = ply:GetAngles()
    }
end

function plyDataSaver.GetAparence(ply)
    return {
        ["model"] = ply:GetModel(),
        ["skin"] = ply:GetSkin(),
        ["bodygroup"] = ply:GetBodyGroups(),
        ["color"] = ply:GetColor(),
        ["size"] = ply:GetModelScale()
    }
end

function plyDataSaver.GetOther(ply)
    local rtn = {}

    return rtn
end

function plyDataSaver.savePlyData(ply)
    // Check if ply is valid
    if !IsValid(ply) || ply:IsBot() then return end

    // ID
    local steamID64 = ply:SteamID64()

    // Char ID
    local charID = ply:GetLinvCharID() || 1

    // Data
    local statistic = util.TableToJSON(plyDataSaver.GetStatistic(ply))
    local weapon = util.TableToJSON(plyDataSaver.GetWeapon(ply))
    local variable = util.TableToJSON(plyDataSaver.GetVariable(ply))
    local position = util.TableToJSON(plyDataSaver.GetPosition(ply))
    local aparence = util.TableToJSON(plyDataSaver.GetAparence(ply))

    // Update
    LinvLib.SQL.Query("UPDATE plyDataSaver SET statistic = '" .. statistic .. "', weapon = '" .. weapon .. "', variable = '" .. variable .. "', position = '" .. position .. "', aparence = '" .. aparence .. "' WHERE steamID64 = '" .. steamID64 .. "' AND charID = '" .. charID .. "'")

    // Call Hook
    hook.Run("linv_plyDataSaver_savePlyData", ply)
end

//
// Setter
//

function plyDataSaver.loadPlyData(ply)
    // Check if ply is valid
    if !IsValid(ply) || ply:IsBot() then return end

    // ID
    local steamID64 = ply:SteamID64()

    // Char ID
    local charID = ply:GetLinvCharID() || 1

    // Data
    LinvLib.SQL.Query("SELECT * FROM plyDataSaver WHERE steamID64 = '" .. steamID64 .. "' AND charID = '" .. charID .. "'", function(data)
        // Check if data is valid
        if !data || !data[1] then
            // Insert
            LinvLib.SQL.Query("INSERT INTO plyDataSaver (steamID64, charID) VALUES ('" .. steamID64 .. "', '" .. charID .. "')", function()
                hook.Run("linv_plyDataSaver_SQL_Init_Player", ply)
                plyDataSaver.savePlyData(ply)
            end)
            return
        end
        data = data[1]

        // Get data
        local statistic = util.JSONToTable(data["statistic"]) || {}
        local weapon = util.JSONToTable(data["weapon"]) || {}
        local variable = util.JSONToTable(data["variable"]) || {}
        local position = util.JSONToTable(data["position"]) || {}
        local aparence = util.JSONToTable(data["aparence"]) || {}

        // Update
        if plyDataSaver.Config.loadPos && position["pos"] && position["ang"] then
            local pos = simpleUnstuck.findValidPos(position["pos"])
            if (pos) then ply:SetPos(pos) end
            ply:SetAngles(position["ang"])
        end

        if plyDataSaver.Config.loadModel && aparence["model"] then
            ply:SetModel(aparence["model"])
        end

        if plyDataSaver.Config.loadSkin && aparence["skin"] then
            ply:SetSkin(aparence["skin"])
        end

        if plyDataSaver.Config.loadBodygroups && aparence["bodygroup"] then
            for _, bodygroup in pairs(aparence["bodygroup"]) do
                ply:SetBodygroup(bodygroup["id"], bodygroup["num"])
            end
        end

        if plyDataSaver.Config.loadColor && aparence["color"] then
            ply:SetColor(aparence["color"])
        end

        if plyDataSaver.Config.loadSize && aparence["size"] then
            ply:SetModelScale(aparence["size"])
        end

        if plyDataSaver.Config.loadWeapon && weapon then
            for weaponName, weaponData in pairs(weapon) do
                ply:Give(weaponName)
                local weapon = ply:GetWeapon(weaponName)
                weapon:SetClip1(weaponData["ammo"])
                weapon:SetClip2(weaponData["ammo2"])
                ply:SetAmmo(weaponData["ammoReserve"], weapon:GetPrimaryAmmoType())
                ply:SetAmmo(weaponData["ammoReserve2"], weapon:GetSecondaryAmmoType())
            end
        end

        if plyDataSaver.Config.loadName && variable["name"] then
            ply:SetName(variable["name"])
        end

        if plyDataSaver.Config.loadAmmo && variable["ammo"] then
            for ammoType, ammoCount in pairs(variable["ammo"]) do
                ply:SetAmmo(ammoCount, ammoType)
            end
        end

        if plyDataSaver.Config.loadTeam && variable["team"] then
            ply:SetTeam(variable["team"])
        end

        if plyDataSaver.Config.loadHealth && variable["health"] then
            ply:SetHealth(variable["health"])
        end

        if plyDataSaver.Config.loadArmor && variable["armor"] then
            ply:SetArmor(variable["armor"] or 0)
        end

        if plyDataSaver.Config.loadFood && variable["food"] then
            ply:SetNWInt("Energy", variable["food"])
        end

        if plyDataSaver.Config.loadTeam && variable["team"] then
            ply:SetTeam(variable["team"])
        end

        if plyDataSaver.Config.loadStat && statistic["frags"] && statistic["deaths"] then
            ply:SetFrags(statistic["frags"])
            ply:SetDeaths(statistic["deaths"])
        end

        // Call Hook
        hook.Run("linv_plyDataSaver_loadPlyData", ply, data)
    end)
end

plyDataSaver.net = plyDataSaver.net or {}
function plyDataSaver.net.clientReady(ply)
    -- if (ply.plyDataSaverLoaded) then return end
    plyDataSaver.loadPlyData(ply)
    ply.plyDataSaverLoaded = true
end