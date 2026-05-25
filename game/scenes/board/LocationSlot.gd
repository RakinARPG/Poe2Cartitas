extends Panel

var location_index := 0
var cards_played: Array = []
var pending_cards: Array = []

@onready var location_name_label = %LocationNameLabel
@onready var power_label = %PowerLabel
@onready var cards_container = %CardsContainer

const MAX_CARDS := 4

func _ready():
	# Nota: Si ya lo tienes asignado en el Editor de Godot dentro de la escena,
	# esta línea duplicará el nodo en el grupo. De todas formas lo dejamos por seguridad.
	if not is_in_group("location_slots"):
		add_to_group("location_slots")


func setup(location_name: String, index: int):
	location_index = index
	location_name_label.text = location_name
	update_power_display()


func can_drop_data(_at_position, data) -> bool:
	# Retorna verdadero solo si hay espacio y los datos recibidos son válidos
	if cards_played.size() + pending_cards.size() >= MAX_CARDS:
		return false
	return data != null


func drop_data(_at_position, data):
	if data == null:
		return

	# Control de calidad: Verificamos que lo que soltamos sea el nodo de la carta
	if typeof(data) == TYPE_OBJECT and data.has_method("reveal_card"):
		print("[Location ", location_index, "] Carta válida detectada en el soltado.")
		add_card_to_location(data)
	else:
		print("[⚠️ Error Location ", location_index, "] Se intentó soltar algo que no es un CardNode. Datos recibidos: ", data)


func update_power_display():
	var p0 = LocationManager.get_power(0, location_index)
	var p1 = LocationManager.get_power(1, location_index)
	power_label.text = str(p0) + " - " + str(p1)


func add_card_to_location(card_node) -> bool:
	if cards_played.size() + pending_cards.size() >= MAX_CARDS:
		print("[Location ", location_index, "] Localización llena.")
		return false

	pending_cards.append(card_node)

	# Reparentar de forma segura al contenedor visual
	card_node.reparent(cards_container)
	card_node.position = Vector2.ZERO
	card_node.scale = Vector2(0.7, 0.7)
	card_node.is_locked = true
	
	if card_node.has_method("hide_card"):
		card_node.hide_card()

	update_power_display()

	# Evitar crasheo si por alguna razón .data viene vacío en tus pruebas
	if "data" in card_node and card_node.data != null:
		print("Played card: ", card_node.data.card_name)
	else:
		print("Played card sin recurso 'data' asignado.")

	return true
	

func reveal_pending_cards():
	print("[Location ", location_index, "] Ejecutando reveal_pending_cards(). Cartas en espera: ", pending_cards.size())

	for card in pending_cards:
		# 🛑 FILTRO ANTICRASHEO: Comprueba que la instancia sea válida y tenga el script correcto
		if not is_instance_valid(card):
			print("[⚠️ Alerta] Una carta en la lista pending_cards dejó de ser válida (instancia nula).")
			continue
			
		if not card.has_method("reveal_card"):
			print("[⚠️ Error Crítico] El objeto en pending_cards NO es un CardNode. Tipo/Datos: ", card)
			continue

		# Si pasa los filtros, ejecutamos la lógica original con seguridad
		card.reveal_card()
		cards_played.append(card)

		# Aseguramos que data y power existan en el nodo de la carta antes de sumarlo
		if "data" in card and card.data != null:
			LocationManager.add_power(0, location_index, card.data.power)
		else:
			print("[⚠️ Alerta] La carta revelada no posee datos de poder asignados.")

		EffectResolver.push_effect(
			EffectResolver.EffectType.REVEAL,
			card,
			location_index,
			{}
		)

	pending_cards.clear()
	update_power_display()
