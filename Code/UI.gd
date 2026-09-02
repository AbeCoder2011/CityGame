extends CanvasLayer

var already_unlocked := []

func _ready() -> void:
	for Cat :Button in $UI/Building/CategorySelection/CategoryList.get_children():
		Cat.pressed.connect(SelectCategory.bind(Cat.name))

func SelectCategory(cat_name:String) -> void:
	for n in $UI/Building/Categories.get_children():
		n.hide()
	$UI/Building/Categories.get_node(cat_name).show()


func _on_select_pressed() -> void:
	if Global.Tool == 1:
		$UI/Building/AnimationPlayer.play("hide")
	Global.Tool = 0
	$UI/Tools/Selection.offset_left = 3

func _on_draw_pressed() -> void:
	if Global.Tool != 1:
		$UI/Building/AnimationPlayer.play("show")
	Global.Tool = 1
	$UI/Tools/Selection.offset_left = 66
	

func _on_destroy_pressed() -> void:
	if Global.Tool == 1:
		$UI/Building/AnimationPlayer.play("hide")
	Global.Tool = 2
	$UI/Tools/Selection.offset_left = 128

func UpdateCityStats():
	$UI/CityInfo/Info/Money/Label.text = Global.GetBigNumber(Global.Money)
	$UI/CityInfo/Info/IncomePerSecond/Label.text = Global.GetBigNumber(Global.Income * 2) + "/s"
	$UI/CityInfo/Info/Happiness/Label.text = str(Global.Happiness)
	if Global.Happiness < 65:
		$UI/CityInfo/Info/Happiness/TextureRect.texture.region = Rect2(352,0,16,16)
	elif Global.Happiness < 130:
		$UI/CityInfo/Info/Happiness/TextureRect.texture.region = Rect2(320,0,16,16)
	else:
		$UI/CityInfo/Info/Happiness/TextureRect.texture.region = Rect2(288,0,16,16)
	$UI/CityInfo/Info/Population/Label.text = str(Global.Population)
	for n in $UI/Building/Categories.get_children():
		for b in n.get_children():
			if not b.name.begins_with("Gap"):
				b.Update()

func insufficient_funds():
	$UI/CityInfo/Info/Money/Label.label_settings.font_color = Color.DARK_RED
	$UI/CityInfo/Info/Money/RedTimer.start()
	await $UI/CityInfo/Info/Money/RedTimer.timeout
	$UI/CityInfo/Info/Money/Label.label_settings.font_color = Color.WHITE
	
func CheckBuildingUnlocks():
	for c in $UI/Building/Categories.get_children():
		for b in c.get_children():
			if b.name.begins_with("Gap"):
				continue
			if $"..".UnlockedBuildings[b.Building_Name] == true and not b.name in already_unlocked:
				b.Unlock()
				already_unlocked.append(b.name)
				$UI/Messages/NewBuilding/Name.text = b.Building_Name
				$UI/Messages/NewBuilding/Cost.text = "Cost:      " + str(Global.GetBuildingCost(b.Building_Name))
				$UI/Messages/NewBuilding/TextureRect.texture.region = Rect2(Global.BuildingData[b.Building_Name]["atlas_coords"] * 16,Global.BuildingData[b.Building_Name].get("size",Vector2(1,1)) * 16)
				$UI/Messages/AnimationPlayer.play("new_building")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("pause") and event.is_pressed():
		$UI/Pause.visible = !$UI/Pause.visible
		get_tree().paused = $UI/Pause.visible


func _on_save_pressed() -> void:
	$"..".SaveGame()


func _on_close_pressed() -> void:
	$UI/Achievements/Animation.play("Close")


func _on_continue_pressed() -> void:
	$UI/Pause.visible = !$UI/Pause.visible
	get_tree().paused = $UI/Pause.visible


func _on_save_and_return_pressed() -> void:
	$"..".SaveGame()
	print("a")
	$UI/Fade/AnimationPlayer.play("fade_out")
	await $UI/Fade/AnimationPlayer.animation_finished
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/title.tscn")

func _on_save_and_quit_pressed() -> void:
	$"..".SaveGame()
	get_tree().paused = false
	get_tree().quit()
