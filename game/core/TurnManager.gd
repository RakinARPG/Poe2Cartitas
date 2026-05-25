extends Node


signal turn_started(turn_num)
signal turn_ended(turn_num)

signal game_over()

signal state_changed(new_state)

signal draw_phase_started(turn_num)


enum GameState {
	SETUP,
	DRAW,
	PLANNING,
	REVEALING,
	RESOLVING,
	GAME_OVER
}


var current_state: GameState = GameState.SETUP


var current_turn: int = 1

var max_turns: int = 6

var mana: Array[int] = [1, 2, 3, 4, 5, 6]
var current_mana := {
	0: 0,
	1: 0
}


func start_game():

	current_turn = 1

	change_state(GameState.SETUP)

	print("GAME START")

	start_draw_phase()


func advance_turn():

	turn_ended.emit(current_turn)

	print("TURN ENDED: ", current_turn)

	current_turn += 1

	if current_turn > max_turns:

		change_state(GameState.GAME_OVER)

		print("GAME OVER")

		game_over.emit()

		return

	start_draw_phase()


func get_current_mana(player_id: int) -> int:

	# luego puedes separar mana por jugador

	var index = clamp(
		current_turn - 1,
		0,
		mana.size() - 1
	)

	return mana[index]

func reset_mana():

	var mana_for_turn = mana[
			clamp(
				current_turn - 1,
				0,
				mana.size() - 1
			)
		]

	current_mana[0] = mana_for_turn

	current_mana[1] = mana_for_turn

	print(
		"Mana refreshed: ",
		mana_for_turn
	)


func spend_mana(
	player_id: int,
	amount: int
):

	current_mana[player_id] -= amount

	print(
		"Player ",
		player_id,
		" mana left: ",
		current_mana[player_id]
	)


func start_draw_phase():

	change_state(GameState.DRAW)

	print("DRAW PHASE")

	draw_phase_started.emit(current_turn)

	# FUTURO:
	#
	# HandManager.draw_card(0)
	# HandManager.draw_card(1)
	#
	# triggers:
	# on_draw
	# replace draw
	# corrupt draw
	# bleed draw
	# prophecy systems

	start_planning_phase()



func start_planning_phase():

	reset_mana()

	change_state(GameState.PLANNING)

	print("PLANNING PHASE")

	print(
		"Current Mana: ",
		current_mana[0]
	)

	turn_started.emit(current_turn)


func start_reveal_phase():

	change_state(GameState.REVEALING)

	print("REVEALING PHASE")

	# aquí luego:
	#
	# reveal cards in order
	# trigger reveal effects
	# reveal animations

	start_resolving_phase()


func start_resolving_phase():

	change_state(GameState.RESOLVING)

	print("RESOLVING PHASE")

	# aquí luego:
	#
	# EffectResolver.resolve_all()
	# deaths
	# ongoing
	# bleed
	# location effects

	advance_turn()


func change_state(new_state: GameState):

	current_state = new_state

	state_changed.emit(current_state)

	print(
		"STATE CHANGED: ",
		GameState.keys()[current_state]
	)
