extends Node2D

var inputs : Dictionary[String,float] = {}
var extra_data : Dictionary = {}

var Recomputed = false

var power := 0
var use_power := false
var building_name = ""

var grid_pos := Vector2i.ZERO

var bridge_rail = false
var horizontal_bridge = true
var rail_connections := {"l":false,"r":false,"u":false,"d":false}

var Claims : Dictionary = {}

var UI_Settings = {}

var selected = false

var line = preload("res://Scenes/line.tscn")

var decision_ID = -1

func init_building(nam,pos) -> void:
	building_name = nam
	grid_pos = pos
	match building_name:
		"Wind Turbine":
			$Sprite.hide()
			$AnimatedSprite2D.show()
		_:
			$Sprite.texture = AtlasTexture.new()
			$Sprite.position = GetSize(nam) * 24
			$Sprite.texture.atlas = Global.BuildingTilemap
	$Info/TextureRect.texture = AtlasTexture.new()
	match nam:
		"Rail":
			$HoverDetection.size = GetSize(nam) * 48
		"Fishing Dock":
			$Info/TextureRect.texture.atlas = Global.IconTilemap
			$HoverDetection.size = GetSize(nam) * 48
			$Sprite.texture.region = Rect2(Global.BuildingData[nam]["atlas_coords"] * 16,GetSize(nam)*16)
			for n : Vector2i in Global.AroundTiles:
				var t = $"../../Terrain".get_tile(grid_pos + n)
				if t not in [1,7]:
					$Sprite.rotation = Vector2(Vector2i.ZERO - n).angle() - PI/2
					return
		_:
			$Info/TextureRect.texture.atlas = Global.IconTilemap
			$HoverDetection.size = GetSize(nam) * 48
			$Visible.rect = Rect2(Vector2(0,0),GetSize(nam)*48).grow(5)
			$Sprite.texture.region = Rect2(Global.BuildingData[nam]["atlas_coords"] * 16,GetSize(nam)*16)
	
func display_income(i:float):
	if $Visible.is_on_screen() and Global.Zoom >= 2.0:
		if i == 0:
			return
		$Income.text = "+" + Global.GetBigNumber(i)
		$Income/AnimationPlayer.play("play")


func _on_mouse_enter() -> void:
	$Info.show()
	$Lines.show()
	UpdateData()
	$"../../UI".ShowInfo(GetBuildingInfo())


func _on_mouse_exit() -> void:
	$Info.hide()
	$Lines.hide()
	$"../../UI".HideInfo()

