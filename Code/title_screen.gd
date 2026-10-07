extends Control

const DifficultyDescriptions = {
	1:"[font_size=24][font=res://Assets/Fonts/Space_Mono/SpaceMono.ttf]The easiest difficulty for CityScape, or the sandbox difficulty. Building prices barely scale and you start with a large budget.",
	2:"[font_size=24][font=res://Assets/Fonts/Space_Mono/SpaceMono.ttf]The easier difficulty for CityScape. Building prices scale a little bit, and you start with a moderate budget.",
	3:"[font_size=24][font=res://Assets/Fonts/Space_Mono/SpaceMono.ttf]The intended difficulty for CityScape. Building prices scale moderately, and you start with a moderate budget.",
	4:"[font_size=24][font=res://Assets/Fonts/Space_Mono/SpaceMono.ttf]The hard difficulty for CityScape. Building prices scale quickly, and you start with a small budget.",
	5:"[font_size=24][font=res://Assets/Fonts/Space_Mono/SpaceMono.ttf]The hardest difficulty for CityScape. Building prices scale very quickly, and you start with a small budget. ",
}

const SAVE_PATH := "user://saves/"
const SAVE_NAME := "save.tres"

const MiniTileMap = {
	
}

func HasSave() -> bool:
	return FileAccess.file_exists(SAVE_PATH + SAVE_NAME)

func _ready() -> void:
	if not Global.First:
		$Fade/Anim.play("fade_in")
	Global.First = false
	RerollSeed()
	if not HasSave():
		$Main/Vbox/Continue.hide()
	for n : Control in $NewGame/Vbox.get_children():
		if not n.name in ["Back","Description","Difficulty","ExtraSettings"]:
			n.mouse_entered.connect(mouse_enter.bind(int(n.name)))
			n.mouse_exited.connect(mouse_exit.bind(int(n.name)))
			n.pressed.connect(difficulty_pressed.bind(int(n.name)))
	if FileAccess.file_exists("user://settings.cfg"):
		$Pause.LoadSettings()

func mouse_enter(id:int):
	$NewGame/Vbox/Description.text = DifficultyDescriptions[id]

func mouse_exit(_id:int):
	$NewGame/Vbox/Description.text = ""

func difficulty_pressed(id:int):
	for n in $NewGame/Vbox.get_children():
		if n is Button:
			n.disabled = true
	Global.Difficulty = id
	Global.LoadSettings["load"] = false
	$Fade/Anim.play("fade_out")
	await $Fade/Anim.animation_finished
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

func _on_back_pressed() -> void:
	$NewGame.hide()
	$Credits.hide()
	$Pause.hide()
	$Main.show()
	

func _on_new_game_pressed() -> void:
	$Main.hide()
	$NewGame.show()


func _on_continue_pressed() -> void:
	$Main/Vbox/Continue.disabled = true
	Global.LoadSettings["load"] = true
	$Fade/Anim.play("fade_out")
	await $Fade/Anim.animation_finished
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_credits_pressed() -> void:
	$Credits.show()
	$Main.hide()

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_settings_pressed() -> void:
	$Main.hide()
	$Pause.show()
	$Pause._on_settings_pressed()

func OnSettingChanged(new_value:Variant,nam:String):
	print(nam," ---> ",new_value)
	match nam:
		"map_size":
			Global.GameSettings[nam] = int(floor(new_value))
		"seed":
			if is_same(new_value,""):
				Global.GameSettings.erase(nam)
				$NewGame/ExtraSettings/Control.hide()
			else:
				Global.GameSettings[nam] = int(new_value)
				$NewGame/ExtraSettings/Control.show()
		_:
			Global.GameSettings[nam] = new_value
	match nam:
		"map_size":
			$NewGame/ExtraSettings/Label.text = "Map size (%dx%d)" % [floor(new_value * 12 + 6),floor(new_value * 12 + 6)]
		"seed":
			$NewGame/ExtraSettings/Control/TileMapLayer.clear()
			$NewGame/ExtraSettings/Control/TileMapLayer.seed = int(new_value)
			$NewGame/ExtraSettings/Control/TileMapLayer.SetUpNoiseMaps(int(new_value))
			print(Global.GameSettings)
			for x in range(-30,30):
				for y in range(-30,30):
					var tile = $NewGame/ExtraSettings/Control/TileMapLayer.FindTerrainTile(x,y)
					$NewGame/ExtraSettings/Control/TileMapLayer.set_cell(Vector2i(x+30,y+30),0,tile)
func _on_extra_settings_pressed() -> void:
	$NewGame/ExtraSettings.visible = !$NewGame/ExtraSettings.visible
	$NewGame/ExtraSettings2.visible = !$NewGame/ExtraSettings2.visible

func RerollSeed() -> void:
	var s : int = -1
	while not $NewGame/ExtraSettings/Control/TileMapLayer.ValidateSeed(s) or s == -1:
		s = randi()
	$NewGame/ExtraSettings/HBoxContainer/Seed.text = str(s)
	OnSettingChanged(s,"seed")
