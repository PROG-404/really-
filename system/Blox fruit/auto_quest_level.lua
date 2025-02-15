function Custom.Level()
    local Quest = QuestManager:GetQuest()
    
    if not Quest then
      return nil
    end
    
    local Target = Quest.Enemy.Name
    local Position = Quest.Enemy.Position
    
    local EnemyName = QuestManager:VerifyQuest(Target)
    
    if EnemyName and IsBoss(EnemyName) then
      return KillBossByInfo(Bosses[EnemyName], EnemyName, false)
    end
    
    if EnemyName then
      local Enemy = GetEnemy(EnemyName)
      
      if Enemy and Enemy.PrimaryPart then
        Attack(Enemy, true)
        return `Custom Killing: {EnemyName}`
      else
        local QuestPosition = QuestManager:GetQuestPosition(Quest.Name)
        
        if #Position > 0 then
          Tween:NPCs(Position)
        elseif QuestPosition then
          MoveTo(QuestPosition + QuestManager._Position)
        end
        
        return `Custom Waiting for: {EnemyName}`
      end
    else
      return QuestManager:StartQuest(Quest.Name, Quest.Count, QuestManager:GetQuestPosition(Quest.Name))
    end
  end
  
  return Custom
end
