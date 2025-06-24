-- cl_surveillance.lua

local flaggedPlayers = {}

net.Receive("ISU_SyncFlags", function()
    flaggedPlayers = net.ReadTable() or {}
end)

hook.Add("HUDPaint", "ISU_SurveillanceOverlay", function()
    local ply = LocalPlayer()
    if not ISU_Config.CombineTeams[team.GetName(ply:Team())] then return end

    local tr = ply:GetEyeTrace()
    local target = tr.Entity

    if not IsValid(target) or not target:IsPlayer() then return end
    if tr.HitPos:DistToSqr(ply:GetPos()) > 150000 then return end -- ~387 units

    local steamID = target:SteamID64()
    local flag = flaggedPlayers[steamID] or "UNFLAGGED"
    local color = Color(200, 200, 200)

    if flag == "WATCHLIST" then color = Color(255, 255, 100) end
    if flag == "WANTED" then color = Color(255, 150, 0) end
    if flag == "ANTI-CITIZEN" then color = Color(255, 50, 50) end

    draw.SimpleTextOutlined("SUBJECT: " .. target:Nick(), "DermaLarge", ScrW()/2, ScrH()*0.25, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
    draw.SimpleTextOutlined("FLAG: " .. flag, "Trebuchet24", ScrW()/2, ScrH()*0.25 + 40, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
end)
