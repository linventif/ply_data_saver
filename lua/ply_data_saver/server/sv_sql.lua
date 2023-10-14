//
// SQL
//

// Create DB Stucture
hook.Add("LinvLib.SQL.Init", "plyDataSaver:SQL:Init", function()
    LinvLib.SQL.Query("CREATE TABLE IF NOT EXISTS plyDataSaver (steamID64 CHAR(255), charID INT, statistic TEXT, weapon TEXT, variable TEXT, position TEXT, aparence TEXT, other TEXT, PRIMARY KEY (steamID64, charID))")

    LinvLib.SQL.Query("SELECT * FROM plyDataSaver LIMIT 1", function(data)
        // Call Hook
        hook.Run("linv_plyDataSaver_SQL_Init", data)

        // Retro Compatibility
        if data[1] and not data[1].charID then
            LinvLib.SQL.Query("ALTER TABLE plyDataSaver ADD charID INT")
            LinvLib.SQL.Query("UPDATE plyDataSaver SET charID = 1")
            // move steamID64 and charID side by side to make them a primary key
            LinvLib.SQL.Query("ALTER TABLE plyDataSaver DROP PRIMARY KEY")
            LinvLib.SQL.Query("ALTER TABLE plyDataSaver ADD PRIMARY KEY (steamID64, charID)")
        end
    end)
end)