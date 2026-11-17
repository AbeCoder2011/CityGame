extends Node2D

var train_scene = preload("res://Scenes/train.tscn")

func _on_train_timer_timeout() -> void:
	for nw in $"../../Buildings".station_networks:
		if nw.size() < 2:
			continue
		var new_nw = nw.duplicate()
		var stA = new_nw.pick_random()
		new_nw.erase(stA)
		var stB = new_nw.pick_random()
		var path :Array = $"../../Buildings".GetRailPath(stA["pos"],stB["pos"])
		if path.is_empty():
			continue
		var train : Path2D = train_scene.instantiate()
		train.position = stA["pos"] * 48 + Vector2i(24,24)
		train.curve = Curve2D.new()
		var pts : Array[Vector2] = []
		for n in path:
			pts.append(Vector2((n - stA["pos"]) * 48))
		for i in pts.size():
			var p = pts[i]
			var handle_in = Vector2.ZERO
			var handle_out = Vector2.ZERO
			if i > 0 and i < pts.size() - 1:
				var dir = (pts[i + 1] - pts[i - 1]).normalized()
				handle_in = -dir * 8
				handle_out = dir * 8
			train.curve.add_point(p, handle_in, handle_out)
		add_child(train)
