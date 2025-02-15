function Module.KillAura(Distance: number?, Name: string?): (nil)
    Distance = Distance or 500
    
    local EnemyList = Enemies:GetChildren()
    
    for i = 1, #EnemyList do
      local Enemy = EnemyList[i]
      local PrimaryPart = Enemy.PrimaryPart
      
      if (not Name or Enemy.Name == Name) and PrimaryPart and not Enemy:HasTag(KILLAURA_TAG) then
        if Module.IsAlive(Enemy) and Player:DistanceFromCharacter(PrimaryPart.Position) < Distance then
          Enemy:AddTag(KILLAURA_TAG)
        end
      end
    end
  end

-- use kill

function Module.KillAura(Distance: number?, Name: string?): (nil)
    Distance = Distance or 500
    
    local EnemyList = Enemies:GetChildren()
    
    for i = 1, #EnemyList do
      local Enemy = EnemyList[i]
      local PrimaryPart = Enemy.PrimaryPart
      
      if (not Name or Enemy.Name == Name) and PrimaryPart and not Enemy:HasTag(KILLAURA_TAG) then
        if Module.IsAlive(Enemy) and Player:DistanceFromCharacter(PrimaryPart.Position) < Distance then
          Enemy:AddTag(KILLAURA_TAG)
        end
      end
    end
  end
  
  function Module.IsBoss(Name: string): boolean
    return Module.Bosses[Name] and true or false
  end
  
  function Module.UseSkills(Target: any?, Skills: table?): (nil)
    if Player:DistanceFromCharacter(Target.Position) >= 60 then
      return nil
    end
    
    local Equipped = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
    local MasteryRequirements = Module.Inventory.MasteryRequirements
    
    if Equipped then
      local Level = Equipped:GetAttribute("Level") or 0
      local Mastery = MasteryRequirements[Equipped.Name]
      
      if Mastery == nil and Equipped:FindFirstChild("Data") then
        local Success, Requirements = pcall(require, Equipped.Data)
        
        if Success and type(Requirements) == "table" then
          MasteryRequirements[Equipped.Name] = Requirements.Lvl or false
        else
          MasteryRequirements[Equipped.Name] = false
        end
      end
      
      for Skill, Enabled in Skills do
        if Mastery and not Mastery[Skill] then continue end
        if Mastery and Level < Mastery[Skill] then continue end
        
        local Debounce = Module.Debounce.Skills[Skill]
        
        if Enabled and (not Debounce or (tick() - Debounce) >= HIDDEN_SETTINGS.SKILL_COOLDOWN) then
          VirtualInputManager:SendKeyEvent(true, Skill, false, game)
          VirtualInputManager:SendKeyEvent(false, Skill, false, game)
          Module.Debounce.Skills[Skill] = tick()
        end
      end
    end
  end
