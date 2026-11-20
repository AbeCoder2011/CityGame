extends Control

const DifficultyDescriptions = {
	1:"[font_size=24][font=res://Assets/Fonts/Space_Mono/SpaceMono.ttf]The easiest difficulty for CityScape, or the sandbox difficulty. Building prices barely scale and you start with a large budget.",
	2:"[font_size=24][font=res://Assets/Fonts/Space_Mono/SpaceMono.ttf]The easier difficulty for CityScape. Building prices scale a little bit, and you start with a moderate budget.",
	3:"[font_size=24][font=res://Assets/Fonts/Space_Mono/SpaceMono.ttf]The intended difficulty for CityScape. Building prices scale moderately, and you start with a moderate budget.",
	4:"[font_size=24][font=res://Assets/Fonts/Space_Mono/SpaceMono.ttf]The hard difficulty for CityScape. Building prices scale quickly, and you start with a small budget.",
	5:"[font_size=24][font=res://Assets/Fonts/Space_Mono/SpaceMono.ttf]The hardest difficulty for CityScape. Building prices scale very quickly, and you start with a small budget. ",
}

var SaveButton = preload("res://Scenes/SaveButton.tscn")

const SAVE_PATH := "user://saves/"
const SAVE_NAME := "save.tres"
const SPLASH_TEXTS := [
	"Special thanks to our friends: []",
	"why do they call it oven if you of in the cold food of out hot eat the food",
	"- signed by mayor jerry",
	"vive la mayor jerry",
	#"Built by Gamers!",
	"Stay Hydrated",
	"Mayor [font_size=96]Jerry[font_size=64]!",
	"with 'frequent' updates",
	"D:",
	"[color=pink]:3",
	"the worlds first AAAA game (real)",
	"made by humans",
	"they don't pay me enough for this",
	"i use [color=red]arch[color=white] btw",
	"human, i remember you're [color=red]genocides[color=white]",
	"[font=res://Assets/Fonts/wingding.ttf]VERY, VERY, INTERESTING",
]

var Textures = {}
var Data : Dictionary[String,Dictionary] = {}

const MiniTileMap = {
	
}

func HasSave() -> bool:
	return FileAccess.file_exists(SAVE_PATH + SAVE_NAME)

func _ready() -> void:
	random_splash_text()
	Global.GameSettings = {}
	if not Global.First:
		$Fade/Anim.play("fade_in")
		$Base/TextureRect.hide()
	else:
		$Base/TextureRect/AnimationPlayer.play("hide")
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
func random_splash_text():
	$"Base/Splash Text".text = "[font=res://Assets/Fonts/ShantellSans-VariableFont_BNCE,INFM,SPAC,wght.ttf][font_size=64]" + SPLASH_TEXTS.pick_random()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("HACK"):
		OnSettingChanged(not Global.GameSettings.get("hacked",false),"hacked")
		# ^^^ Invert the value, if it doesn't exist: defaults to: not false (true)

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
	$LoadGame.hide()
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

func LoadAutosave(n:String) -> void:
	Global.LoadSettings["load"] = true
	Global.LoadSettings["custom_save"] = n
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
	match nam:
		"map_size":
			Global.GameSettings[nam] = int(floor(new_value))
		"seed":
			if is_same(new_value,""):
				Global.GameSettings.erase(nam)
				$NewGame/ExtraSettings/Control.hide()
			else:
				if str(new_value).is_valid_int():
					Global.GameSettings[nam] = int(new_value)
				else:
					Global.GameSettings[nam] = hash(new_value)
				$NewGame/ExtraSettings/Control.show()
		"water_amount","forest_amount","mountain_amount","wheat_field_amount","desert_amount":
			Global.GameSettings[nam] = new_value
			GenerateTerrainPreview(Global.GameSettings.get("seed",0))
		_:
			Global.GameSettings[nam] = new_value
	match nam:
		"map_size":
			$NewGame/ExtraSettings/Label.text = "Map size (%dx%d)" % [floor(new_value * 12 + 6),floor(new_value * 12 + 6)]
		"seed":
			GenerateTerrainPreview(int(Global.GameSettings.get(nam,0)))
		"hacked":
			$NewGame/HackedLabel.visible = Global.GameSettings.get("hacked",false)
func _on_extra_settings_pressed() -> void:
	$NewGame/ExtraSettings.visible = !$NewGame/ExtraSettings.visible
	$NewGame/ExtraSettings2.visible = !$NewGame/ExtraSettings2.visible

