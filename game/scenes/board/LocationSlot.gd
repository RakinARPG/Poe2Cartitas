extends Panel


var location_index := 0

var cards_played: Array = []


@onready var location_name_label = %LocationNameLabel

@onready var power_label = %PowerLabel

@onready var cards_container = %CardsContainer

const MAX_CARDS := 4

func _ready():

	add_to_group("location_slots")


func setup(
	location_name: String,
	index: int
):

	location_index = index

	location_name_label.text = location_name

	update_power_display()


func can_drop_data(
	_at_position,
	data
):

	return true


func drop_data(
	_at_position,
	data
):

	if data == null:

		return

	print("Card dropped on location")

	add_card_to_location(data)




func update_power_display():

	var total_power := 0

	for card in cards_played:

		total_power += card.data.power

	power_label.text = "Power: " + str(total_power)

func add_card_to_location(card_node) -> bool:

	if cards_played.size() >= MAX_CARDS:

		print("Location full")

		return false

	cards_played.append(card_node)

	card_node.reparent(cards_container)

	card_node.position = Vector2.ZERO

	card_node.scale = Vector2(0.7, 0.7)

	card_node.is_locked = true

	LocationManager.add_power(
		0,
		location_index,
		card_node.data.power
	)

	update_power_display()

	print(
		"Played card: ",
		card_node.data.card_name
	)

	return true
