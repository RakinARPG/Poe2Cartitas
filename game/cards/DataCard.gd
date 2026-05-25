extends Resource
class_name CardData


enum Keyword {
	NONE,
	REVEAL,
	ONGOING,
	LAST_BREATH,
	CORRUPT,
	BLEED
}


enum EffectId {
	NONE,
	DRAW_CARD,
	GAIN_POWER,
	APPLY_BLEED,
	CORRUPT_SELF
}


@export var card_name: String = ""

@export var cost: int = 0

@export var power: int = 0


@export var keywords: Array[int] = []


@export var effect_id: int = EffectId.NONE

@export var effect_value: int = 0


@export_multiline var effect_text: String = ""


@export var art: Texture2D


# FUTURE

@export var faction: String = ""

@export var rarity: String = "Common"
