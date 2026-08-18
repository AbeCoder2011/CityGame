extends Button

@export var Building_Name := ""
const Atlas = preload("res://Assets/tiles.png")

@onready var building_size : Vector2= Global.BuildingData[Building_Name].get("size",Vector2(1,1))

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
	name = Building_Name
	pressed.connect(SelectBuilding)
	$Info/Name.text = Building_Name
	$Info/Cost.text = "Cost:      " + str(Global.BuildingData[Building_Name]["cost"])
	if Global.BuildingData[Building_Name].has("description"):
		$Info/Info.text = Global.BuildingData[Building_Name]["description"]
	else:
		$Info/Info.text = "[MISSING]"
	$Info.hide()
	
func SelectBuilding():
	Global.CurrentBuilding = Building_Name


func hover_start() -> void:
	$Info.show()


func hover_end() -> void:
	$Info.hide()

func Update():
	if Global.Money < Global.BuildingData[Building_Name]["cost"]:
		modulate = Color("888888")
	else:
		modulate = Color("ffffffff")
		
