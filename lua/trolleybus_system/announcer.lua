if SERVER then
    util.AddNetworkString("Trolleybus_System.Announcer")
else
    Trolleybus_System.ActiveAnnouncements = Trolleybus_System.ActiveAnnouncements or {}

    net.Receive("Trolleybus_System.Announcer",function(len,ply)
        local bus = net.ReadEntity()
        if !(bus and bus.RenderClientEnts) then return end
        local msg = net.ReadString()
        local vol = net.ReadFloat()

        local CurSound = Trolleybus_System.ActiveAnnouncements[bus]
        if CurSound and msg~="_VOL" then
            Trolleybus_System.StopBassSound(bus,CurSound,true)
            if msg=="_S" or msg=="_STOP" then Trolleybus_System.ActiveAnnouncements[bus] = nil end
        end

        if bus.Speakers then
            for _,v in ipairs(bus.Speakers) do
                if msg == "_VOL" and v.m_Sound then
                    v.m_Sound.volume = vol
                else
                    Trolleybus_System.StopAllBassSounds(v)
                    
                    if msg == "_S" or msg == "_STOP" then
                        v.m_Sound = nil
                    else
                        v.m_Sound = Trolleybus_System.PlayBassSound(v,msg,250,vol)
                    end
                end
            end
        elseif msg=="_VOL" and CurSound then
            pcall(function()
                Trolleybus_System.BassSounds[bus][CurSound].volume = vol
            end)
        elseif !(msg=="_S" or msg=="_STOP") then
            Trolleybus_System.PlayBassSound(bus,msg,500,vol,false,nil,Vector())
            Trolleybus_System.ActiveAnnouncements[bus] = msg
        end
    end)
end