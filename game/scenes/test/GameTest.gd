extends Control


@onready var start_button = $CanvasLayer/VBoxContainer/StartGameButton
@onready var advance_button = $CanvasLayer/VBoxContainer/AdvanceTurnButton
@onready var add_effect_button = $CanvasLayer/VBoxContainer/AddEffectButton
@onready var resolve_button = $CanvasLayer/VBoxContainer/ResolveEffectsButton
@onready var winner_button = $CanvasLayer/VBoxContainer/TestWinnerButton
@onready var hand_manager = %HandManager
@onready var draw_button = %DrawCardButton

const LocationScene = preload(
	"res://game/scenes/board/LocationSlot.tscn"
)

@onready var locations_container = %LocationsContainer
var test_deck

const CardScene = preload(
	"res://game/scenes/cards/CardNode.tscn"
)

func _ready():

	print("GameTest Ready")
#temporal
	connect_buttons()
	test_deck = load(
	"res://game/cards/decks/deck_reveal.tres")
	DeckManager.load_deck(test_deck)
	LocationManager.setup_locations()
	setup_locations()
	
	for i in range(3):

		var card = DeckManager.draw_card()

		if card != null:

			hand_manager.add_card(card)
		
		
func connect_buttons():

	start_button.pressed.connect(
		_on_start_game_pressed
	)

	advance_button.pressed.connect(
		_on_advance_turn_pressed
	)

	add_effect_button.pressed.connect(
		_on_add_effect_pressed
	)

	resolve_button.pressed.connect(
		_on_resolve_effects_pressed
	)

	winner_button.pressed.connect(
		_on_test_winner_pressed
	)
	
	draw_button.pressed.connect(
		_on_draw_card_pressed
	)

func _on_start_game_pressed():

	print("START GAME")

	LocationManager.setup_locations()

	TurnManager.start_game()


func _on_advance_turn_pressed():

	print("ADVANCE TURN")

	TurnManager.start_reveal_phase()


func _on_add_effect_pressed():

	print("ADD EFFECT")

	var fake_card = {
		"card_name": "Test Card"
	}

	EffectResolver.push_effect(
		EffectResolver.EffectType.REVEAL,
		fake_card,
		null,
		{}
	)

	EffectResolver.push_effect(
		EffectResolver.EffectType.BLEED,
		fake_card,
		null,
		{}
	)

	EffectResolver.push_effect(
		EffectResolver.EffectType.LAST_BREATH,
		fake_card,
		null,
		{}
	)
	var drawn_card = DeckManager.draw_card()
	if drawn_card != null:
		print(
		"Card Drawn: ",
		drawn_card.card_name
		)

func _on_resolve_effects_pressed():

	print("RESOLVE EFFECTS")

	EffectResolver.resolve_all()


func _on_test_winner_pressed():

	print("TEST WINNER")

	LocationManager.add_power(
		0,
		0,
		10
	)

	LocationManager.add_power(
		1,
		1,
		10
	)

	LocationManager.add_power(
		0,
		2,
		10
	)

	LocationManager.calculate_final_winner()
	
func _on_draw_card_pressed():

	var card = DeckManager.draw_card()

	if card != null:

		hand_manager.add_card(card)
		
func setup_locations():

	for child in locations_container.get_children():

		child.queue_free()

	for i in range(3):

		var location = LocationScene.instantiate()

		locations_container.add_child(
			location
		)

		var location_data = LocationManager.active_locations[i]

		location.setup(
			location_data.location_name,
			i
		)
