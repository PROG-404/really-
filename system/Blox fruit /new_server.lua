function Module:ServerHop(MaxPlayers: number?, Region: string?): (nil)
    MaxPlayers = MaxPlayers or self.SH_MaxPlrs or 8
    -- Region = Region or self.SH_Region or "Singapore"
    
    local ServerBrowser = ReplicatedStorage.__ServerBrowser
    
    for i = 1, 100 do
      local Servers = ServerBrowser:InvokeServer(i)
      for id,info in pairs(Servers) do
        if id ~= game.JobId and info["Count"] <= MaxPlayers then
          task.spawn(ServerBrowser.InvokeServer, ServerBrowser, "teleport", id)
        end
      end
    end
end
