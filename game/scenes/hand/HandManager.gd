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

	card_node.card_dropped.connect(
		_on_card_dropped
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

	card_node.queue_free()


func hide_card_visual(card_node):

	card_node.modulate = Color.BLACK


func _on_card_dropped(
	card_node,
	drop_position
):

	print(
		"Card dropped: ",
		card_node.data.card_name
	)

	validate_card_play(card_node)


func validate_card_play(card_node):

	var mana_available = TurnManager.get_current_mana(
			player_id
		)

	var card_cost = card_node.data.cost

	if card_cost > mana_available:

		print(
			"NOT ENOUGH MANA"
		)

		card_node.global_position = card_node.original_position

		return

	print(
		"Card can be played"
	)

	remove_card(card_node)

	# luego:
	#
	# BoardManager.play_card()
