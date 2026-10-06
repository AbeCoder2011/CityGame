extends Camera2D
var right_clicked = false

var trauma = 0.0
var trauma_power = 2
var max_offset = Vector2(100,100)
func _process(delta: float) -> void:
	if trauma:
		trauma = max(trauma - 0.5 * delta, 0)
		shake()
func shake():
	var amount = pow(trauma, trauma_power) * (1 / zoom.x)
	offset.x = max_offset.x * amount * randf_range(-1, 1)
	offset.y = max_offset.y * amount * randf_range(-1, 1)
func traumatize(amount):
	trauma = min(trauma + amount, 0.2)

func _ready() -> void:
	limit_left = - Global.GameSettings.get("map_size",20) * 288 - 144
	limit_right = Global.GameSettings.get("map_size",20) * 288 + 144
	limit_top = - Global.GameSettings.get("map_size",20) * 288 - 144
	limit_bottom = Global.GameSettings.get("map_size",20) * 288 + 144


func _physics_process(_delta: float) -> void:
	var dir = Vector2(Input.get_axis("left","right"),Input.get_axis("up","down")).normalized()
	position += dir * Global.Settings.get("camera_speed",12) / zoom.x
	var vp_size = get_viewport_rect().size / zoom
	global_position.x = clamp(global_position.x, limit_left + (vp_size.x / 2), limit_right - (vp_size.x / 2))
	global_position.y = clamp(global_position.y, limit_top + (vp_size.y / 2), limit_bottom - (vp_size.y / 2))



func _input(event: InputEvent) -> void:
	if event.is_action("zoom_out"):
		var mouse_pos = get_local_mouse_position()
		zoom *= 0.9
		zoom = clamp(zoom,Vector2(0.05,0.05),Vector2(15,15))
		await get_tree().process_frame
		global_position += mouse_pos - get_local_mouse_position()
	elif event.is_action("zoom_in"):
		var mouse_pos = get_local_mouse_position()
		zoom *= 1.1
		zoom = clamp(zoom,Vector2(0.05,0.05),Vector2(15,15))
		await get_tree().process_frame
		global_position += mouse_pos - get_local_mouse_position()
	if event is InputEventMouseButton:
		Global.Zoom = zoom.x
		if event.is_action("move_camera") and event.is_pressed():
			right_clicked = true
		if event.is_action("move_camera") and event.is_released():
			right_clicked = false

	if event is InputEventMouseMotion and right_clicked:
		position -= event.relative / zoom
		position.x = clamp(position.x, limit_left, limit_right)
		position.y = clamp(position.y, limit_top, limit_bottom)
	
