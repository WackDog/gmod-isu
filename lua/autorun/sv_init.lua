-- sv_init.lua

-- Shared Config
AddCSLuaFile("isu/sh_config.lua")
include("isu/sh_config.lua")

-- Client-side files
AddCSLuaFile("isu/cl_menu.lua")
AddCSLuaFile("isu/cl_surveillance.lua")

-- Server-side
if SERVER then
    include("isu/sv_dossiers.lua")
    include("isu/sv_terminals.lua")
end

-- Client-side
if CLIENT then
    include("isu/cl_menu.lua")
    include("isu/cl_surveillance.lua")
end
