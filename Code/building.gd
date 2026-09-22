extends Node2D

var inputs : Dictionary[String,float] = {}
var extra_data : Dictionary = {}

var power := 0
var use_power := false
var building_name = ""

var grid_pos := Vector2i.ZERO
var rail_connections := {"l":false,"r":false,"u":false,"d":false}

var Claims : Dictionary = {}

var UI_Settings = {}

var selected = false

var line = preload("res://Scenes/line.tscn")

func init_building(nam,pos) -> void:
	building_name = nam
	grid_pos = pos
	if building_name == "Wind Turbine":
		$Sprite.hide()
		$AnimatedSprite2D.show()
	else:
		$Sprite.texture = AtlasTexture.new()
		$Sprite.position = GetSize(nam) * 24
		$Sprite.texture.atlas = Global.BuildingTilemap
	$Info/TextureRect.texture = AtlasTexture.new()
	if nam == "Rail":
		var other_rails = $"..".Rails
		var locations = [Vector2i(pos.x+1,pos.y),Vector2i(pos.x-1,pos.y),Vector2i(pos.x,pos.y+1),Vector2i(pos.x,pos.y-1),]
		for n : Vector2i in other_rails:
			if n in locations:
				other_rails[n].UpdateRailSprite()
		$HoverDetection.size = GetSize(nam) * 48
		UpdateRailSprite()
	else:
		$Info/TextureRect.texture.atlas = Global.IconTilemap
		$HoverDetection.size = GetSize(nam) * 48
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
			$Info/TextureRect.texture.region = Rect2(1*32,0,16,16)
			$Info.text = str(int(inputs.get("population",0)))
		"Mill":
			$Info/TextureRect.texture.region = Rect2(2*32,0,16,16)
			$Info.text = str(int(inputs.get("flour",0)))
		"Small Wheatfield","Large Wheatfield":
			$Info/TextureRect.texture.region = Rect2(3*32,0,16,16)
			$Info.text = str(int(inputs.get("wheat",0)))
		"Transformator Building":
			$Info/TextureRect.texture.region = Rect2(4*32,0,16,16)
			$Info.text = str(int(inputs.get("power",0)))
		"Animal Farm":
			$Info/TextureRect.texture.region = Rect2(5*32,0,16,16)
			$Info.text = str(int(inputs.get("livestock",0)))
		"Butcher":
			$Info/TextureRect.texture.region = Rect2(6*32,0,16,16)
			$Info.text = str(int(inputs.get("meat",0)))
		"Pocket Park","Small Park","Fountain Park","Large Park":
			$Info/TextureRect.texture.region = Rect2(7*32,0,16,16)
			$Info.text = str(int(inputs.get("nature",0)))
		"Small Factory","Large Factory":
			$Info/TextureRect.texture.region = Rect2(8*32,0,16,16)
			$Info.text = str(int(inputs.get("products",0)))
		"Mine":
			$Info/TextureRect.texture.region = Rect2(13*32,0,16,16)
			$Info.text = str(int(inputs.get("ores",0)))
		"Ore Extractor":
			$Info/TextureRect.texture.region = Rect2(14*32,0,16,16)
			$Info.text = str(int(inputs.get("gemstones",0)))
		"Library","University","Elementary School":
			$Info/TextureRect.texture.region = Rect2(15*32,0,16,16)
			$Info.text = str(int(inputs.get("gemstones",0)))
		"Fishing Hut":
			$Info/TextureRect.texture.region = Rect2(16*32,0,16,16)
			$Info.text = str(int(inputs.get("fish",0)))
		"Sand Mine":
			$Info/TextureRect.texture.region = Rect2(17*32,0,16,16)
			$Info.text = str(int(inputs.get("sand",0)))
		"Smeltery":
			$Info/TextureRect.texture.region = Rect2(18*32,0,16,16)
			$Info.text = str(int(inputs.get("glass",0)))
			
		_:
			$Info.hide()


