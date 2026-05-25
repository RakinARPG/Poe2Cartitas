extends Panel


signal card_released(card_node)


var data: CardData

var is_dragging := false

var drag_offset := Vector2.ZERO

var original_position := Vector2.ZERO

var is_locked := false

var is_revealed := false

var owner_player_id := 0

@onready var art_rect = %TextureRect
@onready var name_label = %NameLabel
@onready var cost_label = %CostLabel
@onready var power_label = %PowerLabel
@onready var text_label = %TextLabel


func setup(card_data: CardData):

	data = card_data

	name_label.text = data.card_name

	cost_label.text = str(data.cost)

	power_label.text = str(data.power)

	text_label.text = data.effect_text

	if data.art != null:

		art_rect.texture = data.art


func _gui_input(event):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT:

			if event.pressed:

				start_drag(event)

			else:

				stop_drag()


func _process(delta):

	if is_dragging:

		global_position = get_global_mouse_position() - drag_offset


func start_drag(event):
	
	if is_locked:
		return

	is_dragging = true

	original_position = global_position

	drag_offset = event.position


func stop_drag():

	if is_dragging:

		is_dragging = false

		card_released.emit(self)

func hide_card():

	is_revealed = false

	modulate = Color(0.2, 0.2, 0.2)

	text_label.visible = false
	name_label.visible = false
	power_label.visible = false
	cost_label.visible = false


func reveal_card():

	is_revealed = true

	modulate = Color.WHITE

	text_label.visible = true
	name_label.visible = true
	power_label.visible = true
	cost_label.visible = true
