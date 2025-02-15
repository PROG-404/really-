function EnableBuso()
    local Character = Player.Character
    local IsAlive = Module.IsAlive(Character)
    
    if Settings.AutoBuso and IsAlive and not Character:FindFirstChild("HasBuso") then
        if Character:HasTag("Buso") then
            Module.FireRemote("Buso")
        elseif Money.Value >= 25e3 then
            Module.FireRemote("BuyHaki", "Buso")
        end
    end
end
]]
