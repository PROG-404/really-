## Library 

```lua
here the library 
```
# Functions that help you build your own script

### Simulating clicking or pressing buttons

```lua
local VirtualInputManager = game:GetService("VirtualInputManager")
```

### Manage a collection of objects

```lua
local CollectionService = game:GetService("CollectionService")
```

### Store objects

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
```

### Transferring players from one place to another

```lua
local TeleportService = game:GetService("TeleportService")
```

### Control the main game episodes if it is running on a server or client

```lua
local RunService = game:GetService("RunService")
```
### Add, remove or deal with a player

```lua
local Players = game:GetService("Players")
```

### Improving things like event models, functions, etc

```lua
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
```

### An object is created

```lua
local Validator2 = Remotes:WaitForChild("Validator2")
```

### Subobject

```lua
local Validator = Remotes:WaitForChild("Validator")
```

### Interact with the event or its distant guest

```lua
local CommF = Remotes:WaitForChild("CommF_")
```

### He also interacted with the event or his guest and then dealt with her

```lua
local CommE = Remotes:WaitForChild("CommE")
```

### Access to the box

```lua
local ChestModels = workspace:WaitForChild("ChestModels")
```

### It is used as a reference point in the world, such as the zero or central point

```lua
local WorldOrigin = workspace:WaitForChild("_WorldOrigin")
```

### It is used to access sub-objects such as Player 1, Player 2, etc

```lua
local Characters = workspace:WaitForChild("Characters")
```

### Accessing Seabest 1 or Seabest 2 sub-objects

```lua
local SeaBeasts = workspace:WaitForChild("SeaBeasts")
```
