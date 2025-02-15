local Tween = {
    BodyVelocity = Instance.new("BodyVelocity")
}

function Tween:NoClipOnStepped(Character)
    if not IsAlive(Character) then
        return nil
    end
    if _ENV.OnFarm then
        for i = 1, #BaseParts do
            local BasePart = BaseParts[i]
            if CanCollideObjects[BasePart] and BasePart.CanCollide then
                BasePart.CanCollide = false
            end
        end
    end
end
