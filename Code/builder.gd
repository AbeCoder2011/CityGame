extends Node2D


func _process(delta: float) -> void:
	if Global.Tool == 1:
		$BuildingPreview.show()
		var grid_pos = Vector2i(floor(get_local_mouse_position() / 48))
		$BuildingPreview.position = Vector2(grid_pos) * 48

		var grid_size = Global.BuildingData[Global.CurrentBuilding].get("size",Vector2i(1,1))
		var atlas_pos = Global.BuildingData[Global.CurrentBuilding]["atlas_coords"]
		$BuildingPreview.texture.region = Rect2(atlas_pos * 16, Vector2(grid_size) * 16)
		if IsColliding(grid_pos, grid_size,Global.BuildingData.get(Global.CurrentBuilding).get("forcewater",false),Global.BuildingData.get(Global.CurrentBuilding).get("can_on_water",false),Global.BuildingData.get(Global.CurrentBuilding).get("forcedeepwater",false)):
			$BuildingPreview.modulate = Color(1, 0.4, 0.4,.5)
		else:
			$BuildingPreview.modulate = Color(1, 1, 1,.5)
	else:
		$BuildingPreview.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("build") and event.is_pressed() and Global.Tool == 1:
		var grid_pos = Vector2i(floor(get_local_mouse_position() / 48))
		var grid_size = Global.BuildingData[Global.CurrentBuilding].get("size",Vector2i(1,1))
		
		if Global.CurrentBuilding == "None" or IsColliding(grid_pos, grid_size, Global.BuildingData.get(Global.CurrentBuilding).get("forcewater",false), Global.BuildingData.get(Global.CurrentBuilding).get("can_on_water",false),Global.BuildingData.get(Global.CurrentBuilding).get("forcedeepwater",false)):
			return

		if Global.Money >= Global.GetBuildingCost(Global.CurrentBuilding) and $"..".UnlockedBuildings.get(Global.CurrentBuilding,false):
			Global.Money -= Global.GetBuildingCost(Global.CurrentBuilding)
			$"..".UpdateCityStats()
			$"../Buildings".NewBuilding(Global.CurrentBuilding, grid_pos)
			Global.BuildingUses.set(Global.CurrentBuilding,Global.BuildingUses.get_or_add(Global.CurrentBuilding,0) + 1	)
		else:
			$"../UI".insufficient_funds()

func GetBuildingSize(building_name: String) -> Vector2i:
	return Global.BuildingData[building_name].get("size", Vector2i(1, 1))

func IsColliding(pos: Vector2i, size: Vector2i, wateronly=false, canwater=false,forcedeep=false) -> bool:
	var new_rect = Rect2i(pos, size)
	if TerrainCollide(pos,size, wateronly,canwater,forcedeep):
		return true
	var poses = []
	for x in range(size.x):
		for y in range(size.y):
			poses.append(pos + Vector2i(x,y))
			
	for b in $"../Buildings"._get_nearby_buildings(pos,size,1):
		var b_size = GetBuildingSize(b["name"])
		var b_rect = Rect2i(b["pos"], b_size)
		if new_rect.intersects(b_rect):
			return true
	var p = poses.duplicate()
	for n in p:
		for r : Rect2 in $"..".BuildableAreas:
			if r.has_point(n):
				poses.erase(n)
				continue
	if poses.is_empty():
		return false
	return true

func TerrainCollide(pos,size,wateronly,canwater,forcedeep) -> bool:
	for x in size.x:
		for y in size.y:
			var tile = $"../Terrain".get_tile(Vector2i(x + pos.x, y + pos.y))
			match tile:
				1: # water
					if wateronly or canwater: 
						continue
					else:
						return true
				7: # deep water
					if forcedeep or canwater: 
						continue
					else:
						return true
				4: # mountain
					return true
				_:
					if wateronly or forcedeep:
						return true
	return false
