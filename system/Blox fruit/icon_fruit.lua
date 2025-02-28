      Module.FruitsId = {
      ["rbxassetid://15124425041"] = "Rocket-Rocket",
      ["rbxassetid://15123685330"] = "Spin-Spin",
      ["rbxassetid://15123613404"] = "Blade-Blade",
      ["rbxassetid://15123689268"] = "Spring-Spring",
      ["rbxassetid://15123595806"] = "Bomb-Bomb",
      ["rbxassetid://15123677932"] = "Smoke-Smoke",
      ["rbxassetid://15124220207"] = "Spike-Spike",
      ["rbxassetid://15123629861"] = "Flame-Flame",
      ["rbxassetid://15123627377"] = "Falcon-Falcon",
      ["rbxassetid://15100433167"] = "Ice-Ice",
      ["rbxassetid://15123673019"] = "Sand-Sand",
      ["rbxassetid://15123618591"] = "Dark-Dark",
      ["rbxassetid://15112600534"] = "Diamond-Diamond",
      ["rbxassetid://15123640714"] = "Light-Light",
      ["rbxassetid://15123668008"] = "Rubber-Rubber",
      ["rbxassetid://15100485671"] = "Barrier-Barrier",
      ["rbxassetid://15123662036"] = "Ghost-Ghost",
      ["rbxassetid://15123645682"] = "Magma-Magma",
      ["rbxassetid://15123606541"] = "Quake-Quake",
      ["rbxassetid://15123606541"] = "Buddha-Buddha",
      ["rbxassetid://15123643097"] = "Love-Love",
      ["rbxassetid://15123681598"] = "Spider-Spider",
      ["rbxassetid://15123679712"] = "Sound-Sound",
      ["rbxassetid://15123654553"] = "Phoenix-Phoenix",
      ["rbxassetid://15123656798"] = "Portal-Portal",
      ["rbxassetid://15123670514"] = "Rumble-Rumble",
      ["rbxassetid://15123652069"] = "Pain-Pain",
      ["rbxassetid://15123587371"] = "Blizzard-Blizzard",
      ["rbxassetid://15123633312"] = "Gravity-Gravity",
      ["rbxassetid://15123648309"] = "Mammoth-Mammoth",
      ["rbxassetid://15708895165"] = "T-Rex-T-Rex",
      ["rbxassetid://15123624401"] = "Dough-Dough",
      ["rbxassetid://15123675904"] = "Shadow-Shadow",
      ["rbxassetid://10773719142"] = "Venom-Venom",
      ["rbxassetid://15123616275"] = "Control-Control",
      ["rbxassetid://11911905519"] = "Spirit-Spirit",
      ["rbxassetid://15123638064"] = "Leopard-Leopard",
      ["rbxassetid://15487764876"] = "Kitsune-Kitsune",
      ["rbxassetid://115276580506154"] = "Yeti-Yeti",
      ["rbxassetid://118054805452821"] = "Gas-Gas",
      ["rbxassetid://95749033139458"] = "Dragon East-Dragon East"
    }
    

-- name for fruit 

name fruit sestym 
    Module.FruitsName = setmetatable({}, {
    __index = function(self, Fruit)
      local RealFruitsName = Module.FruitsId
      local Name = Fruit.Name
      
      if Name ~= "Fruit " then
        rawset(self, Fruit, Name)
        return Name
      end
      
      rawset(self, Fruit, "Fruit [ ??? ]")
      
      local Model = Fruit:WaitForChild("Fruit", 9e9)
      local Idle = FastWait(2, Model, "Idle") or FastWait(1, Model, "Animation") or FastWait(1, Model, "Fruit")
      
      if Idle and (Idle:IsA("Animation") or Idle:IsA("MeshPart")) then
        local Property = if Idle:IsA("MeshPart") then "MeshId" else "AnimationId"
        local RealName = RealFruitsName[Idle[Property] or ""]
        
        if RealName and type(RealName) == "string" then
          rawset(self, Fruit, `Fruit [ {RealName} ]`)
        end
      end
      
      return rawget(self, Fruit)
    end
  })
