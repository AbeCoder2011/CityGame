@tool
class_name YggdrasilProceduralGrid
extends Control

@export var primary_line_step: int = 4
@export var line_color = Color(1, 1, 1, 0.12)
@export var line_width = 1.0

var cell_size = Vector2(16, 16)

var parent: Control

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if not is_inside_tree():
		return
	
	var s: Vector2 = parent.offset_transform_scale
	var pan: Vector2 = parent.offset_transform_position
	var size: Vector2 = get_rect().size
	var pivot: Vector2 = size * 0.5
	var step: Vector2 = cell_size * s
	var origin_space: Vector2 = pan + pivot
	var off_x: float = fposmod(origin_space.x, step.x)
	var off_y: float = fposmod(origin_space.y, step.y)

	var x: float = off_x
	while x <= size.x:
		draw_line(Vector2(x, 0), Vector2(x, size.y), line_color, line_width)
		x += step.x

	var y: float = off_y
	while y <= size.y:
		draw_line(Vector2(0, y), Vector2(size.x, y), line_color, line_width)
		y += step.y
	
	if primary_line_step > 0:
		var primary_step: Vector2 = cell_size * primary_line_step * s
		var off_x_primary: float = fposmod(origin_space.x, primary_step.x)
		var off_y_primary: float = fposmod(origin_space.y, primary_step.y)

		var x_primary: float = off_x_primary
		while x_primary <= size.x:
			draw_line(Vector2(x_primary, 0), Vector2(x_primary, size.y), line_color, line_width * 1.5)
			x_primary += primary_step.x
		
		var y_primary: float = off_y_primary
		while y_primary <= size.y:
			draw_line(Vector2(0, y_primary), Vector2(size.x, y_primary), line_color, line_width * 1.5)
			y_primary += primary_step.y
