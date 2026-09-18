extends Camera2D
var right_clicked = false

func _ready() -> void:
	limit_left = - Global.MAP_SIZE.x * 288
	limit_right = Global.MAP_SIZE.x * 288
	limit_top = - Global.MAP_SIZE.y * 288
	limit_bottom = Global.MAP_SIZE.y * 288


func _physics_process(_delta: float) -> void:
	var dir = Vector2(Input.get_axis("left","right"),Input.get_axis("up","down")).normalized()
	position += dir * Global.Settings.get("camera_speed",12) / zoom.x
	var vp_size = get_viewport_rect().size / zoom
	global_position.x = clamp(global_position.x, limit_left + (vp_size.x / 2), limit_right - (vp_size.x / 2))
	global_position.y = clamp(global_position.y, limit_top + (vp_size.y / 2), limit_bottom - (vp_size.y / 2))



func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom *= 0.9
			if zoom.x < 0.05:
				zoom = Vector2(0.05,0.05)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom *= 1.1
			if zoom.x > 15:
				zoom = Vector2(15,15)
		Global.Zoom = zoom.x
		if event.is_action("move_camera") and event.is_pressed():
			right_clicked = true
		if event.is_action("move_camera") and event.is_released():
			right_clicked = false

	if event is InputEventMouseMotion and right_clicked:
		position -= event.relative / zoom
		position.x = clamp(position.x, limit_left, limit_right)
		position.y = clamp(position.y, limit_top, limit_bottom)
