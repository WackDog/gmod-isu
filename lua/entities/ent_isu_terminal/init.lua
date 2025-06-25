-- init.lua

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_combine/combine_interface001.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end
end

function ENT:Use(activator, caller)
    if not IsValid(caller) or not caller:IsPlayer() then return end
    if not table.HasValue(ISU_Config.AdminRanks, caller:GetUserGroup()) then
        caller:ChatPrint("[ISU] Access Denied.")
        return
    end

    net.Start("ISU_RequestDossier")
    net.WriteString(caller:SteamID64()) -- or let them choose a target in UI
    net.Send(caller)
end
