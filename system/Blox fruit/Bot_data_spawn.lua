local SpawnLocations = Module.SpawnLocations
local EnemyLocations = Module.EnemyLocations

local function NewSpawn(Part)
    local EnemyName = GetEnemyName(Part.Name)
    EnemyLocations[EnemyName] = EnemyLocations[EnemyName] or {}
    
    local EnemySpawn = Part.CFrame + Vector3.new(0, 25, 0)
    SpawnLocations[EnemyName] = Part
    
    if not table.find(EnemyLocations[EnemyName], EnemySpawn) then
        table.insert(EnemyLocations[EnemyName], EnemySpawn)
    end
end

for _, Spawn in EnemySpawns:GetChildren() do
    NewSpawn(Spawn)
end

table.insert(Connections, EnemySpawns.ChildAdded:Connect(NewSpawn))
