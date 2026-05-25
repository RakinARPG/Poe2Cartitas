extends Node


signal locations_selected(locations)

signal power_changed(
	player_id,
	location_idx,
	new_power
)

signal game_winner_decided(winner_id)


const LocationData = preload(
	"res://game/cards/LocationData.gd"
)


const LOCATIONS_PATH := "res://game/cards/locations/"


var active_locations: Array = []


# POWER TRACKING
#
# power[player_id][location_idx]
#
var power := {
	0: [0, 0, 0],
	1: [0, 0, 0]
}


# BOARD STATE
#
# board_cards[player][location]
#
var board_cards := {
	0: [[], [], []],
	1: [[], [], []]
}


func setup_locations():

	var all_locations = load_all_locations()

	all_locations.shuffle()

	active_locations.clear()

	for i in range(3):

		active_locations.append(
			all_locations[i]
		)

	print("Locations selected:")

	for location in active_locations:

		print(location.location_name)

	locations_selected.emit(
		active_locations
	)


func load_all_locations() -> Array:

	var locations = []

	var dir = DirAccess.open(
		LOCATIONS_PATH
	)

	if dir == null:
		return locations

	dir.list_dir_begin()

	var file_name = dir.get_next()

	while file_name != "":

		if file_name.ends_with(".tres"):

			var path = (
				LOCATIONS_PATH
				+ file_name
			)

			var location = load(path)

			if location != null:

				locations.append(location)

		file_name = dir.get_next()

	dir.list_dir_end()

	return locations


func add_card_to_board(
	player_id: int,
	location_idx: int,
	card_node
):

	board_cards[player_id][location_idx].append(
		card_node
	)


func get_cards_at_location(
	player_id: int,
	location_idx: int
) -> Array:

	return board_cards[player_id][location_idx]


func add_power(
	player_id: int,
	location_idx: int,
	amount: int
):

	power[player_id][location_idx] += amount

	power_changed.emit(
		player_id,
		location_idx,
		power[player_id][location_idx]
	)

	print(
		"Player ",
		player_id,
		" gained ",
		amount,
		" power at location ",
		location_idx
	)


func get_power(
	player_id: int,
	location_idx: int
) -> int:

	return power[player_id][location_idx]


func get_winner(
	location_idx: int
) -> int:

	var p0 = power[0][location_idx]

	var p1 = power[1][location_idx]

	if p0 > p1:
		return 0

	if p1 > p0:
		return 1

	return -1


func calculate_final_winner() -> int:

	var player_0_wins := 0

	var player_1_wins := 0

	for i in range(3):

		var winner = get_winner(i)

		match winner:

			0:
				player_0_wins += 1

			1:
				player_1_wins += 1

	print(
		"Final Score: ",
		player_0_wins,
		" - ",
		player_1_wins
	)

	if player_0_wins > player_1_wins:

		print("PLAYER 0 WINS")

		game_winner_decided.emit(0)

		return 0

	if player_1_wins > player_0_wins:

		print("PLAYER 1 WINS")

		game_winner_decided.emit(1)

		return 1

	print("DRAW")

	game_winner_decided.emit(-1)

	return -1


func reset_board():

	power = {
		0: [0, 0, 0],
		1: [0, 0, 0]
	}

	board_cards = {
		0: [[], [], []],
		1: [[], [], []]
	}