func UpdateData():
	for n in $Lines.get_children():
		n.queue_free()
	
	for n in Claims.keys():
		var l : Line2D = line.instantiate()
		l.add_point(Vector2(0.0,0.0))
		l.add_point((n - grid_pos) * 48)
		$Lines.add_child(l)
	
	match building_name:
		"Small Supermarket", "Large Supermarket", "Electronics Store","Cafe", "Bakery", "Restaurant", "Mall","Seafood Market":
			$Info/TextureRect.texture.region = Rect2(0,0,16,16)
			$Info.text = Global.GetBigNumber(inputs.get("money",0) * 2) + "/s"
		"Basic House", "Double House", "Small Apartment Complex","Large Apartment Complex", "Mega Apartment Complex","Low-Budget Apartment","Giant Apartment Complex":
			$Info/TextureRect.texture.region = Rect2(1*16,0,16,16)
			$Info.text = str(int(inputs.get("population",0)))
		"Mill":
			$Info/TextureRect.texture.region = Rect2(2*16,0,16,16)
			$Info.text = str(int(inputs.get("flour",0)))
		"Small Wheatfield","Large Wheatfield":
			$Info/TextureRect.texture.region = Rect2(3*16,0,16,16)
			$Info.text = str(int(inputs.get("wheat",0)))
		"Transformator Building":
			$Info/TextureRect.texture.region = Rect2(4*16,0,16,16)
			$Info.text = str(int(inputs.get("power",0)))
		"Animal Farm":
			$Info/TextureRect.texture.region = Rect2(5*16,0,16,16)
			$Info.text = str(int(inputs.get("livestock",0)))
		"Butcher":
			$Info/TextureRect.texture.region = Rect2(6*16,0,16,16)
			$Info.text = str(int(inputs.get("meat",0)))
		"Pocket Park","Small Park","Fountain Park","Large Park":
			$Info/TextureRect.texture.region = Rect2(7*16,0,16,16)
			$Info.text = str(int(inputs.get("nature",0)))
		"Small Factory","Large Factory":
			$Info/TextureRect.texture.region = Rect2(0*16,1*16,16,16)
			$Info.text = str(int(inputs.get("products",0)))
		"Mine":
			$Info/TextureRect.texture.region = Rect2(5*16,16,16,16)
			$Info.text = str(int(inputs.get("ores",0)))
		"Ore Extractor":
			$Info/TextureRect.texture.region = Rect2(6*16,16,16,16)
			$Info.text = str(int(inputs.get("gemstones",0)))
		"Library","University","Elementary School":
			$Info/TextureRect.texture.region = Rect2(7*16,16,16,16)
			$Info.text = str(int(inputs.get("gemstones",0)))
		"Fishing Hut":
			$Info/TextureRect.texture.region = Rect2(0*16,32,16,16)
			$Info.text = str(int(inputs.get("fish",0)))
		"Sand Mine":
			$Info/TextureRect.texture.region = Rect2(1*16,32,16,16)
			$Info.text = str(int(inputs.get("sand",0)))
		"Smeltery":
			$Info/TextureRect.texture.region = Rect2(2*16,32,16,16)
			$Info.text = str(int(inputs.get("glass",0)))
		"Fishing Dock":
			$Info/TextureRect.texture.region = Rect2(3*16,32,16,16)
			$Info.text = str(int(inputs.get("exoticfish",0)))
		_:
			$Info.hide()


func _on_pressed() -> void:
	if Global.Tool == 2:
		hide()
		$"../../Camera".traumatize(0.22)
		Global.Money += floor(Global.BuildingData[building_name]["cost"] / 2)
		Global.BuildingUses[building_name] -= 1
		$"..".AddToRemovalList({"pos":grid_pos,"name":building_name,"node":self,"claims":Claims})
	if Global.Tool == 0:
		if selected:
			selected = false
		else:
			if not Input.is_action_pressed("select_multiple"):
				$"..".DeselectOthers()
			selected = true

func Deselect():
	selected = false
	$Sprite/Outline.visible = selected

func FreeNode():
	queue_free()

