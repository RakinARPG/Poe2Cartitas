extends Node

signal deck_empty


var current_deck: DeckConfig

var draw_pile: Array[CardData] = []



func load_deck(deck_config: DeckConfig):

	current_deck = deck_config

	draw_pile.clear()

	for card in current_deck.cards:

		draw_pile.append(card)

	shuffle_deck()

	print(
		"Deck loaded with ",
		draw_pile.size(),
		" cards"
	)


func shuffle_deck():

	draw_pile.shuffle()

	print("Deck shuffled")


func draw_card() -> CardData:

	if draw_pile.is_empty():

		print("Deck Empty")

		deck_empty.emit()

		return null

	var card = draw_pile.pop_front()

	print(
		"Drew card: ",
		card.card_name
	)

	return card


func cards_remaining() -> int:

	return draw_pile.size()
