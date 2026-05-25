extends Control


const CardScene = preload(
	"res://game/scenes/cards/CardNode.tscn"
)


@export var player_id := 0

@export var hide_hand := false


var cards_in_hand: Array = []


@onready var hand_container = %HBoxContainer


func add_card(card_data: CardData):

	var card_node = CardScene.instantiate()

	hand_container.add_child(card_node)

	card_node.setup(card_data)

	cards_in_hand.append(card_node)

	card_node.card_released.connect(
		_on_card_released
	)

	if hide_hand:

		hide_card_visual(card_node)

	print(
		"Card added to hand: ",
		card_data.card_name
	)


func remove_card(card_node):

	if cards_in_hand.has(card_node):

		cards_in_hand.erase(card_node)


func hide_card_visual(card_node):

	card_node.modulate = Color.BLACK


func _on_card_released(card_node):

	print(
		"Card released: ",
		card_node.data.card_name
	)

	validate_card_play(card_node)


func validate_card_play(card_node):

	var mana_available = TurnManager.current_mana[player_id]

	var card_cost = card_node.data.cost

	print(
		"Mana available: ",
		mana_available
	)

	print(
		"Card cost: ",
		card_cost
	)

	if card_cost > mana_available:

		print("NOT ENOUGH MANA")

		card_node.global_position = card_node.original_position

		return

	var played = try_play_card(card_node)

	if played:

		print("Card played")

		TurnManager.spend_mana(
			player_id,
			card_cost
		)

		remove_card(card_node)

	else:

		print("Invalid location")

		card_node.global_position = card_node.original_position


func try_play_card(card_node) -> bool:

	var locations = get_tree().get_nodes_in_group(
		"location_slots"
	)

	for location in locations:

		var rect = Rect2(
			location.global_position,
			location.size
		)

		if rect.has_point(
			card_node.global_position
		):

			var success = location.add_card_to_location(
				card_node
			)

			if success:

				return true

	return false