func UpdateRailSprite() -> void:
	var other_rails : Dictionary = $"..".Rails
	rail_connections = {"l":false,"r":false,"u":false,"d":false}
	if other_rails.has(Vector2i(grid_pos.x + 1, grid_pos.y)) or $"..".IsStationAt(grid_pos + Vector2i.RIGHT):
		rail_connections["r"] = true
	if other_rails.has(Vector2i(grid_pos.x - 1, grid_pos.y)) or $"..".IsStationAt(grid_pos + Vector2i.LEFT):
		rail_connections["l"] = true
	if other_rails.has(Vector2i(grid_pos.x, grid_pos.y + 1)) or $"..".IsStationAt(grid_pos + Vector2i.DOWN):
		rail_connections["d"] = true
	if other_rails.has(Vector2i(grid_pos.x, grid_pos.y - 1)) or $"..".IsStationAt(grid_pos + Vector2i.UP):
		rail_connections["u"] = true
	if $"../../Terrain".get_tile(grid_pos) in [1,7]:
		bridge_rail = true
	if bridge_rail:
		if rail_connections["r"] or rail_connections["l"]:
			$Sprite.texture.region = Rect2(Vector2(288,112), Vector2(16,16))
			$Sprite.rotation_degrees = 0
			horizontal_bridge = true
		else:
			$Sprite.texture.region = Rect2(Vector2(304,112), Vector2(16,16))
			$Sprite.rotation_degrees = 0
			horizontal_bridge = false
	else:
		if rail_connections["l"] and rail_connections["u"] and rail_connections["r"] and rail_connections["d"]:
			$Sprite.texture.region = Rect2(Vector2(288,80), Vector2(16,16))
			$Sprite.rotation_degrees = 0
		elif rail_connections["l"] and rail_connections["r"] and rail_connections["d"]:
			$Sprite.texture.region = Rect2(Vector2(288,96), Vector2(16,16))
			$Sprite.rotation_degrees = 0
		elif rail_connections["l"] and rail_connections["u"] and rail_connections["d"]:
			$Sprite.texture.region = Rect2(Vector2(288,96), Vector2(16,16))
			$Sprite.rotation_degrees = 90
		elif rail_connections["l"] and rail_connections["u"] and rail_connections["r"]:
			$Sprite.texture.region = Rect2(Vector2(288,96), Vector2(16,16))
			$Sprite.rotation_degrees = 180
		elif rail_connections["u"] and rail_connections["r"] and rail_connections["d"]:
			$Sprite.texture.region = Rect2(Vector2(288,96), Vector2(16,16))
			$Sprite.rotation_degrees = 270
		elif rail_connections["l"] and rail_connections["u"]:
			$Sprite.texture.region = Rect2(Vector2(304,96), Vector2(16,16))
			$Sprite.rotation_degrees = 0
		elif rail_connections["u"] and rail_connections["r"]:
			$Sprite.texture.region = Rect2(Vector2(304,96), Vector2(16,16))
			$Sprite.rotation_degrees = 90
		elif rail_connections["r"] and rail_connections["d"]:
			$Sprite.texture.region = Rect2(Vector2(304,96), Vector2(16,16))
			$Sprite.rotation_degrees = 180
		elif rail_connections["d"] and rail_connections["l"]:
			$Sprite.texture.region = Rect2(Vector2(304,96), Vector2(16,16))
			$Sprite.rotation_degrees = 270
		elif rail_connections["u"] or rail_connections["d"]:
			$Sprite.texture.region = Rect2(Vector2(304,80), Vector2(16,16))
			$Sprite.rotation_degrees = 0
		elif rail_connections["l"] or rail_connections["r"]:
			$Sprite.texture.region = Rect2(Vector2(304,80), Vector2(16,16))
			$Sprite.rotation_degrees = 90
		else:
			$Sprite.texture.region = Rect2(Vector2(304,80), Vector2(16,16))
			$Sprite.rotation_degrees = 0
	
func GetSize(n) -> Vector2i:
	return Global.BuildingData[n].get("size",Vector2i(1,1))

