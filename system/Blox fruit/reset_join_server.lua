-- اعاده الاتصال بنفس سيرفر 
function Module.Rejoin(): (nil)
    task.spawn(TeleportService.TeleportToPlaceInstance, TeleportService, game.PlaceId, game.JobId, Player)
end
