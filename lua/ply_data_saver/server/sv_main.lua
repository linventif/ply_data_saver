//
// Function
//

//
// Getter
//

// Create Table plyDataSaver(steamID64, statistic, weapon, variable, position, aparence, other)
function plyDataSaver.GetStatistic(ply)
    local rtn = {}

    local frag = ply:Frags()
    local death = ply:Deaths()

    rtn = {
        ["frags"] = frag,
        ["deaths"] = death
    }

    return rtn
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
    local rtn = {}

    local health = ply:Health()
    local health_max = ply:GetMaxHealth()

    local armor = ply:Armor()
    local armor_max = ply:GetMaxArmor()

    local energy = ply:GetNWInt("Energy") or 0
    local ammo = ply:GetAmmo()

    rtn = {
        ["health"] = health,
        ["health_max"] = health_max,
        ["armor"] = armor,
        ["armor_max"] = armor_max,
        ["food"] = energy,
        ["ammo"] = ammo,
        ["team"] = ply:Team()
    }

    return rtn
end

function plyDataSaver.GetPosition(ply)
    local rtn = {}

    local pos = ply:GetPos()
    local ang = ply:GetAngles()

    rtn = {
        ["pos"] = pos,
        ["ang"] = ang
    }

    return rtn
end

function plyDataSaver.GetAparence(ply)
    local rtn = {}

    local model = ply:GetModel()
    local skin = ply:GetSkin()
    local bodygroup = ply:GetBodyGroups()

    rtn = {
        ["model"] = model,
        ["skin"] = skin,
        ["bodygroup"] = bodygroup,
        ["color"] = ply:GetColor(),
        ["size"] = ply:GetModelScale()
    }

    return rtn
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

    // Data
    local statistic = util.TableToJSON(plyDataSaver.GetStatistic(ply))
    local weapon = util.TableToJSON(plyDataSaver.GetWeapon(ply))
    local variable = util.TableToJSON(plyDataSaver.GetVariable(ply))
    local position = util.TableToJSON(plyDataSaver.GetPosition(ply))
    local aparence = util.TableToJSON(plyDataSaver.GetAparence(ply))
    local other = util.TableToJSON(plyDataSaver.GetOther(ply))

    // Update
    LinvLib.SQL.Query("UPDATE plyDataSaver SET statistic = '" .. statistic .. "', weapon = '" .. weapon .. "', variable = '" .. variable .. "', position = '" .. position .. "', aparence = '" .. aparence .. "', other = '" .. other .. "' WHERE steamID64 = '" .. steamID64 .. "'")
end

//
// Setter
//

function plyDataSaver.loadPlyData(ply)
    // Check if ply is valid
    if !IsValid(ply) || ply:IsBot() then return end

    // ID
    local steamID64 = ply:SteamID64()

    // Data
    LinvLib.SQL.Query("SELECT * FROM plyDataSaver WHERE steamID64 = '" .. steamID64 .. "'", function(data)
        // Check if data is valid
        if !data then
            // Insert
            LinvLib.SQL.Query("INSERT INTO plyDataSaver (steamID64, statistic, weapon, variable, position, aparence, other) VALUES ('" .. steamID64 .. "', '[]', '[]', '[]', '[]', '[]', '[]')")
            plyDataSaver.savePlyData(ply)
            return
        end
        data = data[1]

        // Get data
        local statistic = util.JSONToTable(data["statistic"]) or {}
        local weapon = util.JSONToTable(data["weapon"]) or {}
        local variable = util.JSONToTable(data["variable"]) or {}
        local position = util.JSONToTable(data["position"]) or {}
        local aparence = util.JSONToTable(data["aparence"]) or {}
        local other = util.JSONToTable(data["other"]) or {}

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
    end)
end

plyDataSaver.net = plyDataSaver.net or {}
function plyDataSaver.net.clientReady(ply)
    if (ply.plyDataSaverLoaded) then return end
    plyDataSaver.loadPlyData(ply)
    ply.plyDataSaverLoaded = true
end