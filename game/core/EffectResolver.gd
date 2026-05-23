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

	resolve_phase(EffectType.ONGOING)

	resolve_phase(EffectType.BLEED)

	resolve_phase(EffectType.LAST_BREATH)

	resolve_phase(EffectType.CORRUPT)

	print("All effects resolved")

	all_effects_resolved.emit()

	queue.clear()


func resolve_phase(effect_type: int):

	for effect_data in queue:

		if effect_data.type != effect_type:
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

	var card = effect_data.source_card

	print(
		"[REVEAL] ",
		card.card_name
	)

	# Ejemplo futuro:
	# draw cards
	# reveal buffs
	# location triggers


func _resolve_ongoing(effect_data: Dictionary):

	var card = effect_data.source_card

	print(
		"[ONGOING] ",
		card.card_name
	)

	# buffs permanentes
	# aura effects
	# lane modifiers


func _resolve_bleed(effect_data: Dictionary):

	var card = effect_data.source_card

	print(
		"[BLEED] ",
		card.card_name
	)

	# daño over time
	# execute
	# spread bleed


func _resolve_last_breath(effect_data: Dictionary):

	var card = effect_data.source_card

	print(
		"[LAST BREATH] ",
		card.card_name
	)

	# summon tokens
	# death triggers
	# revive


func _resolve_corrupt(effect_data: Dictionary):

	var card = effect_data.source_card

	print(
		"[CORRUPT] ",
		card.card_name
	)

	# mutate
	# gain power
	# unstable effects
