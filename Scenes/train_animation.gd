extends Node2D

var train_scene = preload("res://Scenes/train.tscn")

func _on_train_timer_timeout() -> void:
	for nw in $"../Buildings".station_networks:
		if nw.size() < 2:
			print("small")
			continue
		print("ok!")
		var new_nw = nw.duplicate()
		var stA = new_nw.pick_random()
		new_nw.erase(stA)
		var stB = new_nw.pick_random()
		var path :Array = $"../Buildings".GetRailPath(stA,stB)
		if path.is_empty():
			return
		var train : Path2D = train_scene.instantiate()
		train.position = stA["pos"] * 48 + Vector2i(24,24)
		train.curve = Curve2D.new()
		for n in path:
			train.curve.add_point((n - stA["pos"])*48)
		add_child(train)
