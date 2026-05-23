@tool
extends EditorScript


const DeckConfig = preload(
	"res://game/cards/DeckConfig.gd"
)

const DataCard = preload(
	"res://game/cards/DataCard.gd"
)


const CARDS_PATH := "res://game/cards/generated/"
const OUTPUT_PATH := "res://game/cards/decks/"


func _run():

	DirAccess.make_dir_recursive_absolute(
		OUTPUT_PATH
	)

	var all_cards = load_all_cards()

	var reveal_deck = build_reveal_deck(
		all_cards
	)

	var lastbreath_deck = build_lastbreath_deck(
		all_cards
	)

	ResourceSaver.save(
		reveal_deck,
		OUTPUT_PATH + "deck_reveal.tres"
	)

	ResourceSaver.save(
		lastbreath_deck,
		OUTPUT_PATH + "deck_lastbreath.tres"
	)

	print("Decks generated")


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


func build_reveal_deck(
	all_cards: Array
) -> DeckConfig:

	var deck := DeckConfig.new()

	for card in all_cards:

		if card.keywords.has(
			DataCard.Keyword.REVEAL
		):

			deck.cards.append(card)

		if deck.cards.size() >= 12:
			break

	fill_deck(deck, all_cards)

	return deck


func build_lastbreath_deck(
	all_cards: Array
) -> DeckConfig:

	var deck := DeckConfig.new()

	for card in all_cards:

		if card.keywords.has(
			DataCard.Keyword.LAST_BREATH
		):

			deck.cards.append(card)

		if deck.cards.size() >= 12:
			break

	fill_deck(deck, all_cards)

	return deck


func fill_deck(
	deck: DeckConfig,
	all_cards: Array
):

	while deck.cards.size() < 12:

		deck.cards.append(
			all_cards.pick_random()
		)
