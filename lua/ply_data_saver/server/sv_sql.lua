//
// SQL
//

// Create DB Stucture
hook.Add("LinvLib.SQL.Init", "plyDataSaver:SQL:Init", function()
    LinvLib.SQL.Query("CREATE TABLE IF NOT EXISTS plyDataSaver (steamID64 CHAR(255), pos TEXT, ang TEXT, health INT, armor INT, team INT, model TEXT, bodyGroup TEXT, PRIMARY KEY (steamID64))")
end)

function plyDataSaver.savePlyData(ply)
    // Check if ply is valid
    if !IsValid(ply) || ply:IsBot() then return end

    // ID
    local steamID64 = ply:SteamID64()

    // Info
    local model = ply:GetModel()
    local team = ply:Team()
    local bodyGroup = util.TableToJSON(ply:GetBodyGroups())
    local health = ply:Health()
    local armor = ply:Armor()

    // Pos
    local pos = ply:GetPos()
    local tblPos = {x = pos.x, y = pos.y, z = pos.z}
    local jsonPos = util.TableToJSON(tblPos)

    // Ang
    local ang = ply:EyeAngles()
    local tblAng = {p = ang.p, y = ang.y, r = ang.r}
    local jsonAng = util.TableToJSON(tblAng)

    // Update
    LinvLib.SQL.Query("INSERT INTO plyDataSaver (steamID64, pos, ang, health, armor, team, model, bodyGroup) VALUES ('" .. steamID64 .. "', '" .. jsonPos .. "', '" .. jsonAng .. "', '" .. health .. "', '" .. armor .. "', '" .. team .. "', '" .. model .. "', '" .. bodyGroup .. "') ON DUPLICATE KEY UPDATE pos = '" .. jsonPos .. "', ang = '" .. jsonAng .. "', health = '" .. health .. "', armor = '" .. armor .. "', team = '" .. team .. "', model = '" .. model .. "', bodyGroup = '" .. bodyGroup .. "'")
end

function plyDataSaver.loadPlyData(ply)
    // Check if ply is valid
    if !IsValid(ply) || ply:IsBot() then return end

    // ID
    local steamID64 = ply:SteamID64()

    // Query
    LinvLib.SQL.Query("SELECT * FROM plyDataSaver WHERE steamID64 = '" .. steamID64 .. "'", function(data)
        // Check if data is valid
        if !data || !data[1] then return end

        // Data
        local data = data[1]

        // Pos & Ang
        local pos = util.JSONToTable(data.pos)
        pos = Vector(pos.x, pos.y, pos.z)
        local ang = util.JSONToTable(data.ang)

        // Model
        local model = data.model

        // Health
        local health = data.health

        // Armor
        local armor = data.armor

        // Team
        local team = data.team

        // BodyGroup
        local bodyGroup = util.JSONToTable(data.bodyGroup)

        // Load
        if plyDataSaver.Config.loadPos then
            local validPos = simpleUnstuck.findValidPos(pos)
            if (validPos) then ply:SetPos(validPos) end
        end

        if plyDataSaver.Config.loadAng then
            ply:SetEyeAngles(Angle(ang.p, ang.y, ang.r))
        end

        if plyDataSaver.Config.loadModel then
            ply:SetModel(model)
        end

        if plyDataSaver.Config.loadHealth then
            ply:SetHealth(health)
        end

        if plyDataSaver.Config.loadArmor then
            ply:SetArmor(armor)
        end

        if plyDataSaver.Config.loadTeam then
            ply:SetTeam(team)
        end

        if plyDataSaver.Config.loadBodyGroup then
            for k, v in pairs(bodyGroup) do
                ply:SetBodygroup(v.id, v.num)
            end
        end
    end);
end