func RerollSeed() -> void:
	var s : int = -1
	while not $NewGame/ExtraSettings/Control/MiniTerrain.ValidateSeed(s) or s == -1:
		s = randi()
	$NewGame/ExtraSettings/HBoxContainer/Seed.text = str(s)
	OnSettingChanged(s,"seed")

func GenerateTerrainPreview(s:int):
	$NewGame/ExtraSettings/Control/MiniTerrain.clear()
	$NewGame/ExtraSettings/Control/MiniTerrain.world_seed = int(s)
	$NewGame/ExtraSettings/Control/MiniTerrain.SetUpNoiseMaps(int(s))
	for x in range(-33,33):
		for y in range(-33,33):
			$NewGame/ExtraSettings/Control/MiniTerrain.set_cell(Vector2i(x+33,y+33),0,$NewGame/ExtraSettings/Control/MiniTerrain.FindTerrainTile(x,y))

func GetAutoSaves():
	for n in $LoadGame/Hbox/Saves.get_children():
		if not n.name in ["Back"]:
			n.free()
	
	
	DirAccess.make_dir_absolute("user://autosaves/")
	
	var dir := DirAccess.open("user://autosaves/")
	dir.list_dir_begin()
	var files : Array = dir.get_files()
	files.sort_custom(SortByDate)
	for n in files:
		var l = SaveButton.instantiate()
		print("[%s] Created Button" % [n])
		l.SaveName = n
		var rs = ResourceLoader.load("user://autosaves/" + n)
		Textures[n] = ImageTexture.create_from_image(rs.get("image"))
		Data[n] = rs.get("extra_data")
		
		print("[%s] Downloaded texture" % [n])
		l.text = FormatSaveName(n)
		$LoadGame/Hbox/Saves.add_child(l)
	dir.list_dir_end()

func SortByDate(a:String,b:String):
	return FileAccess.get_modified_time("user://autosaves/" + a) > FileAccess.get_modified_time("user://autosaves/" + b)

func _on_load_game_pressed() -> void:
	$Main.hide()
	$LoadGame.show()
	GetAutoSaves()


func FormatSaveName(txt:String):
	var new = txt.rstrip(".tres")
	new = new.split("-")
	if len(new) < 6:
		printerr("kut ",new)
		return txt
	var out = "%s-%s-%s - %02d:%02d:%02d" % [new[2],new[1],new[0],int(new[3]),int(new[4]),int(new[5])]
	return out

func OnHover(nam:String):
	var img = Textures.get(nam)
	var data : Dictionary = Data.get(nam)
	if not data.is_empty():
		$LoadGame/Hbox/Data/RichTextLabel.source_text = GetSaveText(data)
	else:
		$LoadGame/Hbox/Data/RichTextLabel.source_text = ""
		
	$LoadGame/Hbox/Data/Image.texture = img
	$LoadGame/Hbox/Data/Image.show()

func OnNotHover():
	$LoadGame/Hbox/Data/Image.hide()

func GetSaveText(d:Dictionary) -> String:
	var out = "[font=res://Assets/Fonts/Space_Mono/SpaceMono.ttf][font_size=25]Save\n"
	out += "[tile x=0 y=0 f=1.6]res://Assets/icons.png[/tile] " + Global.GetBigNumber(d["money"]) + "\n"
	out += "[tile x=2 y=0 f=1.6]res://Assets/icons.png[/tile] " + Global.GetBigNumber(d["population"]) + "\n"
	if d["happiness"] < 65:
		out += "[tile x=22 y=0 f=1.6]res://Assets/icons.png[/tile] " + Global.GetBigNumber(d["happiness"]) + "\n"
	elif d["happiness"] < 130:
		out += "[tile x=20 y=0 f=1.6]res://Assets/icons.png[/tile] " + Global.GetBigNumber(d["happiness"]) + "\n"
	else:
		out += "[tile x=18 y=0 f=1.6]res://Assets/icons.png[/tile] " + Global.GetBigNumber(d["happiness"]) + "\n"
	out += "[tile x=24 y=0 f=1.6]res://Assets/icons.png[/tile] " + Global.GetBigNumber(d["income"]) + "\n"

	
	
	
	
	return out
func _input(event: InputEvent) -> void:
	if event.is_action("HACK") && event.is_pressed():
		random_splash_text()
