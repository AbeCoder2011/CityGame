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

var building_name = ""

var selected = false

func init_building(nam) -> void:
	building_name = nam
	$Sprite.texture = AtlasTexture.new()
	$Sprite.texture.atlas = Global.BuildingTilemap
	$Info/TextureRect.texture = AtlasTexture.new()
	$Info/TextureRect.texture.atlas = Global.IconTilemap
	$HoverDetection.size = Global.BuildingData[nam].get("size",Vector2i(1,1)) * 48
	$Sprite.texture.region = Rect2(Global.BuildingData[nam]["atlas_coords"] * 16,Global.BuildingData[nam].get("size",Vector2i(1,1))*16)
	
func display_income(i:float):
	if $Visible.is_on_screen() and Global.Zoom >= 2.0:
		if i == 0:
			return
		if int(i) == i:
			$Income.text = "+" + str(int(i))
		else:
			$Income.text = "+" + str(i)
		$Income/AnimationPlayer.play("play")


func _on_mouse_enter() -> void:
	$Info.show()
	UpdateData()
			


func _on_mouse_exit() -> void:
	$Info.hide()

func UpdateData():
	match building_name:
		"Basic House", "Double House", "Small Apartment Complex","Large Apartment Complex", "Mega Apartment Complex","Low-Budget Apartment":
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
