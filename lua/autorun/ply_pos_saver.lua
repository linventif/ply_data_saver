//
// Loader
//

// Verif Required Lib and Version
if !LinvLib || LinvLib.Info.version < "0.3.5" then
    print(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
    print(" -                                                                                         - ")
    print(" -                      Linventif Library is outdated or not installed.                    - ")
    print(" -            Informations and Download Links : https://linv.dev/docs/#library             - ")
    print(" -                                                                                         - ")
    print(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
    return
end

// Variables
local folder = "ply_data_saver"
local name = "Player Data Saver"
local license = "CC BY-SA 4.0"
local version = "0.1.4"

plyDataSaver = {
    ["Config"] = {},
    ["Info"] = {
        ["name"] = name,
        ["version"] = version,
        ["folder"] = folder,
        ["license"] = license
    },
}

// Load Addon
LinvLib.Install[folder] = version
LinvLib.ShowAddonInfos(name, version, license)
LinvLib.LoadLocalizations(folder, name)
LinvLib.LoadAllFiles(folder, name)