extends CanvasLayer

var already_unlocked := []

var now_hover = ""

var Progresses = {}


func _ready() -> void:
	for Cat :Button in $UI/Building/CategorySelection/CategoryList.get_children():
		Cat.pressed.connect(SelectCategory.bind(Cat.name))
	if FileAccess.file_exists("user://settings.cfg"):
		$UI/Pause.LoadSettings()
	var i = 0
	for n in $UI/Achievements/Container/Achievements.get_children():
		n.AchievementName = Global.ACHIEVEMENTS.keys()[i]
		i += 1
		n.Update()
	await get_tree().process_frame
	i = 0
	for n in $UI/Achievements/Container/Achievements.get_children():
		UpdateAchievementProgress(Global.ACHIEVEMENTS.keys()[i])
		i += 1

func Hover(nam,desc):
	now_hover = nam
	$UI/Achievements/Container/Container/Name.text = nam
	$UI/Achievements/Container/Container/Description.text = desc
	var p = Progresses.get(nam,false)
	if p is bool and p:
		$UI/Achievements/Container/Container/Unlocked.show()
		$UI/Achievements/Container/Container/Progress.hide()
	else:
		$UI/Achievements/Container/Container/Unlocked.hide()
		$UI/Achievements/Container/Container/Progress.show()
		if p is bool and not p:
			$UI/Achievements/Container/Container/Progress.value = 0
		else:
			$UI/Achievements/Container/Container/Progress.value = Progresses[nam]

func StopHover():
	now_hover = ""
	$UI/Achievements/Container/Container/Name.text = ""
	$UI/Achievements/Container/Container/Description.text = ""

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
				if Global.Settings.get("disable_unlock_notification",true):
					$UI/Messages/NewBuilding/Name.text = b.Building_Name
					$UI/Messages/NewBuilding/Cost.text = "Cost:      " + str(Global.GetBuildingCost(b.Building_Name))
					$UI/Messages/NewBuilding/TextureRect.texture.region = Rect2(Global.BuildingData[b.Building_Name]["atlas_coords"] * 16,Global.BuildingData[b.Building_Name].get("size",Vector2(1,1)) * 16)
					$UI/Messages/AnimationPlayer.play("new_building")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("pause") and event.is_pressed() and not event.is_echo():
		match $UI/Pause.menu:
			"main":
				$UI/Pause.visible = true
				get_tree().paused = true
				$UI/Pause.menu = "paused"
			"paused":
				$UI/Pause.visible = false
				get_tree().paused = false
				$UI/Pause.menu = "main"
			"settings":
				$UI/Pause._on_back_settings_pressed()
			"general_settings", "video_settings", "sound_settings", "accesibility_settings":
				$UI/Pause._on_back_sub_setting_pressed()


func _on_save_pressed() -> void:
	$"..".SaveGame()

func UpdateAchievementProgress(nam:String):
	var prog = Global.GetAchievementProgress(nam)
	$UI/Achievements/Container/Achievements.get_node(nam).Unlocked = is_same(prog, true)
	if prog is int:
		$UI/Achievements/Container/Achievements.get_node(nam).Progress = prog
	elif is_same(prog, false):
		$UI/Achievements/Container/Achievements.get_node(nam).Progress = 0
	$UI/Achievements/Container/Achievements.get_node(nam).Update()
	if now_hover == nam:
		Hover(nam,Global.ACHIEVEMENTS[nam]["data"]["desc"])
	Progresses[nam] = prog


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
