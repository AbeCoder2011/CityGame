extends Button

@export var Building_Name := ""
const Atlas = preload("res://Assets/tiles.png")


@onready var building_size : Vector2= Global.BuildingData[Building_Name].get("size",Vector2(1,1))

var unlocked = false

func _ready() -> void:
	$Texture.texture = AtlasTexture.new()
	$Texture.texture.atlas = Atlas
		#$Locked.show()
		#$Locked.size = Vector2(21.333,21.333) * building_size
		#if not building_size == Vector2(1,1):
			#$Locked.scale = Vector2(3.09375,3.09375)
	$Texture.texture.region = Rect2(Global.BuildingData[Building_Name]["atlas_coords"] * 16,building_size * 16)
	$Texture/HoverDetection.size = Vector2(building_size * 16)  + Vector2(.5,.5)
	$Texture.scale = Vector2(4,4) - Vector2(.125,.125) + building_size * .125
	$LockedTexture.scale = Vector2(4,4) - Vector2(.125,.125) + building_size * .125
	$LockedTexture.size = building_size * 16
	name = Building_Name
	pressed.connect(SelectBuilding)
	$Info/Name.text = Building_Name
	$Info/Cost.text = "Cost:      " + str(Global.BuildingData[Building_Name]["cost"])
	if Global.BuildingData[Building_Name].has("description"):
		$Info/Info.text = Global.BuildingData[Building_Name]["description"]
	else:
		$Info/Info.text = "[MISSING]"
	if Global.UnlockRequirements.has(Building_Name):
		var t = "Locked - To unlock:\n"
		for n in Global.UnlockRequirements[Building_Name]:
			match n["type"]:
				"population":
					t += " - Reach " + str(n["amount"]) + " population\n" 
				"money":
					t += " - Reach " + str(n["amount"]) + " money\n"
				"building_count":
					t += " - Build " + str(n["amount"]) + " " + str(n["building"]) + "\n"
				"total_buildings":
					t += " - Build " + str(n["amount"]) + " total buildings\n"
				_:
					t += " - ???\n"
		$Info/LockedInfo.text = t
	else:
		Unlock()
	$Info.hide()
	
func SelectBuilding():
	Global.CurrentBuilding = Building_Name


func hover_start() -> void:
	$Info.show()


func hover_end() -> void:
	$Info.hide()

func Update():
	$Info/Cost.text = "Cost:      " + str(Global.GetBuildingCost(Building_Name))
	if Global.Money < Global.GetBuildingCost(Building_Name) and unlocked:
		modulate = Color("888888")
	else:
		modulate = Color("ffffffff")

func UpdateCost(new_cost):
	$Info/Cost.text = "Cost:      " + str(new_cost)
	

func Unlock():
	$Info/Info.show()
	$Info/LockedInfo.hide()
	$LockedTexture.hide()
	$Info/LockedName.hide()
	$Info/Name.show()
	$Info/LockedCost.hide()
	$Info/Cost.show()
	unlocked = true
	
	
