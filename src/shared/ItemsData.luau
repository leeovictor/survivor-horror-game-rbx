local ReplicatedStorage = game:GetService("ReplicatedStorage")
export type ItemType = "Consumable" | "Equippable" | "Usable"

export type ItemBase = {
	name: string,
	key: string,
	type: ItemType,
	description: string,
	stackable: boolean,
	stackSize: number?,
	canBeDiscarded: boolean,
	icon: string,
}

export type ConsumableItem = ItemBase & {
	type: "Consumable",
}

export type EquippableItem = ItemBase & {
	type: "Equippable",
	tool: Tool,
}

export type UsableItem = ItemBase & {
	type: "Usable",
}

export type Item = ConsumableItem | EquippableItem | UsableItem

local ItemsData: {
	ItemsType: {
		Consumable: ItemType,
		Equippable: ItemType,
		Usable: ItemType,
	},
	Items: { [string]: Item },
} =
	{
		ItemsType = {
			Consumable = "Consumable" :: ItemType,
			Equippable = "Equippable" :: ItemType,
			Usable = "Usable" :: ItemType,
		},
		Items = {
			handgun_001 = {
				name = "Handgun",
				key = "handgun_001",
				type = "Equippable" :: ItemType,
				description = "A standard issue handgun.",
				stackable = false,
				canBeDiscarded = false,
				icon = "rbxassetid://1234567890",
				tool = ReplicatedStorage.Tools.Handgun :: Tool,
			},
		},
	}

return ItemsData
