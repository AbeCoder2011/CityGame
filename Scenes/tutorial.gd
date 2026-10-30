extends Control

const TUTORIAL_BRANCHES = {
	"start":[
		{"pointer":"money"},
		{"text":"Hello, and welcome! Have you played this game before?"},
		{"buttons":["Yep!","No!"],"branch":["end","tutorial"]},
		{"await":"buttons"},
		{"hide_pointer":"money"},
	],
	"tutorial":[
		{"text":"bla bla bla"},
		{"await":"next"},
		{"pointer":"income"},
		{"text":"how is life?????"},
		{"await":"next"},
		{"hide_pointer":"income"},
		{"text":"opinoin on pineapple on pizza?"},
		{"buttons":["Delicious!","Great!","I love it!"]},
		{"await":"buttons"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"text":"Thats what I thought."},
		{"await":"next"},
		{"text":"6767676767676776676776767676767676767676767767676767676767676767"},
		{"await":"next"},
		{"branch":"end"}
	],
	"end":[
		{"text":"Enjoy!"},
		{"await":"next"},
	]
}

#const TUTORIAL_DATA = [
	#{"pointer":0},
	#{"text":"Hello, and welcome! Have you played this game before?"},
	#{"buttons":["Yep!","No!"]},
	#{"await":"button"},
	#{"text":"Okay!"},
	#{"await":"next"},
#]

signal next_dialogue
signal button_pressed

var pointers = {}

var next_branch = "start"
var next_branch_options = []

func _ready() -> void:
	StartTutorial()

func StartTutorial():
	show()
	await EnterBranch("start")
	hide()

func EnterBranch(branch_name):
	var data = TUTORIAL_BRANCHES[branch_name]
	for n in data:
		await TutorialPart(n)
	if not branch_name == "end":
		await EnterBranch(next_branch)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("skip_dialogue"):
		done()

func done():
	next_dialogue.emit()

func TutorialPart(part:Dictionary) -> void:
	var v = part.values()[0]
	match part.keys()[0]:
		"pointer":
			print(pointers)
			pointers.get(v).active = true
		"hide_pointer":
			print("hiding ",pointers)
			pointers.get(v).active = false
		"text":
			$HBoxContainer/Jerry/Mayor/Sprite.play()
			await $HBoxContainer/Dialogue/Text.type_text(v,part.get("speed",0.05))
			$HBoxContainer/Jerry/Mayor/Sprite.pause()
		"buttons":
			var i = 0
			for b in $HBoxContainer/Dialogue/Buttons.get_children():
				b.hide()
			for b in v:
				$HBoxContainer/Dialogue/Buttons.get_child(i).show()
				$HBoxContainer/Dialogue/Buttons.get_child(i).text = b
				i += 1
			next_branch_options = part.get("branch",[])
		"await":
			match v:
				"next":
					$NextTexture.show()
					await next_dialogue
					$NextTexture.hide()
				"buttons":
					await button_pressed
					# Hide buttons after input is given
					for b in $HBoxContainer/Dialogue/Buttons.get_children():
						b.hide()
					
		"branch":
			next_branch = v
		
func option_button(idx:int):
	if len(next_branch_options) >= idx + 1:
		next_branch = next_branch_options.get(idx)
	button_pressed.emit()

func h(node):
	node.hide()

func register_pointer(nod:TextureRect,nam:String):
	pointers[nam] = nod
