extends Camera2D
var camera_speed := 4	
var right_clicked = false

func _physics_process(delta: float) -> void:
	pass
	#position += (Vector2(Input.get_axis("left","right"),Input.get_axis("up","down")) * (Vector2(1,1) / zoom)) * camera_speed

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom *= 0.9
			if zoom.x < 0.7:
				zoom = Vector2(0.7,0.7)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom *= 1.1
			if zoom.x > 15:
				zoom = Vector2(15,15)
		if event.is_action("move_camera") and event.is_pressed():
			right_clicked = true
		if event.is_action("move_camera") and event.is_released():
			right_clicked = false

	if event is InputEventMouseMotion and right_clicked:
		position -= event.relative / zoom
		position.x = clamp(position.x, limit_left, limit_right)
		position.y = clamp(position.y, limit_top, limit_bottom)
