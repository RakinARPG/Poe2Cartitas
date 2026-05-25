extends Node


signal effect_pushed(effect_data)

signal effect_started(effect_data)

signal effect_resolved(effect_data)

signal all_effects_resolved


var queue: Array[Dictionary] = []


enum EffectType {
	REVEAL,
	ONGOING,
	BLEED,
	LAST_BREATH,
	CORRUPT
}


func push_effect(
	type: int,
	source_card,
	target_location,
	params := {}
):

	var effect_data := {
		"type": type,
		"source_card": source_card,
		"target_location": target_location,
		"params": params
	}

	queue.append(effect_data)

	effect_pushed.emit(effect_data)

	print(
		"Effect queued: ",
		EffectType.keys()[type]
	)


func resolve_all():

	print("Resolving effects...")

	resolve_phase(EffectType.REVEAL)

	resolve_ongoing_board()

	resolve_phase(EffectType.BLEED)

	resolve_phase(EffectType.LAST_BREATH)

	resolve_phase(EffectType.CORRUPT)

	print("All effects resolved")

	all_effects_resolved.emit()

	queue.clear()


func resolve_phase(effect_type: int):

	for effect_data in queue:

		if effect_data["type"] != effect_type:
			continue

		effect_started.emit(effect_data)

		match effect_type:

			EffectType.REVEAL:
				_resolve_reveal(effect_data)

			EffectType.ONGOING:
				_resolve_ongoing(effect_data)

			EffectType.BLEED:
				_resolve_bleed(effect_data)

			EffectType.LAST_BREATH:
				_resolve_last_breath(effect_data)

			EffectType.CORRUPT:
				_resolve_corrupt(effect_data)

		effect_resolved.emit(effect_data)


func _resolve_reveal(effect_data: Dictionary):

	var card = effect_data["source_card"]

	var location_idx = (
		effect_data["target_location"]
	)

	print(
		"[REVEAL] ",
		card.data.card_name
	)

	match card.data.effect_id:

		CardData.EffectId.DRAW_CARD:

			resolve_draw_card(card)

		CardData.EffectId.GAIN_POWER:

			resolve_gain_power(
				card,
				location_idx
			)

		CardData.EffectId.APPLY_BLEED:

			print("Apply Bleed")

		CardData.EffectId.CORRUPT_SELF:

			print("Corrupt Self")


func resolve_draw_card(card):

	var hand_managers = (
		get_tree().get_nodes_in_group(
			"hand_manager"
		)
	)

	for hand in hand_managers:

		if hand.player_id == card.owner_player_id:

			var drawn_card = (
				DeckManager.draw_card()
			)

			if drawn_card != null:

				hand.add_card(drawn_card)

				print(
					"Player drew a card"
				)

			break


func resolve_gain_power(
	card,
	location_idx: int
):

	LocationManager.add_power(
		card.owner_player_id,
		location_idx,
		card.data.effect_value
	)

	print(
		"Gain power: ",
		card.data.effect_value
	)


func resolve_ongoing_board():

	for player_id in [0, 1]:

		for location_idx in range(3):

			var cards = (
				LocationManager
				.get_cards_at_location(
					player_id,
					location_idx
				)
			)

			for card in cards:

				if card.data.keywords.has(
					CardData.Keyword.ONGOING
				):

					_resolve_ongoing_card(
						card,
						location_idx
					)


func _resolve_ongoing_card(
	card,
	location_idx: int
):

	print(
		"[ONGOING] ",
		card.data.card_name
	)

	# TEST:
	# ongoing grants +1 each turn

	LocationManager.add_power(
		card.owner_player_id,
		location_idx,
		1
	)


func _resolve_ongoing(effect_data: Dictionary):

	var card = effect_data["source_card"]

	print(
		"[ONGOING] ",
		card.data.card_name
	)


func _resolve_bleed(effect_data: Dictionary):

	var card = effect_data["source_card"]

	print(
		"[BLEED] ",
		card.data.card_name
	)

	# FUTURE:
	#
	# bleed stacks
	# damage over time
	# execute effects


func _resolve_last_breath(effect_data: Dictionary):

	var card = effect_data["source_card"]

	print(
		"[LAST BREATH] ",
		card.data.card_name
	)

	# FUTURE:
	#
	# death triggers
	# summons
	# revive mechanics


func _resolve_corrupt(effect_data: Dictionary):

	var card = effect_data["source_card"]

	print(
		"[CORRUPT] ",
		card.data.card_name
	)

	# FUTURE:
	#
	# random modifiers
	# mutations
	# unstable effects
