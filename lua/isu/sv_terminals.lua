-- sv_terminals.lua

util.AddNetworkString("ISU_InterrogationSubmit")

-- Submit Interrogation: adds Dossier to JSON
net.Receive("ISU_InterrogationSubmit", function(_, ply)
    if not table.HasValue(ISU_Config.AdminRanks, ply:GetUserGroup()) then return end

    local target = net.ReadEntity()
    local qna = net.ReadTable()
    if not IsValid(target) or not target:IsPlayer() then return end

    local charID = target:SteamID64() -- Replace with character ID if using multi-character system

    ISU_Dossiers[charID] = ISU_Dossiers[charID] or {}

    hook.Run("ISU_InterrogationStarted", ply, target)

    table.insert(ISU_Dossiers[charID], {
        time = os.date("%Y-%m-%d %H:%M:%S"),
        officer = ply:Nick(),
        notes = "Q: " .. qna.question .. " | A: " .. qna.answer
    })

    file.CreateDir("isu")
    file.Write("isu/dossiers.json", util.TableToJSON(ISU_Dossiers, true))
end)