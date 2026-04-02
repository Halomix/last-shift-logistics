local serviceOrder = {
	"WorldStateService",
	"ProgressionService",
	"VehicleService",
	"RouteService",
	"EconomyService",
	"DeliveryService",
	"AmbientLifeService",
	"ContractService"
}

local servicesFolder = script.Parent:WaitForChild("Services")
local registry = {}

for _, serviceName in ipairs(serviceOrder) do
	local module = require(servicesFolder:WaitForChild(serviceName))
	registry[serviceName] = module.new()
end

for _, serviceName in ipairs(serviceOrder) do
	local service = registry[serviceName]
	if service.Init then
		service:Init(registry)
	end
end

_G.LastShiftLogisticsServer = registry