func GetBuildingInfo() -> String:
	if not Recomputed:
		return "[font=res://Assets/Fonts/Space_Mono/SpaceMono.ttf] Recomputing... \n Please wait"

	var out = "[font=res://Assets/Fonts/Space_Mono/SpaceMono.ttf]" + building_name + "\n"
	for d in extra_data.keys():
		var v = extra_data[d]
		if not extra_data[d] is Dictionary:
			v = int(extra_data[d])
		match d:
			"population":
				if extra_data.has("gets_pop_boost"):
					if extra_data["gets_pop_boost"]:
						out += "[tile x=1 y=0 f=1.5]res://Assets/icons.png[/tile] " + str(v) + " population nearby. ([b]Sufficient[/b])\n"
					else:
						out += "[tile x=1 y=0 f=1.5]res://Assets/icons.png[/tile] " + str(v) + " population nearby. ([b]Not sufficient[/b])\n"
				else:
					out += "[tile x=1 y=0 f=1.5]res://Assets/icons.png[/tile] " + str(v) + " population nearby.\n"
			"base_pop":
				out += "[tile x=1 y=0 f=1.5]res://Assets/icons.png[/tile] " + str(v) + " base population.\n"
			"happiness":
				out += "[tile x=2 y=1 f=1.5]res://Assets/icons.png[/tile] Happiness value: " + str(int(v / inputs.get("population",1))) + "\n"
			"wheat":
				out += "[tile x=3 y=0 f=1.5]res://Assets/icons.png[/tile] " + str(v) + " wheat nearby.\n"
			"flour":
				out += "[tile x=2 y=0 f=1.5]res://Assets/icons.png[/tile] " + str(v) + " flour nearby.\n"
			"industry":
				out += "[tile x=5 y=2 f=1.5]res://Assets/icons.png[/tile] Industry debuff: " + str(v) + "x.\n"
			"meat":
				out += "[tile x=6 y=0 f=1.5]res://Assets/icons.png[/tile] " + str(v) + " meat nearby.\n"
			"livestock":
				out += "[tile x=5 y=0 f=1.5]res://Assets/icons.png[/tile] " + str(v) + " livestock nearby.\n"
			"products":
				out += "[tile x=0 y=1 f=1.5]res://Assets/icons.png[/tile] " + str(v) + " products nearby.\n"
			"nature":
				out += "[tile x=7 y=0 f=1.5]res://Assets/icons.png[/tile] Nature score: " + str(v) + "\n"
			"entertainment":
				out += "[tile x=6 y=2 f=1.5]res://Assets/icons.png[/tile] Entertainment score: " + str(v) + "\n"
			"ores":
				out += "[tile x=5 y=1 f=1.5]res://Assets/icons.png[/tile] " + str(v) + " ores nearby.\n"
			"gemstones":
				out += "[tile x=6 y=1 f=1.5]res://Assets/icons.png[/tile] " + str(v) + " gemstones nearby.\n"
			"water":
				out += "[tile x=0 y=3 f=1.5]res://Assets/icons.png[/tile] " + str(v) + " water tiles nearby.\n"
			"deep_water":
				out += "[tile x=1 y=3 f=1.5]res://Assets/icons.png[/tile] " + str(v) + " deep water tiles nearby.\n"
			"mountains":
				out += "[tile x=2 y=3 f=1.5]res://Assets/icons.png[/tile] " + str(v) + " mountain tiles nearby.\n"
			"desert":
				out += "[tile x=3 y=3 f=1.5]res://Assets/icons.png[/tile] " + str(v) + " desert tiles nearby.\n"
			"sand":
				out += "[tile x=1 y=2 f=1.5]res://Assets/icons.png[/tile] " + str(v) + " sand nearby.\n"
			"shops_nearby":
				out += "[tile x=4 y=3 f=1.5]res://Assets/icons.png[/tile] " + str(v) + " other shops nearby.\n"
			"power_boost":
				if extra_data.has("power_boost_mult"):
					out += "[tile x=4 y=0 f=1.5]res://Assets/icons.png[/tile] " + str(v) + " power supplied nearby. (" + str(extra_data["power_boost_mult"]) + "x boost)\n"
				else:
					out += "[tile x=4 y=0 f=1.5]res://Assets/icons.png[/tile] " + str(v) + " power supplied nearby.\n"
			"global_power":
				out += "[tile x=4 y=0 f=1.5]res://Assets/icons.png[/tile] Global power grid has " + str(v) + " power.\n"
			"power":
				out += "[tile x=4 y=0 f=1.5]res://Assets/icons.png[/tile] Generates " + str(v) + " energy.\n"
			"inventory":
				out += "[tile x=0 y=1 f=1.5]res://Assets/icons.png[/tile] Network Inventory: \n"
				for n in v.keys():
					if v[n] > 0:
						out += " - %s x %s\n" % [str(int(v[n])),str(n)]
			"flights":
				out += "[tile x=6 y=3 f=1.5]res://Assets/icons.png[/tile] Accomodates " + str(v) + " flights.\n"
			"control_towers":
				out += "[tile x=5 y=3 f=1.5]res://Assets/icons.png[/tile] Has " + str(v) + " control towers nearby.\n"
			"my_passengers":
				out += "[tile x=1 y=0 f=1.5]res://Assets/icons.png[/tile] Takes in " + str(v) + " passengers.\n"
			"total_passengers":
				out += "[tile x=1 y=0 f=1.5]res://Assets/icons.png[/tile] " + str(v) + " passengers in total.\n"
			"power_boost_mult","gets_pop_boost":
				pass
			"tourists":
				out += "[tile x=4 y=2 f=1.5]res://Assets/icons.png[/tile] Houses " + str(v) + " tourists.\n"
			"fish":
				out += "[tile x=3 y=2 f=1.5]res://Assets/icons.png[/tile] Receives " + str(v) + " fish.\n"
			"exoticfish":
				out += "[tile x=0 y=2 f=1.5]res://Assets/icons.png[/tile] Receives " + str(v) + " exotic fish.\n"
			
			_:
				printerr("Extra text for " + d + " not found! (value = " + str(v) + ")")

	if use_power:
		out += "[tile x=4 y=0 f=1.5]res://Assets/icons.png[/tile] " + str(power) + " power collected nearby.\n"
	for d in inputs.keys():
		var v = int(inputs[d])
		var decimal_v = inputs[d]
		match d:
			"population":
				out += "[tile x=1 y=0 f=1.5]res://Assets/icons.png[/tile] Houses " + str(v) + " people.\n"
			"money":
				out += "[tile x=0 y=0 f=1.5]res://Assets/icons.png[/tile] Earns " + str(Global.GetBigNumber(decimal_v*2)) + "/s\n"
			"flour":
				out += "[tile x=2 y=2 f=1.5]res://Assets/icons.png[/tile] Produces " + str(v) + " flour.\n"
			"wheat":
				out += "[tile x=3 y=0 f=1.5]res://Assets/icons.png[/tile] Grows " + str(v) + " wheat.\n"
			"meat":
				out += "[tile x=6 y=0 f=1.5]res://Assets/icons.png[/tile] Prepares " + str(v) + " meat.\n"
			"livestock":
				out += "[tile x=5 y=0 f=1.5]res://Assets/icons.png[/tile] Breeds " + str(v) + " livestock.\n"
			"products":
				out += "[tile x=0 y=1 f=1.5]res://Assets/icons.png[/tile] Produces " + str(v) + " products.\n"
			"silicon":
				out += "[tile x=2 y=2 f=1.5]res://Assets/icons.png[/tile] Makes " + str(v) + " silicon.\n"
			"sand":
				out += "[tile x=1 y=2 f=1.5]res://Assets/icons.png[/tile] Mines " + str(v) + " sand.\n"
			"exoticfish":
				out += "[tile x=3 y=2 f=1.5]res://Assets/icons.png[/tile] Catches " + str(v) + " exotic fish.\n"
			"nature":
				out += "[tile x=7 y=0 f=1.5]res://Assets/icons.png[/tile] Gives " + str(v) + " nature points.\n"
			"entertainment":
				out += "[tile x=6 y=2 f=1.5]res://Assets/icons.png[/tile] Gives " + str(v) + " entertainment points.\n"
			"ores":
				out += "[tile x=5 y=1 f=1.5]res://Assets/icons.png[/tile] Mines " + str(v) + " ores.\n"
			"gemstones":
				out += "[tile x=6 y=1 f=1.5]res://Assets/icons.png[/tile] Refines " + str(v) + " gemstones.\n"
			"power":
				out += "[tile x=4 y=0 f=1.5]res://Assets/icons.png[/tile] Generates " + str(v) + " energy.\n"
			"tourists":
				out += "[tile x=4 y=2 f=1.5]res://Assets/icons.png[/tile] Receives " + str(v) + " tourists.\n"
			"flights":
				out += "[tile x=6 y=3 f=1.5]res://Assets/icons.png[/tile] Accomodates " + str(v) + " flights.\n"
			_:
				printerr("Text for " + d + " not found! (value = " + str(v) + ")")
	return out


func _on_visible_screen_entered() -> void:
	pass#$Sprite.show()


func _on_visible_screen_exited() -> void:
	pass#$Sprite.hide()


func _on_plane_timer_timeout() -> void:
	if building_name == "Airport Runway":
		$"../../Animations/Planes".SummonPlaneTo(Vector2(grid_pos * 48) + Vector2(24,24))
		$PlaneTimer.wait_time = randi_range(20,50)
		$PlaneTimer.start()

func SpawnDecision(id:int):
	decision_ID = id
	$DecisionButton.position = Vector2(randi_range(-32,32),randi_range(-32,32))
	$DecisionButton.show()

func HideDecision():
	$DecisionButton.hide()

func _on_decision_button_pressed() -> void:
	$"../../DecisionManager".DecisionPressed(decision_ID)
