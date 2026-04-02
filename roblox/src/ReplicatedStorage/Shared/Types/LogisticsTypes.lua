local Types = {}

export type Stage = {
	NodeId: string,
	Label: string,
	Role: string
}

export type Assignment = {
	ContractId: string,
	Status: string,
	AcceptedAt: number,
	StartedAt: number,
	CurrentStageIndex: number,
	Stages: { Stage },
	BoardModifierId: string,
	FeaturedDistrictId: string,
	PartySlots: { number },
	Capacity: number
}

export type Profile = {
	Credits: number,
	DeliveriesCompleted: number,
	Reputation: number,
	CompanyLevel: number,
	VehicleTier: string,
	DispatchStreak: number,
	DistrictMastery: { [string]: number }
}

return Types
