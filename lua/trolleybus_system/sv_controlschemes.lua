Trolleybus_System.ControlSchemes = Trolleybus_System.ControlSchemes or {
    bus_pedals = function(ply,dt,C,OC)
        if Trolleybus_System.GetPlayerSetting(ply,"UseExternalPedals") then
            local startpedal = ply.TrolleybusDeviceInputData_startpedal
            local brakepedal = ply.TrolleybusDeviceInputData_brakepedal
        
            C.StartPedal = C.BrakePedal>0 and 0 or startpedal or C.StartPedal
            C.BrakePedal = brakepedal or C.BrakePedal
        elseif Trolleybus_System.GetPlayerSetting(ply,"TrP_Pedals") then
            if C.FullBrake or C.FullBrakeActive then
                C.StartPedal = 0
                C.BrakePedal = 1
                C.FullBrakeActive = !(C.WActive or C.SActive)
            else
                local pow = (C.Reset and 0.25) or (C.FastPedals and 1) or 0.5

                if C.SActive then
                    C.StartPedal = 0

                    if C.BrakePedal<pow then
                        C.BrakePedal = math.min(C.BrakePedal+dt*(C.FastPedals and 2 or 1),pow)
                    elseif C.BrakePedal>pow then
                        C.BrakePedal = math.max(C.BrakePedal-dt,pow)
                    end
                elseif C.WActive then
                    C.BrakePedal = 0

                    if C.StartPedal<pow then
                        C.StartPedal = math.min(C.StartPedal+dt*(C.FastPedals and 2 or 1),pow)
                    elseif C.StartPedal>pow then
                        C.StartPedal = math.max(C.StartPedal-dt,pow)
                    end
                else
                    C.StartPedal = (C.StartPedal>0 and C.FastPedals and !C.Reset) and 0.1 or 0

                    if !(C.Speed<1) or C.Reset then
                        C.BrakePedal = (C.BrakePedal>0 and C.FastPedals and !C.Reset) and 0.1 or 0
                    end
                end
            end
        else
            if C.FullBrake then
                C.StartPedal = 0
                C.BrakePedal = 1
            else
                if C.Reset then
                    if !OC.Reset then
                        C.StartPedal = 0
                        C.BrakePedal = 0
                    end
                elseif C.SActive then
                    C.StartPedal = 0
                    
                    C.BrakePedal = math.min(1,C.BrakePedal+dt/(C.FastPedals and 1 or 2))
                elseif C.WActive then
                    C.BrakePedal = 0
                    
                    C.StartPedal = math.min(1,C.StartPedal+dt/(C.FastPedals and 1 or 2))
                end
            end
        end
    end,
    ziu_pedals = function(ply,dt,C,OC)
        if Trolleybus_System.GetPlayerSetting(ply,"UseExternalPedals") then
            local startpedal = ply.TrolleybusDeviceInputData_startpedal
            local brakepedal = ply.TrolleybusDeviceInputData_brakepedal
        
            C.StartPedal = C.BrakePedal>0 and 0 or startpedal and startpedal*4 or C.StartPedal
            C.BrakePedal = brakepedal and brakepedal*3 or C.BrakePedal
        elseif Trolleybus_System.GetPlayerSetting(ply,"TrP_Pedals") then
            if C.FullBrake or C.FullBrakeActive then
                C.StartPedal = 0
                C.BrakePedal = 3
                C.FullBrakeActive = !(C.WActive or C.SActive)
            else 
                if C.SActive then
                   C.StartPedal = 0
                    
                    if C.Reset then
                        C.BrakePedal = 1
                    elseif C.BrakePedal<2 then
                        C. BrakePedal = 2
                    elseif C.FastPedals and C.BrakePedal<3 then
                        C.BrakePedal = math.min(C.BrakePedal+dt,3)
                    elseif !C.FastPedals and C.BrakePedal>2 then
                        C.BrakePedal = math.max(C.BrakePedal-dt,2)
                    end
                elseif C.WActive then
                    C.BrakePedal = 0
                    C.StartPedal = (C.Reset and 1) or (C.FastPedals and 4) or 2
                else
                    C.StartPedal = (C.StartPedal>0 and C.FastPedals and !C.Reset) and 1 or 0

                    if !(C.Speed<1) or C.Reset then
                        C.BrakePedal = (C.BrakePedal>0 and C.FastPedals and !C.Reset) and 1 or 0
                    end
                end
            end
        else
            if C.FullBrake then
                C.StartPedal = 0
                C.BrakePedal = 3
            else
                if C.Reset then
                    if !OC.Reset then
                        C.StartPedal = 0
                        C.BrakePedal = 0
                    end
                elseif C.SActive then
                    C.StartPedal = 0
                    
                    if !OC.SActive and C.BrakePedal<2 then
                        C.BrakePedal = C.FastPedals and 2.01 or math.min(2,C.BrakePedal+1)
                    elseif (C.BrakePedal>2 or C.BrakePedal==2 and !OC.SActive) and C.BrakePedal<3 then
                        C.BrakePedal = math.min(C.BrakePedal+dt/(C.FastPedals and 1 or 2),3)
                    end
                elseif C.WActive then
                    C.BrakePedal = 0
                
                    if C.StartPedal==0 and C.FastPedals then
                        C.StartPedal = 2
                    elseif !OC.WActive and C.StartPedal<4 then
                        C.StartPedal = math.min(4,C.StartPedal+1)
                    end
                end
            end
        end
    end,
}

function Trolleybus_System.GetControlScheme(type)
    return Trolleybus_System.ControlSchemes[type] or Trolleybus_System.ControlSchemes["bus_pedals"]
end
