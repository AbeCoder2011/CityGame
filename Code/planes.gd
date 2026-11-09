extends Node2D

var plane = preload("res://Scenes/plane.tscn")

func SummonPlaneTo(pos: Vector2):
	var p: Path2D = plane.instantiate()
	var target : Vector2 = pos
	var straight_dir: Vector2 = [Vector2.UP, Vector2.DOWN].pick_random()
	if straight_dir == Vector2.UP:
		target += straight_dir * 48 * -2
	var side_dir: Vector2 = straight_dir.orthogonal() * (randf() - .5) * 2
	var entry := target + straight_dir * randi_range(300,700)
	p.setup(target, entry, entry + (straight_dir + side_dir) * randi_range(2000,4000))
	add_child(p)
	
