extends Node2D

var StartingPoint : Vector2i
var dragging = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("build") and Global.Tool == 1:
		match Global.BuildingTool:
			0:
				if event.is_released():
					var grid_pos = Vector2i(floor(get_local_mouse_position() / 48))
					var grid_size = Global.BuildingData[Global.CurrentBuilding].get("size",Vector2i(1,1))
					TryPlace(grid_pos,grid_size)
			1:
				if event.is_pressed():
					dragging = true
					StartingPoint = floor(get_local_mouse_position() / 48)
				else:
					dragging = false
					SetBuildingPreview()
					var EndPoint = floor(get_local_mouse_position() / 48)
					var XDir = 1 if EndPoint.x > StartingPoint.x else -1
					var YDir = 1 if EndPoint.y > StartingPoint.y else -1
					var grid_size = Global.BuildingData[Global.CurrentBuilding].get("size",Vector2i(1,1))
					for x in range(StartingPoint.x,EndPoint.x + XDir,XDir):
						for y in range(StartingPoint.y,EndPoint.y + YDir,YDir):
							TryPlace(Vector2i(x,y),grid_size)
							print(x," - ",y)
							await Global.CheckFrame(50)

	SetBuildingPreview()

func SetBuildingPreview():
	if Global.Tool == 1:
		$BuildingPreview.show()
		var grid_pos = Vector2i(floor(get_local_mouse_position() / 48))

		var grid_size = Global.BuildingData[Global.CurrentBuilding].get("size",Vector2i(1,1))
		var atlas_pos = Global.BuildingData[Global.CurrentBuilding]["atlas_coords"]
		if IsColliding(grid_pos, grid_size,Global.BuildingData.get(Global.CurrentBuilding).get("forcewater",false),Global.BuildingData.get(Global.CurrentBuilding).get("can_on_water",false),Global.BuildingData.get(Global.CurrentBuilding).get("forcedeepwater",false), Global.BuildingData.get(Global.CurrentBuilding).get("nexttoland",false)):
			$BuildingPreview.modulate = Color(1, 0.4, 0.4,.5)
		else:
			$BuildingPreview.modulate = Color(1, 1, 1,.5)
		match Global.BuildingTool:
			0:
				$BuildingPreview.clear()
				$BuildingPreview.set_cell(Vector2i.ZERO,0,atlas_pos)
				$BuildingPreview.position = Vector2(grid_pos) * 48
			1:
				$BuildingPreview.clear()
				if dragging:
					$BuildingPreview.position = Vector2.ZERO
					var EndPoint = floor(get_local_mouse_position() / 48)
					var XDir = 1 if EndPoint.x > StartingPoint.x else -1
					var YDir = 1 if EndPoint.y > StartingPoint.y else -1
					for x in range(StartingPoint.x,EndPoint.x + XDir,XDir):
						for y in range(StartingPoint.y,EndPoint.y + YDir,YDir):
							$BuildingPreview.set_cell(Vector2i(x,y),0,atlas_pos)
				else:
					$BuildingPreview.set_cell(Vector2i.ZERO,0,atlas_pos)
					$BuildingPreview.position = Vector2(grid_pos) * 48

			_:
				pass
	else:
		$BuildingPreview.hide()

func TryPlace(grid_pos:Vector2i ,grid_size:Vector2i):
	if Global.CurrentBuilding == "None" or IsColliding(grid_pos, grid_size, Global.BuildingData.get(Global.CurrentBuilding).get("forcewater",false), Global.BuildingData.get(Global.CurrentBuilding).get("can_on_water",false),Global.BuildingData.get(Global.CurrentBuilding).get("forcedeepwater",false),Global.BuildingData.get(Global.CurrentBuilding).get("nexttoland",false)):
		return

	if Global.Money >= Global.GetBuildingCost(Global.CurrentBuilding) and $"..".UnlockedBuildings.get(Global.CurrentBuilding,false):
		$"../Camera".traumatize(0.15)
		Global.Money -= Global.GetBuildingCost(Global.CurrentBuilding)
		$"..".UpdateCityStats()
		$"../Buildings".NewBuilding(Global.CurrentBuilding, grid_pos)
		Global.BuildingUses.set(Global.CurrentBuilding,Global.BuildingUses.get_or_add(Global.CurrentBuilding,0) + 1	)
	else:
		$"../UI".insufficient_funds()

func GetBuildingSize(building_name: String) -> Vector2i:
	return Global.BuildingData[building_name].get("size", Vector2i(1, 1))

func IsColliding(pos: Vector2i, size: Vector2i, wateronly=false, canwater=false,forcedeep=false,forceshore=false) -> bool:
	var new_rect = Rect2i(pos, size)
	if TerrainCollide(pos,size, wateronly,canwater,forcedeep,forceshore):
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

func TerrainCollide(pos,size,wateronly,canwater,forcedeep, forceshore) -> bool:
	for x in size.x:
		for y in size.y:
			var tile = $"../Terrain".get_tile(Vector2i(x + pos.x, y + pos.y))
			match tile:
				1: # water
					if wateronly or canwater:
						if forceshore:
							var okay = false
							for i in [Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP]:
								if $"../Terrain".get_tile(i+pos) != 1 and $"../Terrain".get_tile(i+pos) != 7:
									okay = true
							if not okay:
								return true
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
