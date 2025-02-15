-- Make sure of a dead or present personality


function Module.IsAlive(Character)
    if Character then
        local Humanoids = Cached.Humanoids
        local Humanoid = Humanoids[Character] or GetCharacterHumanoid(Character)
        
        if Humanoid then
            if not Humanoids[Character] then
                Humanoids[Character] = Humanoid
            end
            return Humanoid[if Humanoid.ClassName == "Humanoid" then "Health" else "Value"] > 0
        end
    end
end
