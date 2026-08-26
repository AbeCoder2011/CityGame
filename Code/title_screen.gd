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
func HasSave() -> bool:
	return FileAccess.file_exists(SAVE_PATH + SAVE_NAME)

func _ready() -> void:
	if not HasSave():
		$Main/Vbox/Continue.hide()
	for n : Control in $NewGame/Vbox.get_children():
		if not n.name in ["Back","Description","Difficulty"]:
			print(n.name)
			n.mouse_entered.connect(mouse_enter.bind(int(n.name)))
			n.mouse_exited.connect(mouse_exit.bind(int(n.name)))
			n.pressed.connect(difficulty_pressed.bind(int(n.name)))

func mouse_enter(id:int):
	$NewGame/Vbox/Description.text = DifficultyDescriptions[id]

func mouse_exit(_id:int):
	$NewGame/Vbox/Description.text = ""

func difficulty_pressed(id:int):
	Global.Difficulty = id
	Global.LoadSettings["load"] = false
	$Fade/Anim.play("fade_in")
	await $Fade/Anim.animation_finished
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

func _on_back_pressed() -> void:
	$NewGame.hide()
	$Credits.hide()
	$Main.show()

func _on_new_game_pressed() -> void:
	$Main.hide()
	$NewGame.show()


func _on_continue_pressed() -> void:
	Global.LoadSettings["load"] = true
	$Fade/Anim.play("fade_in")
	await $Fade/Anim.animation_finished
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_credits_pressed() -> void:
	$Credits.show()
	$Main.hide()


func _on_quit_pressed() -> void:
	get_tree().quit()
