# LocationData.gd
extends Resource
class_name LocationData


enum LocationEffect {
	NONE,
	FIRST_CARD_BONUS,
	DRAW_ON_REVEAL,
	REVEAL_POWER_BONUS,
	ONGOING_BUFF,
	LAST_BREATH_TRIGGER,
	BLEED_DAMAGE,
	CORRUPT_BUFF,
	RANDOM_POWER,
	COST_REDUCTION
}


@export var location_name: String = ""

# Guarda valores del enum
@export var effect_type: int = LocationEffect.NONE

# Parámetros configurables
@export var params: Dictionary = {}
