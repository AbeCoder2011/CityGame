extends CanvasLayer

var already_unlocked := []
# main, pause, settings, general_settings, video_settings, sound_settings, accesibility_settings, 
var menu = "main"

func _ready() -> void:
	for Cat :Button in $UI/Building/CategorySelection/CategoryList.get_children():
		Cat.pressed.connect(SelectCategory.bind(Cat.name))

func SelectCategory(cat_name:String) -> void:
	for n in $UI/Building/Categories.get_children():
		n.hide()
	$UI/Building/Categories.get_node(cat_name).show()

func ShowInfo(txt:String):
	$UI/BuildingInfo.show()
	$UI/BuildingInfo/Text.text = txt
func HideInfo():
	$UI/BuildingInfo.hide()
	
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action("build_tool") and event.is_pressed():
		_on_draw_pressed()
	if event.is_action("select_tool") and event.is_pressed():
		_on_select_pressed()
	if event.is_action("erase_tool") and event.is_pressed():
		_on_destroy_pressed()

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
			if $"..".UnlockedBuildings.get(b.Building_Name, false) == true and not b.name in already_unlocked:
				b.Unlock()
				already_unlocked.append(b.name)
				if Global.Settings.get("unlock_notification",true):
					$UI/Messages/NewBuilding/Name.text = b.Building_Name
					$UI/Messages/NewBuilding/Cost.text = "Cost:      " + str(Global.GetBuildingCost(b.Building_Name))
					$UI/Messages/NewBuilding/TextureRect.texture.region = Rect2(Global.BuildingData[b.Building_Name]["atlas_coords"] * 16,Global.BuildingData[b.Building_Name].get("size",Vector2(1,1)) * 16)
					$UI/Messages/AnimationPlayer.play("new_building")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("pause") and event.is_pressed() and not event.is_echo():
		match menu:
			"main":
				$UI/Pause.visible = true
				get_tree().paused = true
				menu = "paused"
			"paused":
				$UI/Pause.visible = false
				get_tree().paused = false
				menu = "main"
			"settings":
				_on_back_settings_pressed()
			"general_settings", "video_settings", "sound_settings", "accesibility_settings":
				_on_back_sub_setting_pressed()


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


func _on_settings_pressed() -> void:
	$UI/Pause/Main.hide()
	$UI/Pause/Settings.show()
	menu = "settings"

func _on_back_settings_pressed() -> void:
	$UI/Pause/Settings.hide()
	$UI/Pause/Main.show()
	menu = "paused"

func _on_back_sub_setting_pressed() -> void:
	$UI/Pause/General.hide()
	$UI/Pause/Sound.hide()
	$UI/Pause/Video.hide()
	$UI/Pause/Accesibility.hide()
	$UI/Pause/Settings.show()
	menu = "settings"

func SubSetting(nam:String):
	match nam:
		"general":
			$UI/Pause/General.show()
			menu = "general_settings"
		"sound":
			menu = "sound_settings"
			$UI/Pause/Sound.show()
		"video":
			menu = "video_settings"
			$UI/Pause/Video.show()
		"accesibility":
			menu = "accesibility_settings"
			$UI/Pause/Accesibility.show()
	$UI/Pause/Settings.hide()

func SetSettingValue(new_value:float,nam:String):
	Global.Settings[nam] = new_value
	match nam:
		"camera_speed":
			$"UI/Pause/General/HBoxContainer/1/CamSpeed".text = "Camera Speed (" + str(int(new_value)) + "px)"
		"autosave_interval":
			$"UI/Pause/General/HBoxContainer/1/AutosaveInterval2".text = "Autosave Interval (" + str(int(new_value)) + "s)"

func SetSettingBool(new_state:bool,nam:String):
	Global.Settings[nam] = new_state
	match nam:
		"autosave":
			$"UI/Pause/General/HBoxContainer/1/AutosaveInterval2".visible = new_state
			$"UI/Pause/General/HBoxContainer/1/AutosaveIntervalSlider".visible = new_state
	
func SetOptionID(new_id:int,nam:String):
	Global.Settings[nam] = new_id
