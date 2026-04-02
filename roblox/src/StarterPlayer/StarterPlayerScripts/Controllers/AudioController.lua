local AudioController = {}
AudioController.__index = AudioController

function AudioController.new()
	local self = setmetatable({}, AudioController)
	self.LastCue = ""
	return self
end

function AudioController:Init()
end

function AudioController:PlayCue(cueName)
	self.LastCue = cueName
end

return AudioController