func _on_pressed() -> void:
	if Global.Tool == 2:
		hide()
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
	var water = 0
	var other_rails : Dictionary = $"..".Rails
	rail_connections = {"l":false,"r":false,"u":false,"d":false}
	if other_rails.has(Vector2i(grid_pos.x + 1, grid_pos.y)):
		rail_connections["r"] = true
	if other_rails.has(Vector2i(grid_pos.x - 1, grid_pos.y)):
		rail_connections["l"] = true
	if other_rails.has(Vector2i(grid_pos.x, grid_pos.y + 1)):
		rail_connections["d"] = true
	if other_rails.has(Vector2i(grid_pos.x, grid_pos.y - 1)):
		rail_connections["u"] = true
	if $"../../Terrain".get_tile(grid_pos) == 1:
		water = 32
	
	if rail_connections["l"] and rail_connections["u"] and rail_connections["r"] and rail_connections["d"]:
		$Sprite.texture.region = Rect2(Vector2(288,80 + water), Vector2(16,16))
		$Sprite.rotation_degrees = 0
	elif rail_connections["l"] and rail_connections["r"] and rail_connections["d"]:
		$Sprite.texture.region = Rect2(Vector2(288,96 + water), Vector2(16,16))
		$Sprite.rotation_degrees = 0
	elif rail_connections["l"] and rail_connections["u"] and rail_connections["d"]:
		$Sprite.texture.region = Rect2(Vector2(288,96 + water), Vector2(16,16))
		$Sprite.rotation_degrees = 90
	elif rail_connections["l"] and rail_connections["u"] and rail_connections["r"]:
		$Sprite.texture.region = Rect2(Vector2(288,96 + water), Vector2(16,16))
		$Sprite.rotation_degrees = 180
	elif rail_connections["u"] and rail_connections["r"] and rail_connections["d"]:
		$Sprite.texture.region = Rect2(Vector2(288,96 + water), Vector2(16,16))
		$Sprite.rotation_degrees = 270
	elif rail_connections["l"] and rail_connections["u"]:
		$Sprite.texture.region = Rect2(Vector2(304,96 + water), Vector2(16,16))
		$Sprite.rotation_degrees = 0
	elif rail_connections["u"] and rail_connections["r"]:
		$Sprite.texture.region = Rect2(Vector2(304,96 + water), Vector2(16,16))
		$Sprite.rotation_degrees = 90
	elif rail_connections["r"] and rail_connections["d"]:
		$Sprite.texture.region = Rect2(Vector2(304,96 + water), Vector2(16,16))
		$Sprite.rotation_degrees = 180
	elif rail_connections["d"] and rail_connections["l"]:
		$Sprite.texture.region = Rect2(Vector2(304,96 + water), Vector2(16,16))
		$Sprite.rotation_degrees = 270
	elif rail_connections["u"] or rail_connections["d"]:
		$Sprite.texture.region = Rect2(Vector2(304,80 + water), Vector2(16,16))
		$Sprite.rotation_degrees = 0
	elif rail_connections["l"] or rail_connections["r"]:
		$Sprite.texture.region = Rect2(Vector2(304,80 + water), Vector2(16,16))
		$Sprite.rotation_degrees = 90
	else:
		$Sprite.texture.region = Rect2(Vector2(304,80 + water), Vector2(16,16))
		$Sprite.rotation_degrees = 0
	
func GetSize(n) -> Vector2i:
	return Global.BuildingData[n].get("size",Vector2i(1,1))

