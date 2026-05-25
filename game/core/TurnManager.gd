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


var current_turn := 1

var max_turns := 6


var mana: Array[int] = [
	1,
	2,
	3,
	4,
	5,
	6
]


var current_mana := {
	0: 0,
	1: 0
}


func start_game():

	current_turn = 1

	change_state(
		GameState.SETUP
	)

	print("GAME START")

	start_draw_phase()


func advance_turn():

	turn_ended.emit(
		current_turn
	)

	print(
		"TURN ENDED: ",
		current_turn
	)

	current_turn += 1

	if current_turn > max_turns:

		change_state(
			GameState.GAME_OVER
		)

		print("GAME OVER")

		game_over.emit()

		return

	start_draw_phase()


func get_current_mana(
	player_id: int
) -> int:

	return current_mana[player_id]


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

	change_state(
		GameState.DRAW
	)

	print("DRAW PHASE")

	draw_phase_started.emit(
		current_turn
	)

	draw_cards_for_players()

	start_planning_phase()


func draw_cards_for_players():
	var hands = get_tree().get_nodes_in_group("hand_manager")

	for hand in hands:
		# 🛑 FILTRO DE SEGURIDAD: Validar que la mano exista y esté lista
		if not is_instance_valid(hand) or hand.is_queued_for_deletion():
			print("⚠️ Alerta TurnManager: Se ignoró una instancia de mano inválida o en proceso de borrado.")
			continue

		# Validamos que el nodo realmente tenga la función para añadir cartas
		if not hand.has_method("add_card"):
			print("⚠️ Error TurnManager: El nodo '", hand.name, "' está en el grupo 'hand_manager' pero no tiene el método add_card()")
			continue

		# Si pasa los filtros, robamos y añadimos la carta de forma segura
		var card = DeckManager.draw_card()
		if card != null:
			hand.add_card(card)
		else:
			print("⚠️ Alerta TurnManager: El mazo se quedó sin cartas al intentar robar.")

func start_planning_phase():

	reset_mana()

	change_state(
		GameState.PLANNING
	)

	print("PLANNING PHASE")

	print(
		"Current Mana: ",
		current_mana[0]
	)

	turn_started.emit(
		current_turn
	)


func start_reveal_phase():
	change_state(GameState.REVEALING)
	print("REVEAL PHASE")

	var locations = get_tree().get_nodes_in_group("location_slots")

	# 1. Revelar cartas y acumular efectos en el resolver
	for location in locations:
		if is_instance_valid(location) and not location.is_queued_for_deletion():
			location.reveal_pending_cards()

	# 2. Resolver todos los efectos (aquí se altera el poder en el LocationManager)
	EffectResolver.resolve_all()

	# 3. 💥 NUEVO: Le pedimos a las localizaciones que refresquen su marcador visual
	# Ahora que los efectos ya se aplicaron en la lógica, la pantalla mostrará el número correcto.
	for location in locations:
		if is_instance_valid(location) and location.has_method("update_power_display"):
			location.update_power_display()

	# 4. Continuar el flujo normal
	start_resolving_phase()


func start_resolving_phase():

	change_state(
		GameState.RESOLVING
	)

	print("RESOLVING PHASE")

	# FUTURO:
	#
	# deaths
	# bleed ticks
	# ongoing cleanup
	# location triggers
	# destroy queue
	# summon queue

	advance_turn()


func change_state(
	new_state: GameState
):

	current_state = new_state

	state_changed.emit(
		current_state
	)

	print(
		"STATE CHANGED: ",
		GameState.keys()[current_state]
	)
