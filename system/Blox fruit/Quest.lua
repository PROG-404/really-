function Module.RunFunctions.Quests(self, QuestsModule, getTasks)
    local MaxLvl = ({ {0, 700}, {700, 1500}, {1500, math.huge} })[self.Sea]
    local bl_Quests = {"BartiloQuest", "MarineQuest", "CitizenQuest"}
    for name, task in QuestsModule do
        if table.find(bl_Quests, name) then continue end
        for num, mission in task do
            local Level = mission.LevelReq
            if Level >= MaxLvl[1] and Level < MaxLvl[2] then
                local target, positions = getTasks(mission)
                table.insert(self.QuestList, {
                    Name = name,
                    Count = num,
                    Enemy = { Name = target, Level = Level, Position = positions }
                })
            end
        end
    end
    table.sort(self.QuestList, function(v1, v2) return v1.Enemy.Level < v2.Enemy.Level end)
end
