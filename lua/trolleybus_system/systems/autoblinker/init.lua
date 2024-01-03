-- A simple system to automatically reset turn signal when steering wheel is centered

SYSTEM = {}

AddCSLuaFile("shared.lua")
include("shared.lua")

function SYSTEM:Initialize()
	self.Switch = false
end

function SYSTEM:Think(dt)
	local bus = self.Trolleybus
	local C = bus.Controls
	local steer = math.abs(C.Steer)

	if steer < 0.05 and self.Switch then
		if self.mb then
			bus:SetMultiButton(self.mb,0)
		else
			bus:SetTurnSignal(0)
		end
		self.Switch = false
	elseif steer >= 0.175 and !self.Switch then
		self.Switch = true
	end
end

Trolleybus_System.RegisterSystem("BlinkerReset",SYSTEM)
SYSTEM = nil