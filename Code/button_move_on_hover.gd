extends Button

var offset = 0.0
var ishovered = false
var originalpos

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	print(position)
	originalpos = position

func _process(delta: float) -> void:
	if ishovered:
		if offset < 1.0:
			offset += 5 * delta
	else:
		if offset > 0.0:
			offset -= 5 * delta
	
	position.x = ease(offset,2.0) * 50


func _on_mouse_entered() -> void:
	ishovered = true

func _on_mouse_exited() -> void:
	ishovered = false
