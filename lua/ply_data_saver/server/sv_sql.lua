//
// SQL
//

// Create DB Stucture
hook.Add("LinvLib.SQL.Init", "plyDataSaver:SQL:Init", function()
    LinvLib.SQL.Query("CREATE TABLE IF NOT EXISTS plyDataSaver (steamID64 CHAR(255), charID INT DEFAULT 1, statistic TEXT DEFAULT '{}', weapon TEXT DEFAULT '{}', variable TEXT DEFAULT '{}', position TEXT DEFAULT '{}', aparence TEXT DEFAULT '{}', other TEXT DEFAULT '{}', PRIMARY KEY (steamID64, charID))", function()
        hook.Run("linv_plyDataSaver_SQL_Init")
    end)
end)