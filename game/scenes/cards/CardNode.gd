extends Panel


signal card_dropped(
	card_node,
	drop_position
)


var data: CardData


var is_dragging := false

var drag_offset := Vector2.ZERO

var original_position := Vector2.ZERO


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


	if event is InputEventMouseMotion:

		if is_dragging:

			global_position = get_global_mouse_position() - drag_offset


func start_drag(event):

	is_dragging = true

	original_position = global_position

	drag_offset = event.position


func stop_drag():

	if is_dragging:

		is_dragging = false

		card_dropped.emit(
			self,
			global_position
		)
