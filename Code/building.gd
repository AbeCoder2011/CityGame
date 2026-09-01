extends Node2D

var money = 0.0
var population := 0
var products := 0
var flour := 0
var wheat := 0
var electronics := 0
var power := 0
var livestock := 0
var meat := 0
var nature := 0
var entertainment := 0
var ores := 0
var gemstones := 0

var building_name = ""

var grid_pos := Vector2i.ZERO
var rail_connections := {"l":false,"r":false,"u":false,"d":false}

var selected = false

func init_building(nam,pos) -> void:
	building_name = nam
	grid_pos = pos
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
	UpdateData()
			


func _on_mouse_exit() -> void:
	$Info.hide()

func UpdateData():
	match building_name:
		"Basic House", "Double House", "Small Apartment Complex","Large Apartment Complex", "Mega Apartment Complex","Low-Budget Apartment","Giant Apartment Complex":
			$Info/TextureRect.texture.region = Rect2(32,0,16,16)
			$Info.text = str(population)
		"Small Supermarket", "Large Supermarket", "Electronics Store","Cafe", "Bakery", "Restaurant", "Mall":
			$Info/TextureRect.texture.region = Rect2(0,0,16,16)
			$Info.text = Global.GetBigNumber(money) + "/s"
		"Mill":
			$Info/TextureRect.texture.region = Rect2(64,0,16,16)
			$Info.text = str(flour)
		"Small Wheatfield","Large Wheatfield":
			$Info/TextureRect.texture.region = Rect2(96,0,16,16)
			$Info.text = str(wheat)
		"Transformator Building":
			$Info/TextureRect.texture.region = Rect2(128,0,16,16)
			$Info.text = str(power)
		"Animal Farm":
			$Info/TextureRect.texture.region = Rect2(160,0,16,16)
			$Info.text = str(livestock)
		"Butcher":
			$Info/TextureRect.texture.region = Rect2(192,0,16,16)
			$Info.text = str(meat)
		"Pocket Park","Small Park","Fountain Park","Large Park":
			$Info/TextureRect.texture.region = Rect2(224,0,16,16)
			$Info.text = str(nature)
		"Small Factory","Large Factory":
			$Info/TextureRect.texture.region = Rect2(256,0,16,16)
			$Info.text = str(products)
		"Mine":
			$Info/TextureRect.texture.region = Rect2(416,0,16,16)
			$Info.text = str(ores)
		"Ore Extractor":
			$Info/TextureRect.texture.region = Rect2(448,0,16,16)
			$Info.text = str(gemstones)
			
		_:
			$Info.hide()


func _on_pressed() -> void:
	if Global.Tool == 2:
		hide()
		Global.Money += floor(Global.BuildingData[building_name]["cost"] / 2)
		Global.BuildingUses[building_name] -= 1
		$"..".AddToRemovalList(self)
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
	if other_rails.has(Vector2i(grid_pos.x + 1, grid_pos.y)):
		rail_connections["r"] = true
	if other_rails.has(Vector2i(grid_pos.x - 1, grid_pos.y)):
		rail_connections["l"] = true
	if other_rails.has(Vector2i(grid_pos.x, grid_pos.y + 1)):
		rail_connections["d"] = true
	if other_rails.has(Vector2i(grid_pos.x, grid_pos.y - 1)):
		rail_connections["u"] = true
	if rail_connections["l"] and rail_connections["u"]:
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
