extends Node2D


func _process(delta: float) -> void:
	if Global.Tool == 1:
		$BuildingPreview.show()
		var grid_pos = Vector2i(floor(get_local_mouse_position() / 48))
		$BuildingPreview.position = Vector2(grid_pos) * 48

		var grid_size = Global.BuildingData[Global.CurrentBuilding].get("size",Vector2i(1,1))
		var atlas_pos = Global.BuildingData[Global.CurrentBuilding]["atlas_coords"]
		$BuildingPreview.texture.region = Rect2(atlas_pos * 16, Vector2(grid_size) * 16)
		if IsColliding(grid_pos, grid_size):
			$BuildingPreview.modulate = Color(1, 0.4, 0.4,.5)
		else:
			$BuildingPreview.modulate = Color(1, 1, 1,.5)
	else:
		$BuildingPreview.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("build") and event.is_pressed():
		var grid_pos = Vector2i(floor(get_local_mouse_position() / 48))
		var grid_size = Global.BuildingData[Global.CurrentBuilding].get("size",Vector2i(1,1))

		if Global.CurrentBuilding == "None" or IsColliding(grid_pos, grid_size):
			return

		if Global.Money >= Global.GetBuildingCost(Global.CurrentBuilding):
			Global.Money -= Global.GetBuildingCost(Global.CurrentBuilding)
			$"..".UpdateCityStats()
			$"../Buildings".NewBuilding(Global.CurrentBuilding, grid_pos)
			Global.BuildingUses.set(Global.CurrentBuilding,Global.BuildingUses.get_or_add(Global.CurrentBuilding,0) + 1	)
			print(Global.BuildingUses)
		else:
			$"../UI".insufficient_funds()

func GetBuildingSize(building_name: String) -> Vector2i:
	return Global.BuildingData[building_name].get("size", Vector2i(1, 1))

func IsColliding(pos: Vector2i, size: Vector2i) -> bool:
	var new_rect = Rect2i(pos, size)
	for b in $"../Buildings".Buildings:
		var b_size = GetBuildingSize(b["name"])
		var b_rect = Rect2i(b["pos"], b_size)
		if new_rect.intersects(b_rect):
			return true
	return false
