local FastAttack = {
    Distance = 50,
    attackMobs = true,
    attackPlayers = true,
    Equipped = nil,
    Debounce = 0,
    ComboDebounce = 0,
    ShootDebounce = 0,
    M1Combo = 0
}

function FastAttack:ShootInTarget(TargetPosition: Vector3): (nil)
    local Equipped = IsAlive(Player.Character) and Player.Character:FindFirstChildOfClass("Tool")
    if Equipped and Equipped.ToolTip == "Gun" then
        if Equipped:FindFirstChild("Cooldown") and (tick() - self.ShootDebounce) >= Equipped.Cooldown.Value then
            if self.ShootsFunctions[Equipped.Name] then
                return self.ShootsFunctions[Equipped.Name](self, Equipped, TargetPosition)
            end
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1);task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1);task.wait(0.05)
            self.ShootDebounce = tick()
        end
    end
end
