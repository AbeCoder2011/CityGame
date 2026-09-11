@tool
class_name YggdrasilCamera
extends RefCounted

signal zoom_changed(zoom: float, previous_zoom: float)

var _viewport: Control
var _bounds: Rect2

var _zoom: float = 1.0
var _dragging = false
var _last_mouse_pos: Vector2

func set_viewport(viewport: Control) -> void:
	_viewport = viewport
	_viewport.offset_transform_enabled = true
	_viewport.offset_transform_visual_only = false
	_viewport.get_parent().resized.connect(_on_viewport_resized)

func set_bounds(bounds: Rect2) -> void:
	_bounds = bounds

func input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
		set_camera_zoom(min(_zoom + 0.1, 1.0))
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
		set_camera_zoom(max(_zoom - 0.1, 0.4))
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			_dragging = event.pressed
			if _dragging:
				_last_mouse_pos = event.position
	elif event is InputEventMouseMotion and _dragging:
		var delta = event.position - _last_mouse_pos
		_last_mouse_pos = event.position
		_on_camera_dragged(delta)

func set_camera_zoom(zoom: float):
	var previous_zoom = _zoom
	_zoom = zoom
	_viewport.offset_transform_scale = Vector2(_zoom, _zoom)

	var zoom_factor = _zoom / previous_zoom
	_viewport.offset_transform_position = _viewport.offset_transform_position * zoom_factor
	_clamp()

	zoom_changed.emit(_zoom, previous_zoom)

func _on_camera_dragged(delta: Vector2):
	_viewport.offset_transform_position += delta
	_clamp()

func _on_viewport_resized():
	_clamp()

func _clamp():
	var cam_pos = _viewport.offset_transform_position
	var view_size = _viewport.get_parent().get_rect().size
	var bounds_min = _bounds.position * _zoom
	var bounds_max = _bounds.size * _zoom
	var min_pos = (_bounds.position * _zoom) + (view_size * 0.5)
	var max_pos = (_bounds.size * _zoom) - (view_size * 0.5)

	if min_pos.x > max_pos.x:
		cam_pos.x = (bounds_min.x + bounds_max.x) * 0.5
	else:
		cam_pos.x = clamp(cam_pos.x, min_pos.x, max_pos.x)

	if min_pos.y > max_pos.y:
		cam_pos.y = (bounds_min.y + bounds_max.y) * 0.5
	else:
		cam_pos.y = clamp(cam_pos.y, min_pos.y, max_pos.y)

	_viewport.offset_transform_position = cam_pos
