extends Node2D

var train_scene = preload("res://Scenes/train.tscn")

func _on_train_timer_timeout() -> void:
	for nw in $"../Buildings".station_networks:
		var st = nw.pick_random()
		print(st)
