-- sv_dossiers.lua

util.AddNetworkString("ISU_OpenDossier")
util.AddNetworkString("ISU_SubmitDossier")
util.AddNetworkString("ISU_RequestDossier")
util.AddNetworkString("ISU_UpdateFlag")
util.AddNetworkString("ISU_SubmitMetadata")
util.AddNetworkString("ISU_SyncFlags")
util.AddNetworkString("ISU_RequestAllDossierKeys")
util.AddNetworkString("ISU_AllDossierKeys")
util.AddNetworkString("ISU_RequestExport")

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

function ISU_BroadcastFlags()
    local flags = {}
    for charID, data in pairs(ISU_Dossiers) do
        if istable(data) and data._flag then
            flags[charID] = data._flag
        end
    end

    net.Start("ISU_SyncFlags")
    net.WriteTable(flags)
    net.Broadcast()
end

net.Receive("ISU_SubmitDossier", function(_, ply)
    local teamName = team.GetName(ply:Team())
    if not ISU_Config.CombineTeams[teamName] then return end

    local charID = net.ReadString()
    local entry = net.ReadTable()

    ISU_Dossiers[charID] = ISU_Dossiers[charID] or {}

    if not ISU_Dossiers[charID]._initialized then
        ISU_Dossiers[charID]._initialized = true
        hook.Run("ISU_DossierCreated", ply, charID)
    end

    table.insert(ISU_Dossiers[charID], entry)
    SaveDossiers()
end)

net.Receive("ISU_RequestDossier", function(_, ply)
    local teamName = team.GetName(ply:Team())
    if not ISU_Config.CombineTeams[teamName] then return end

    local charID = net.ReadString()
    local data = ISU_Dossiers[charID] or {}

    net.Start("ISU_OpenDossier")
    net.WriteTable(data)
    net.Send(ply)
end)

net.Receive("ISU_UpdateFlag", function(_, ply)
    local teamName = team.GetName(ply:Team())
    if not ISU_Config.CombineTeams[teamName] then return end

    local charID = net.ReadString()
    local newFlag = net.ReadString()

    ISU_Dossiers[charID] = ISU_Dossiers[charID] or {}
    local oldFlag = ISU_Dossiers[charID]._flag

    ISU_Dossiers[charID]._flag = newFlag
    SaveDossiers()
    ISU_BroadcastFlags()

    hook.Run("ISU_FlagChanged", ply, charID, newFlag, oldFlag)

    file.Append(ISU_Config.DataPath .. "logs/dossier_history.txt",
        os.date() .. " - " .. ply:Nick() .. " set flag for " .. charID .. ": " .. newFlag .. "\n")
end)

net.Receive("ISU_SubmitMetadata", function(_, ply)
    local teamName = team.GetName(ply:Team())
    if not ISU_Config.CombineTeams[teamName] then return end

    local charID = net.ReadString()
    local faction = net.ReadString()
    local location = net.ReadString()
    local comment = net.ReadString()

    ISU_Dossiers[charID] = ISU_Dossiers[charID] or {}
    ISU_Dossiers[charID]._meta = {
        faction = faction,
        location = location,
        comment = comment
    }

    SaveDossiers()

    file.Append(ISU_Config.DataPath .. "logs/dossier_history.txt",
        os.date() .. " - " .. ply:Nick() .. " updated metadata for " .. charID .. "\n")
end)

net.Receive("ISU_RequestAllDossierKeys", function(_, ply)
    local teamName = team.GetName(ply:Team())
    if not ISU_Config.CombineTeams[teamName] then return end

    local list = {}
    for charID, data in pairs(ISU_Dossiers) do
        list[charID] = {
            flag = data._flag or "UNFLAGGED",
            name = data._meta and data._meta.comment or nil -- Optional name/hint
        }
    end

    net.Start("ISU_AllDossierKeys")
    net.WriteTable(list)
    net.Send(ply)
end)

net.Receive("ISU_RequestExport", function(_, ply)
    local teamName = team.GetName(ply:Team())
    if not ISU_Config.CombineTeams[teamName] then return end

    local charID = net.ReadString()
    local data = ISU_Dossiers[charID]
    if not data then return end

    local out = {}
    table.insert(out, "ISU Dossier Export for " .. charID)
    if data._flag then table.insert(out, "Flag: " .. data._flag) end
    if data._meta then
        table.insert(out, "Faction: " .. (data._meta.faction or ""))
        table.insert(out, "Location: " .. (data._meta.location or ""))
        table.insert(out, "Comment: " .. (data._meta.comment or ""))
    end
    table.insert(out, "\nInterrogation Log:")
    for _, entry in ipairs(data) do
        if entry.time then
            table.insert(out, string.format("[%s] %s: %s", entry.time, entry.officer or "?", entry.notes or ""))
        end
    end

    file.CreateDir(ISU_Config.DataPath .. "logs/")
    file.Write(ISU_Config.DataPath .. "logs/" .. charID .. ".txt", table.concat(out, "\n"))
end)
