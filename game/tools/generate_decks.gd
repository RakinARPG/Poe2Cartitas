@tool
extends EditorScript

const DeckConfig = preload("res://game/cards/DeckConfig.gd")
const CardData = preload("res://game/cards/DataCard.gd")

const CARDS_PATH := "res://game/cards/generated/"
const OUTPUT_PATH := "res://game/cards/decks/"

const DECK_SIZE := 12

func _run():
	randomize()

	DirAccess.make_dir_recursive_absolute(OUTPUT_PATH)

	var all_cards = load_all_cards()

	if all_cards.is_empty():
		print("No cards found")
		return

	# ✅ Pasamos un flag 'force_duplicates' en true solo para el mazo de Reveal
	var reveal_deck = build_keyword_deck(all_cards, CardData.Keyword.REVEAL, true)
	var ongoing_deck = build_keyword_deck(all_cards, CardData.Keyword.ONGOING, false)
	var bleed_deck = build_keyword_deck(all_cards, CardData.Keyword.BLEED, false)
	var corrupt_deck = build_keyword_deck(all_cards, CardData.Keyword.CORRUPT, false)
	var lastbreath_deck = build_keyword_deck(all_cards, CardData.Keyword.LAST_BREATH, false)

	save_deck(reveal_deck, "deck_reveal.tres")
	save_deck(ongoing_deck, "deck_ongoing.tres")
	save_deck(bleed_deck, "deck_bleed.tres")
	save_deck(corrupt_deck, "deck_corrupt.tres")
	save_deck(lastbreath_deck, "deck_lastbreath.tres")

	print("Decks generated - Reveal deck optimized for testing!")


func save_deck(deck: DeckConfig, file_name: String):
	ResourceSaver.save(deck, OUTPUT_PATH + file_name)


func load_all_cards() -> Array:
	var cards = []
	var dir = DirAccess.open(CARDS_PATH)

	if dir == null:
		return cards

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tres"):
			var path = CARDS_PATH + file_name
			var card = load(path)
			if card != null:
				cards.append(card)
		file_name = dir.get_next()

	dir.list_dir_end()
	return cards


func build_keyword_deck(all_cards: Array, keyword: int, force_duplicates: bool = false) -> DeckConfig:
	var deck := DeckConfig.new()
	var filtered_cards := []

	# Filtrar cartas principales del arquetipo
	for card in all_cards:
		if card.keywords.has(keyword):
			filtered_cards.append(card)

	# 🔄 Si no hay suficientes cartas únicas de Reveal y queremos forzar duplicados,
	# llenamos la base del mazo repitiendo las cartas del arquetipo que ya tenemos.
	if force_duplicates and not filtered_cards.is_empty():
		while deck.cards.size() < 10: # Subimos a 10 cartas objetivo del arquetipo (antes era 8)
			var random_keyword_card = filtered_cards.pick_random()
			deck.cards.append(random_keyword_card)
	else:
		# Comportamiento normal para los demás mazos
		filtered_cards.shuffle()
		for card in filtered_cards:
			if deck.cards.size() >= 8:
				break
			deck.cards.append(card)

	# Completar las que falten para llegar a DECK_SIZE (12)
	fill_deck(deck, all_cards, force_duplicates, keyword)

	return deck


func fill_deck(deck: DeckConfig, all_cards: Array, ignore_limits: bool, target_keyword: int):
	var attempts := 0

	# Separamos las de reveal por si las necesitamos para rellenar
	var reveal_pool = []
	for card in all_cards:
		if card.keywords.has(target_keyword):
			reveal_pool.append(card)

	while deck.cards.size() < DECK_SIZE:
		# Si estamos en el mazo de pruebas e ignoramos límites, priorizamos rellenar con Reveal puro
		var random_card
		if ignore_limits and not reveal_pool.is_empty():
			random_card = reveal_pool.pick_random()
		else:
			random_card = all_cards.pick_random()

		# Si el mazo no es el de pruebas, aplica el límite estricto de 2 copias
		if not ignore_limits:
			var copies := count_card_copies(deck, random_card.card_name)
			if copies >= 2:
				attempts += 1
				if attempts > 100:
					break
				continue

		deck.cards.append(random_card)


func count_card_copies(deck: DeckConfig, card_name: String) -> int:
	var count := 0
	for card in deck.cards:
		if card.card_name == card_name:
			count += 1
	return count
