-- Copyright © Platunov I. M., 2020 All rights reserved

SYSTEM = {}

AddCSLuaFile("shared.lua")
include("shared.lua")

SYSTEM.Start1Resistance = 10
SYSTEM.Start2Resistance = 0.1

function SYSTEM:Initialize()
	self:SetEngineAmperage(0)
	self.LastResistance = math.huge
end

function SYSTEM:SetEngineAmperage(amperage)
	self:SetNWVar("EngineAmperage",amperage)
end

function SYSTEM:Think(dt)
	local bus = self.Trolleybus
	local C = bus.Controls
	
	self.StartActive = bus:GetReverseState()!=0 and C.StartPedal
	self.BrakeActive = bus:GetReverseState()!=0 and C.BrakePedal>0
	
	local br = self.BrakeActive and C.BrakePedal or 0
	
	self:SetNWVar("EngineAsGenerator",self.BrakeActive)
	
	if self:IsEngineAsGenerator() then
		self.EngineBrakeFraction = br
	end
end

function SYSTEM:GetResistance()
	local resistance = math.huge

	if self.StartActive and self.StartActive>0 then
		local engamp = self:GetNWVar("EngineAmperage",0)
		local res = math.Remap(self.StartActive,0,1,self.Start1Resistance,self.Start2Resistance)
		local minres = self.LastResistance*engamp/450

		resistance = minres!=minres and self.Start1Resistance or math.max(res,minres)
	end

	self.LastResistance = resistance
	return resistance
end

function SYSTEM:GetEngineBrakeFraction()
	return self.EngineBrakeFraction or 0
end

function SYSTEM:ControlPedals(ply,dt,C,OC)
	Trolleybus_System.GetControlScheme("bus_pedals")(ply,dt,C,OC)
end

Trolleybus_System.RegisterSystem("TRSU",SYSTEM)
SYSTEM = nil