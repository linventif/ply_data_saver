//
// SQL
//

// Create DB Stucture
hook.Add("LinvLib.SQL.Init", "plyDataSaver:SQL:Init", function()
    LinvLib.SQL.Query("CREATE TABLE IF NOT EXISTS plyDataSaver (steamID64 CHAR(255), statistic TEXT, weapon TEXT, variable TEXT, position TEXT, aparence TEXT, other TEXT, PRIMARY KEY (steamID64))")
end)