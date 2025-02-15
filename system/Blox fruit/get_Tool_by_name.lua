function GetToolByName(Name)
    local Cached = Module.Cached.Tools[Name]
    if Cached and (Cached.Parent == Player.Character or Cached.Parent == Player.Backpack) then
        return Cached
    end
    if Player.Character then
        local HasTool = Player.Character:FindFirstChild(Name) or Player.Backpack:FindFirstChild(Name)
        if HasTool then
            Module.Cached.Tools[Name] = HasTool
            return HasTool
        end
    end
end