func GetBuildingInfo() -> String:
	var out = "[font=res://Assets/Fonts/Space_Mono/SpaceMono.ttf]" + building_name + "\n"
	for d in extra_data.keys():
		var v = int(extra_data[d])
		match d:
			"population":
				if extra_data.has("gets_pop_boost"):
					if extra_data["gets_pop_boost"]:
						out += "👥 " + str(v) + " population nearby. ([b]Sufficient[/b])\n"
					else:
						out += "👥 " + str(v) + " population nearby. ([b]Not sufficient[/b])\n"
				else:
					out += "👥 " + str(v) + " population nearby.\n"
			"base_pop":
				out += "👥 " + str(v) + " base population.\n"
			"happiness":
				out += "😊 Happiness value: " + str(int(v / inputs.get("population",1))) + "\n"
			"wheat":
				out += "🌾 " + str(v) +  " wheat nearby.\n"
			"flour":
				out += "🍚 " + str(v) +  " flour nearby.\n"
			"industry":
				out += "🏭 Industry debuff: " + str(v) +  "x.\n"
			"meat":
				out += "🥩 " + str(v) +  " meat nearby.\n"
			"livestock":
				out += "🐖 " + str(v) +  " livestock nearby.\n"
			"products":
				out += "📦 " + str(v) +  " products nearby.\n"
			"nature":
				out += "🌿 Nature score: " + str(v) + "\n"
			"entertainment":
				out += "🎬 Entertainment score: " + str(v) + "\n"
			"ores":
				out += "🪨 " + str(v) +  " ores nearby.\n"
			"gemstones":
				out += "💎 " + str(v) +  " gemstones nearby.\n"
			"water":
				out += "🌊 " + str(v) +  " water tiles nearby.\n"
			"mountains":
				out += "⛰️ " + str(v) +  " mountain tiles nearby.\n"
			"desert":
				out += "🏜️ " + str(v) +  " desert tiles nearby.\n"
			"sand":
				out += "🏖️ " + str(v) +  " sand nearby.\n"
			"shops_nearby":
				out += "🏪 " + str(v) +  " other shops nearby.\n"
			"mountains":
				out += "⛰️ " + str(v) +  " mountain tiles nearby.\n"
			"power_boost":
				if extra_data.has("power_boost_mult"):
					out += "⚡ " + str(v) +  " power supplied nearby. (" + str(extra_data["power_boost_mult"]) + "x boost)\n"
				else:
					out += "⚡ " + str(v) +  " power supplied nearby.\n"
			"global_power":
				out += "🔋 Global power grid has " + str(v) +  " power.\n"
			"power":
				out += "🔋 Generates " + str(v) +  " energy.\n"
			"power_boost_mult","gets_pop_boost":
				pass
			_:
				printerr("Extra text for " + d + " not found! (value = " + str(v) + ")")
	if use_power:
		out += "🔋 " + str(power) +  " power collected nearby.\n"
	for d in inputs.keys():
		var v = int(inputs[d])
		var decimal_v = inputs[d]
		match d:
			"population":
				out += "👥 Houses " + str(v) + " people.\n"
			"money":
				out += "[img]res://Assets/coin.png[/img] Earns " + str(Global.GetBigNumber(decimal_v*2)) + "/s\n"
			"flour":
				out += "🍚 Produces " + str(v) +  " flour.\n"
			"wheat":
				out += "🌾 Grows" + str(v) +  " wheat.\n"
			"meat":
				out += "🥩 Prepares " + str(v) +  " meat.\n"
			"livestock":
				out += "🐖 Breeds " + str(v) +  " livestock.\n"
			"products":
				out += "📦 Produces " + str(v) +  " products.\n"
			"silicon":
				out += "🪨 Makes " + str(v) +  " silicon.\n"
			"sand":
				out += "📦 Mines " + str(v) +  " sand.\n"
			"exoticfish":
				out += "🐠 Catches " + str(v) + " exotic fish.\n"
			"nature":
				out += "🌿 Gives " + str(v) +  " nature points.\n"
			"entertainment":
				out += "🎬 Gives " + str(v) +  " entertainment points.\n"
			"ores":
				out += "🪨 Mines " + str(v) +  " ores.\n"
			"gemstones":
				out += "💎 Refines " + str(v) +  " gemstones.\n"
			"power":
				out += "🔋 Generates " + str(v) +  " energy.\n"
			_:
				printerr("Text for " + d + " not found! (value = " + str(v) + ")")
	return out
	
#papyrus_knight
