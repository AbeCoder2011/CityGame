extends Button

@export var Building_Name := ""
const Atlas = preload("res://Assets/tiles.png")


func _ready() -> void:
	$Texture.texture = AtlasTexture.new()
	$Texture.texture.atlas = Atlas
	$Texture.texture.region = Rect2(Global.BuildingData[Building_Name]["atlas_coords"] * 16,Global.BuildingData[Building_Name].get("size",Vector2i(1,1)) * 16)
	$Texture/HoverDetection.size = Vector2(Global.BuildingData[Building_Name].get("size",Vector2(1,1)) * 16)  + Vector2(.5,.5)
	$Texture.scale = Vector2(4,4) - Vector2(.125,.125) + Global.BuildingData[Building_Name].get("size",Vector2i(1,1)) * .125
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
