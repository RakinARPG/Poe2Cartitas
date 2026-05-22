@tool
extends EditorScript

const LocationData = preload(
	"res://game/cards/LocationData.gd"
)

const OUTPUT_PATH := "res://game/cards/locations/"


const LOCATION_PREFIXES = [
	"Vaal",
	"Karui",
	"Eternal",
	"Forbidden",
	"Ancient",
	"Corrupted",
	"Fallen",
	"Twilight",
	"Blood",
	"Forgotten",
	"Sunken",
	"Ashen"
]


const LOCATION_TYPES = [
	"Temple",
	"Ruins",
	"Catacombs",
	"Arena",
	"Sanctum",
	"Crypt",
	"Laboratory",
	"Fortress",
	"Vault",
	"Prison",
	"Citadel",
	"Necropolis"
]


func _run():

	randomize()

	DirAccess.make_dir_recursive_absolute(
		OUTPUT_PATH
	)

	for i in range(10):

		var location := generate_location()

		var file_name = (
			location.location_name
			.to_lower()
			.replace(" ", "_")
			+ "_" + str(i)
		)

		var save_path = (
			OUTPUT_PATH
			+ file_name
			+ ".tres"
		)

		ResourceSaver.save(location, save_path)

	print("10 locations generated")


func generate_location() -> LocationData:

	var location := LocationData.new()

	location.location_name = generate_name()

	location.effect_type = randi_range(1, 9)

	location.params = generate_params(
		location.effect_type
	)

	return location


func generate_name() -> String:

	var prefix = LOCATION_PREFIXES.pick_random()

	var type = LOCATION_TYPES.pick_random()

	return prefix + " " + type


func generate_params(
	effect_type: int
) -> Dictionary:

	var params := {}

	match effect_type:

		LocationData.LocationEffect.FIRST_CARD_BONUS:

			params = {
				"power_bonus": 2
			}

		LocationData.LocationEffect.DRAW_ON_REVEAL:

			params = {
				"cards_drawn": 1
			}

		LocationData.LocationEffect.REVEAL_POWER_BONUS:

			params = {
				"bonus_power": 3
			}

		LocationData.LocationEffect.ONGOING_BUFF:

			params = {
				"ongoing_bonus": 1
			}

		LocationData.LocationEffect.LAST_BREATH_TRIGGER:

			params = {
				"spawn_power": 2
			}

		LocationData.LocationEffect.BLEED_DAMAGE:

			params = {
				"damage": 1
			}

		LocationData.LocationEffect.CORRUPT_BUFF:

			params = {
				"corrupt_power": 2
			}

		LocationData.LocationEffect.RANDOM_POWER:

			params = {
				"min": -2,
				"max": 4
			}

		LocationData.LocationEffect.COST_REDUCTION:

			params = {
				"cost_reduction": 1
			}

		_:
			params = {}

	return params
