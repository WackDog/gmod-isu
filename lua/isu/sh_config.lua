--sh_config.lua

ISU_Config = {}
ISU_Config.DataPath = "isu/"
ISU_Config.CombineTeams = {
    ["Combine"] = true,
    ["OTA"] = true
}


-- File: lua/isu/sv_dossiers.lua
util.AddNetworkString("ISU_OpenDossier")
util.AddNetworkString("ISU_SubmitDossier")

ISU_Dossiers = ISU_Dossiers or {}

local function SaveDossiers()
    file.CreateDir(ISU_Config.DataPath)
    file.Write(ISU_Config.DataPath .. "dossiers.json", util.TableToJSON(ISU_Dossiers, true))
end

local function LoadDossiers()
    if file.Exists(ISU_Config.DataPath .. "dossiers.json", "DATA") then
        ISU_Dossiers = util.JSONToTable(file.Read(ISU_Config.DataPath .. "dossiers.json", "DATA")) or {}
    end
end

hook.Add("Initialize", "ISU_LoadDossiers", LoadDossiers)

net.Receive("ISU_SubmitDossier", function(len, ply)
    if not table.HasValue(ISU_Config.AdminRanks, ply:GetUserGroup()) then return end

    local charID = net.ReadString()
    local entry = net.ReadTable()

    ISU_Dossiers[charID] = ISU_Dossiers[charID] or {}
    table.insert(ISU_Dossiers[charID], entry)

    SaveDossiers()
end)