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

@export var card_name: String = ""
@export var cost: int = 0
@export var power: int = 0
@export var keywords: Array[int] = []
@export_multiline var effect_text: String = ""
@export var art: Texture2D

# Opcional para expansión futura
@export var faction: String = ""
@export var rarity: String = "Common"
