-- cl_surveillance.lua

local flaggedPlayers = {}
local alpha = 0
local lastTarget = nil
local lastFlag = nil
local fadeSpeed = 5

net.Receive("ISU_SyncFlags", function()
    flaggedPlayers = net.ReadTable() or {}
end)

hook.Add("HUDPaint", "ISU_SurveillanceOverlay", function()
    local ply = LocalPlayer()
    if not ISU_Config.CombineTeams[team.GetName(ply:Team())] then return end

    local tr = ply:GetEyeTrace()
    local target = tr.Entity

    if not IsValid(target) or not target:IsPlayer() then
        alpha = math.max(alpha - fadeSpeed, 0)
        return
    end
    if tr.HitPos:DistToSqr(ply:GetPos()) > 150000 then
        alpha = math.max(alpha - fadeSpeed, 0)
        return
    end

    local steamID = target:SteamID64()
    local flag = flaggedPlayers[steamID] or "UNFLAGGED"
    local color = Color(200, 200, 200)

    if flag == "WATCHLIST" then color = Color(255, 255, 100) end
    if flag == "WANTED" then color = Color(255, 150, 0) end
    if flag == "ANTI-CITIZEN" then color = Color(255, 50, 50) end

    -- Sound feedback when changing targets or flag changes
    if target ~= lastTarget or flag ~= lastFlag then
        if flag == "WATCHLIST" then surface.PlaySound("buttons/button3.wav") end
        if flag == "WANTED" then surface.PlaySound("buttons/button9.wav") end
        if flag == "ANTI-CITIZEN" then surface.PlaySound("ambient/alarms/klaxon1.wav") end
        lastTarget = target
        lastFlag = flag
    end

    alpha = math.min(alpha + fadeSpeed, 255)

    surface.SetAlphaMultiplier(alpha / 255)
    draw.SimpleTextOutlined("SUBJECT: " .. target:Nick(), "DermaLarge", ScrW()/2, ScrH()*0.25, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
    draw.SimpleTextOutlined("FLAG: " .. flag, "Trebuchet24", ScrW()/2, ScrH()*0.25 + 40, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
    surface.SetAlphaMultiplier(1)
end)
