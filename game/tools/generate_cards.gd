@tool
extends EditorScript

const CardData = preload(
	"res://game/cards/DataCard.gd"
)

const OUTPUT_PATH :="res://game/cards/generated/"


const PREFIXES = [
	"Vaal",
	"Eternal",
	"Karui",
	"Azmeri",
	"Corrupted",
	"Templar",
	"Ezomyte",
	"Blackguard",
	"Undying",
	"Nightfall",
	"Bloodbound",
	"Ashen",
	"Twilight",
	"Forgotten",
	"Wraeclast"
]


const UNITS = [
	"Marauder",
	"Witch",
	"Ranger",
	"Cultist",
	"Titan",
	"Executioner",
	"Beast",
	"Stalker",
	"Necromancer",
	"Archer",
	"Monk",
	"Abomination",
	"Priest",
	"Champion",
	"Warlock",
	"Brute",
	"Slayer",
	"Revenant",
	"Invoker",
	"Defiler"
]


func _run():

	randomize()

	DirAccess.make_dir_recursive_absolute(
		OUTPUT_PATH
	)

	for i in range(100):

		var card := generate_card()

		var file_name = (
			card.card_name
			.to_lower()
			.replace(" ", "_")
		)

		var save_path = OUTPUT_PATH + file_name + "_" + str(i) + ".tres"

		ResourceSaver.save(
			card,
			save_path
		)

	print("100 cartas generadas")


func generate_card() -> CardData:

	var card := CardData.new()

	# COST
	card.cost = generate_cost()

	# KEYWORDS
	card.keywords = generate_keywords(
		card.cost
	)

	# POWER
	card.power = generate_balanced_power(
		card.cost,
		card.keywords
	)

	# NAME
	card.card_name = generate_name(
		card.keywords
	)

	# EFFECT
	card.effect_text = generate_effect_text(
		card.keywords
	)

	return card


func generate_cost() -> int:

	var roll = randi_range(1, 100)

	# Muy comunes
	if roll <= 30:
		return 1

	if roll <= 55:
		return 2

	# Comunes
	if roll <= 75:
		return 3

	# Menos comunes
	if roll <= 88:
		return 4

	# Raras
	if roll <= 96:
		return 5

	# Muy raras
	return 6


func generate_keywords(
	cost: int
) -> Array[int]:

	var result: Array[int] = []

	var roll = randi_range(1, 100)

	# Más coste = más habilidades
	if roll <= (25 + cost * 8):

		var keyword = randi_range(1, 5)

		result.append(keyword)

	# Chance de doble keyword
	var double_keyword_chance := 0

	match cost:

		4:
			double_keyword_chance = 10

		5:
			double_keyword_chance = 25

		6:
			double_keyword_chance = 45

	if randi_range(
		1,
		100
	) <= double_keyword_chance:

		var second = randi_range(1, 5)

		if not result.has(second):

			result.append(second)

	return result


func generate_balanced_power(
	cost: int,
	keywords: Array[int]
) -> int:

	var power := cost * 2

	for keyword in keywords:

		match keyword:

			CardData.Keyword.REVEAL:
				power -= 1

			CardData.Keyword.ONGOING:
				power -= 2

			CardData.Keyword.LAST_BREATH:
				power -= 1

			CardData.Keyword.CORRUPT:
				power -= 1

			CardData.Keyword.BLEED:
				power -= 2

	power += randi_range(-1, 1)

	power = max(power, 1)

	return power


func generate_name(
	keywords: Array[int]
) -> String:

	var prefix = PREFIXES.pick_random()

	var unit = UNITS.pick_random()

	if keywords.has(
		CardData.Keyword.BLEED
	):
		prefix = "Blood"

	if keywords.has(
		CardData.Keyword.CORRUPT
	):
		prefix = "Corrupted"

	if keywords.has(
		CardData.Keyword.LAST_BREATH
	):
		prefix = "Undying"

	return prefix + " " + unit


func generate_effect_text(
	keywords: Array[int]
) -> String:

	if keywords.is_empty():

		return (
			"A warrior from Wraeclast."
		)

	var lines: Array[String] = []

	for keyword in keywords:

		match keyword:

			CardData.Keyword.REVEAL:

				lines.append(
					"Reveal: Draw 1 card."
				)

			CardData.Keyword.ONGOING:

				lines.append(
					"Ongoing: Adjacent allies gain +1 Power."
				)

			CardData.Keyword.LAST_BREATH:

				lines.append(
					"Last Breath: Summon a 1/1 Spirit."
				)

			CardData.Keyword.CORRUPT:

				lines.append(
					"Corrupt: Gains +2 Power after damage."
				)

			CardData.Keyword.BLEED:

				lines.append(
					"Bleed: Damage enemies over time."
				)

	return " ".join(lines)
