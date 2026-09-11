@tool
class_name YggdrasilSelectionBox
extends Panel

signal selected(rect: Rect2)

var selecting = false
var _start_screen: Vector2
var _start_local: Vector2
var _current_local: Vector2

var _view: YggdrasilTreeView

func _ready():
	var style = StyleBoxFlat.new()
	style.set_border_width_all(1)
	style.border_color = Color(0.0, 0.6, 1.0)
	style.bg_color = Color(0.0, 0.6, 1.0, 0.2)
	add_theme_stylebox_override("panel", style)
	visible = false

func set_view(view: YggdrasilTreeView) -> void:
	_view = view

func input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var local_pos = _view.get_local_space() * event.position
			selecting = true
			_start_screen = event.position
			_start_local = local_pos
			_current_local = local_pos

			visible = true
			position = _start_screen
			size = Vector2.ZERO
		elif selecting:
			selecting = false
			visible = false

			var top_left = Vector2(
				min(_start_local.x, _current_local.x),
				min(_start_local.y, _current_local.y)
			)
			var bottom_right = Vector2(
				max(_start_local.x, _current_local.x),
				max(_start_local.y, _current_local.y)
			)
			selected.emit(Rect2(top_left, bottom_right - top_left))

	elif event is InputEventMouseMotion and selecting:
		var local_pos = _view.get_local_space() * event.position
		_current_local = local_pos

		var current_screen = event.position
		var rect_position = Vector2(
			min(_start_screen.x, current_screen.x),
			min(_start_screen.y, current_screen.y)
		)
		var rect_size = Vector2(
			abs(current_screen.x - _start_screen.x),
			abs(current_screen.y - _start_screen.y)
		)
		position = rect_position
		size = rect_size